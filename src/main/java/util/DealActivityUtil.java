package util;

import model.Activity;
import model.User;
import service.ActivityService;

import java.sql.Connection;
import java.time.LocalDateTime;

/**
 * Utility tạo Activity tự động cho Deal CRUD.
 * Logging lỗi không làm ảnh hưởng main flow.
 */
public class DealActivityUtil {

    private DealActivityUtil() {
    }

    public static void logDealCreated(int dealId, String dealName, Integer customerId, Integer leadId, User createdBy) {
        String description = "Created deal #" + dealId + " (" + safe(dealName) + ").";
        logDealActivity(dealId, "CREATE", "Deal created", description, customerId, leadId, createdBy);
    }

    public static void logDealUpdated(int dealId, String dealName, Integer customerId, Integer leadId, User createdBy) {
        String description = "Updated deal #" + dealId + " (" + safe(dealName) + ").";
        logDealActivity(dealId, "UPDATE", "Deal updated", description, customerId, leadId, createdBy);
    }

    public static void logDealStageUpdated(int dealId, String oldStage, String newStage,
                                           Integer customerId, Integer leadId, User createdBy) {
        String from = (oldStage == null || oldStage.isBlank()) ? "(none)" : oldStage;
        String to = (newStage == null || newStage.isBlank()) ? "(none)" : newStage;
        String description = "Updated deal #" + dealId + " stage: " + from + " -> " + to + ".";
        logDealActivity(dealId, "UPDATE", "Deal stage updated", description, customerId, leadId, createdBy);
    }

    public static void logDealDeleted(int dealId, String dealName, Integer customerId, Integer leadId, User createdBy) {
        String description = "Deleted deal #" + dealId + " (" + safe(dealName) + ").";
        logDealActivity(dealId, "DELETE", "Deal deleted", description, customerId, leadId, createdBy);
    }

    private static void logDealActivity(int dealId, String activityType, String subject, String description,
                                        Integer customerId, Integer leadId, User createdBy) {
        try (Connection conn = DBContext.getConnection()) {
            Activity activity = new Activity();
            activity.setRelatedType("Deal");
            activity.setRelatedId(dealId);
            activity.setActivityType(activityType);
            activity.setSubject(subject);
            activity.setDescription(description);
            activity.setCreatedBy(createdBy);
            activity.setPerformedBy(createdBy);
            activity.setActivityDate(LocalDateTime.now());
            applySource(activity, customerId, leadId);

            new ActivityService(conn).createActivity(activity);
        } catch (Exception e) {
            System.err.println("[DealActivityUtil] Failed to log activity for deal "
                    + dealId + ": " + e.getMessage());
        }
    }

    private static void applySource(Activity activity, Integer customerId, Integer leadId) {
        if (customerId != null && customerId > 0) {
            activity.setSourceType("Customer");
            activity.setSourceId(customerId);
            return;
        }
        if (leadId != null && leadId > 0) {
            activity.setSourceType("Lead");
            activity.setSourceId(leadId);
        }
    }

    private static String safe(String value) {
        return (value == null || value.isBlank()) ? "N/A" : value;
    }
}
