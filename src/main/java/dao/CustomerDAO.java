package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;

import model.Customer;
import model.User;
import service.PhoneCheck;
import ultil.DBContext;

public class CustomerDAO extends DBContext {

    private final String BASE_CUSTOMER_QUERY = "SELECT [customer_id], [name], [address], [industry], [company_size], [phone], [email], [status], [owner_id], [created_at], [updated_at] FROM [Customers] ";

    public ArrayList<Customer> getAllCustomers() {
        ArrayList<Customer> customers = new ArrayList<>();

        String sql = BASE_CUSTOMER_QUERY + "ORDER BY created_at DESC";

        try (
                PreparedStatement stm = connection.prepareStatement(sql);
                ResultSet rs = stm.executeQuery();) {
            while (rs.next()) {
                Customer customer = new Customer();
                customer.setCustomerId(rs.getInt("customer_id"));
                customer.setName(rs.getString("name"));
                customer.setAddress(rs.getString("address"));
                customer.setIndustry(rs.getString("industry"));
                customer.setCompanySize(rs.getString("company_size"));

                // Email and Phone validation
                if (PhoneCheck.isValidPhone(rs.getString("phone"))) {
                    customer.setPhone(rs.getString("phone"));

                } else {
                    customer.setPhone(null);
                }

                if (service.EmailCheck.isValidEmail(rs.getString("email"))) {
                    customer.setEmail(rs.getString("email"));
                } else {
                    customer.setEmail(null);
                }

                customer.setStatus(rs.getString("status"));
                User owner = new User();
                owner.setUserId(rs.getInt("owner_id"));
                customer.setOwner(owner);

                Timestamp createdAtTs = rs.getTimestamp("created_at");
                if (createdAtTs != null) {
                    customer.setCreatedAt(createdAtTs.toLocalDateTime());
                }

                Timestamp updatedTs = rs.getTimestamp("updated_at");
                if (updatedTs != null) {
                    customer.setUpdatedAt(updatedTs.toLocalDateTime());
                }

                customers.add(customer);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return customers;
    }

    public Customer getCustomerById(int customerId) {
        String sql = BASE_CUSTOMER_QUERY + "WHERE customer_id = ?";

        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setInt(1, customerId);
            ResultSet rs = stm.executeQuery();
            if (rs.next()) {
                Customer customer = new Customer();
                customer.setCustomerId(rs.getInt("customer_id"));
                customer.setName(rs.getString("name"));
                customer.setAddress(rs.getString("address"));
                customer.setIndustry(rs.getString("industry"));
                customer.setCompanySize(rs.getString("company_size"));

                // Email and Phone validation
                if (PhoneCheck.isValidPhone(rs.getString("phone"))) {
                    customer.setPhone(rs.getString("phone"));

                } else {
                    customer.setPhone(null);
                }

                if (service.EmailCheck.isValidEmail(rs.getString("email"))) {
                    customer.setEmail(rs.getString("email"));
                } else {
                    customer.setEmail(null);
                }

                customer.setStatus(rs.getString("status"));
                User owner = new User();
                owner.setUserId(rs.getInt("owner_id"));
                customer.setOwner(owner);

                Timestamp createdAtTs = rs.getTimestamp("created_at");
                if (createdAtTs != null) {
                    customer.setCreatedAt(createdAtTs.toLocalDateTime());
                }

                Timestamp updatedTs = rs.getTimestamp("updated_at");
                if (updatedTs != null) {
                    customer.setUpdatedAt(updatedTs.toLocalDateTime());
                }

                return customer;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public void addCustomer(Customer customer) {
        String sql = "INSERT INTO [Customers] ([name], [address], [industry], [company_size], [phone], [email], [status], [owner_id], [created_at], [updated_at]) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setString(1, customer.getName());
            stm.setString(2, customer.getAddress());
            stm.setString(3, customer.getIndustry());
            stm.setString(4, customer.getCompanySize());
            stm.setString(5, customer.getPhone());
            stm.setString(6, customer.getEmail());
            stm.setString(7, customer.getStatus());
            stm.setInt(8, customer.getOwner().getUserId());
            stm.setTimestamp(9, Timestamp.valueOf(customer.getCreatedAt()));
            stm.setTimestamp(10, Timestamp.valueOf(customer.getUpdatedAt()));

            stm.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

}
