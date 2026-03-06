package listener;

import service.NotificationRuleService;
import util.DBContext;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.sql.Connection;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Background scheduler that scans Notification_Rules every minute and triggers due reminders.
 */
@WebListener
public class NotificationRuleSchedulerListener implements ServletContextListener {

    private static final Logger LOG = Logger.getLogger(NotificationRuleSchedulerListener.class.getName());
    private static final int BATCH_SIZE = 50;

    private ScheduledExecutorService executor;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        executor = Executors.newSingleThreadScheduledExecutor(r -> {
            Thread t = new Thread(r, "notification-rule-scheduler");
            t.setDaemon(true);
            return t;
        });

        // initial delay gives the app a moment to start before hitting DB
        executor.scheduleWithFixedDelay(this::runOnceSafe, 5, 60, TimeUnit.SECONDS);
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (executor != null) {
            executor.shutdownNow();
        }
    }

    private void runOnceSafe() {
        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            NotificationRuleService svc = new NotificationRuleService(conn);
            svc.processDueRules(BATCH_SIZE);

            conn.commit();
        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (Exception ignored) {
                }
            }
            LOG.log(Level.WARNING, "Notification rule scheduler error", e);
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (Exception ignored) {
                }
            }
        }
    }
}

