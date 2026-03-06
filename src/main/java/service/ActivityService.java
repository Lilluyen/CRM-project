package service;

import dao.ActivityDAO;
import model.Activity;
import model.User;

import java.sql.Connection;
import java.util.Collections;
import java.util.List;

/**
 * ActivityService – orchestrates business rules between controller and ActivityDAO.
 *
 * Responsibilities:
 *   - Validate input data before delegating to DAO
 *   - Apply role-based visibility (optional extension point)
 *   - Coordinate notification when activities are created
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
    // READ – LIST (paged)
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
}
