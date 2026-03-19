package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Timestamp;

import model.CustomerMeasurement;

public class CustomerMeasurementDAO {

    public void insertCustomerMeasurement(CustomerMeasurement measurement, Connection connection) throws Exception {
        String sql = """
                INSERT INTO [Customer_Measurements]
                           ([customer_id]
                           ,[height]
                           ,[weight]
                           ,[bust]
                           ,[waist]
                           ,[hips]
                           ,[shoulder]
                           ,[preferred_size]
                           ,[body_shape]
                           ,[measured_at])
                     VALUES
                           (?
                           ,?
                           ,?
                           ,?
                           ,?
                           ,?
                           ,?
                           ,?
                           ,?
                           ,?)""";

        try (

                PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, measurement.getCustomerId());
            stmt.setObject(2, measurement.getHeight() != null ? measurement.getHeight() : null);
            stmt.setObject(3, measurement.getWeight() != null ? measurement.getWeight() : null);
            stmt.setObject(4, measurement.getBust() != null ? measurement.getBust() : null);
            stmt.setObject(5, measurement.getWaist() != null ? measurement.getWaist() : null);
            stmt.setObject(6, measurement.getHips() != null ? measurement.getHips() : null);
            stmt.setObject(7, measurement.getShoulder() != null ? measurement.getShoulder() : null);
            stmt.setString(8, measurement.getPreferredSize() != null ? measurement.getPreferredSize() : null);
            stmt.setString(9, measurement.getBodyShape() != null ? measurement.getBodyShape() : null);
            stmt.setTimestamp(10, new java.sql.Timestamp(System.currentTimeMillis()));

            stmt.executeUpdate();
        }
    }

    public CustomerMeasurement getLatestMeasurement(Connection conn, int id)
            throws Exception {

        String sql = """
                SELECT TOP 1
                    measure_id,
                    customer_id,
                    height,
                    weight,
                    bust,
                    waist,
                    hips,
                    shoulder,
                    preferred_size,
                    body_shape,
                    measured_at
                FROM Customer_Measurements
                WHERE customer_id = ?
                ORDER BY measured_at DESC
                """;

        try (var ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);

            try (var rs = ps.executeQuery()) {

                if (rs.next()) {

                    CustomerMeasurement m = new CustomerMeasurement();

                    m.setMeasureId(rs.getInt("measure_id"));
                    m.setCustomerId(rs.getInt("customer_id"));

                    // 🔥 DÙNG BigDecimal ĐÚNG CHUẨN
                    m.setHeight(rs.getBigDecimal("height"));
                    m.setWeight(rs.getBigDecimal("weight"));
                    m.setBust(rs.getBigDecimal("bust"));
                    m.setWaist(rs.getBigDecimal("waist"));
                    m.setHips(rs.getBigDecimal("hips"));
                    m.setShoulder(rs.getBigDecimal("shoulder"));

                    m.setPreferredSize(rs.getString("preferred_size"));
                    m.setBodyShape(rs.getString("body_shape"));

                    Timestamp ts = rs.getTimestamp("measured_at");
                    if (ts != null) {
                        m.setMeasuredAt(ts.toLocalDateTime());
                    }

                    return m;
                }
            }
        }

        return null;
    }
}
