package service;

import dao.ActivityDAO;
import model.Activity;

import java.sql.Connection;
import java.util.Collections;
import java.util.List;

/**
 * ActivityService – orchestrates business rules between controller and ActivityDAO.
 *
 * Responsibilities:
 *   - Validate input data before delegating to DAO
 *   - Apply role-based visibility (optional extension point)
 *   - Expose task-specific timeline queries for TaskService
 *   - Expose dashboard "recent activities" query
 */
public class ActivityService {

    private final ActivityDAO activityDAO;

    public ActivityService(Connection connection) {
        this.activityDAO = new ActivityDAO(connection);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // CREATE
    // ─────────────────────────────────────────────────────────────────────────
    public boolean createActivity(Activity activity) {
        if (activity == null) return false;
        if (activity.getSubject() == null || activity.getSubject().isBlank()) return false;
        if (activity.getActivityType() == null || activity.getActivityType().isBlank()) return false;
        if (activity.getActivityDate() == null) return false;
        return activityDAO.createActivity(activity);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // UPDATE
    // ─────────────────────────────────────────────────────────────────────────
    public boolean updateActivity(Activity activity) {
        if (activity == null || activity.getActivityId() == null
                || activity.getActivityId() <= 0) return false;
        return activityDAO.updateActivity(activity);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // DELETE
    // ─────────────────────────────────────────────────────────────────────────
    public boolean deleteActivity(int id) {
        return activityDAO.deleteActivity(id);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // READ – LIST (paged + filtered)
    // ─────────────────────────────────────────────────────────────────────────
    public List<Activity> getActivitiesPaged(String subject, String activityType,
                                              String relatedType,
                                              String sortField, String sortDir,
                                              int page, int pageSize) {
        try {
            return activityDAO.getActivitiesPaged(
                    subject, activityType, relatedType, sortField, sortDir, page, pageSize);
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    public int countActivities(String subject, String activityType, String relatedType) {
        return activityDAO.countActivitiesFiltered(subject, activityType, relatedType);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // READ – DETAIL
    // ─────────────────────────────────────────────────────────────────────────
    public Activity getActivityById(int id) {
        return activityDAO.getActivityById(id);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // FULL LIST (for small result sets / dropdowns)
    // ─────────────────────────────────────────────────────────────────────────
    public List<Activity> getAllActivities() {
        try {
            return activityDAO.getAllActivities();
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // TASK TIMELINE – used by TaskService for the task detail page
    // ─────────────────────────────────────────────────────────────────────────
    /**
     * Returns paged activities where entity_type = 'task' AND entity_id = taskId.
     * Ordered newest-first.
     */
    public List<Activity> getActivitiesByTask(int taskId, int page, int pageSize) {
        try {
            return activityDAO.getActivitiesByTask(taskId, page, pageSize);
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    public int countActivitiesByTask(int taskId) {
        try {
            return activityDAO.countActivitiesByTask(taskId);
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // DASHBOARD – most recent N activities (Scenario 16)
    // ─────────────────────────────────────────────────────────────────────────
    public List<Activity> getRecentActivities(int limit) {
        try {
            return activityDAO.getRecentActivities(limit > 0 ? limit : 20);
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // CUSTOMER / LEAD JOURNEY
    // ─────────────────────────────────────────────────────────────────────────
    public List<Activity> getCustomerJourney(int customerId) {
        try {
            return activityDAO.getActivitiesForCustomerJourney(customerId);
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    public List<Activity> getLeadJourney(int leadId) {
        try {
            return activityDAO.getActivitiesForLeadJourney(leadId);
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }
}