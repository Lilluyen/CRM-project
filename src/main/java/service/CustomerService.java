package service;

import dao.*;
import dto.*;
import mapper.CustomerMapper;
import model.*;
import util.DBContext;
import util.EmailCheck;
import util.PhoneCheck;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.*;

public class CustomerService {

    private final CustomerDAO customerDAO;
    private final CustomerStyleDAO customerStyleDAO;
    private final CustomerQueryDAO customerQueryDAO;
    private final CustomerSegmentDAO customerSegmentDAO;

    private final CustomerContactDAO contactDAO;
    private final CustomerNoteDAO noteDAO;

    public CustomerService(CustomerDAO customerDAO,
                           CustomerStyleDAO customerStyleDAO,
                           CustomerQueryDAO customerQueryDAO,
                           CustomerSegmentDAO customerSegmentDAO,
                           CustomerContactDAO contactDAO,
                           CustomerNoteDAO noteDAO) {
        this.customerDAO = customerDAO;
        this.customerStyleDAO = customerStyleDAO;
        this.customerQueryDAO = customerQueryDAO;
        this.customerSegmentDAO = customerSegmentDAO;
        this.contactDAO = contactDAO;
        this.noteDAO = noteDAO;
    }

    public ConflictResult checkDuplicate(CustomerCreateDTO dto) throws Exception {
        try (Connection conn = DBContext.getConnection()) {
            if (dto.getPhone() != null) {
                Customer existing = customerDAO.findByPhoneOrEmail(conn, dto.getPhone(), "");
                if (existing != null) {
                    CustomerDetailDTO detail = customerDAO.getCustomerBase(conn, existing.getCustomerId());
                    return new ConflictResult(detail, dto, "phone");
                }
            }

            if (dto.getEmail() != null) {
                Customer existing = customerDAO.findByPhoneOrEmail(conn, "", dto.getEmail());
                if (existing != null) {
                    CustomerDetailDTO detail = customerDAO.getCustomerBase(conn, existing.getCustomerId());
                    return new ConflictResult(detail, dto, "email");
                }
            }
        }
        return null;
    }

    public ConflictResult checkDuplicate(CustomerCreateDTO dto, int excludeCustomerId) throws Exception {
        try (Connection conn = DBContext.getConnection()) {
            if (dto.getPhone() != null) {
                Customer existing = customerDAO.findByPhoneOrEmail(conn, dto.getPhone(), "");
                if (existing != null && existing.getCustomerId() != excludeCustomerId) {
                    CustomerDetailDTO detail = customerDAO.getCustomerBase(conn, existing.getCustomerId());
                    return new ConflictResult(detail, dto, "phone");
                }
            }

            if (dto.getEmail() != null) {
                Customer existing = customerDAO.findByPhoneOrEmail(conn, "", dto.getEmail());
                if (existing != null && existing.getCustomerId() != excludeCustomerId) {
                    CustomerDetailDTO detail = customerDAO.getCustomerBase(conn, existing.getCustomerId());
                    return new ConflictResult(detail, dto, "email");
                }
            }
        }
        return null;
    }

    public void mergeCustomer(int existingId, CustomerCreateDTO incoming, int userId, String source)
            throws Exception {

        try (Connection conn = DBContext.getConnection()) {
            try {
                conn.setAutoCommit(false);

                CustomerDetailDTO existing = customerDAO.getCustomerBase(conn, existingId);

                // 1. Lưu email/phone của incoming vào customer_contact nếu khác existing
                if (incoming.getEmail() != null && !incoming.getEmail().isBlank()
                        && !incoming.getEmail().equalsIgnoreCase(existing.getEmail())) {
                    contactDAO.insertCustomerContact(conn, new CustomerContact(
                            existingId, false, "EMAIL", incoming.getEmail()));
                }
                if (incoming.getPhone() != null
                        && !incoming.getPhone().equals(existing.getPhone())) {
                    contactDAO.insertCustomerContact(conn, new CustomerContact(
                            existingId, false, "PHONE", incoming.getPhone()));
                }

                // 2. Merge profile — chỉ fill field nào existing đang null/blank
                Customer merged = buildMergedCustomer(existing, incoming);
                customerDAO.updateBasicInfo(merged, conn);

                // 3. Merge style tags (union 2 set)
                // Union tags: lấy tags hiện có của existing + tags của incoming
                List<Integer> existingTags = customerStyleDAO.getTagIdsByCustomerId(conn, existingId);
                Set<Integer> unionTags = new HashSet<>(existingTags);
                if (incoming.getStyleTags() != null)
                    unionTags.addAll(incoming.getStyleTags());
                updateCustomerStylesSmart(existingId, new ArrayList<>(unionTags), conn);

                // 4. Nếu là UPDATE → bản ghi incoming đã tồn tại trong DB → xóa đi
                if ("update".equals(source) && incoming.getCustomerId() != null) {
                    int incomingId = incoming.getCustomerId();

                    // Chuyển toàn bộ dữ liệu liên quan về existing trước khi xóa incoming
                    customerQueryDAO.reassignCustomerRelatedData(incomingId, existingId, conn);

                    // Xóa bản ghi customer
                    customerDAO.deleteCustomerById(incomingId, conn);
                }

                // 5. Re-calc các chỉ số tổng hợp sau merge
                customerDAO.updateTotalSpent(conn, existingId);
                customerDAO.updateLastPurchase(conn, existingId);
                customerDAO.updateLoyaltyTier(conn, existingId);
                // 6. Ghi note lịch sử merge
                noteDAO.insertCustomerNote(conn, new CustomerNote(
                        existingId,
                        "Merged"
                                + ("update".equals(source)
                                ? " và xóa customer #" + incoming.getName()
                                : " data từ bản ghi mới")
                                + " — phone=" + incoming.getPhone()
                                + ", email=" + incoming.getEmail(),
                        userId));

                conn.commit();

            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        }
    }

    private Customer buildMergedCustomer(CustomerDetailDTO existing, CustomerCreateDTO incoming) {
        Customer c = new Customer();
        c.setCustomerId(existing.getCustomerId());
        c.setName(existing.getName()); // tên existing luôn được giữ

        // Chỉ lấy field của incoming khi existing đang trống
        c.setAddress(existing.getAddress() != null ? existing.getAddress() : incoming.getAddress());
        c.setBirthday(existing.getBirthday() != null ? existing.getBirthday() : incoming.getBirthday());
        c.setGender(existing.getGender() != null ? existing.getGender() : incoming.getGender());
        c.setSource(existing.getSource() != null ? existing.getSource() : incoming.getSource());

        // Phone và email của existing luôn là primary — không thay đổi
        c.setPhone(existing.getPhone());
        c.setEmail(existing.getEmail());
        return c;
    }

    public int ignoreAndCreate(CustomerCreateDTO dto, int userId, int duplicateOfId, String reason)
            throws Exception {

        try (Connection conn = DBContext.getConnection()) {
            try {
                conn.setAutoCommit(false);

                // 1. Tạo customer mới bình thường
                int newId = customerDAO.insertCustomer(
                        CustomerMapper.toCustomerForCreate(dto, userId), conn);

                if (dto.getStyleTags() != null && !dto.getStyleTags().isEmpty()) {
                    customerStyleDAO.insertCustomerStyles(conn, newId, dto.getStyleTags());
                }

                // 2. Ghi note giải thích tại sao không merge
                String noteText = "Bỏ qua merge với customer #" + duplicateOfId
                        + ". Lý do: " + (reason != null ? reason : "không cung cấp");
                noteDAO.insertCustomerNote(conn, new CustomerNote(newId, noteText, userId));

                conn.commit();
                return newId;

            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        }
    }

    public void ignoreAndUpdate(CustomerCreateDTO dto, int customerId,
                                int conflictWithId, String reason, int userId)
            throws Exception {
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                customerDAO.updateBasicInfo(
                        CustomerMapper.toCustomerForUpdate(dto, customerId), conn);

                updateCustomerStylesSmart(customerId, dto.getStyleTags(), conn);

                String noteText = "Bỏ qua merge với customer #" + conflictWithId
                        + ". Lý do: " + (reason != null ? reason : "không cung cấp");
                noteDAO.insertCustomerNote(conn, new CustomerNote(customerId, noteText, userId));

                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        }
    }

    public int createCustomer(CustomerCreateDTO dto, int userId)
            throws SQLException {
        try (Connection conn = DBContext.getConnection()) {
            try {
                conn.setAutoCommit(false);
                int newCustomerId = customerDAO.insertCustomer(CustomerMapper.toCustomerForCreate(dto, userId), conn);
                if (dto.getStyleTags() != null && !dto.getStyleTags().isEmpty()) {
                    customerStyleDAO.insertCustomerStyles(
                            conn, newCustomerId, dto.getStyleTags());
                }
                if (dto.getPhone() != null && !dto.getPhone().isBlank()) {
                    contactDAO.insertCustomerContact(conn, new CustomerContact(newCustomerId,
                            true, "PHONE", dto.getPhone()));
                }

                if (dto.getEmail() != null && !dto.getEmail().isBlank()) {
                    contactDAO.insertCustomerContact(conn, new CustomerContact(newCustomerId,
                            true, "EMAIL", dto.getEmail()));
                }

                conn.commit();
                return newCustomerId;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } catch (Exception e) {
                conn.rollback();
                throw new SQLException("Error creating customer: " + e.getMessage(), e);
            }

        }

    }

    public int updateCustomer(CustomerCreateDTO dto, int customerId)
            throws Exception {

        try (Connection conn = DBContext.getConnection()) {
            try {
                conn.setAutoCommit(false);
                int row = customerDAO.updateBasicInfo(
                        CustomerMapper.toCustomerForUpdate(dto, customerId),
                        conn);
                updateCustomerStylesSmart(
                        customerId,
                        dto.getStyleTags(),
                        conn);

                if (dto.getPhone() != null && !dto.getPhone().isBlank()) {
                    contactDAO.clearPrimaryByType(conn, customerId, "PHONE");
                    CustomerContact existing = contactDAO.getByValue(conn, customerId, dto.getPhone());
                    if (existing != null) {
                        // Phone mới đã có trong customer_contact → set primary
                        contactDAO.setPrimary(conn, existing.getContactId(), customerId);
                    } else {
                        // Phone mới chưa có → insert mới với is_primary = true
                        contactDAO.insertCustomerContact(conn,
                                new CustomerContact(customerId, true, "PHONE", dto.getPhone()));
                    }
                }

                // Sync EMAIL primary
                if (dto.getEmail() != null && !dto.getEmail().isBlank()) {
                    contactDAO.clearPrimaryByType(conn, customerId, "EMAIL");
                    CustomerContact existing = contactDAO.getByValue(conn, customerId, dto.getEmail());
                    if (existing != null) {
                        contactDAO.setPrimary(conn, existing.getContactId(), customerId);
                    } else {
                        contactDAO.insertCustomerContact(conn,
                                new CustomerContact(customerId, true, "EMAIL", dto.getEmail())); // fix bug 3
                    }
                }
                conn.commit();

                return row;
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        }
    }

    public List<Customer> getCustomerList(int page, int size) throws SQLException {
        try (Connection conn = DBContext.getConnection()) {

            return customerQueryDAO.getCustomerList(conn, page, size);

        }
    }

    public int countTotalCustomer(String keyword, List<String> loyaltyTier, List<String> source, String gender,
                                  List<TimeCondition> timeConditions) throws SQLException {
        try (Connection conn = DBContext.getConnection()) {
            return customerQueryDAO.countTotalCustomers(conn, keyword, loyaltyTier, source, gender, timeConditions);
        }
    }

    public List<StyleTag> getListStyleTags() throws SQLException {
        try (Connection conn = DBContext.getConnection()) {

            return customerStyleDAO.getAllStyleTags(conn);

        }
    }

    public boolean removeCustomer(int customerId) throws SQLException, Exception {
        try (Connection conn = DBContext.getConnection()) {
            try {
                conn.setAutoCommit(false);

                // 1. Xóa tất cả dữ liệu liên quan (Style, Measurements, Wardrobe...)
                customerQueryDAO.deleteCustomerRelatedData(customerId, conn);

                // 2. Xóa customer chính
                boolean deleted = customerDAO.deleteCustomerById(customerId, conn);

                if (!deleted) {
                    throw new SQLException("Không thể xóa khách hàng. Khách hàng không tồn tại.");
                }

                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        }
    }

    public CustomerDetailDTO getCustomerDetail(int customerId) throws Exception {
        try (Connection conn = DBContext.getConnection()) {

            CustomerDetailDTO customer = customerDAO.getCustomerBase(conn, customerId);

            if (customer == null) {
                return null;
            }
            List<StyleTag> styleTags = customerStyleDAO.getStyleTags(conn, customerId);
            customer.setContacts(contactDAO.getByCustomerId(conn, customerId));
            customer.setStyleTags(styleTags);

            return customer;
        }
    }

    public void addStyleTagsToCustomer(int customerId, List<Integer> styleTagIds) throws SQLException {
        try (Connection conn = DBContext.getConnection()) {
            try {
                conn.setAutoCommit(false);

                // Thêm các tag mới
                if (styleTagIds != null && !styleTagIds.isEmpty()) {
                    customerStyleDAO.insertCustomerStyles(conn, customerId, styleTagIds);
                }

                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        }

    }

    private void updateCustomerStylesSmart(
            int customerId,
            List<Integer> newTagIds,
            Connection conn) throws SQLException {

        // Lấy tag hiện tại trong DB
        List<Integer> currentTagIds = customerStyleDAO.getTagIdsByCustomerId(conn, customerId);

        Set<Integer> currentSet = new HashSet<>(currentTagIds);
        Set<Integer> newSet = new HashSet<>(
                newTagIds == null ? Collections.emptyList() : newTagIds);

        // =====================
        // 1. XÓA những tag bị bỏ chọn
        // =====================
        for (Integer oldId : currentSet) {
            if (!newSet.contains(oldId)) {
                customerStyleDAO.deleteCustomerStyle(conn, customerId, oldId);
            }
        }

        // =====================
        // 2. THÊM tag mới
        // =====================
        for (Integer newId : newSet) {
            if (!currentSet.contains(newId)) {
                customerStyleDAO.insertCustomerStyle(conn, customerId, newId);
            }
        }
    }

    public List<Customer> filterAdvanced(String keyword, List<String> loyaltyTier,
                                         List<String> source, String gender, List<TimeCondition> timeConditions, int page, int size)
            throws SQLException {
        try (Connection conn = DBContext.getConnection()) {
            return customerQueryDAO.filterAdvanced(conn, keyword, loyaltyTier, source, gender, timeConditions, page,
                    size);
        }
    }

    public boolean upgradeToLoyaltyCustomer(int customerId) throws SQLException, Exception {
        try (Connection conn = DBContext.getConnection()) {
            try {
                conn.setAutoCommit(false);
                boolean isUpgrade = customerSegmentDAO.upgradeToLoyaltyCustomer(conn, customerId);
                conn.commit();
                return isUpgrade;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        }
    }

    public boolean downgradeToLoyaltyCustomer(int customerId) throws SQLException, Exception {
        try (Connection conn = DBContext.getConnection()) {
            try {
                conn.setAutoCommit(false);
                boolean isDowngrade = customerSegmentDAO.downgradeToLoyaltyCustomer(conn, customerId);
                conn.commit();
                return isDowngrade;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        }
    }

    public List<String> getSources() throws SQLException {
        try (Connection conn = DBContext.getConnection()) {
            return customerDAO.getSources(conn);
        }
    }

    public List<String> getRanks() throws SQLException {
        try (Connection conn = DBContext.getConnection()) {
            return customerDAO.getRanks(conn);
        }
    }

    public List<ContactValidationResult> saveExtraContacts(int customerId,
                                                           String[] types,
                                                           String[] values)
            throws Exception {
        if (types == null || values == null)
            return Collections.emptyList();

        List<ContactValidationResult> issues = new ArrayList<>();

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                CustomerDetailDTO customer = customerDAO.getCustomerBase(conn, customerId);

                // Tập hợp contact đã có của chính customer này
                List<CustomerContact> existingContacts = contactDAO.getByCustomerId(conn, customerId);
                Set<String> selfValues = new HashSet<>();
                existingContacts.forEach(c -> selfValues.add(c.getValue().toLowerCase()));
                // if (customer.getPhone() != null)
                // selfValues.add(customer.getPhone().toLowerCase());
                // if (customer.getEmail() != null)
                // selfValues.add(customer.getEmail().toLowerCase());

                int len = Math.min(types.length, values.length);
                for (int i = 0; i < len; i++) {
                    String type = types[i];
                    String value = values[i];

                    if (value == null || value.isBlank())
                        continue;
                    if (!"PHONE".equals(type) && !"EMAIL".equals(type))
                        continue;

                    String valueTrimmed = value.trim();
                    String valueLower = valueTrimmed.toLowerCase();

                    // Rule 1: Validate định dạng
                    if ("PHONE".equals(type) && !PhoneCheck.isValidPhone(valueTrimmed)) {
                        issues.add(new ContactValidationResult(
                                ContactValidationResult.Status.INVALID_FORMAT,
                                type, valueTrimmed, null));
                        continue;
                    }

                    if ("EMAIL".equals(type) && !EmailCheck.isValidEmail(valueTrimmed)) {
                        issues.add(new ContactValidationResult(
                                ContactValidationResult.Status.INVALID_FORMAT,
                                type, valueTrimmed, null));
                        continue;
                    }

                    // Rule 2: Trùng với contact đã có của chính customer này
                    if (selfValues.contains(valueLower)) {
                        issues.add(new ContactValidationResult(
                                ContactValidationResult.Status.DUPLICATE_SELF,
                                type, valueTrimmed, null));
                        continue;
                    }

                    // Rule 3: Trùng với phone/email chính của customer KHÁC
                    Customer other = customerDAO.findByPhoneOrEmail(conn,
                            "PHONE".equals(type) ? valueTrimmed : "",
                            "EMAIL".equals(type) ? valueTrimmed : "");
                    if (other != null && other.getCustomerId() != customerId) {
                        issues.add(new ContactValidationResult(
                                ContactValidationResult.Status.CONFLICT_OTHER,
                                type, valueTrimmed, other.getCustomerId()));
                        continue; // không insert, báo lên controller xử lý
                    }

                    // Tất cả rule pass → insert
                    contactDAO.insertCustomerContact(conn,
                            new CustomerContact(customerId, false, type, valueTrimmed));

                    // Cập nhật set để tránh trùng trong cùng batch
                    selfValues.add(valueLower);
                }

                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        }

        return issues; // empty = tất cả OK
    }

    public boolean deleteContact(int contactId, int customerId) throws Exception {
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                boolean deleted = contactDAO.deleteById(conn, contactId, customerId);
                conn.commit();
                return deleted;
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        }
    }

    public void setPrimaryContact(int contactId, int customerId) throws Exception {
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // 1. Lấy contact được chọn làm primary
                CustomerContact newPrimary = contactDAO.findById(conn, contactId, customerId);
                if (newPrimary == null)
                    throw new IllegalArgumentException("Contact not found");

                String type = newPrimary.getType(); // "PHONE" hoặc "EMAIL"

                // 2. Lấy giá trị primary hiện tại từ bảng customers
                CustomerDetailDTO current = customerDAO.getCustomerBase(conn, customerId);
                String oldPrimaryValue = "PHONE".equals(type)
                        ? current.getPhone()
                        : current.getEmail();

                // 3. Nếu old primary có giá trị → chuyển xuống customer_contact
                if (oldPrimaryValue != null && !oldPrimaryValue.isBlank()) {
                    // Bỏ is_primary của tất cả contact cùng type trước
                    contactDAO.clearPrimaryByType(conn, customerId, type);

                    // Insert old primary xuống customer_contact (is_primary = false)
                    if (!contactDAO.existsByValue(conn, customerId, oldPrimaryValue)) {
                        contactDAO.insertCustomerContact(conn,
                                new CustomerContact(customerId, false, type, oldPrimaryValue));
                    }
                } else {
                    contactDAO.clearPrimaryByType(conn, customerId, type);
                }

                // 4. Cập nhật bảng customers với giá trị mới
                if ("PHONE".equals(type)) {
                    customerDAO.updatePrimaryPhone(conn, customerId, newPrimary.getValue());
                } else {
                    customerDAO.updatePrimaryEmail(conn, customerId, newPrimary.getValue());
                }

                // 5. Đánh dấu contact vừa chọn là primary
                contactDAO.setPrimary(conn, contactId, customerId);

                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        }
    }

    public List<CustomerSearchResultDTO> searchForMerge(String keyword,
                                                        int excludeId,
                                                        int limit) throws Exception {
        try (Connection conn = DBContext.getConnection()) {
            return customerQueryDAO.searchForMerge(conn, keyword, excludeId, limit);
        }
    }

    public int countDealByCusId(int id) throws SQLException {
        try (Connection conn = DBContext.getConnection()) {
            DealDAO dealDAO = new DealDAO(conn);
            int count = dealDAO.countDealByCusId(id);
            return count;
        }
    }

    public List<Deal> getListDealsByCusId(int id) throws SQLException {
        try (Connection conn = DBContext.getConnection()) {
            DealDAO dealDAO = new DealDAO(conn);
            return dealDAO.getListDealsByCusId(id);

        }
    }
}
