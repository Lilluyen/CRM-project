//package controller;
//
//import controller.sale.deal.UpdateDealStageController;
//import dao.DealDAO;
//import jakarta.servlet.ServletException;
//import jakarta.servlet.http.HttpServletRequest;
//import jakarta.servlet.http.HttpServletResponse;
//import org.junit.jupiter.api.BeforeEach;
//import org.junit.jupiter.api.Test;
//import org.mockito.Mock;
//import org.mockito.MockedStatic;
//import org.mockito.MockitoAnnotations;
//import util.DBContext;
//
//import java.sql.Connection;
//import java.sql.SQLException;
//
//import static org.junit.jupiter.api.Assertions.*;
//import static org.mockito.Mockito.mockStatic;
//import static org.mockito.Mockito.when;
//
//class UpdateDealStageControllerTest {
//
//    private UpdateDealStageController controller;
//
//    @Mock
//    private HttpServletRequest request;
//
//    @Mock
//    private HttpServletResponse response;
//
//    @Mock
//    private Connection mockConnection;
//
//    @BeforeEach
//    void setUp() {
//        MockitoAnnotations.openMocks(this);
//        controller = new UpdateDealStageController();
//    }
//
//    // --- A. FUNCTIONAL SCENARIOS ---
//
//    @Test
//    void TC_DEAL_01_UpdateStandardStage_Success() throws Exception {
//        try (MockedStatic<DBContext> dbContext = mockStatic(DBContext.class)) {
//            dbContext.when(DBContext::getConnection).thenReturn(mockConnection);
//
//            // Mock Parameters
//            when(request.getParameter("id")).thenReturn("101");
//            when(request.getParameter("stage")).thenReturn("Qualified");
//            when(request.getParameter("actualValue")).thenReturn("1500.50");
//
//            // Execute (Assuming the internal logic handles the mock connection)
//            assertDoesNotThrow(() -> controller.doPost(request, response));
//        }
//    }
//
//    @Test
//    void TC_DEAL_03_LeadConversion_ClosedWon() throws Exception {
//        try (MockedStatic<DBContext> dbContext = mockStatic(DBContext.class)) {
//            dbContext.when(DBContext::getConnection).thenReturn(mockConnection);
//
//            when(request.getParameter("id")).thenReturn("202");
//            when(request.getParameter("stage")).thenReturn("Closed Won");
//            when(request.getParameter("actualValue")).thenReturn("5000");
//
//            // Verify redirect or success after processing conversion
//            controller.doPost(request, response);
//            // In a real scenario, you'd verify if leadDAO.markConverted was called
//        }
//    }
//
//    // --- B. VALIDATION & UI SCENARIOS ---
//
//    @Test
//    void TC_DEAL_06_ProbabilityMapping_Logic() {
//        // Test static utility method in DealDAO
//        assertEquals(10, DealDAO.stageToDefaultProbability("Prospecting"));
//        assertEquals(60, DealDAO.stageToDefaultProbability("Proposal"));
//        assertEquals(100, DealDAO.stageToDefaultProbability("Closed Won"));
//        assertEquals(0, DealDAO.stageToDefaultProbability("Closed Lost"));
//    }
//
//    @Test
//    void TC_DEAL_07_InvalidActualValue_ThrowsException() throws Exception {
//        try (MockedStatic<DBContext> dbContext = mockStatic(DBContext.class)) {
//            dbContext.when(DBContext::getConnection).thenReturn(mockConnection);
//
//            when(request.getParameter("id")).thenReturn("1");
//            when(request.getParameter("stage")).thenReturn("Qualified");
//            when(request.getParameter("actualValue")).thenReturn("INVALID_NUMBER");
//
//            // Expected behavior: NumberFormatException from new BigDecimal()
//            assertThrows(NumberFormatException.class, () -> controller.doPost(request, response));
//        }
//    }
//
//    @Test
//    void TC_DEAL_09_EmptyActualValue_Success() throws Exception {
//        try (MockedStatic<DBContext> dbContext = mockStatic(DBContext.class)) {
//            dbContext.when(DBContext::getConnection).thenReturn(mockConnection);
//
//            when(request.getParameter("id")).thenReturn("1");
//            when(request.getParameter("stage")).thenReturn("Negotiation");
//            when(request.getParameter("actualValue")).thenReturn(""); // Blank
//
//            assertDoesNotThrow(() -> controller.doPost(request, response));
//        }
//    }
//
//    // --- C. BUSINESS LOGIC & EXCEPTIONS ---
//
//    @Test
//    void TC_DEAL_11_DatabaseConnectionFailure_ThrowsServletException() throws Exception {
//        try (MockedStatic<DBContext> dbContext = mockStatic(DBContext.class)) {
//            // Simulate Connection error
//            dbContext.when(DBContext::getConnection).thenThrow(new SQLException("Conn Failed"));
//
//            when(request.getParameter("id")).thenReturn("1");
//            when(request.getParameter("stage")).thenReturn("Prospecting");
//
//            assertThrows(ServletException.class, () -> controller.doPost(request, response));
//        }
//    }
//
//    @Test
//    void TC_DEAL_12_InvalidIdFormat_ThrowsNumberFormatException() {
//        when(request.getParameter("id")).thenReturn("NOT_AN_ID");
//
//        assertThrows(NumberFormatException.class, () -> controller.doPost(request, response));
//    }
//}