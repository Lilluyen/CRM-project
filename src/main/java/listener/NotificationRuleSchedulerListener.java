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
 * NotificationRuleSchedulerListener – Processes scheduled notification rules.
 *
 * Runs every 5 seconds to check for due notification rules:
 *   - Reminder rules (schedule-based)
 *   - Condition-based rules
 *   - Escalation rules
 *
 * Each rule execution:
 *   1. Load rule from Notification_Rule_Engine
 *   2. Build notification from template
 *   3. Resolve recipients
 *   4. Create notification + push via WebSocket
 *   5. Update rule's next_run_at or deactivate if one-time
 *
 * Tuning:
 *   INITIAL_DELAY_SECONDS – default 5s (waits for app startup)
 *   INTERVAL_SECONDS      – default 5s (frequency of rule checking)
 *   BATCH_SIZE           – default 50 (max rules processed per run)
 */
@WebListener
public class NotificationRuleSchedulerListener implements ServletContextListener {

    private static final Logger LOG = Logger.getLogger(NotificationRuleSchedulerListener.class.getName());

    private static final int BATCH_SIZE = 50;
    private static final long INITIAL_DELAY_SECONDS = 5;
    private static final long INTERVAL_SECONDS = 5;

    private ScheduledExecutorService executor;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        executor = Executors.newSingleThreadScheduledExecutor(r -> {
            Thread t = new Thread(r, "notification-rule-scheduler");
            t.setDaemon(true);
            return t;
        });

        executor.scheduleWithFixedDelay(this::runOnceSafe, INITIAL_DELAY_SECONDS, INTERVAL_SECONDS, TimeUnit.SECONDS);
        LOG.info("NotificationRuleScheduler started – runs every " + INTERVAL_SECONDS + "s, batch size=" + BATCH_SIZE);
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (executor != null) {
            executor.shutdownNow();
            LOG.info("NotificationRuleScheduler stopped.");
        }
    }

    private void runOnceSafe() {
        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            NotificationRuleService svc = new NotificationRuleService(conn);
            int processed = svc.processDueRules(BATCH_SIZE);

            conn.commit();

            if (processed > 0) {
                LOG.info("NotificationRuleScheduler: processed " + processed + " rule(s).");
            }
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

