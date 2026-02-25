package dao;

import model.Activity;
import model.User;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import dao.UserDAO;

public class ActivityDAO {

    private Connection connection;

    public ActivityDAO(Connection connection) {
        this.connection = connection;
    }

    // =============================
    // 1. Create Activity
    // =============================
    public boolean createActivity(Activity activity) {
        String sql = "INSERT INTO Activities (related_type, related_id, activity_type, subject, description, created_by, activity_date) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setString(1, activity.getRelatedType());
            ps.setInt(2, activity.getRelatedId());
            ps.setString(3, activity.getActivityType());
            ps.setString(4, activity.getSubject());
            ps.setString(5, activity.getDescription());
            // createdBy is a User object; store its id
            if (activity.getCreatedBy() != null) {
                ps.setInt(6, activity.getCreatedBy().getUserId());
            } else {
                ps.setNull(6, java.sql.Types.INTEGER);
            }
            ps.setTimestamp(7, Timestamp.valueOf(activity.getActivityDate()));

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // =============================
    // 2. Update Activity
    // =============================
    public boolean updateActivity(Activity activity) {
        String sql = "UPDATE Activities SET related_type=?, related_id=?, activity_type=?, subject=?, description=?, activity_date=? "
                   + "WHERE activity_id=?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setString(1, activity.getRelatedType());
            ps.setInt(2, activity.getRelatedId());
            ps.setString(3, activity.getActivityType());
            ps.setString(4, activity.getSubject());
            ps.setString(5, activity.getDescription());
            ps.setTimestamp(6, Timestamp.valueOf(activity.getActivityDate()));
            ps.setInt(7, activity.getActivityId());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // =============================
    // 3. View Activities (List)
    // =============================
    public List<Activity> getAllActivities() {
        List<Activity> list = new ArrayList<>();
        String sql = "SELECT * FROM Activities";

        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapResultSet(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // =============================
    // 4. View Activity Details
    // =============================
    public Activity getActivityById(int id) {
        String sql = "SELECT * FROM Activities WHERE activity_id=?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return mapResultSet(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // =============================
    // Map ResultSet
    // =============================
    private Activity mapResultSet(ResultSet rs) throws SQLException {
        Activity activity = new Activity();

        activity.setActivityId(rs.getInt("activity_id"));
        activity.setRelatedType(rs.getString("related_type"));
        activity.setRelatedId(rs.getInt("related_id"));
        activity.setActivityType(rs.getString("activity_type"));
        activity.setSubject(rs.getString("subject"));
        activity.setDescription(rs.getString("description"));
        int createdById = rs.getInt("created_by");
        if (!rs.wasNull() && createdById > 0) {
            // fetch user details (may use separate connection internally)
            UserDAO userDAO = new UserDAO();
            User user = userDAO.getUserById(createdById);
            activity.setCreatedBy(user);
        } else {
            activity.setCreatedBy(null);
        }

        Timestamp activityDate = rs.getTimestamp("activity_date");
        if (activityDate != null) {
            activity.setActivityDate(activityDate.toLocalDateTime());
        }

        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            activity.setCreatedAt(createdAt.toLocalDateTime());
        }

        return activity;
    }
}