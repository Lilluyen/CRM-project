//package dao;
//
//import static org.junit.jupiter.api.Assertions.assertEquals;
//import static org.junit.jupiter.api.Assertions.assertFalse;
//import static org.junit.jupiter.api.Assertions.assertTrue;
//import static org.mockito.ArgumentMatchers.any;
//import static org.mockito.ArgumentMatchers.anyInt;
//import static org.mockito.ArgumentMatchers.anyString;
//import static org.mockito.ArgumentMatchers.eq;
//import static org.mockito.Mockito.mock;
//import static org.mockito.Mockito.verify;
//import static org.mockito.Mockito.when;
//
//import java.math.BigDecimal;
//import java.sql.Connection;
//import java.sql.PreparedStatement;
//import java.sql.ResultSet;
//import java.sql.Statement;
//import java.sql.Timestamp;
//import java.time.LocalDate;
//import java.time.LocalDateTime;
//import java.util.List;
//
//import org.junit.jupiter.api.Test;
//
//import model.Deal;
//
//class DealDAOTest {
//
//    @Test
//    void getDefaultStages_shouldContainAllExpected() {
//        List<String> stages = DealDAO.getDefaultStages();
//        assertEquals(6, stages.size());
//        assertTrue(stages.contains("Prospecting"));
//        assertTrue(stages.contains("Closed Lost"));
//    }
//
//    @Test
//    void stageToDefaultProbability_shouldReturnCorrectValues() {
//        assertEquals(Integer.valueOf(10), DealDAO.stageToDefaultProbability("Prospecting"));
//        assertEquals(Integer.valueOf(40), DealDAO.stageToDefaultProbability("Qualified"));
//        assertEquals(Integer.valueOf(60), DealDAO.stageToDefaultProbability("Proposal"));
//        assertEquals(Integer.valueOf(75), DealDAO.stageToDefaultProbability("Negotiation"));
//        assertEquals(Integer.valueOf(100), DealDAO.stageToDefaultProbability("Closed Won"));
//        assertEquals(Integer.valueOf(0), DealDAO.stageToDefaultProbability("Closed Lost"));
//        assertEquals(null, DealDAO.stageToDefaultProbability("Unknown"));
//        assertEquals(null, DealDAO.stageToDefaultProbability(null));
//    }
//
//    @Test
//    void updateDealStage_success_shouldCallPreparedStatementWithCorrectParameters() throws Exception {
//        Connection conn = mock(Connection.class);
//        PreparedStatement ps = mock(PreparedStatement.class);
//
//        when(conn.prepareStatement(anyString())).thenReturn(ps);
//        when(ps.executeUpdate()).thenReturn(1);
//
//        DealDAO dao = new DealDAO(conn);
//        boolean result = dao.updateDealStage(123, "Proposal", 65, new BigDecimal("1500.00"));
//
//        assertTrue(result);
//        verify(ps).setString(1, "Proposal");
//        verify(ps).setInt(2, 65);
//        verify(ps).setBigDecimal(3, new BigDecimal("1500.00"));
//        verify(ps).setInt(5, 123);
//        verify(ps).executeUpdate();
//    }
//
//    @Test
//    void createDeal_success_shouldReturnGeneratedId() throws Exception {
//        Connection conn = mock(Connection.class);
//        PreparedStatement ps = mock(PreparedStatement.class);
//        ResultSet rs = mock(ResultSet.class);
//
//        when(conn.prepareStatement(anyString(), eq(Statement.RETURN_GENERATED_KEYS))).thenReturn(ps);
//        when(ps.executeUpdate()).thenReturn(1);
//        when(ps.getGeneratedKeys()).thenReturn(rs);
//        when(rs.next()).thenReturn(true);
//        when(rs.getInt(1)).thenReturn(999);
//
//        Deal deal = new Deal();
//        deal.setCustomerId(0);
//        deal.setLeadId(0);
//        deal.setDealName("Super deal");
//        deal.setExpectedValue(new BigDecimal("2500.00"));
//        deal.setActualValue(new BigDecimal("0.00"));
//        deal.setStage("Prospecting");
//        deal.setProbability(10);
//        deal.setExpectedCloseDate(LocalDate.of(2026, 4, 30));
//        deal.setOwnerId(5);
//
//        DealDAO dao = new DealDAO(conn);
//        int id = dao.createDeal(deal);
//
//        assertEquals(999, id);
//        verify(ps).setNull(1, java.sql.Types.INTEGER);
//        verify(ps).setNull(2, java.sql.Types.INTEGER);
//        verify(ps).setString(3, "Super deal");
//        verify(ps).setBigDecimal(4, new BigDecimal("2500.00"));
//        verify(ps).setBigDecimal(5, new BigDecimal("0.00"));
//        verify(ps).setString(6, "Prospecting");
//        verify(ps).setInt(7, 10);
//        verify(ps).setDate(8, java.sql.Date.valueOf(LocalDate.of(2026, 4, 30)));
//        verify(ps).setInt(9, 5);
//        verify(ps).executeUpdate();
//    }
//
//    @Test
//    void deleteDeal_success_shouldReturnTrue() throws Exception {
//        Connection conn = mock(Connection.class);
//        PreparedStatement ps = mock(PreparedStatement.class);
//
//        when(conn.prepareStatement(anyString())).thenReturn(ps);
//        when(ps.executeUpdate()).thenReturn(1);
//
//        DealDAO dao = new DealDAO(conn);
//        boolean result = dao.deleteDeal(234);
//
//        assertTrue(result);
//        verify(ps).setInt(1, 234);
//        verify(ps).executeUpdate();
//    }
//
//    @Test
//    void deleteDeal_notFound_shouldReturnFalse() throws Exception {
//        Connection conn = mock(Connection.class);
//        PreparedStatement ps = mock(PreparedStatement.class);
//
//        when(conn.prepareStatement(anyString())).thenReturn(ps);
//        when(ps.executeUpdate()).thenReturn(0);
//
//        DealDAO dao = new DealDAO(conn);
//        boolean result = dao.deleteDeal(234);
//
//        assertFalse(result);
//        verify(ps).setInt(1, 234);
//        verify(ps).executeUpdate();
//    }
//}
