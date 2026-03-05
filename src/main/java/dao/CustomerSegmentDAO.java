package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;

public class CustomerSegmentDAO {

    public boolean upgradeToLoyaltyCustomer(Connection conn, int customerId) throws Exception {
        String sql = """
                UPDATE [Customers]
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

    public boolean downgradeToLoyaltyCustomer(Connection conn, int customerId) throws Exception{
        String sql = """ 
                     UPDATE [Customers]
                SET [loyalty_tier] = CASE [loyalty_tier]
                     WHEN 'BLACKLIST' THEN 'BLACKLIST'
                     WHEN 'BRONZE' THEN 'BLACKLIST'
                     WHEN 'SILVER' THEN 'BRONZE'
                     WHEN 'GOLD' THEN 'SILVER'
                     WHEN 'PLATINUM' THEN 'GOLD'
                     WHEN 'DIAMOND' THEN 'PLATINUM'
                     ELSE [loyalty_tier]
                 END,
                     [updated_at] = GETDATE()
                 WHERE [customer_id] = ?
                            """;
        
        try(PreparedStatement stm = conn.prepareStatement(sql)){
            stm.setInt(1, customerId);
            stm.executeUpdate();
            return true;
        }
    }
}
