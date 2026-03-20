//package controller;
//
//import controller.sale.CreateCustomerController;
//import dto.CustomerCreateDTO;
//import exception.DuplicateEmailException;
//import exception.DuplicatePhoneException;
//import jakarta.servlet.RequestDispatcher;
//import jakarta.servlet.ServletException;
//import jakarta.servlet.http.HttpServletRequest;
//import jakarta.servlet.http.HttpServletResponse;
//import jakarta.servlet.http.HttpSession;
//import model.User;
//import org.junit.jupiter.api.BeforeEach;
//import org.junit.jupiter.api.Test;
//import org.mockito.ArgumentCaptor;
//import org.mockito.InjectMocks;
//import org.mockito.Mock;
//import org.mockito.MockitoAnnotations;
//import service.CustomerService;
//
//import java.util.Map;
//
//import static org.junit.jupiter.api.Assertions.*;
//import static org.mockito.Mockito.*;
//
//class CreateCustomerControllerTest {
//
//    @InjectMocks
//    private CreateCustomerController controller;
//
//    @Mock
//    private CustomerService customerService;
//
//    @Mock
//    private HttpServletRequest request;
//
//    @Mock
//    private HttpServletResponse response;
//
//    @Mock
//    private HttpSession session;
//
//    @Mock
//    private RequestDispatcher dispatcher;
//
//    @BeforeEach
//    void setUp() {
//        MockitoAnnotations.openMocks(this);
//        when(request.getContextPath()).thenReturn("/crm");
//        when(request.getRequestDispatcher(anyString())).thenReturn(dispatcher);
//    }
//
//    private void mockLoggedInUser() {
//        User user = new User();
//        user.setUserId(1);
//        when(request.getSession(false)).thenReturn(session);
//        when(session.getAttribute("user")).thenReturn(user);
//    }
//
//    // =========================================================================
//    // A. FUNCTIONAL SCENARIOS (HAPPY PATH)
//    // =========================================================================
//
//    @Test
//    void TC_CUST_01_CreateCustomer_MinimumFields_Success() throws Exception {
//        mockLoggedInUser();
//        when(request.getParameter("name")).thenReturn("John Doe");
//        when(request.getParameter("phone")).thenReturn("0912345678");
//        when(request.getParameter("gender")).thenReturn("Male");
//        when(request.getParameter("birthday")).thenReturn("1995-05-20");
//
//        controller.doPost(request, response);
//
//        verify(customerService).createCustomer(any(CustomerCreateDTO.class), eq(1));
//        verify(response).sendRedirect("/crm/customers?status=success");
//    }
//
//    @Test
//    void TC_CUST_02_CreateCustomer_FullProfile_Success() throws Exception {
//        mockLoggedInUser();
//        when(request.getParameter("name")).thenReturn("Jane Smith");
//        when(request.getParameter("phone")).thenReturn("0988776655");
//        when(request.getParameter("email")).thenReturn("jane@example.com");
//        when(request.getParameter("gender")).thenReturn("Female");
//        when(request.getParameter("birthday")).thenReturn("1992-10-10");
//        when(request.getParameter("height")).thenReturn("165");
//        when(request.getParameter("weight")).thenReturn("55");
//        when(request.getParameterValues("styleTags")).thenReturn(new String[]{"1", "2"});
//
//        controller.doPost(request, response);
//
//        verify(customerService).createCustomer(argThat(dto ->
//                dto.getEmail().equals("jane@example.com") &&
//                        dto.getStyleTags().size() == 2
//        ), anyInt());
//        verify(response).sendRedirect("/crm/customers?status=success");
//    }
//
//    @Test
//    void TC_CUST_03_LoadForm_GetRequest_Success() throws Exception {
//        controller.doGet(request, response);
//
//        verify(customerService).getListStyleTags();
//        verify(request).setAttribute(eq("pageTitle"), contains("Add New Customer"));
//        verify(dispatcher).forward(request, response);
//    }
//
//    // =========================================================================
//    // B. VALIDATION & UI SCENARIOS
//    // =========================================================================
//
//    @Test
//    void TC_CUST_04_Validation_NameMissing() throws Exception {
//        mockLoggedInUser();
//        when(request.getParameter("name")).thenReturn(""); // Empty name
//
//        controller.doPost(request, response);
//
//        ArgumentCaptor<Map> errors = ArgumentCaptor.forClass(Map.class);
//        verify(request).setAttribute(eq("fieldErrors"), errors.capture());
//        assertEquals("Full name is required.", errors.getValue().get("name"));
//    }
//
//    @Test
//    void TC_CUST_05_Validation_PhoneFormat() throws Exception {
//        // 1. Giả lập login
//        mockLoggedInUser();
//
//        // 2. Mock đầy đủ các tham số bắt buộc để tránh lỗi ở các dòng validation trước đó
//        when(request.getParameter("name")).thenReturn("Test User");
//        when(request.getParameter("phone")).thenReturn("123"); // Giá trị sai định dạng
//        when(request.getParameter("gender")).thenReturn("Male");
//        when(request.getParameter("birthday")).thenReturn("1999-01-01");
//
//        // Mock dispatcher vì khi có lỗi validation, controller sẽ dùng forward
//        when(request.getRequestDispatcher(anyString())).thenReturn(dispatcher);
//
//        // 3. Thực thi
//        controller.doPost(request, response);
//
//        // 4. Kiểm tra kết quả
//        ArgumentCaptor<Map> errorsCaptor = ArgumentCaptor.forClass(Map.class);
//
//        // Kiểm tra xem setAttribute("fieldErrors", ...) có được gọi không
//        verify(request, atLeastOnce()).setAttribute(eq("fieldErrors"), errorsCaptor.capture());
//
//        Map<String, String> errors = errorsCaptor.getValue();
//
//        // Assert: Đảm bảo key "phone" tồn tại trong map lỗi
//        assertNotNull(errors.get("phone"), "Error map should contain a message for 'phone'");
//        assertTrue(errors.get("phone").contains("9–15 digits"),
//                "Expected error message to contain '9–15 digits' but got: " + errors.get("phone"));
//    }
//
//    @Test
//    void TC_CUST_06_Validation_BirthdayFuture() throws Exception {
//        mockLoggedInUser();
//        when(request.getParameter("name")).thenReturn("Test User");
//        when(request.getParameter("birthday")).thenReturn("2099-01-01");
//
//        controller.doPost(request, response);
//
//        ArgumentCaptor<Map> errors = ArgumentCaptor.forClass(Map.class);
//        verify(request).setAttribute(eq("fieldErrors"), errors.capture());
//        assertEquals("Birthday must be in the past.", errors.getValue().get("birthday"));
//    }
//
//    @Test
//    void TC_CUST_07_Validation_NegativeMeasurement() throws Exception {
//        mockLoggedInUser();
//        when(request.getParameter("height")).thenReturn("-10");
//
//        controller.doPost(request, response);
//
//        ArgumentCaptor<Map> errors = ArgumentCaptor.forClass(Map.class);
//        verify(request).setAttribute(eq("fieldErrors"), errors.capture());
//        assertEquals("Value must be greater than 0.", errors.getValue().get("height"));
//    }
//
//    @Test
//    void TC_CUST_08_UI_OldValuesPreserved() throws Exception {
//        mockLoggedInUser();
//        when(request.getParameter("name")).thenReturn("Keep Me");
//        when(request.getParameter("phone")).thenReturn("Invalid");
//
//        controller.doPost(request, response);
//
//        verify(request).setAttribute("oldName", "Keep Me");
//        verify(request).setAttribute(eq("fieldErrors"), anyMap());
//        verify(dispatcher).forward(request, response);
//    }
//
//    // =========================================================================
//    // C. BUSINESS LOGIC & EXCEPTION SCENARIOS
//    // =========================================================================
//
//    @Test
//    void TC_CUST_09_Business_DuplicatePhone() throws Exception {
//        mockLoggedInUser();
//        when(request.getParameter("name")).thenReturn("John");
//        when(request.getParameter("phone")).thenReturn("0912345678");
//        when(request.getParameter("gender")).thenReturn("Male");
//        when(request.getParameter("birthday")).thenReturn("1990-01-01");
//
//        doThrow(new DuplicatePhoneException("Exists")).when(customerService).createCustomer(any(), anyInt());
//
//        controller.doPost(request, response);
//
//        ArgumentCaptor<Map> errors = ArgumentCaptor.forClass(Map.class);
//        verify(request).setAttribute(eq("fieldErrors"), errors.capture());
//        assertEquals("This phone number is already registered.", errors.getValue().get("phone"));
//    }
//
//    @Test
//    void TC_CUST_10_Business_DuplicateEmail() throws Exception {
//        // 1. Giả lập login
//        mockLoggedInUser();
//
//        // 2. Mock các tham số input (PHẢI ĐẦY ĐỦ VÀ ĐÚNG ĐỊNH DẠNG)
//        when(request.getParameter("name")).thenReturn("Valid Name");
//        when(request.getParameter("phone")).thenReturn("0912345678");
//        when(request.getParameter("email")).thenReturn("duplicate@test.com");
//        when(request.getParameter("gender")).thenReturn("Male");
//        when(request.getParameter("birthday")).thenReturn("1990-01-01"); // Phải có để không lỗi parse
//
//        // 3. Thiết lập Service ném lỗi DuplicateEmailException
//        // Đảm bảo dùng any() hoặc đúng kiểu dữ liệu
//        doThrow(new DuplicateEmailException("Email exists"))
//                .when(customerService).createCustomer(any(CustomerCreateDTO.class), anyInt());
//
//        // 4. Thực thi
//        controller.doPost(request, response);
//
//        // 5. Kiểm tra kết quả
//        ArgumentCaptor<Map> errorsCaptor = ArgumentCaptor.forClass(Map.class);
//        verify(request).setAttribute(eq("fieldErrors"), errorsCaptor.capture());
//
//        Map<String, String> errors = errorsCaptor.getValue();
//
//        // Debug nếu vẫn lỗi: System.out.println("Errors found: " + errors);
//
//        assertNotNull(errors.get("email"), "Key 'email' should exist in fieldErrors map");
//        assertEquals("This email is already registered.", errors.get("email"));
//    }
//
//    @Test
//    void TC_CUST_11_Security_NoSession() throws Exception {
//        when(request.getSession(false)).thenReturn(null);
//
//        controller.doPost(request, response);
//
//        verify(response).sendRedirect("/crm/login");
//        verifyNoInteractions(customerService);
//    }
//
//    @Test
//    void TC_CUST_12_Error_DatabaseFailure() throws Exception {
//        mockLoggedInUser();
//
//        // Giả lập service ném lỗi
//        doThrow(new RuntimeException("DB Down"))
//                .when(customerService).createCustomer(any(), anyInt());
//
//        // Mock các tham số cần thiết
//        when(request.getParameter("name")).thenReturn("John");
//        when(request.getParameter("phone")).thenReturn("0123456789");
//        when(request.getParameter("gender")).thenReturn("Male");
//        when(request.getParameter("birthday")).thenReturn("1990-01-01");
//
//        // Assert: Kiểm tra xem Controller có ném ServletException hay không
//        assertThrows(ServletException.class, () -> {
//            controller.doPost(request, response);
//        });
//    }
//}