package service;

import dao.NotificationDAO;
import util.DBContext;
import util.Email;
import util.EmailService;
import model.Notification;

import java.sql.Connection;
import java.time.LocalDateTime;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * Notification service - coordinates DB notifications and email sending
 */
public class NotificationService {

    private final NotificationDAO notificationDAO;
    private final ExecutorService emailExecutor = Executors.newFixedThreadPool(2);

    public NotificationService(Connection connection) {
        this.notificationDAO = new NotificationDAO(connection);
    }

    public boolean createPopupNotification(int userId, String title, String content, String type) {
        try {
            Notification n = new Notification();
            n.setUserId(userId);
            n.setTitle(title);
            n.setContent(content);
            n.setType(type);
            n.setRead(false);
            n.setCreatedAt(LocalDateTime.now());

            return notificationDAO.insert(n);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Notification> getUnreadForUser(int userId) {
        try {
            return notificationDAO.findUnreadByUser(userId);
        } catch (Exception e) {
            e.printStackTrace();
            return java.util.Collections.emptyList();
        }
    }

    public boolean markAsRead(int notificationId) {
        try {
            return notificationDAO.markAsRead(notificationId);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public void sendAssignmentEmailAsync(String toEmail, String subject, String htmlBody) {
        emailExecutor.submit(() -> {
            try {
                Email email = new Email()
                        .setTo(toEmail)
                        .setSubject(subject)
                        .setBodyHtml(htmlBody);
                EmailService.send(email);
            } catch (Exception e) {
                e.printStackTrace();
            }
        });
    }

    public static NotificationService withDefaultConnection() throws Exception {
        Connection conn = DBContext.getConnection();
        return new NotificationService(conn);
    }
}
