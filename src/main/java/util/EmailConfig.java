package util;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/**
 * Email configuration loader from properties file
 * @author Pham Minh Quan
 */
public class EmailConfig {
    private static Properties properties;

    static {
        loadProperties();
    }

    private static void loadProperties() {
        properties = new Properties();
        try (InputStream input = EmailConfig.class.getClassLoader().getResourceAsStream("email.properties")) {
            if (input == null) {
                throw new RuntimeException("email.properties file not found in classpath");
            }
            properties.load(input);
        } catch (IOException e) {
            throw new RuntimeException("Failed to load email configuration", e);
        }
    }

    public static String getSmtpHost() {
        return properties.getProperty("email.smtp.host");
    }

    public static int getSmtpPort() {
        return Integer.parseInt(properties.getProperty("email.smtp.port", "587"));
    }

    public static boolean isSmtpAuthEnabled() {
        return Boolean.parseBoolean(properties.getProperty("email.smtp.auth", "true"));
    }

    public static boolean isStartTlsEnabled() {
        return Boolean.parseBoolean(properties.getProperty("email.smtp.starttls.enable", "true"));
    }

    public static boolean isStartTlsRequired() {
        return Boolean.parseBoolean(properties.getProperty("email.smtp.starttls.required", "true"));
    }

    public static String getSmtpUser() {
        return properties.getProperty("email.smtp.user");
    }

    public static String getSmtpPassword() {
        return properties.getProperty("email.smtp.password");
    }

    public static String getFromAddress() {
        return properties.getProperty("email.from.address");
    }

    public static String getFromName() {
        return properties.getProperty("email.from.name", "CRM System");
    }
}
