package dto;

import java.time.LocalDate;
import java.util.List;

public class CustomerCreateDTO {

    private Integer customerId;
    private String name;
    private String phone;
    private String gender;
    private String email;
    private LocalDate birthday;
    private String source;
    private String address;


    private List<Integer> styleTags;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public Integer getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customer_id) {
        this.customerId = customer_id;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public LocalDate getBirthday() {
        return birthday;
    }

    public void setBirthday(LocalDate birthday) {
        this.birthday = birthday;
    }

    public String getSource() {
        return source;
    }

    public void setSource(String source) {
        this.source = source;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public List<Integer> getStyleTags() {
        return styleTags;
    }

    public void setStyleTags(List<Integer> styleTags) {
        this.styleTags = styleTags;
    }
}