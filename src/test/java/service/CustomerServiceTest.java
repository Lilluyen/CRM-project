//package service;
//
//import dao.CustomerDAO;
//import dao.CustomerMeasurementDAO;
//import dao.CustomerStyleDAO;
//import dto.CustomerCreateDTO;
//import exception.DuplicateEmailException;
//import exception.DuplicatePhoneException;
//import org.junit.jupiter.api.Test;
//import org.junit.jupiter.api.extension.ExtendWith;
//import org.mockito.InjectMocks;
//import org.mockito.Mock;
//import org.mockito.MockedStatic;
//import org.mockito.junit.jupiter.MockitoExtension;
//import util.DBContext;
//
//import java.sql.Connection;
//import java.sql.SQLException;
//import java.util.Collections;
//import java.util.List;
//
//import static org.junit.jupiter.api.Assertions.assertEquals;
//import static org.junit.jupiter.api.Assertions.assertThrows;
//import static org.mockito.ArgumentMatchers.*;
//import static org.mockito.Mockito.*;
//
//@ExtendWith(MockitoExtension.class)
//class CustomerServiceTest {
//
//    @InjectMocks
//    private CustomerService customerService;
//
//    @Mock
//    private CustomerDAO customerDAO;
//
//    @Mock
//    private CustomerStyleDAO customerStyleDAO;
//
//    @Mock
//    private CustomerMeasurementDAO customerMeasurementDAO;
//
//    @Mock
//    private Connection conn;
//
//    @Test
//    void createCustomer_phoneDuplicate_throwException() throws Exception {
//
//        CustomerCreateDTO dto = new CustomerCreateDTO();
//        dto.setPhone("123");
//
//        try (MockedStatic<DBContext> db = mockStatic(DBContext.class)) {
//
//            db.when(DBContext::getConnection).thenReturn(conn);
//
//            when(customerDAO.existsByPhone("123", conn)).thenReturn(true);
//
//            assertThrows(DuplicatePhoneException.class,
//                    () -> customerService.createCustomer(dto, 1));
//
//            verify(conn).rollback();
//        }
//    }
//
//    @Test
//    void createCustomer_emailDuplicate_throwException() throws Exception {
//
//        CustomerCreateDTO dto = new CustomerCreateDTO();
//        dto.setPhone("123");
//        dto.setEmail("a@gmail.com");
//
//        try (MockedStatic<DBContext> db = mockStatic(DBContext.class)) {
//
//            db.when(DBContext::getConnection).thenReturn(conn);
//
//            when(customerDAO.existsByPhone("123", conn)).thenReturn(false);
//            when(customerDAO.existsByEmail("a@gmail.com", conn)).thenReturn(true);
//
//            assertThrows(DuplicateEmailException.class,
//                    () -> customerService.createCustomer(dto, 1));
//
//            verify(conn).rollback();
//        }
//    }
//
//    @Test
//    void createCustomer_success_withStyles() throws Exception {
//
//        CustomerCreateDTO dto = new CustomerCreateDTO();
//        dto.setPhone("123");
//        dto.setEmail("a@gmail.com");
//        dto.setStyleTags(List.of(1, 2));
//
//        try (MockedStatic<DBContext> db = mockStatic(DBContext.class)) {
//
//            db.when(DBContext::getConnection).thenReturn(conn);
//
//            when(customerDAO.existsByPhone(any(), eq(conn))).thenReturn(false);
//            when(customerDAO.existsByEmail(any(), eq(conn))).thenReturn(false);
//            when(customerDAO.insertCustomer(any(), eq(conn))).thenReturn(10);
//
//            int id = customerService.createCustomer(dto, 1);
//
//            assertEquals(10, id);
//
//            verify(customerStyleDAO)
//                    .insertCustomerStyles(conn, 10, dto.getStyleTags());
//
//            verify(conn).commit();
//        }
//    }
//
//    @Test
//    void createCustomer_success_withoutStyles() throws Exception {
//
//        CustomerCreateDTO dto = new CustomerCreateDTO();
//        dto.setPhone("123");
//        dto.setEmail("a@gmail.com");
//        dto.setStyleTags(Collections.emptyList());
//
//        try (MockedStatic<DBContext> db = mockStatic(DBContext.class)) {
//
//            db.when(DBContext::getConnection).thenReturn(conn);
//
//            when(customerDAO.existsByPhone(any(), eq(conn))).thenReturn(false);
//            when(customerDAO.existsByEmail(any(), eq(conn))).thenReturn(false);
//            when(customerDAO.insertCustomer(any(), eq(conn))).thenReturn(5);
//
//            customerService.createCustomer(dto, 1);
//
//            verify(customerStyleDAO, never())
//                    .insertCustomerStyles(any(), anyInt(), any());
//
//            verify(conn).commit();
//        }
//    }
//
//    @Test
//    void createCustomer_styleTagsNull_shouldNotInsertStyles() throws Exception {
//
//        CustomerCreateDTO dto = new CustomerCreateDTO();
//        dto.setPhone("123");
//        dto.setEmail("a@gmail.com");
//        dto.setStyleTags(null); // boundary
//
//        try (MockedStatic<DBContext> db = mockStatic(DBContext.class)) {
//
//            db.when(DBContext::getConnection).thenReturn(conn);
//
//            when(customerDAO.existsByPhone(any(), eq(conn))).thenReturn(false);
//            when(customerDAO.existsByEmail(any(), eq(conn))).thenReturn(false);
//            when(customerDAO.insertCustomer(any(), eq(conn))).thenReturn(7);
//
//            customerService.createCustomer(dto, 1);
//
//            verify(customerStyleDAO, never())
//                    .insertCustomerStyles(any(), anyInt(), any());
//
//            verify(conn).commit();
//        }
//    }
//
//    @Test
//    void createCustomer_insertSQLException_shouldRollback() throws Exception {
//
//        CustomerCreateDTO dto = new CustomerCreateDTO();
//        dto.setPhone("123");
//        dto.setEmail("a@gmail.com");
//
//        try (MockedStatic<DBContext> db = mockStatic(DBContext.class)) {
//
//            db.when(DBContext::getConnection).thenReturn(conn);
//
//            when(customerDAO.existsByPhone(any(), eq(conn))).thenReturn(false);
//            when(customerDAO.existsByEmail(any(), eq(conn))).thenReturn(false);
//
//            when(customerDAO.insertCustomer(any(), eq(conn)))
//                    .thenThrow(new SQLException("DB error"));
//
//            assertThrows(SQLException.class,
//                    () -> customerService.createCustomer(dto, 1));
//
//            verify(conn).rollback();
//        }
//    }
//
//    @Test
//    void createCustomer_runtimeException_shouldWrapSQLException() throws Exception {
//
//        CustomerCreateDTO dto = new CustomerCreateDTO();
//        dto.setPhone("123");
//        dto.setEmail("a@gmail.com");
//
//        try (MockedStatic<DBContext> db = mockStatic(DBContext.class)) {
//
//            db.when(DBContext::getConnection).thenReturn(conn);
//
//            when(customerDAO.existsByPhone(any(), eq(conn))).thenReturn(false);
//            when(customerDAO.existsByEmail(any(), eq(conn))).thenReturn(false);
//            when(customerDAO.insertCustomer(any(), eq(conn))).thenReturn(10);
//
//            assertThrows(SQLException.class,
//                    () -> customerService.createCustomer(dto, 1));
//
//            verify(conn).rollback();
//        }
//    }
//
//    @Test
//    void updateCustomer_phoneDuplicate() throws Exception {
//
//        CustomerCreateDTO dto = new CustomerCreateDTO();
//        dto.setPhone("123");
//
//        try (MockedStatic<DBContext> db = mockStatic(DBContext.class)) {
//
//            db.when(DBContext::getConnection).thenReturn(conn);
//
//            when(customerDAO.existsByPhoneExcludeId("123", 1, conn))
//                    .thenReturn(true);
//
//            assertThrows(DuplicatePhoneException.class,
//                    () -> customerService.updateCustomer(dto, 1));
//
//            verify(conn).rollback();
//        }
//    }
//
//    @Test
//    void updateCustomer_emailDuplicate() throws Exception {
//
//        CustomerCreateDTO dto = new CustomerCreateDTO();
//        dto.setPhone("123");
//        dto.setEmail("a@gmail.com");
//
//        try (MockedStatic<DBContext> db = mockStatic(DBContext.class)) {
//
//            db.when(DBContext::getConnection).thenReturn(conn);
//
//            when(customerDAO.existsByPhoneExcludeId("123", 1, conn))
//                    .thenReturn(false);
//
//            when(customerDAO.existsByEmailExcludeId("a@gmail.com", 1, conn))
//                    .thenReturn(true);
//
//            assertThrows(DuplicateEmailException.class,
//                    () -> customerService.updateCustomer(dto, 1));
//
//            verify(conn).rollback();
//        }
//    }
//
//    @Test
//    void updateCustomer_success() throws Exception {
//
//        CustomerCreateDTO dto = new CustomerCreateDTO();
//        dto.setPhone("123");
//        dto.setEmail("a@gmail.com");
//
//        try (MockedStatic<DBContext> db = mockStatic(DBContext.class)) {
//
//            db.when(DBContext::getConnection).thenReturn(conn);
//
//            when(customerDAO.existsByPhoneExcludeId(any(), anyInt(), eq(conn)))
//                    .thenReturn(false);
//
//            when(customerDAO.existsByEmailExcludeId(any(), anyInt(), eq(conn)))
//                    .thenReturn(false);
//
//            customerService.updateCustomer(dto, 1);
//
//            verify(customerDAO).updateBasicInfo(any(), eq(conn));
//
//            verify(conn).commit();
//        }
//    }
//
//    @Test
//    void updateCustomer_styleTagsNull_shouldStillUpdate() throws Exception {
//
//        CustomerCreateDTO dto = new CustomerCreateDTO();
//        dto.setPhone("123");
//        dto.setEmail("a@gmail.com");
//        dto.setStyleTags(null); // boundary
//
//        try (MockedStatic<DBContext> db = mockStatic(DBContext.class)) {
//
//            db.when(DBContext::getConnection).thenReturn(conn);
//
//            when(customerDAO.existsByPhoneExcludeId(any(), anyInt(), eq(conn)))
//                    .thenReturn(false);
//
//            when(customerDAO.existsByEmailExcludeId(any(), anyInt(), eq(conn)))
//                    .thenReturn(false);
//
//            customerService.updateCustomer(dto, 1);
//
//            verify(customerDAO).updateBasicInfo(any(), eq(conn));
//
//            verify(conn).commit();
//        }
//    }
//
//    @Test
//    void testCuaCo() throws Exception {
//        CustomerCreateDTO dto = new CustomerCreateDTO();
//        dto.setPhone("345");
//        try (MockedStatic<DBContext> db = mockStatic(DBContext.class)) {
/// /
//            db.when(DBContext::getConnection).thenReturn(conn);
//
//            when(customerDAO.existsByPhone(dto.getPhone(), conn)).thenReturn(true);
//            assertThrows(DuplicatePhoneException.class, () ->
//                    customerService.createCustomer(dto, 0)
//            );
//
//            verify(conn).rollback();
//
//        }
//    }
//}
