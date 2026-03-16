package dao;

import dto.CustomerListDTO;
import model.CustomerSegment;
import model.SegmentHistory;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SegmentDetailDAO {

    public CustomerSegment getSegmentById(Connection conn, int id) throws SQLException {
        String sql = """
                  SELECT
                  s.segment_id,
                  s.segment_name,
                  s.criteria_logic,
                  s.segment_type,
                  s.assignment_type,
                  s.[status],
                  s.created_at,
                  uc.email AS created_by,
                  s.updated_at,
                  uu.email AS updated_by,
                  s.customer_count
                
                  FROM Customer_Segments s
                
                  LEFT JOIN Users uc
                  ON s.created_by = uc.[user_id]
                
                  LEFT JOIN Users uu
                  ON s.updated_by = uu.[user_id]
                
                  WHERE segment_id = ?
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                CustomerSegment s = new CustomerSegment();

                s.setSegmentId(rs.getInt("segment_id"));
                s.setSegmentName(rs.getString("segment_name"));
                s.setCriteriaLogic(rs.getString("criteria_logic"));
                s.setSegmentType(rs.getString("segment_type"));
                s.setAssignType(rs.getString("assignment_type"));
                s.setStatus(rs.getString("status"));
                Timestamp ts1 = rs.getTimestamp("created_at");
                if (ts1 != null) {
                    s.setCreatedAt(ts1.toLocalDateTime());
                }
                s.setCreatedBy(rs.getString("created_by"));

                Timestamp ts2 = rs.getTimestamp("updated_at");
                if (ts2 != null) {
                    s.setUpdatedAt(ts2.toLocalDateTime());
                }

                s.setUpdatedBy(rs.getString("updated_by"));
                s.setNumberData(rs.getInt("customer_count"));
                return s;
            }
        }
        return null;
    }

    public List<SegmentHistory> getSegmentHistory(Connection conn, int id) throws SQLException {
        String sql = """
                SELECT [history_id]
                      ,[segment_id]
                      ,u.email as updated_by
                      ,s.[updated_at]
                      ,[change_description]
                  FROM [Segment_Update_History] s
                  LEFT JOIN Users u ON u.user_id = updated_by
                  WHERE [segment_id] = ?
                """;
        List<SegmentHistory> segmentHistories = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                SegmentHistory s = new SegmentHistory();

                s.setSegmentId(rs.getInt("segment_id"));
                s.setChangeDescription(rs.getString("change_description"));
                Timestamp ts = rs.getTimestamp("updated_at");
                if (ts != null) {
                    s.setUpdatedAt(ts.toLocalDateTime());
                }
                s.setUpdatedByName(rs.getString("updated_by"));

                segmentHistories.add(s);
            }
        }
        return segmentHistories;
    }

    public List<CustomerListDTO> getListInDetailSegment(Connection conn, int id) throws SQLException {
        String sql = """
                SELECT\s
                	c.customer_id,
                	c.[name],
                	c.email,
                	c.loyalty_tier,
                	c.source,
                	u.full_name
                
                FROM Customers c
                JOIN Customer_Segment_Map csm ON c.customer_id = csm.customer_id
                JOIN Customer_Segments cs ON cs.segment_id = csm.segment_id
                LEFT JOIN Users u ON csm.assigned_by = u.[user_id]
                WHERE cs.segment_id = ?
                ORDER BY c.customer_id
                """;
        List<CustomerListDTO> list = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                CustomerListDTO c = new CustomerListDTO();

                c.setCustomerId(rs.getInt("customer_id"));
                c.setEmail(rs.getString("email"));
                c.setName(rs.getNString("name"));
                c.setSource(rs.getString("source"));
                c.setLoyaltyTier(rs.getString("loyalty_tier"));
                c.setOwner(rs.getString("full_name"));

                list.add(c);

            }
            return list;
        }
    }

    public int updateSegmentation(Connection conn, int id, String name, String logic,
                                  String segmentType, int updater, String currentName, String currentType, String currentLogic) throws SQLException {
        String sql = """
                UPDATE Customer_Segments
                SET
                    segment_name = ?,
                    criteria_logic = ?,
                    segment_type = ?,
                    updated_at = GETDATE(),
                    updated_by = ?
                WHERE segment_id = ?
                """;
        int row = 0;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, logic);
            ps.setString(3, segmentType);
            ps.setInt(4, updater);
            ps.setInt(5, id);

            row = ps.executeUpdate();
            if (row > 0) {
                return insertHistorySegment(conn, id, name, logic, segmentType, updater, currentName, currentType, currentLogic);
            }
        }
        return row;
    }

    //13
    public void updateSegmentCount(Connection conn, int id) throws SQLException {
        String sql = """
                    UPDATE Customer_Segments
                    SET customer_count =
                    (
                        SELECT COUNT(*)
                        FROM Customer_Segment_Map
                        WHERE segment_id = ?
                    )
                    WHERE segment_id = ?
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, id);

            ps.executeUpdate();
        }
    }

    private int insertHistorySegment(Connection conn, int id, String name, String logic, String segmentType, int updater
            , String currentName, String currentType, String currentLogic) throws SQLException {
        String sql = """
                INSERT INTO Segment_Update_History
                (
                    segment_id,
                    updated_by,
                    updated_at,
                    change_description
                )
                VALUES
                (
                    ?,
                    ?,
                    GETDATE(),
                    ?
                )
                """;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, updater);

            StringBuilder changeDes = new StringBuilder("");
            if (!name.equalsIgnoreCase(currentName)) {
                changeDes.append("Change segment name from " + currentName + " -> " + name);
            }
            if (!segmentType.equalsIgnoreCase(currentType)) {
                changeDes.append(", Change segment name from " + currentType + " -> " + segmentType);
            }
            if (!logic.equalsIgnoreCase(currentLogic)) {
                changeDes.append(", Change segment name from " + currentLogic + " -> " + logic);
            }
            if (changeDes.toString().equalsIgnoreCase("")) {
                return 0;
            }
            ps.setString(3, changeDes.toString());

            return ps.executeUpdate();
        }
    }


}
