package service;

import java.util.List;

import dto.CustomerCreateDTO;
import dto.CustomerListDTO;
import java.sql.Connection;
import java.sql.SQLException;
import util.DBContext;

public class CustomerService {

    public int createCustomer(CustomerCreateDTO dto, int userId) throws SQLException {
        try (DBContext db = new DBContext(); Connection conn = db.getConnection()) {
            conn.setAutoCommit(false);
            
        }
        
        return 0;
    }

    public List<CustomerListDTO> getCustomerList() throws SQLException {
        try (DBContext db = new DBContext(); Connection conn = db.getConnection()) {
            conn.setAutoCommit(false);
            
        }
        return null;
    }
}
