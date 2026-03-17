package dao;

import model.Activity;
import model.Role;
import model.User;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * ActivityDAO – CRUD + paging for the Activities table.
 *
 * Full schema now reflected (columns previously missing from INSERT/SELECT):
 *   entity_type, entity_id   – which entity triggered the activity (e.g. task, deal)
 *   source_type, source_id   – original system source when auto-created
 *   performed_by             – FK to Users; the actor (may differ from created_by)
 *   metadata                 – arbitrary JSON payload for automation rules
 *   updated_at               – last modification timestamp
 *
 * New methods added to support task/activity scenarios:
 *   getActivitiesByTask()   – paged timeline for a specific task
 *   countActivitiesByTask() – pair for pagination
 *   getRecentActivities()   – dashboard "recent activities" panel (Scenario 16)
 */
public class ActivityDAO {

    private final Connection connection;

    public ActivityDAO(Connection connection) {
        this.connection = connection;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // BASE SELECT
    //   Two user aliases:
    //     cb / cb_role  = created_by  (who logged the activity)
    //     pb / pb_role  = performed_by (who actually performed the action)
    // ─────────────────────────────────────────────────────────────────────────
    private static final String BASE_SELECT =
        "SELECT a.activity_id, a.related_type, a.related_id, a.activity_type, "
      + "       a.subject, a.description, a.activity_date, a.created_at, a.updated_at, "
      + "       a.entity_type, a.entity_id, "
      + "       a.source_type, a.source_id, "
      + "       a.metadata, "
      + "       cb.user_id  AS cb_id,   cb.full_name AS cb_name, "
      + "       cb.email    AS cb_email, cb.username  AS cb_username, "
      + "       cbr.role_id AS cb_role_id, cbr.role_name AS cb_role_name, "
      + "       pb.user_id  AS pb_id,   pb.full_name AS pb_name, "
      + "       pb.email    AS pb_email, pb.username  AS pb_username, "
      + "       pbr.role_id AS pb_role_id, pbr.role_name AS pb_role_name "
      + "FROM Activities a "
      + "LEFT JOIN Users cb  ON a.created_by   = cb.user_id "
      + "LEFT JOIN Roles cbr ON cb.role_id      = cbr.role_id "
      + "LEFT JOIN Users pb  ON a.performed_by  = pb.user_id "
      + "LEFT JOIN Roles pbr ON pb.role_id      = pbr.role_id ";

    // ─────────────────────────────────────────────────────────────────────────
    // 1. CREATE
    // ─────────────────────────────────────────────────────────────────────────
    public boolean createActivity(Activity activity) {
        String sql =
            "INSERT INTO Activities "
          + "(related_type, related_id, activity_type, subject, description, "
          + " created_by, activity_date, entity_type, entity_id, "
          + " source_type, source_id, performed_by, metadata) "
          + "VALUES (?,?,?,?,?, ?,?,?,?, ?,?,?,?)";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, activity.getRelatedType());
            ps.setObject(2, activity.getRelatedId(), Types.INTEGER);
            ps.setString(3, activity.getActivityType());
            ps.setString(4, activity.getSubject());
            ps.setString(5, activity.getDescription());
            ps.setObject(6, activity.getCreatedBy()   != null ? activity.getCreatedBy().getUserId()   : null, Types.INTEGER);
            ps.setObject(7, activity.getActivityDate() != null ? Timestamp.valueOf(activity.getActivityDate()) : null, Types.TIMESTAMP);
            ps.setString(8, activity.getEntityType());
            ps.setObject(9, activity.getEntityId(), Types.INTEGER);
            ps.setString(10, activity.getSourceType());
            ps.setObject(11, activity.getSourceId(), Types.INTEGER);
            ps.setObject(12, activity.getPerformedBy() != null ? activity.getPerformedBy().getUserId() : null, Types.INTEGER);
            ps.setString(13, activity.getMetadata());

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) activity.setActivityId(keys.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 2. UPDATE
    // ─────────────────────────────────────────────────────────────────────────
    public boolean updateActivity(Activity activity) {
        String sql =
            "UPDATE Activities SET "
          + "related_type=?, related_id=?, activity_type=?, subject=?, description=?, "
          + "activity_date=?, entity_type=?, entity_id=?, "
          + "source_type=?, source_id=?, performed_by=?, metadata=?, updated_at=GETDATE() "
          + "WHERE activity_id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, activity.getRelatedType());
            ps.setObject(2, activity.getRelatedId(), Types.INTEGER);
            ps.setString(3, activity.getActivityType());
            ps.setString(4, activity.getSubject());
            ps.setString(5, activity.getDescription());
            ps.setObject(6, activity.getActivityDate() != null ? Timestamp.valueOf(activity.getActivityDate()) : null, Types.TIMESTAMP);
            ps.setString(7, activity.getEntityType());
            ps.setObject(8, activity.getEntityId(), Types.INTEGER);
            ps.setString(9, activity.getSourceType());
            ps.setObject(10, activity.getSourceId(), Types.INTEGER);
            ps.setObject(11, activity.getPerformedBy() != null ? activity.getPerformedBy().getUserId() : null, Types.INTEGER);
            ps.setString(12, activity.getMetadata());
            ps.setInt(13, activity.getActivityId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 3. DELETE
    // ─────────────────────────────────────────────────────────────────────────
    public boolean deleteActivity(int id) {
        String sql = "DELETE FROM Activities WHERE activity_id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 4. GET BY ID
    // ─────────────────────────────────────────────────────────────────────────
    public Activity getActivityById(int id) {
        String sql = BASE_SELECT + "WHERE a.activity_id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 5. GET ALL (for small sets / dropdowns)
    // ─────────────────────────────────────────────────────────────────────────
    public List<Activity> getAllActivities() {
        List<Activity> list = new ArrayList<>();
        String sql = BASE_SELECT + "ORDER BY a.activity_date DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 6. PAGED + FILTERED LIST
    // ─────────────────────────────────────────────────────────────────────────
    public List<Activity> getActivitiesPaged(String subject, String activityType,
                                              String relatedType,
                                              String sortField, String sortDir,
                                              int page, int pageSize) {
        List<Activity> list = new ArrayList<>();
        List<Object> params = new ArrayList<>();
        StringBuilder sql = new StringBuilder(BASE_SELECT + "WHERE 1=1 ");

        appendActivityFilters(sql, params, subject, activityType, relatedType);

        sql.append("ORDER BY ").append(resolveSortColumn(sortField))
           .append(" ").append("ASC".equalsIgnoreCase(sortDir) ? "ASC" : "DESC").append(" ");
        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add((page - 1) * pageSize);
        params.add(pageSize);

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countActivitiesFiltered(String subject, String activityType, String relatedType) {
        List<Object> params = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM Activities a WHERE 1=1 ");
        appendActivityFilters(sql, params, subject, activityType, relatedType);

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 7. TASK TIMELINE – activities linked to a specific task (entity_type='task')
    //    Used on the task detail page alongside Task_History.
    // ─────────────────────────────────────────────────────────────────────────
    public List<Activity> getActivitiesByTask(int taskId, int page, int pageSize) {
        List<Activity> list = new ArrayList<>();
        String sql =
            BASE_SELECT
          + "WHERE a.entity_type = 'task' AND a.entity_id = ? "
          + "ORDER BY a.activity_date DESC "
          + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, taskId);
            ps.setInt(2, (page - 1) * pageSize);
            ps.setInt(3, pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countActivitiesByTask(int taskId) {
        String sql =
            "SELECT COUNT(*) FROM Activities "
          + "WHERE entity_type = 'task' AND entity_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, taskId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 8. CUSTOMER / LEAD JOURNEY (full cross-entity timeline)
    // ─────────────────────────────────────────────────────────────────────────
    /**
     * Customer timeline: activities directly on Customer AND on Leads that
     * were converted into this Customer (Scenario 14).
     */
    public List<Activity> getActivitiesForCustomerJourney(int customerId) {
        List<Activity> list = new ArrayList<>();
        String sql =
            BASE_SELECT
          + "WHERE (a.related_type = 'Customer' AND a.related_id = ?) "
          + "   OR (a.related_type = 'Lead' AND a.related_id IN ("
          + "       SELECT lead_id FROM Leads WHERE converted_customer_id = ?)) "
          + "ORDER BY a.activity_date DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lead timeline: activities on Lead AND on its converted Customer (if any).
     */
    public List<Activity> getActivitiesForLeadJourney(int leadId) {
        List<Activity> list = new ArrayList<>();
        String sql =
            BASE_SELECT
          + "WHERE (a.related_type = 'Lead' AND a.related_id = ?) "
          + "   OR (a.related_type = 'Customer' AND a.related_id = ("
          + "       SELECT converted_customer_id FROM Leads WHERE lead_id = ?)) "
          + "ORDER BY a.activity_date ASC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, leadId);
            ps.setInt(2, leadId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 9. DASHBOARD – most recent N activities (Scenario 16)
    // ─────────────────────────────────────────────────────────────────────────
    public List<Activity> getRecentActivities(int limit) {
        List<Activity> list = new ArrayList<>();
        String sql =
            BASE_SELECT
          + "ORDER BY a.created_at DESC "
          + "OFFSET 0 ROWS FETCH NEXT ? ROWS ONLY";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // PRIVATE HELPERS
    // ─────────────────────────────────────────────────────────────────────────

    private void appendActivityFilters(StringBuilder sql, List<Object> params,
                                       String subject, String activityType, String relatedType) {
        if (subject != null && !subject.isBlank()) {
            sql.append("AND a.subject LIKE ? ");
            params.add("%" + subject.trim() + "%");
        }
        if (activityType != null && !activityType.isBlank()) {
            sql.append("AND a.activity_type = ? ");
            params.add(activityType.trim());
        }
        if (relatedType != null && !relatedType.isBlank()) {
            sql.append("AND a.related_type = ? ");
            params.add(relatedType.trim());
        }
    }

    private String resolveSortColumn(String sortField) {
        if (sortField == null) return "a.activity_date";
        return switch (sortField) {
            case "subject"   -> "a.subject";
            case "type"      -> "a.activity_type";
            case "createdAt" -> "a.created_at";
            default          -> "a.activity_date";
        };
    }

    private Activity mapRow(ResultSet rs) throws SQLException {
        Activity a = new Activity();
        a.setActivityId(rs.getInt("activity_id"));
        a.setRelatedType(rs.getString("related_type"));
        a.setRelatedId(rs.getInt("related_id"));
        a.setActivityType(rs.getString("activity_type"));
        a.setSubject(rs.getString("subject"));
        a.setDescription(rs.getString("description"));
        a.setEntityType(rs.getString("entity_type"));
        a.setEntityId(rs.getInt("entity_id"));
        a.setSourceType(rs.getString("source_type"));
        a.setSourceId(rs.getInt("source_id"));
        a.setMetadata(rs.getString("metadata"));

        Timestamp ad  = rs.getTimestamp("activity_date");
        Timestamp cat = rs.getTimestamp("created_at");
        Timestamp uat = rs.getTimestamp("updated_at");
        if (ad  != null) a.setActivityDate(ad.toLocalDateTime());
        if (cat != null) a.setCreatedAt(cat.toLocalDateTime());
        if (uat != null) a.setUpdatedAt(uat.toLocalDateTime());

        // created_by user
        int cbId = rs.getInt("cb_id");
        if (!rs.wasNull() && cbId > 0) {
            a.setCreatedBy(mapUser(rs, "cb_id", "cb_name", "cb_email", "cb_username",
                                       "cb_role_id", "cb_role_name"));
        }

        // performed_by user (optional, may be same as created_by for manual entries)
        int pbId = rs.getInt("pb_id");
        if (!rs.wasNull() && pbId > 0) {
            a.setPerformedBy(mapUser(rs, "pb_id", "pb_name", "pb_email", "pb_username",
                                         "pb_role_id", "pb_role_name"));
        }

        return a;
    }

    /** Reusable user + role mapper using aliased column names. */
    private User mapUser(ResultSet rs,
                         String idCol, String nameCol, String emailCol, String usernameCol,
                         String roleIdCol, String roleNameCol) throws SQLException {
        User u = new User();
        u.setUserId(rs.getInt(idCol));
        u.setFullName(rs.getString(nameCol));
        u.setEmail(rs.getString(emailCol));
        u.setUsername(rs.getString(usernameCol));
        int roleId = rs.getInt(roleIdCol);
        if (!rs.wasNull()) {
            Role r = new Role();
            r.setRoleId(roleId);
            r.setRoleName(rs.getString(roleNameCol));
            u.setRole(r);
        }
        return u;
    }
}