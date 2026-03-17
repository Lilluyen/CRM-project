package mapper;

import java.time.LocalDateTime;

import dto.CustomerCreateDTO;
import dto.CustomerDetailDTO;
import model.Customer;
import model.CustomerMeasurement;
import model.User;

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
        customer.setCustomerId(dto.getCustomer_id());
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

    public static CustomerMeasurement toCustomerMeasurement(CustomerCreateDTO dto, int customerId) {
        CustomerMeasurement measurement = new CustomerMeasurement();
        measurement.setHeight(dto.getHeight());
        measurement.setWeight(dto.getWeight());
        measurement.setBust(dto.getBust());
        measurement.setWaist(dto.getWaist());
        measurement.setHips(dto.getHips());
        measurement.setMeasuredAt(LocalDateTime.now());
        measurement.setShoulder(dto.getShoulder());
        measurement.setPreferredSize(dto.getPreferredSize());
        measurement.setBodyShape(dto.getBodyShape());
        measurement.setCustomerId(customerId);
        return measurement;
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
        dto.setRfmScore(c.getRfmScore());
        dto.setReturnRate(c.getReturnRate());
        dto.setLastPurchase(c.getLastPurchase());

        if (c.getOwner() != null) {
            dto.setOwnerName(c.getOwner().getFullName());
        }

        return dto;
    }

}
