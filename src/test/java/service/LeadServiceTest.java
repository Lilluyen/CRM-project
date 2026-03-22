//package service;
//
//import java.lang.reflect.Field;
//
//import static org.junit.jupiter.api.Assertions.assertEquals;
//import static org.junit.jupiter.api.Assertions.assertThrows;
//import static org.junit.jupiter.api.Assertions.assertTrue;
//import org.junit.jupiter.api.BeforeEach;
//import org.junit.jupiter.api.Test;
//import static org.mockito.ArgumentMatchers.any;
//import static org.mockito.ArgumentMatchers.anyInt;
//import static org.mockito.ArgumentMatchers.anyString;
//import static org.mockito.Mockito.doNothing;
//import static org.mockito.Mockito.mock;
//import static org.mockito.Mockito.never;
//import static org.mockito.Mockito.spy;
//import static org.mockito.Mockito.verify;
//import static org.mockito.Mockito.when;
//
//import dao.CampaignLeadDAO;
//import dao.LeadDAO;
//import model.Lead;
//class LeadServiceTest {
//
//    private LeadService leadService;
//    private LeadDAO leadDAO;
//    private CampaignLeadDAO campaignLeadDAO;
//    private Lead lead;
//
//    @BeforeEach
//    void setup() throws Exception {
//
//        // mock DAO
//        leadDAO = mock(LeadDAO.class);
//        campaignLeadDAO = mock(CampaignLeadDAO.class);
//
//        // tạo service thật nhưng spy
//        leadService = spy(new LeadService());
//
//        // inject mock bằng reflection
//        injectMock("leadDAO", leadDAO);
//        injectMock("campaignLeadDAO", campaignLeadDAO);
//
//        // bỏ qua validate database
//        doNothing().when(leadService).validateLeadUniqueness(any());
//        doNothing().when(leadService).validateLeadUniqueness(any(), anyInt());
//
//        // tạo lead mẫu
//        lead = new Lead();
//        lead.setLeadId(1);
//        lead.setFullName("John Doe");
//        lead.setEmail("john@gmail.com");
//        lead.setPhone("0123456789");
//        lead.setCampaignId(10);
//        lead.setStatus("NEW");
//    }
//
//    private void injectMock(String fieldName, Object mock) throws Exception {
//        Field field = LeadService.class.getDeclaredField(fieldName);
//        field.setAccessible(true);
//        field.set(leadService, mock);
//    }
//
//    // =============================
//    // TEST createLead()
//    // =============================
//
//    // OK
//    @Test
//    void createLead_success_withCampaign() {
//
//        when(leadDAO.createLead(any())).thenReturn(5);
//
//        int id = leadService.createLead(lead);
//
//        assertEquals(5, id);
//
//        verify(leadDAO).createLead(any());
//        verify(campaignLeadDAO).assignLeadToCampaign(10, 5, "NEW");
//    }
//
//    //OK
//    @Test
//    void createLead_success_withoutCampaign() {
//
//        lead.setCampaignId(0);
//
//        when(leadDAO.createLead(any())).thenReturn(3);
//
//        int id = leadService.createLead(lead);
//
//        assertEquals(3, id);
//
//        verify(campaignLeadDAO, never())
//                .assignLeadToCampaign(anyInt(), anyInt(), anyString());
//    }
//
//    
//    //OK
//    @Test
//    void createLead_fail_fullNameNull() {
//
//        lead.setFullName(null);
//
//        assertThrows(IllegalArgumentException.class,
//                () -> leadService.createLead(lead));
//    }
//
//    //OK
//    @Test
//    void createLead_fail_fullNameEmpty() {
//
//        lead.setFullName(" ");
//
//        assertThrows(IllegalArgumentException.class,
//                () -> leadService.createLead(lead));
//    }
//
//    
//    //OK
//    @Test
//    void createLead_fail_emailNull() {
//
//        lead.setEmail(null);
//
//        assertThrows(IllegalArgumentException.class,
//                () -> leadService.createLead(lead));
//    }
//
//    //OK
//    @Test
//    void createLead_fail_emailEmpty() {
//
//        lead.setEmail(" ");
//
//        assertThrows(IllegalArgumentException.class,
//                () -> leadService.createLead(lead));
//    }
//
//    // =============================
//    // TEST updateLead()
//    // =============================
//    //OK
//    @Test
//    void updateLead_success_normalStatus() {
//
//        when(leadDAO.updateLead(any())).thenReturn(true);
//
//        boolean result = leadService.updateLead(lead);
//
//        assertTrue(result);
//
//        verify(leadDAO).updateLead(any());
//    }
//
//    
//    //OK
//    @Test
//    void updateLead_success_dealCreatedStatus() {
//
//        lead.setStatus("DEAL_CREATED");
//
//        when(leadDAO.updateLead(any())).thenReturn(true);
//
//        boolean result = leadService.updateLead(lead);
//
//        assertTrue(result);
//    }
//
//    //OK
//    @Test
//    void updateLead_fail_invalidId() {
//
//        lead.setLeadId(0);
//
//        assertThrows(IllegalArgumentException.class,
//                () -> leadService.updateLead(lead));
//    }
//
//    //OK
//    @Test
//    void updateLead_fail_fullNameNull() {
//
//        lead.setFullName(null);
//
//        assertThrows(IllegalArgumentException.class,
//                () -> leadService.updateLead(lead));
//    }
//
//    //OK
//    @Test
//    void updateLead_fail_emailNull() {
//
//        lead.setEmail(null);
//
//        assertThrows(IllegalArgumentException.class,
//                () -> leadService.updateLead(lead));
//    }
//}