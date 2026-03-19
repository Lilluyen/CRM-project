package listener;

import service.TaskService;
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
 * TaskOverdueScheduler – Scenario 9 (Task Quá Hạn)
 *
 * Chạy nền mỗi 2 giây:
 *   1. Tìm tất cả task có due_date < NOW và status NOT IN (Done, Cancelled, Overdue)
 *   2. Cập nhật status = Overdue
 *   3. Tạo Activity  activity_type = task_overdue
 *   4. Gửi Notification đến tất cả assignees
 *
 * Lưu ý: Để đạt độ trễ <=5s, KHUYẾN NGHỊ sử dụng trigger ngay trong TaskService
 * (gọi checkAndNotifyOverdue() khi tạo/cập nhật task) - scheduler này là backup.
 *
 * Đăng ký tự động qua @WebListener – không cần khai báo trong web.xml.
 *
 * Tuning:
 *   INITIAL_DELAY_SECONDS – chờ trước khi chạy lần đầu (default 5s để app khởi động xong)
 *   INTERVAL_SECONDS      – chu kỳ kiểm tra (default 2s)
 *   BATCH_SIZE            – số task tối đa xử lý mỗi lần chạy (default 500)
 */
@WebListener
public class TaskOverDueScheduler implements ServletContextListener {

    private static final Logger LOG = Logger.getLogger(TaskOverDueScheduler.class.getName());

    private static final long INITIAL_DELAY_SECONDS = 1;
    private static final long INTERVAL_SECONDS      = 1;
    private static final int  BATCH_SIZE            = 500;

    private ScheduledExecutorService scheduler;

    // ─────────────────────────────────────────────────────────────────────────
    // Lifecycle
    // ─────────────────────────────────────────────────────────────────────────

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        scheduler = Executors.newSingleThreadScheduledExecutor(r -> {
            Thread t = new Thread(r, "task-overdue-scheduler");
            t.setDaemon(true);   // không chặn JVM shutdown
            return t;
        });

        scheduler.scheduleWithFixedDelay(
                this::runOverdueCheck,
                INITIAL_DELAY_SECONDS,
                INTERVAL_SECONDS,
                TimeUnit.SECONDS
        );

        LOG.info("TaskOverdueScheduler started – runs every "
                + INTERVAL_SECONDS + " second(s), batch size=" + BATCH_SIZE);
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null) {
            scheduler.shutdownNow();
            LOG.info("TaskOverdueScheduler stopped.");
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Core job
    // ─────────────────────────────────────────────────────────────────────────

    private void runOverdueCheck() {
        try (Connection conn = DBContext.getConnection()) {
            TaskService svc = new TaskService(conn);
            int count = svc.markOverdueTasks(BATCH_SIZE);
            if (count > 0) {
                LOG.info("TaskOverdueScheduler: marked " + count + " task(s) as Overdue.");
            }
        } catch (Exception ex) {
            // Không để exception kill scheduler thread
            LOG.log(Level.SEVERE, "TaskOverdueScheduler: error during overdue check", ex);
        }
    }
}