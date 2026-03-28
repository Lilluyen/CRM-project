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

    // ── With Connection (preferred – participates in same DB transaction) ─────

    public static void logDealCreated(Connection conn, int dealId, String dealName,
                                      Integer customerId, Integer leadId, User createdBy) {
        String description = "Created deal #" + dealId + " (" + safe(dealName) + ").";
        logDealActivity(conn, dealId, "CREATE", "Deal created", description, customerId, leadId, createdBy);
    }

    public static void logDealUpdated(Connection conn, int dealId, String dealName,
                                      Integer customerId, Integer leadId, User createdBy) {
        String description = "Updated deal #" + dealId + " (" + safe(dealName) + ").";
        logDealActivity(conn, dealId, "UPDATE", "Deal updated", description, customerId, leadId, createdBy);
    }

    public static void logDealStageUpdated(Connection conn, int dealId, String oldStage, String newStage,
                                           Integer customerId, Integer leadId, User createdBy) {
        String from = (oldStage == null || oldStage.isBlank()) ? "(none)" : oldStage;
        String to = (newStage == null || newStage.isBlank()) ? "(none)" : newStage;
        String description = "Updated deal #" + dealId + " stage: " + from + " -> " + to + ".";
        logDealActivity(conn, dealId, "UPDATE", "Deal Stage Updated", description, customerId, leadId, createdBy);
    }

    public static void logDealDeleted(Connection conn, int dealId, String dealName,
                                      Integer customerId, Integer leadId, User createdBy) {
        String description = "Deleted deal #" + dealId + " (" + safe(dealName) + ").";
        logDealActivity(conn, dealId, "DELETE", "Deal deleted", description, customerId, leadId, createdBy);
    }

    private static void logDealActivity(Connection conn, int dealId, String activityType,
                                        String subject, String description, Integer customerId, Integer leadId, User createdBy) {
        Activity activity = new Activity();
        if (customerId != null && customerId > 0) {
            activity.setRelatedType("CUSTOMER");
            activity.setRelatedId(customerId);
        } else if (leadId != null && leadId > 0) {
            activity.setRelatedType("LEAD");
            activity.setRelatedId(leadId);
        }
        activity.setActivityType(activityType);
        activity.setSubject(subject);
        activity.setDescription(description);
        activity.setCreatedBy(createdBy);
        activity.setPerformedBy(createdBy);
        activity.setActivityDate(LocalDateTime.now());
        applySource(activity, customerId, leadId);

        boolean ok = new ActivityService(conn).createActivity(activity);
        if (!ok) {
            throw new RuntimeException("[DealActivityUtil] Failed to log activity for deal " + dealId);
        }
    }

    // ── Legacy no-connection overloads (opens its own connection – not recommended) ──

    public static void logDealCreated(int dealId, String dealName, Integer customerId, Integer leadId, User createdBy) {
        String description = "Created deal #" + dealId + " (" + safe(dealName) + ").";
        try (Connection conn = DBContext.getConnection()) {
            logDealActivity(conn, dealId, "CREATE", "Deal created", description, customerId, leadId, createdBy);
        } catch (RuntimeException e) {
            throw e;
        } catch (Exception e) {
            throw new RuntimeException("[DealActivityUtil] Failed to log activity for deal " + dealId, e);
        }
    }

    public static void logDealUpdated(int dealId, String dealName, Integer customerId, Integer leadId, User createdBy) {
        String description = "Updated deal #" + dealId + " (" + safe(dealName) + ").";
        try (Connection conn = DBContext.getConnection()) {
            logDealActivity(conn, dealId, "UPDATE", "Deal updated", description, customerId, leadId, createdBy);
        } catch (RuntimeException e) {
            throw e;
        } catch (Exception e) {
            throw new RuntimeException("[DealActivityUtil] Failed to log activity for deal " + dealId, e);
        }
    }

    public static void logDealStageUpdated(int dealId, String oldStage, String newStage,
                                           Integer customerId, Integer leadId, User createdBy) {
        String from = (oldStage == null || oldStage.isBlank()) ? "(none)" : oldStage;
        String to = (newStage == null || newStage.isBlank()) ? "(none)" : newStage;
        String description = "Updated deal #" + dealId + " stage: " + from + " -> " + to + ".";
        try (Connection conn = DBContext.getConnection()) {
            logDealActivity(conn, dealId, "UPDATE", "Deal Stage Updated", description, customerId, leadId, createdBy);
        } catch (RuntimeException e) {
            throw e;
        } catch (Exception e) {
            throw new RuntimeException("[DealActivityUtil] Failed to log activity for deal " + dealId, e);
        }
    }

    public static void logDealDeleted(int dealId, String dealName, Integer customerId, Integer leadId, User createdBy) {
        String description = "Deleted deal #" + dealId + " (" + safe(dealName) + ").";
        try (Connection conn = DBContext.getConnection()) {
            logDealActivity(conn, dealId, "DELETE", "Deal deleted", description, customerId, leadId, createdBy);
        } catch (RuntimeException e) {
            throw e;
        } catch (Exception e) {
            throw new RuntimeException("[DealActivityUtil] Failed to log activity for deal " + dealId, e);
        }
    }

    private static void applySource(Activity activity, Integer customerId, Integer leadId) {
        if (customerId != null && customerId > 0) {
            activity.setSourceType("CUSTOMER");
            activity.setSourceId(customerId);
            return;
        }
        if (leadId != null && leadId > 0) {
            activity.setSourceType("LEAD");
            activity.setSourceId(leadId);
        }
    }

    private static String safe(String value) {
        return (value == null || value.isBlank()) ? "N/A" : value;
    }
}
