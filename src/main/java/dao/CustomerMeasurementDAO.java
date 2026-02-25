package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;

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
}
