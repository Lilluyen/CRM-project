import dao.ConfigSegmentDAO;
import dao.CustomerSegmentDAO;
import model.SegmentConfig;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.*;

class CustomerSegmentTest {

    private ConfigSegmentDAO configDAO;
    private CustomerSegmentDAO segmentDAO;
    private Connection mockConn;

    @BeforeEach
    void setUp() {
        configDAO = new ConfigSegmentDAO();
        segmentDAO = new CustomerSegmentDAO();
        mockConn = mock(Connection.class); // Mock kết nối database
    }

    @Test
    @DisplayName("TC_DAO_01: Kiểm tra logic xây dựng SQL từ bộ lọc")
    void testBuildFilterSQL() {
        // GIVEN: Một danh sách các cấu hình filter
        List<SegmentConfig> configs = new ArrayList<>();
        SegmentConfig f1 = new SegmentConfig();
        f1.setField("loyalty_tier");
        f1.setOperator("=");
        f1.setValue("GOLD");
        f1.setLogic("AND");
        configs.add(f1);

        SegmentConfig f2 = new SegmentConfig();
        f2.setField("name");
        f2.setOperator("LIKE");
        f2.setValue("An");
        configs.add(f2);

        // WHEN: Gọi hàm build SQL
        String sql = configDAO.buildFilterSQL(configs);

        // THEN: SQL sinh ra phải đúng cú pháp
        assertTrue(sql.contains("loyalty_tier = 'GOLD'"));
        assertTrue(sql.contains("AND name LIKE '%An%'"));
    }

    @Test
    @DisplayName("TC_DAO_02: Kiểm tra nâng cấp bậc hội viên")
    void testUpgradeLoyaltyCustomer() throws Exception {
        // Giả lập thực thi SQL thành công
        when(mockConn.prepareStatement(anyString())).thenReturn(mock(java.sql.PreparedStatement.class));

        boolean result = segmentDAO.upgradeToLoyaltyCustomer(mockConn, 101);

        assertTrue(result, "Hàm nâng cấp phải trả về true khi thực thi thành công");
    }

    @Test
    @DisplayName("TC_VAL_01: Kiểm tra gán khách hàng đã tồn tại trong Segment")
    void testIsCustomerInSegment() throws SQLException {
        // Giả lập khách hàng đã tồn tại trong segment
        int segmentId = 1;
        int customerId = 99;

        // Mock ResultSet để trả về true
        var mockPs = mock(java.sql.PreparedStatement.class);
        var mockRs = mock(java.sql.ResultSet.class);
        when(mockConn.prepareStatement(anyString())).thenReturn(mockPs);
        when(mockPs.executeQuery()).thenReturn(mockRs);
        when(mockRs.next()).thenReturn(true);

        boolean exists = configDAO.isCustomerInSegment(mockConn, segmentId, customerId);

        assertTrue(exists, "Phải nhận diện được khách hàng đã có trong segment để tránh gán trùng");
    }
}