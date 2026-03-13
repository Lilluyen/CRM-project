/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/UnitTests/JUnit4TestClass.java to edit this template
 */
package service;

import dao.NotificationDAO;
import dao.NotificationRuleDAO;
import model.Notification;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.Mockito;
import org.mockito.junit.jupiter.MockitoExtension;
import websocket.NotificationWebSocketEndpoint;

import java.lang.reflect.Field;
import java.sql.Connection;
import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * Unit tests for {@link NotificationService#createForUser} and
 * {@link NotificationService#createForUserWithRule}.
 *
 * Coverage targets
 * ─────────────────────────────────────────────────────────────
 * Statement coverage : 100 %
 * Decision coverage  : 100 %
 *
 * Strategy
 * ─────────────────────────────────────────────────────────────
 * • NotificationService's constructor creates DAO objects internally,
 *   so we build an instance with a dummy Connection and then swap the
 *   private fields via reflection to inject Mockito mocks.
 * • NotificationWebSocketEndpoint.pushNewUnread is a static method;
 *   we capture it with Mockito's MockedStatic to verify calls and avoid
 *   real network / context-lookup side-effects.
 *
 * Decision map – createForUser (6-param)
 * ─────────────────────────────────────────────────────────────
 *  D1  notifId <= 0            → true  → return false            (TC-CFU-01)
 *                               → false → continue               (TC-CFU-02..05)
 *  D2  ok (addRecipient)       → false → return false            (TC-CFU-02)
 *                               → true  → enter if-block         (TC-CFU-03..05)
 *  D3  full != null (ternary)  → true  → push full               (TC-CFU-03)
 *                               → false → push n                 (TC-CFU-04)
 *  D4  catch branch            → exception thrown → return false (TC-CFU-05)
 *
 * Decision map – createForUserWithRule
 * ─────────────────────────────────────────────────────────────
 *  D1  notifId <= 0            → true  → return false            (TC-CFUWR-01)
 *                               → false → continue               (TC-CFUWR-02..06)
 *  D2  !addRecipient           → true  → return false            (TC-CFUWR-02)
 *                               → false → continue               (TC-CFUWR-03..06)
 *  D3  ok (ruleId > 0)         → false → return false            (TC-CFUWR-03)
 *                               → true  → enter if-block         (TC-CFUWR-04..06)
 *  D4  full != null (ternary)  → true  → push full               (TC-CFUWR-04)
 *                               → false → push n                 (TC-CFUWR-05)
 *  D5  catch branch            → exception thrown → return false (TC-CFUWR-06)
 */
@ExtendWith(MockitoExtension.class)
class NotificationServiceTest {

    // ── shared fixture constants ──────────────────────────────────────────────
    private static final int    USER_ID      = 42;
    private static final int    NOTIF_ID     = 7;
    private static final String TITLE        = "Test title";
    private static final String CONTENT      = "Test content";
    private static final String TYPE         = "TASK";
    private static final String RELATED_TYPE = "Lead";
    private static final int    RELATED_ID   = 99;

    private static final String        RULE_TYPE       = "RECURRING";
    private static final int           INTERVAL_VALUE  = 1;
    private static final String        INTERVAL_UNIT   = "DAY";
    private static final LocalDateTime NEXT_RUN        = LocalDateTime.now().plusDays(1);

    // ── mocks ─────────────────────────────────────────────────────────────────
    @Mock private Connection        mockConnection;
    @Mock private NotificationDAO   mockNotificationDAO;
    @Mock private NotificationRuleDAO mockNotificationRuleDAO;

    // ── system under test ─────────────────────────────────────────────────────
    private NotificationService service;

    /**
     * Build a NotificationService and then inject mock DAOs via reflection,
     * bypassing the constructor's "new DAO(connection)" calls.
     */
    @BeforeEach
    void setUp() throws Exception {
        service = new NotificationService(mockConnection);
        injectField(service, "notificationDAO",     mockNotificationDAO);
        injectField(service, "notificationRuleDAO", mockNotificationRuleDAO);
    }

    // ═════════════════════════════════════════════════════════════════════════
    //  createForUser(userId, title, content, type, relatedType, relatedId)
    // ═════════════════════════════════════════════════════════════════════════
    @Nested
    @DisplayName("createForUser – 6-param overload")
    class CreateForUserTests {

        // ── TC-CFU-01 ─────────────────────────────────────────────────────────
        @Test
        @DisplayName("D1=true  → insertNotification returns ≤ 0 → returns false")
        void tc_cfu_01_insertFails_returnsFalse() throws Exception {
            // D1 TRUE: notifId <= 0
            when(mockNotificationDAO.insertNotification(any())).thenReturn(0);

            boolean result = service.createForUser(USER_ID, TITLE, CONTENT,
                                                   TYPE, RELATED_TYPE, RELATED_ID);

            assertFalse(result, "Should return false when insertNotification returns 0");
            verify(mockNotificationDAO, never()).addRecipient(anyInt(), anyInt());
        }

        // ── TC-CFU-02 ─────────────────────────────────────────────────────────
        @Test
        @DisplayName("D1=false, D2=false → addRecipient returns false → returns false")
        void tc_cfu_02_addRecipientFails_returnsFalse() throws Exception {
            // D1 FALSE: valid notifId
            when(mockNotificationDAO.insertNotification(any())).thenReturn(NOTIF_ID);
            // D2 FALSE: addRecipient fails
            when(mockNotificationDAO.addRecipient(NOTIF_ID, USER_ID)).thenReturn(false);

            boolean result = service.createForUser(USER_ID, TITLE, CONTENT,
                                                   TYPE, RELATED_TYPE, RELATED_ID);

            assertFalse(result, "Should return false when addRecipient fails");
            verify(mockNotificationDAO, never()).findById(anyInt());
            verify(mockNotificationDAO, never()).countUnreadByUser(anyInt());
        }

        // ── TC-CFU-03 ─────────────────────────────────────────────────────────
        @Test
        @DisplayName("D1=false, D2=true, D3=true → findById returns non-null → pushes full notification")
        void tc_cfu_03_addRecipientOk_fullNotNull_pushesFullNotification() throws Exception {
            // D1 FALSE, D2 TRUE, D3 TRUE
            Notification fullNotif = new Notification();
            fullNotif.setTitle(TITLE);

            when(mockNotificationDAO.insertNotification(any())).thenReturn(NOTIF_ID);
            when(mockNotificationDAO.addRecipient(NOTIF_ID, USER_ID)).thenReturn(true);
            when(mockNotificationDAO.findById(NOTIF_ID)).thenReturn(fullNotif);
            when(mockNotificationDAO.countUnreadByUser(USER_ID)).thenReturn(3);

            try (MockedStatic<NotificationWebSocketEndpoint> wsStatic =
                         mockStatic(NotificationWebSocketEndpoint.class)) {

                boolean result = service.createForUser(USER_ID, TITLE, CONTENT,
                                                       TYPE, RELATED_TYPE, RELATED_ID);

                assertTrue(result, "Should return true on full success");
                // Verify the FULL notification (not the local n) was pushed
                wsStatic.verify(() ->
                    NotificationWebSocketEndpoint.pushNewUnread(USER_ID, fullNotif, 3));
            }
        }

        // ── TC-CFU-04 ─────────────────────────────────────────────────────────
        @Test
        @DisplayName("D1=false, D2=true, D3=false → findById returns null → pushes local notification 'n'")
        void tc_cfu_04_addRecipientOk_fullNull_pushesLocalNotification() throws Exception {
            // D1 FALSE, D2 TRUE, D3 FALSE: findById returns null
            when(mockNotificationDAO.insertNotification(any())).thenReturn(NOTIF_ID);
            when(mockNotificationDAO.addRecipient(NOTIF_ID, USER_ID)).thenReturn(true);
            when(mockNotificationDAO.findById(NOTIF_ID)).thenReturn(null);
            when(mockNotificationDAO.countUnreadByUser(USER_ID)).thenReturn(1);

            try (MockedStatic<NotificationWebSocketEndpoint> wsStatic =
                         mockStatic(NotificationWebSocketEndpoint.class)) {

                boolean result = service.createForUser(USER_ID, TITLE, CONTENT,
                                                       TYPE, RELATED_TYPE, RELATED_ID);

                assertTrue(result, "Should return true even when findById returns null");
                // Verify pushNewUnread was called with *some* Notification (the local n)
                // and that it was NOT the null value
                wsStatic.verify(() ->
                    NotificationWebSocketEndpoint.pushNewUnread(
                        eq(USER_ID), notNull(), eq(1)));
            }
        }

        // ── TC-CFU-05 ─────────────────────────────────────────────────────────
        @Test
        @DisplayName("D4=true → DAO throws RuntimeException → catch block executed → returns false")
        void tc_cfu_05_daoThrowsException_returnsFalse() throws Exception {
            // Force catch branch
            when(mockNotificationDAO.insertNotification(any()))
                .thenThrow(new RuntimeException("DB connection lost"));

            boolean result = service.createForUser(USER_ID, TITLE, CONTENT,
                                                   TYPE, RELATED_TYPE, RELATED_ID);

            assertFalse(result, "Should return false when an exception is thrown");
        }
    }

    // ═════════════════════════════════════════════════════════════════════════
    //  createForUserWithRule(...)
    // ═════════════════════════════════════════════════════════════════════════
    @Nested
    @DisplayName("createForUserWithRule")
    class CreateForUserWithRuleTests {

        // ── TC-CFUWR-01 ───────────────────────────────────────────────────────
        @Test
        @DisplayName("D1=true → insertNotification returns ≤ 0 → returns false")
        void tc_cfuwr_01_insertFails_returnsFalse() throws Exception {
            // D1 TRUE
            when(mockNotificationDAO.insertNotification(any())).thenReturn(0);

            boolean result = callWithRule();

            assertFalse(result, "Should return false when insertNotification returns 0");
            verify(mockNotificationDAO, never()).addRecipient(anyInt(), anyInt());
            verify(mockNotificationRuleDAO, never()).insertRule(
                anyInt(), any(), any(), any(), any());
        }

        // ── TC-CFUWR-02 ───────────────────────────────────────────────────────
        @Test
        @DisplayName("D1=false, D2=true → addRecipient returns false → returns false")
        void tc_cfuwr_02_addRecipientFails_returnsFalse() throws Exception {
            // D1 FALSE, D2 TRUE: addRecipient fails
            when(mockNotificationDAO.insertNotification(any())).thenReturn(NOTIF_ID);
            when(mockNotificationDAO.addRecipient(NOTIF_ID, USER_ID)).thenReturn(false);

            boolean result = callWithRule();

            assertFalse(result, "Should return false when addRecipient fails");
            verify(mockNotificationRuleDAO, never()).insertRule(
                anyInt(), any(), any(), any(), any());
        }

        // ── TC-CFUWR-03 ───────────────────────────────────────────────────────
        @Test
        @DisplayName("D1=false, D2=false, D3=false → insertRule returns ≤ 0 → returns false, no WebSocket push")
        void tc_cfuwr_03_insertRuleFails_returnsFalse() throws Exception {
            // D1 FALSE, D2 FALSE, D3 FALSE: ruleId <= 0 → ok=false
            when(mockNotificationDAO.insertNotification(any())).thenReturn(NOTIF_ID);
            when(mockNotificationDAO.addRecipient(NOTIF_ID, USER_ID)).thenReturn(true);
            when(mockNotificationRuleDAO.insertRule(
                    eq(NOTIF_ID), eq(RULE_TYPE), eq(INTERVAL_VALUE),
                    eq(INTERVAL_UNIT), eq(NEXT_RUN)))
                .thenReturn(0);

            try (MockedStatic<NotificationWebSocketEndpoint> wsStatic =
                         mockStatic(NotificationWebSocketEndpoint.class)) {

                boolean result = callWithRule();

                assertFalse(result, "Should return false when insertRule fails");
                wsStatic.verify(() ->
                    NotificationWebSocketEndpoint.pushNewUnread(
                        anyInt(), any(), anyInt()), never());
            }
        }

        // ── TC-CFUWR-04 ───────────────────────────────────────────────────────
        @Test
        @DisplayName("D1=false, D2=false, D3=true, D4=true → findById non-null → pushes full notification, returns true")
        void tc_cfuwr_04_allOk_fullNotNull_pushesFullNotification() throws Exception {
            // D1 FALSE, D2 FALSE, D3 TRUE, D4 TRUE
            Notification fullNotif = new Notification();
            fullNotif.setTitle(TITLE);

            when(mockNotificationDAO.insertNotification(any())).thenReturn(NOTIF_ID);
            when(mockNotificationDAO.addRecipient(NOTIF_ID, USER_ID)).thenReturn(true);
            when(mockNotificationRuleDAO.insertRule(
                    eq(NOTIF_ID), eq(RULE_TYPE), eq(INTERVAL_VALUE),
                    eq(INTERVAL_UNIT), eq(NEXT_RUN)))
                .thenReturn(1);
            when(mockNotificationDAO.findById(NOTIF_ID)).thenReturn(fullNotif);
            when(mockNotificationDAO.countUnreadByUser(USER_ID)).thenReturn(5);

            try (MockedStatic<NotificationWebSocketEndpoint> wsStatic =
                         mockStatic(NotificationWebSocketEndpoint.class)) {

                boolean result = callWithRule();

                assertTrue(result, "Should return true when all operations succeed");
                wsStatic.verify(() ->
                    NotificationWebSocketEndpoint.pushNewUnread(USER_ID, fullNotif, 5));
            }
        }

        // ── TC-CFUWR-05 ───────────────────────────────────────────────────────
        @Test
        @DisplayName("D1=false, D2=false, D3=true, D4=false → findById null → pushes local notification 'n', returns true")
        void tc_cfuwr_05_allOk_fullNull_pushesLocalNotification() throws Exception {
            // D1 FALSE, D2 FALSE, D3 TRUE, D4 FALSE: findById returns null
            when(mockNotificationDAO.insertNotification(any())).thenReturn(NOTIF_ID);
            when(mockNotificationDAO.addRecipient(NOTIF_ID, USER_ID)).thenReturn(true);
            when(mockNotificationRuleDAO.insertRule(
                    eq(NOTIF_ID), eq(RULE_TYPE), eq(INTERVAL_VALUE),
                    eq(INTERVAL_UNIT), eq(NEXT_RUN)))
                .thenReturn(1);
            when(mockNotificationDAO.findById(NOTIF_ID)).thenReturn(null);
            when(mockNotificationDAO.countUnreadByUser(USER_ID)).thenReturn(2);

            try (MockedStatic<NotificationWebSocketEndpoint> wsStatic =
                         mockStatic(NotificationWebSocketEndpoint.class)) {

                boolean result = callWithRule();

                assertTrue(result, "Should return true even when findById returns null");
                wsStatic.verify(() ->
                    NotificationWebSocketEndpoint.pushNewUnread(
                        eq(USER_ID), notNull(), eq(2)));
            }
        }

        // ── TC-CFUWR-06 ───────────────────────────────────────────────────────
        @Test
        @DisplayName("D5=true → DAO throws RuntimeException → catch block executed → returns false")
        void tc_cfuwr_06_daoThrowsException_returnsFalse() throws Exception {
            // Force catch branch
            when(mockNotificationDAO.insertNotification(any()))
                .thenThrow(new RuntimeException("Timeout"));

            boolean result = callWithRule();

            assertFalse(result, "Should return false when an exception is thrown");
        }

        // ── helper ────────────────────────────────────────────────────────────
        /**
         * Calls createForUserWithRule with the shared test constants to keep
         * each test focused on the single decision point under examination.
         */
        private boolean callWithRule() {
            return service.createForUserWithRule(
                USER_ID, TITLE, CONTENT, TYPE, RELATED_TYPE, RELATED_ID,
                RULE_TYPE, INTERVAL_VALUE, INTERVAL_UNIT, NEXT_RUN);
        }
    }

    // ═════════════════════════════════════════════════════════════════════════
    //  Reflection helper
    // ═════════════════════════════════════════════════════════════════════════
    /**
     * Injects {@code value} into the private field {@code fieldName} on {@code target}.
     * This lets us swap the DAOs that were created inside the constructor for Mockito mocks.
     */
    private static void injectField(Object target, String fieldName, Object value)
            throws Exception {
        Field field = target.getClass().getDeclaredField(fieldName);
        field.setAccessible(true);
        field.set(target, value);
    }
}