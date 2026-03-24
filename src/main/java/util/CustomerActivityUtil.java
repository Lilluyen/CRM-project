package util;

import model.Activity;
import model.User;
import service.ActivityService;

import java.sql.Connection;
import java.time.LocalDateTime;

public class CustomerActivityUtil {
    public static void logCustomerActivity(int customerId,
            String activityType, String subject, String description,
            User createdBy) {
        try (Connection conn = DBContext.getConnection()) {
            Activity activity = new Activity();
            activity.setRelatedType("CUSTOMER");
            activity.setRelatedId(customerId);
            activity.setActivityType(activityType);
            activity.setSubject(subject);
            activity.setDescription(description);
            activity.setCreatedBy(createdBy);
            activity.setActivityDate(LocalDateTime.now());
            new ActivityService(conn).createActivity(activity);
        } catch (Exception e) {
            System.err.println(
                    "[CustomerActivityUtil] Failed to log activity for customer " + customerId + ": " + e.getMessage());
        }
    }
}