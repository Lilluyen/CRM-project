package mapper;

import dto.CustomerCreateDTO;
import dto.CustomerDetailDTO;
import model.Customer;
import model.User;

import java.time.LocalDateTime;

public class CustomerMapper {

    public static Customer toCustomerForCreate(CustomerCreateDTO dto, int userId) {
        Customer customer = new Customer();
        customer.setName(dto.getName());
        customer.setPhone(dto.getPhone());
        customer.setBirthday(dto.getBirthday());
        customer.setEmail(dto.getEmail());
        customer.setGender(dto.getGender());
        customer.setAddress(dto.getAddress());
        customer.setSource(dto.getSource());

        User owner = new User();
        owner.setUserId(userId);
        customer.setOwner(owner);

        customer.setCreatedAt(LocalDateTime.now());
        return customer;
    }

    public static Customer toCustomerForUpdate(CustomerCreateDTO dto, int userId) {
        Customer customer = new Customer();
        customer.setCustomerId(dto.getCustomerId());
        customer.setName(dto.getName());
        customer.setPhone(dto.getPhone());
        customer.setBirthday(dto.getBirthday());
        customer.setEmail(dto.getEmail());
        customer.setGender(dto.getGender());
        customer.setAddress(dto.getAddress());
        customer.setSource(dto.getSource());

        User owner = new User();
        owner.setUserId(userId);
        customer.setOwner(owner);

        customer.setUpdatedAt(LocalDateTime.now());
        return customer;
    }

    public static CustomerDetailDTO toDTO(Customer c) {

        CustomerDetailDTO dto = new CustomerDetailDTO();

        dto.setCustomerId(c.getCustomerId());
        dto.setName(c.getName());
        dto.setPhone(c.getPhone());
        dto.setEmail(c.getEmail());
        dto.setBirthday(c.getBirthday());
        dto.setGender(c.getGender());
        dto.setAddress(c.getAddress());
        dto.setSource(c.getSource());
        dto.setStatus(c.getStatus());
        dto.setLoyaltyTier(c.getLoyaltyTier());
        dto.setTotalSpent(c.getTotalSpent());
        dto.setLastPurchase(c.getLastPurchase());

        if (c.getOwner() != null) {
            dto.setOwnerName(c.getOwner().getFullName());
        }

        return dto;
    }

}
