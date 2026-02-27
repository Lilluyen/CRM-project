package mapper;

import java.time.LocalDateTime;

import dto.CustomerCreateDTO;
import model.Customer;
import model.CustomerMeasurement;
import model.User;

public class CustomerMapper {

    public static Customer toCustomer(CustomerCreateDTO dto, int userId) {
        Customer customer = new Customer();
        customer.setName(dto.getName());
        customer.setPhone(dto.getPhone());
        customer.setBirthday(dto.getBirthday());
        customer.setEmail(dto.getEmail());
        customer.setGender(dto.getGender());
        customer.setAddress(dto.getAddress());
        customer.setSocialLink(dto.getSocialLink());

        User owner = new User();
        owner.setUserId(userId);
        customer.setOwner(owner);

        customer.setCreatedAt(LocalDateTime.now());
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

}
