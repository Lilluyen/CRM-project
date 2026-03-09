package service;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import dao.CustomerDAO;
import dao.CustomerMeasurementDAO;
import dao.CustomerQueryDAO;
import dao.CustomerSegmentDAO;
import dao.CustomerStyleDAO;
import dto.CustomerCreateDTO;
import dto.CustomerDetailDTO;
import dto.CustomerFilterRequest;
import dto.CustomerPageResult;
import dto.KpiSummaryDTO;
import exception.DuplicateEmailException;
import exception.DuplicatePhoneException;
import mapper.CustomerMapper;
import model.CustomerMeasurement;
import model.StyleTag;
import util.DBContext;

public class CustomerService {

    private final CustomerDAO customerDAO = new CustomerDAO();
    private final CustomerMeasurementDAO customerMeasurementDAO = new CustomerMeasurementDAO();
    private final CustomerStyleDAO customerStyleDAO = new CustomerStyleDAO();
    private final CustomerQueryDAO customerQueryDAO = new CustomerQueryDAO();
    private final CustomerSegmentDAO customerSegmentDAO = new CustomerSegmentDAO();

    public int createCustomer(CustomerCreateDTO dto, int userId)
            throws SQLException, DuplicateEmailException, DuplicatePhoneException {
        try (Connection conn = DBContext.getConnection()) {
            try {
                conn.setAutoCommit(false);

                if (customerDAO.existsByPhone(dto.getPhone(), conn)) {
                    throw new DuplicatePhoneException("Phone already exists");
                }

                if (customerDAO.existsByEmail(dto.getEmail(), conn)) {
                    throw new DuplicateEmailException("Email already exists");
                }

                int newCustomerId = customerDAO.insertCustomer(CustomerMapper.toCustomerForCreate(dto, userId), conn);
                if (dto.getStyleTags() != null && !dto.getStyleTags().isEmpty()) {
                    customerStyleDAO.insertCustomerStyles(
                            conn, newCustomerId, dto.getStyleTags());
                }
                customerMeasurementDAO
                        .insertCustomerMeasurement(CustomerMapper.toCustomerMeasurement(dto, newCustomerId), conn);

                conn.commit();
                return newCustomerId;
            } catch (SQLException | DuplicateEmailException | DuplicatePhoneException e) {
                conn.rollback();
                throw e;
            } catch (Exception e) {
                conn.rollback();
                throw new SQLException("Error creating customer: " + e.getMessage(), e);
            }

        }

    }

    public void updateCustomer(CustomerCreateDTO dto, int customerId)
            throws Exception {

        try (Connection conn = DBContext.getConnection()) {
            try {
                conn.setAutoCommit(false);

                // ============================
                // 1. CHECK DUPLICATE (exclude chính nó)
                // ============================
                if (customerDAO.existsByPhoneExcludeId(
                        dto.getPhone(), customerId, conn)) {
                    throw new DuplicatePhoneException("Phone already exists");
                }

                if (customerDAO.existsByEmailExcludeId(
                        dto.getEmail(), customerId, conn)) {
                    throw new DuplicateEmailException("Email already exists");
                }

                // ============================
                // 2. UPDATE CUSTOMER INFO
                // ============================
                customerDAO.updateBasicInfo(
                        CustomerMapper.toCustomerForUpdate(dto, customerId),
                        conn);

                // ============================
                // 3. UPDATE STYLE SMART (KHÔNG XÓA HẾT)
                // ============================
                updateCustomerStylesSmart(
                        customerId,
                        dto.getStyleTags(),
                        conn);

                // ============================
                // 4. INSERT NEW MEASUREMENT VERSION
                // ============================
                customerMeasurementDAO.insertCustomerMeasurement(
                        CustomerMapper.toCustomerMeasurement(dto, customerId),
                        conn);

                conn.commit();

            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        }
    }

    public CustomerPageResult getCustomerList(int page, int size, String sessionId) throws SQLException {
        try (Connection conn = DBContext.getConnection()) {

            CustomerPageResult customerList = customerQueryDAO.getCustomerList(conn, page, size, sessionId);
            return customerList;

        }
    }

    public List<StyleTag> getListStyleTags() throws SQLException {
        try (Connection conn = DBContext.getConnection()) {

            List<StyleTag> styleTagList = customerStyleDAO.getAllStyleTags(conn);
            return styleTagList;

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

            CustomerMeasurement latestMeasurement = customerMeasurementDAO.getLatestMeasurement(conn, customerId);

            List<StyleTag> styleTags = customerStyleDAO.getStyleTags(conn, customerId);

            // CustomerDetailDTO dto = CustomerMapper.toDTO(customer);
            customer.setLatestMeasurement(latestMeasurement);
            customer.setStyleTags(styleTags);

            return customer;
        }
    }

    public List<StyleTag> getListStyleTagsByCustomerId(int customerId) throws SQLException {
        try (Connection conn = DBContext.getConnection()) {

            List<StyleTag> styleTagList = customerStyleDAO.getAllStyleTags(conn);

            return styleTagList;

        } catch (Exception ex) {
            throw new SQLException("Error fetching style tags for customer: " + ex.getMessage(), ex);
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

    public CustomerPageResult filterAdvanced(CustomerFilterRequest filterRequest,
            String sessionId) throws SQLException {
        try (Connection conn = DBContext.getConnection()) {
            return customerQueryDAO.filterAdvanced(conn, filterRequest, sessionId);
        }
    }

    public boolean upgradeToLoyaltyCustomer(int customerId) throws SQLException, Exception {
        try (Connection conn = DBContext.getConnection()) {
            try {
                conn.setAutoCommit(false);
                boolean isUpggrade = customerSegmentDAO.upgradeToLoyaltyCustomer(conn, customerId);
                conn.commit();
                return isUpggrade;
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

    public KpiSummaryDTO kpiSummarySegment() throws SQLException, Exception {
        try (Connection conn = DBContext.getConnection()) {
            try {
                return customerSegmentDAO.kpiSummarySegment(conn);
            } catch (SQLException e) {
                throw e;
            }
        }
    }

}
