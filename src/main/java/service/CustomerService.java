package service;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

import dao.CustomerDAO;
import dao.CustomerMeasurementDAO;
import dao.CustomerQueryDAO;
import dao.CustomerStyleDAO;
import dto.CustomerCreateDTO;
import dto.CustomerListDTO;
import exception.DuplicateEmailException;
import exception.DuplicatePhoneException;
import mapper.CustomerMapper;
import model.StyleTag;
import util.DBContext;

public class CustomerService {

    public int createCustomer(CustomerCreateDTO dto, int userId) throws SQLException, Exception {
        try (Connection conn = DBContext.getConnection()) {
            try {
                conn.setAutoCommit(false);
                CustomerDAO customerDAO = new CustomerDAO();
                CustomerStyleDAO customerStyleDAO = new CustomerStyleDAO();
                CustomerMeasurementDAO customerMeasurementDAO = new CustomerMeasurementDAO();

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
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }

        }

    }

    public List<CustomerListDTO> getCustomerList() throws SQLException {
        try (Connection conn = DBContext.getConnection()) {

            CustomerQueryDAO customerQueryDAO = new CustomerQueryDAO();

            List<CustomerListDTO> customerList = customerQueryDAO.getCustomerList(conn);
            return customerList;

        }
    }

    public List<StyleTag> getListStyleTags() throws SQLException {
        try (Connection conn = DBContext.getConnection()) {

            CustomerStyleDAO customerStyleDAO = new CustomerStyleDAO();

            List<StyleTag> styleTagList = customerStyleDAO.getAllStyleTags(conn);
            return styleTagList;

        }
    }
}
