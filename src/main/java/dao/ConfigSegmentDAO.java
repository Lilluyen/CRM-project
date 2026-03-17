package dao;

import model.SegmentConfig;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ConfigSegmentDAO {
    //2
    public void configSegment(Connection conn, int id, List<SegmentConfig> configs) throws SQLException {
        String sql = """
                    INSERT INTO Segment_Filters
                    (segment_id, field_name, operator, value, logic_operator)
                    VALUES (?, ?, ?, ?, ?)
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            for (SegmentConfig f : configs) {

                ps.setInt(1, id);
                ps.setString(2, f.getField());
                ps.setString(3, f.getOperator());
                ps.setString(4, f.getValue());
                ps.setString(5, f.getLogic());

                ps.addBatch();
            }

            ps.executeBatch();
        }
    }

    // 1
    public void deleteOldConfigs(Connection conn, int id) throws SQLException {
        String sql = """
                DELETE FROM Segment_Filters
                WHERE segment_id = ?
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();

        }
    }

    //3
    public void updateTypeAssigment(Connection conn, int id, String method) throws SQLException {
        String sql = """
                UPDATE Customer_Segments
                SET assignment_type = ?
                WHERE segment_id = ?
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, method);
            ps.setInt(2, id);

            ps.executeUpdate();
        }
    }

    //4
    public void deleteOldSegmentMap(Connection conn, int id) throws SQLException {
        String sql = """
                    DELETE FROM Customer_Segment_Map
                    WHERE segment_id = ?
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);

            ps.executeUpdate();
        }
    }

    //5
    public List<SegmentConfig> getFilters(Connection conn, int segmentId) throws SQLException {

        String sql = """
                    SELECT field_name, operator, value, logic_operator
                    FROM Segment_Filters
                    WHERE segment_id = ?
                    ORDER BY filter_id
                """;

        List<SegmentConfig> filters = new ArrayList<>();

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, segmentId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                SegmentConfig f = new SegmentConfig();
                f.setField(rs.getString("field_name"));
                f.setOperator(rs.getString("operator"));
                f.setValue(rs.getString("value"));
                f.setLogic(rs.getString("logic_operator"));

                filters.add(f);
            }
        }

        return filters;
    }

    public boolean isCustomerInSegment(Connection conn, int segmentId, int customerId) throws SQLException {
        String sql = "SELECT 1 FROM Customer_Segment_Map WHERE segment_id = ? AND customer_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, segmentId);
            ps.setInt(2, customerId);

            ResultSet rs = ps.executeQuery();
            return rs.next();

        }
    }

    //6
    public String buildFilterSQL(List<SegmentConfig> filters) {

        StringBuilder where = new StringBuilder();

        for (int i = 0; i < filters.size(); i++) {

            SegmentConfig f = filters.get(i);

            where.append(f.getField())
                    .append(" ")
                    .append(f.getOperator())
                    .append(" ");

            if ("LIKE".equalsIgnoreCase(f.getOperator())) {
                where.append("'%").append(f.getValue()).append("%'");
            } else {
                where.append("'").append(f.getValue()).append("'");
            }

            if (i < filters.size() - 1) {
                where.append(" ").append(f.getLogic()).append(" ");
            }
        }

        return where.toString();
    }

    //7
    public void insertCustomersToSegment(Connection conn, int segmentId, String filterSQL) throws SQLException {

        String sql = """
                    INSERT INTO Customer_Segment_Map (customer_id, segment_id, assigned_at)
                    SELECT customer_id, ?, GETDATE()
                    FROM Customers
                    WHERE
                """ + filterSQL;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, segmentId);
            ps.executeUpdate();
        }
    }

    //8
    public String getAssignmentType(Connection conn, int segmentId) throws SQLException {

        String sql = """
                    SELECT assignment_type
                    FROM Customer_Segments
                    WHERE segment_id = ?
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, segmentId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getString("assignment_type");
            }
        }

        return "ROUND_ROBIN";
    }

    //9
    public int getLeastCustomerUser(Connection conn) throws SQLException {

        String sql = """
                    SELECT TOP 1
                        u.user_id
                    FROM Users u
                    LEFT JOIN Customer_Segment_Map m
                        ON m.assigned_by = u.user_id
                    WHERE u.role_id IN (2, 3, 4) AND u.status = 'ACTIVE'
                    GROUP BY u.user_id
                    ORDER BY COUNT(m.customer_id) ASC
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("user_id");
            }
        }

        return -1;
    }

    //10
    public int getNextRoundRobinUser(Connection conn, int segmentId) throws SQLException {

        int lastUser = -1;

        String getLast = """
                    SELECT last_assigned_user_id
                    FROM Customer_Segments
                    WHERE segment_id = ?
                """;

        try (PreparedStatement ps = conn.prepareStatement(getLast)) {

            ps.setInt(1, segmentId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                lastUser = rs.getInt("last_assigned_user_id");
            }
        }

        String sql = """
                    SELECT TOP 1 user_id
                    FROM Users
                    WHERE user_id > ? AND role_id IN (2, 3, 4) AND status = 'ACTIVE'
                    ORDER BY user_id
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, lastUser);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("user_id");
            }
        }

        String firstUser = """
                    SELECT TOP 1 user_id
                    FROM Users
                    WHERE role_id IN (2, 3, 4) AND status = 'ACTIVE'
                    ORDER BY user_id
                """;

        try (PreparedStatement ps = conn.prepareStatement(firstUser)) {

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("user_id");
            }
        }

        return -1;
    }

    //11
    public void updateCustomerOwner(Connection conn, int customerId, int userId, int segmentId) throws SQLException {

        String sql = """
                    UPDATE Customer_Segment_Map
                    SET assigned_by = ?
                    WHERE customer_id = ? AND segment_id = ?
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, customerId);
            ps.setInt(3, segmentId);

            ps.executeUpdate();
        }
    }

    //12
    public void updateLastAssignedUser(Connection conn, int segmentId, int userId) throws SQLException {

        String sql = """
                    UPDATE Customer_Segments
                    SET last_assigned_user_id = ?
                    WHERE segment_id = ?
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, segmentId);

            ps.executeUpdate();
        }
    }

    //13
    public void assignStaff(Connection conn, int segmentId) throws SQLException {

        String assignmentType = getAssignmentType(conn, segmentId);

        String getCustomers = """
                    SELECT customer_id
                    FROM Customer_Segment_Map
                    WHERE segment_id = ?
                """;

        try (PreparedStatement ps = conn.prepareStatement(getCustomers)) {

            ps.setInt(1, segmentId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                int customerId = rs.getInt("customer_id");

                int userId;

                if ("LEAST_CUSTOMERS".equals(assignmentType)) {
                    userId = getLeastCustomerUser(conn);
                } else {
                    userId = getNextRoundRobinUser(conn, segmentId);
                }

                updateCustomerOwner(conn, customerId, userId, segmentId);
                updateLastAssignedUser(conn, segmentId, userId);
            }
        }
    }
}
