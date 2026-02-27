package service;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

import dao.CustomerDAO;
import dao.CustomerMeasurementDAO;
import dao.CustomerQueryDAO;
import dao.CustomerSegmentDAO;
import dao.CustomerStyleDAO;
import dto.CustomerCreateDTO;
import dto.CustomerDetailDTO;
import dto.CustomerListDTO;
import exception.DuplicateEmailException;
import exception.DuplicatePhoneException;
import mapper.CustomerMapper;
import model.Customer;
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

                int newCustomerId = customerDAO.insertCustomer(CustomerMapper.toCustomer(dto, userId), conn);
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

    public List<CustomerListDTO> getCustomerList() throws SQLException {
        try (Connection conn = DBContext.getConnection()) {

            List<CustomerListDTO> customerList = customerQueryDAO.getCustomerList(conn);
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
            if (customer == null)
                return null;

            CustomerMeasurement latestMeasurement = customerMeasurementDAO.getLatestMeasurement(conn, customerId);

            List<StyleTag> styleTags = customerStyleDAO.getStyleTags(conn, customerId);

            // CustomerDetailDTO dto = CustomerMapper.toDTO(customer);
            customer.setLatestMeasurement(latestMeasurement);
            customer.setStyleTags(styleTags);

            return customer;
        }
    }

}
