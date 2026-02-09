package service;

public class PhoneCheck {
    private static final String PHONE_REGEX = "^(\\+?[0-9]{9,15})$";

    public static boolean isValidPhone(String phone) {
        if (phone == null) {
            return false;
        }
        return phone.matches(PHONE_REGEX);
    }
}
