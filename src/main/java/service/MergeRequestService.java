package service;

import com.fasterxml.jackson.databind.ObjectMapper;
import dao.*;
import dto.CustomerDetailDTO;
import model.Customer;
import model.CustomerContact;
import model.CustomerMergeRequest;
import model.CustomerNote;
import util.DBContext;

import java.sql.Connection;
import java.util.*;

public class MergeRequestService {

    private final MergeRequestDAO mergeRequestDAO;
    private final CustomerDAO customerDAO;
    private final CustomerStyleDAO customerStyleDAO;
    private final CustomerContactDAO contactDAO;
    private final CustomerNoteDAO noteDAO;
    private final CustomerQueryDAO customerQueryDAO;

    private static final ObjectMapper MAPPER = new ObjectMapper();

    public MergeRequestService(MergeRequestDAO mergeRequestDAO,
                               CustomerDAO customerDAO,
                               CustomerStyleDAO customerStyleDAO,
                               CustomerContactDAO contactDAO,
                               CustomerNoteDAO noteDAO,
                               CustomerQueryDAO customerQueryDAO) {
        this.mergeRequestDAO = mergeRequestDAO;
        this.customerDAO = customerDAO;
        this.customerStyleDAO = customerStyleDAO;
        this.contactDAO = contactDAO;
        this.noteDAO = noteDAO;
        this.customerQueryDAO = customerQueryDAO;
    }

    // ── Tạo merge request mới ─────────────────────────────────────────────
    public int createRequest(int sourceId, int targetId,
                             Map<String, String> fieldOverrides,
                             String reason, int createdBy) throws Exception {
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // Không cho tạo nếu đã có request PENDING giữa 2 customer này
                if (mergeRequestDAO.existsPending(conn, sourceId, targetId)) {
                    throw new IllegalStateException(
                            "A pending merge request already exists for these two customers.");
                }

                // Không cho merge customer với chính nó
                if (sourceId == targetId) {
                    throw new IllegalArgumentException(
                            "Cannot merge a customer with itself.");
                }

                String overridesJson = MAPPER.writeValueAsString(fieldOverrides);

                CustomerMergeRequest req = new CustomerMergeRequest(
                        sourceId, targetId, overridesJson, reason, createdBy);

                int newId = mergeRequestDAO.insert(conn, req);
                conn.commit();
                return newId;

            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        }
    }

    // ── Manager approve → thực hiện merge ngay ───────────────────────────
    public void approve(int requestId, int reviewerId) throws Exception {
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                CustomerMergeRequest req = mergeRequestDAO.findById(conn, requestId);

                if (req == null) {
                    throw new IllegalArgumentException("Merge request not found.");
                }
                if (!req.isPending()) {
                    throw new IllegalStateException(
                            "Only PENDING requests can be approved. Current status: " + req.getStatus());
                }

                // 1. Đánh dấu APPROVED
                mergeRequestDAO.approve(conn, requestId, reviewerId);

                // 2. Thực hiện merge theo fieldOverrides đã lưu
                executeMerge(conn, req, reviewerId);

                // 3. Đánh dấu MERGED
                mergeRequestDAO.markMerged(conn, requestId);

                conn.commit();

            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        }
    }

    // ── Manager reject ────────────────────────────────────────────────────
    public void reject(int requestId, int reviewerId, String rejectReason)
            throws Exception {
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                CustomerMergeRequest req = mergeRequestDAO.findById(conn, requestId);

                if (req == null) {
                    throw new IllegalArgumentException("Merge request not found.");
                }
                if (!req.isPending()) {
                    throw new IllegalStateException(
                            "Only PENDING requests can be rejected. Current status: " + req.getStatus());
                }

                mergeRequestDAO.reject(conn, requestId, reviewerId, rejectReason);
                conn.commit();

            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        }
    }

    // ── Lấy danh sách PENDING cho manager ─────────────────────────────────
    public List<CustomerMergeRequest> getPendingRequests() throws Exception {
        try (Connection conn = DBContext.getConnection()) {
            return mergeRequestDAO.findPending(conn);
        }
    }

    // ── Lấy request theo ID (để hiển thị detail) ──────────────────────────
    public CustomerMergeRequest getById(int requestId) throws Exception {
        try (Connection conn = DBContext.getConnection()) {
            return mergeRequestDAO.findById(conn, requestId);
        }
    }

    // ── Lấy requests của 1 customer ───────────────────────────────────────
    public List<CustomerMergeRequest> getByCustomerId(int customerId) throws Exception {
        try (Connection conn = DBContext.getConnection()) {
            return mergeRequestDAO.findByCustomerId(conn, customerId);
        }
    }

    // ── Kiểm tra đã có PENDING chưa ───────────────────────────────────────
    public boolean hasPendingRequest(int sourceId, int targetId) throws Exception {
        try (Connection conn = DBContext.getConnection()) {
            return mergeRequestDAO.existsPending(conn, sourceId, targetId);
        }
    }

    // ── Parse fieldOverrides JSON thành Map ───────────────────────────────
    @SuppressWarnings("unchecked")
    public Map<String, String> parseFieldOverrides(String json) throws Exception {
        if (json == null || json.isBlank()) return Collections.emptyMap();
        return MAPPER.readValue(json, Map.class);
    }

    // ── Thực hiện merge theo fieldOverrides ───────────────────────────────
    // fieldOverrides: key = tên field, value = "source" hoặc "target"
    // Ví dụ: {"name":"source","phone":"target","address":"source"}
    private void executeMerge(Connection conn, CustomerMergeRequest req,
                              int reviewerId) throws Exception {

        int sourceId = req.getSourceId();
        int targetId = req.getTargetId();

        CustomerDetailDTO source = customerDAO.getCustomerBase(conn, sourceId);
        CustomerDetailDTO target = customerDAO.getCustomerBase(conn, targetId);

        Map<String, String> overrides = parseFieldOverrides(req.getFieldOverrides());

        // 1. Build customer target sau merge theo fieldOverrides
        Customer merged = new Customer();
        merged.setCustomerId(targetId);

        // Với mỗi field: "source" → lấy từ source, "target" → lấy từ target
        // Default: target thắng nếu không có trong overrides
        merged.setName(pick(overrides, "name", source.getName(), target.getName()));
        merged.setGender(pick(overrides, "gender", source.getGender(), target.getGender()));
        merged.setBirthday(pickObj(overrides, "birthday", source.getBirthday(), target.getBirthday()));
        merged.setAddress(pick(overrides, "address", source.getAddress(), target.getAddress()));
        merged.setSource(pick(overrides, "source", source.getSource(), target.getSource()));

        // Phone và email: field nào được chọn từ "source" sẽ trở thành primary của target
        String mergedPhone = pick(overrides, "phone", source.getPhone(), target.getPhone());
        String mergedEmail = pick(overrides, "email", source.getEmail(), target.getEmail());
        merged.setPhone(mergedPhone);
        merged.setEmail(mergedEmail);

        customerDAO.updateBasicInfo(merged, conn);

        // 2. Chuyển contacts phụ từ source sang target (tránh trùng)
        List<CustomerContact> sourceContacts = contactDAO.getByCustomerId(conn, sourceId);
        for (CustomerContact sc : sourceContacts) {
            if (!sc.getPrimary() && !contactDAO.existsByValue(conn, targetId, sc.getValue())) {
                contactDAO.insertCustomerContact(conn,
                        new CustomerContact(targetId, false, sc.getType(), sc.getValue()));
            }
        }

        // Phone/email của source mà không được chọn làm primary → thêm vào contacts phụ của target
        if (!source.getPhone().equals(mergedPhone)
                && !contactDAO.existsByValue(conn, targetId, source.getPhone())) {
            contactDAO.insertCustomerContact(conn,
                    new CustomerContact(targetId, false, "PHONE", source.getPhone()));
        }
        if (source.getEmail() != null && !source.getEmail().equals(mergedEmail)
                && !contactDAO.existsByValue(conn, targetId, source.getEmail())) {
            contactDAO.insertCustomerContact(conn,
                    new CustomerContact(targetId, false, "EMAIL", source.getEmail()));
        }

        // 3. Union style tags
        List<Integer> sourceTags = customerStyleDAO.getTagIdsByCustomerId(conn, sourceId);
        List<Integer> targetTags = customerStyleDAO.getTagIdsByCustomerId(conn, targetId);
        Set<Integer> unionTags = new HashSet<>(targetTags);
        unionTags.addAll(sourceTags);
        // Thêm tag của source chưa có ở target
        for (Integer tagId : sourceTags) {
            if (!targetTags.contains(tagId)) {
                customerStyleDAO.insertCustomerStyle(conn, targetId, tagId);
            }
        }

        // 4. Ghi note vào target
        noteDAO.insertCustomerNote(conn, new CustomerNote(
                targetId,
                "Merged với customer #" + sourceId + " (" + source.getName() + ")"
                        + " — approved by user #" + reviewerId,
                reviewerId));

        // 5. Chuyển toàn bộ dữ liệu liên quan source -> target
        customerQueryDAO.reassignCustomerRelatedData(sourceId, targetId, conn);

        // 6. Re-calc các chỉ số tổng hợp của target
        customerDAO.updateTotalSpent(conn, targetId);
        customerDAO.updateLastPurchase(conn, targetId);
        customerDAO.updateLoyaltyTier(conn, targetId);
        TaskDAO taskDAO = new TaskDAO(conn);
        taskDAO.changeTargetTask(targetId, sourceId);

        // 7. Xóa source customer
        customerDAO.deleteCustomerById(sourceId, conn);
    }

    // ── Util: chọn giá trị String theo override ───────────────────────────
    private String pick(Map<String, String> overrides, String field,
                        String sourceVal, String targetVal) {
        String choice = overrides.getOrDefault(field, "target");
        return "source".equals(choice) ? sourceVal : targetVal;
    }

    // ── Util: chọn giá trị Object theo override ───────────────────────────
    private <T> T pickObj(Map<String, String> overrides, String field,
                          T sourceVal, T targetVal) {
        String choice = overrides.getOrDefault(field, "target");
        return "source".equals(choice) ? sourceVal : targetVal;
    }
}