package dao;

import model.Activity;
import model.User;
import model.Role;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * ActivityDAO – CRUD + paging for the Activities table.
 *
 * Activities: activity_id, related_type, related_id, activity_type,
 *             subject, description, created_by (FK Users), activity_date, created_at
 */
public class ActivityDAO {

    private final Connection connection;

    public ActivityDAO(Connection connection) {
        this.connection = connection;
    }

    private static final String BASE_SELECT =
        "SELECT a.*, u.user_id AS u_id, u.full_name, u.email, u.username, "
      + "       r.role_id, r.role_name "
      + "FROM Activities a "
      + "LEFT JOIN Users u ON a.created_by = u.user_id "
      + "LEFT JOIN Roles r ON u.role_id = r.role_id ";

    // ─────────────────────────────────────────────────────────────────────────
    // 1. CREATE
    // ─────────────────────────────────────────────────────────────────────────
    public boolean createActivity(Activity activity) {
        String sql = "INSERT INTO Activities "
                   + "(related_type, related_id, activity_type, subject, description, created_by, activity_date) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, activity.getRelatedType());
            ps.setObject(2, activity.getRelatedId(), Types.INTEGER);
            ps.setString(3, activity.getActivityType());
            ps.setString(4, activity.getSubject());
            ps.setString(5, activity.getDescription());
            ps.setObject(6, activity.getCreatedBy() != null ? activity.getCreatedBy().getUserId() : null, Types.INTEGER);
            ps.setTimestamp(7, activity.getActivityDate() != null
                    ? Timestamp.valueOf(activity.getActivityDate()) : null);

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
        String sql = "UPDATE Activities SET related_type=?, related_id=?, activity_type=?, "
                   + "subject=?, description=?, activity_date=? WHERE activity_id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, activity.getRelatedType());
            ps.setObject(2, activity.getRelatedId(), Types.INTEGER);
            ps.setString(3, activity.getActivityType());
            ps.setString(4, activity.getSubject());
            ps.setString(5, activity.getDescription());
            ps.setTimestamp(6, activity.getActivityDate() != null
                    ? Timestamp.valueOf(activity.getActivityDate()) : null);
            ps.setInt(7, activity.getActivityId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 3. GET ALL
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
    // 4. PAGED + FILTERED
    // ─────────────────────────────────────────────────────────────────────────
    public List<Activity> getActivitiesPaged(String subject, String activityType,
                                              String relatedType,
                                              String sortField, String sortDir,
                                              int page, int pageSize) {
        List<Activity> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(BASE_SELECT + "WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (subject != null && !subject.isBlank()) {
            sql.append("AND a.subject LIKE ? "); params.add("%" + subject.trim() + "%");
        }
        if (activityType != null && !activityType.isBlank()) {
            sql.append("AND a.activity_type = ? "); params.add(activityType.trim());
        }
        if (relatedType != null && !relatedType.isBlank()) {
            sql.append("AND a.related_type = ? "); params.add(relatedType.trim());
        }

        String safe = "a.activity_date";
        if ("subject".equals(sortField)) safe = "a.subject";
        else if ("type".equals(sortField)) safe = "a.activity_type";
        else if ("createdAt".equals(sortField)) safe = "a.created_at";
        String dir = "ASC".equalsIgnoreCase(sortDir) ? "ASC" : "DESC";
        sql.append("ORDER BY ").append(safe).append(" ").append(dir).append(" ");
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
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM Activities WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        if (subject != null && !subject.isBlank()) {
            sql.append("AND subject LIKE ? "); params.add("%" + subject.trim() + "%");
        }
        if (activityType != null && !activityType.isBlank()) {
            sql.append("AND activity_type = ? "); params.add(activityType.trim());
        }
        if (relatedType != null && !relatedType.isBlank()) {
            sql.append("AND related_type = ? "); params.add(relatedType.trim());
        }
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
    // 5. GET BY ID
    // ─────────────────────────────────────────────────────────────────────────
    public Activity getActivityById(int id) {
        String sql = BASE_SELECT + "WHERE a.activity_id = ?";
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
    // 6. DELETE
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
    // PRIVATE HELPER
    // ─────────────────────────────────────────────────────────────────────────
    private Activity mapRow(ResultSet rs) throws SQLException {
        Activity a = new Activity();
        a.setActivityId(rs.getInt("activity_id"));
        a.setRelatedType(rs.getString("related_type"));
        a.setRelatedId(rs.getInt("related_id"));
        a.setActivityType(rs.getString("activity_type"));
        a.setSubject(rs.getString("subject"));
        a.setDescription(rs.getString("description"));

        Timestamp ad = rs.getTimestamp("activity_date");
        if (ad != null) a.setActivityDate(ad.toLocalDateTime());

        Timestamp cat = rs.getTimestamp("created_at");
        if (cat != null) a.setCreatedAt(cat.toLocalDateTime());

        // creator
        int uId = rs.getInt("u_id");
        if (!rs.wasNull() && uId > 0) {
            User u = new User();
            u.setUserId(uId);
            u.setFullName(rs.getString("full_name"));
            u.setEmail(rs.getString("email"));
            u.setUsername(rs.getString("username"));
            int roleId = rs.getInt("role_id");
            if (!rs.wasNull()) {
                Role r = new Role();
                r.setRoleId(roleId);
                r.setRoleName(rs.getString("role_name"));
                u.setRole(r);
            }
            a.setCreatedBy(u);
        }
        return a;
    }
}
