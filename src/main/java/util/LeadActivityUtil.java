package util;

import model.Activity;
import model.User;
import service.ActivityService;

import java.sql.Connection;
import java.time.LocalDateTime;

/**
 * Utility tạo Activity tự động khi có thao tác với Lead.
 * Mọi lỗi đều được nuốt — activity logging không ảnh hưởng main operation.
 */
public class LeadActivityUtil {

    public static void logLeadActivity(int leadId, String leadName,
                                       String subject, String description,
                                       User createdBy) {
        try (Connection conn = DBContext.getConnection()) {
            Activity activity = new Activity();
            activity.setRelatedType("Lead");
            activity.setRelatedId(leadId);
            activity.setActivityType("Note");
            activity.setSubject(subject);
            activity.setDescription(description);
            activity.setCreatedBy(createdBy);
            activity.setActivityDate(LocalDateTime.now());

            new ActivityService(conn).createActivity(activity);
        } catch (Exception e) {
            System.err.println("[LeadActivityUtil] Failed to log activity for lead "
                    + leadId + ": " + e.getMessage());
        }
    }
}
