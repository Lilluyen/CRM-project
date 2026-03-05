package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;

public class CustomerSegmentDAO {

    public boolean upgradeToLoyaltyCustomer(Connection conn, int customerId) throws Exception {
        String sql = """
                UPDATE [dbo].[Customers]
                SET
                    [loyalty_tier] = CASE [loyalty_tier]
                        WHEN 'BLACKLIST' THEN 'BRONZE'
                        WHEN 'BRONZE'    THEN 'SILVER'
                        WHEN 'SILVER'    THEN 'GOLD'
                        WHEN 'GOLD'      THEN 'PLATINUM'
                        WHEN 'PLATINUM'  THEN 'DIAMOND'
                        WHEN 'DIAMOND'   THEN 'DIAMOND'
                        ELSE [loyalty_tier]
                    END,
                    [updated_at] = GETDATE()
                WHERE [customer_id] = ? """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.executeUpdate();
            return true;
        }
    }
}