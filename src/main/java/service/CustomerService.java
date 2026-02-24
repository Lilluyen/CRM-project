package service;

import dao.CustomerDAO;
import dao.CustomerQueryDAO;
import dao.CustomerStyleDAO;
import java.util.List;

import dto.CustomerCreateDTO;
import dto.CustomerListDTO;
import java.sql.Connection;
import java.sql.SQLException;
import mapper.CustomerMapper;
import model.StyleTag;
import util.DBContext;

public class CustomerService {

    public int createCustomer(CustomerCreateDTO dto, int userId) throws SQLException {
        try (Connection conn = DBContext.getConnection()) {
            try {
                conn.setAutoCommit(false);
                CustomerDAO customerDAO = new CustomerDAO();
                if (customerDAO.existsByPhone(dto.getPhone(), conn)) {
                    throw new RuntimeException("Phone already exists");
                }

                customerDAO.insertCustomer(CustomerMapper.toCustomer(dto, userId), conn);

            } catch (Exception e) {
            }

        }

        return 0;
    }

    public List<CustomerListDTO> getCustomerList() throws SQLException {
        try (Connection conn = DBContext.getConnection()) {

            CustomerQueryDAO customerQueryDAO = new CustomerQueryDAO();

            List<CustomerListDTO> customerList = customerQueryDAO.getCustomerList(conn);
            return customerList;

        }
    }
    
    public List<StyleTag> getListStyleTags() throws SQLException{
        try (Connection conn = DBContext.getConnection()) {

            CustomerStyleDAO customerStyleDAO = new CustomerStyleDAO();

            List<StyleTag> styleTagList = customerStyleDAO.getAllStyleTags(conn);
            return styleTagList;

        }
    }
}
