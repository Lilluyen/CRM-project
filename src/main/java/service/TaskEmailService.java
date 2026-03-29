package service;

import model.Task;
import model.TaskComment;
import model.User;
import util.Email;
import util.EmailService;

import java.util.Collection;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Collectors;

/**
 * TaskEmailService – gửi email notification cho toàn bộ vòng đời của Task.
 *
 * Tất cả email được gửi ASYNC (fire-and-forget) qua một daemon thread pool
 * riêng,
 * không bao giờ block HTTP request thread. Thất bại khi gửi chỉ được log.
 *
 * ┌─────────────────────────────────────────────────────────────────┐
 * │ BA TEMPLATE CHUẨN │
 * │ │
 * │ 1. ASSIGNED – khi task được giao cho người dùng │
 * │ 2. CRUD – khi task được tạo / cập nhật / xóa │
 * │ 3. REMINDER – khi task sắp/đã quá hạn hoặc có subtask event │
 * └─────────────────────────────────────────────────────────────────┘
 *
 * Mỗi email đều được cá nhân hóa với tên người nhận ("Hello [Name],").
 * sendToAllPersonalized() gửi riêng cho từng User trong danh sách.
 *
 * Cấu hình base URL ứng dụng qua System Property "app.base.url"
 * hoặc sửa trực tiếp hằng số APP_BASE_URL bên dưới.
 */
public class TaskEmailService {

    private static final Logger LOG = Logger.getLogger(TaskEmailService.class.getName());

    /**
     * Base URL của ứng dụng – dùng để tạo task link trong email.
     * Ví dụ production: "https://crm.yourcompany.com"
     */
    private static final String APP_BASE_URL = System.getProperty("app.base.url", "http://localhost:8080/CRM");

    /** Daemon thread pool: 2 worker threads là đủ cho volume bình thường. */
    private static final ExecutorService POOL = Executors.newFixedThreadPool(2, r -> {
        Thread t = new Thread(r, "task-email-worker");
        t.setDaemon(true);
        return t;
    });

    // =========================================================================
    // TEMPLATE 1 – ASSIGNED
    // Áp dụng: task mới được giao hoặc giao lại cho một người dùng.
    // Người nhận: assignee mới.
    // =========================================================================

    /**
     * Gửi email ASSIGNED cho assignee mới.
     *
     * @param task       task vừa được giao
     * @param assignee   người nhận task (người nhận email)
     * @param assignedBy người thực hiện giao task (manager / team leader)
     * @param isReassign true nếu là reassign
     */
    public void notifyTaskAssigned(Task task, User assignee, User assignedBy, boolean isReassign) {
        if (task == null || !hasEmail(assignee))
            return;

        String subject = (isReassign ? "[Task Reassigned] " : "[New Task Assigned] ")
                + safe(task.getTitle());
        String body = buildAssignedTemplate(assignee, task, assignedBy);
        sendAsync(assignee.getEmail(), subject, body);
    }

    /** Backward-compat: không có assignedBy. */
    public void notifyTaskAssigned(Task task, User assignee, boolean isReassign) {
        notifyTaskAssigned(task, assignee, task != null ? task.getCreatedBy() : null, isReassign);
    }

    // =========================================================================
    // TEMPLATE 2 – CRUD
    // Áp dụng: tạo / cập nhật / xóa task, thay đổi status / progress.
    // Người nhận: creator, assignees, hoặc người bị gỡ.
    // =========================================================================

    /**
     * Gửi email CRUD khi task mới được tạo.
     * Người nhận: người tạo task.
     */
    public void notifyTaskCreated(Task task, User creator) {
        if (task == null || !hasEmail(creator))
            return;

        String subject = "[Task Created] " + safe(task.getTitle());
        String changeDesc = "Task <strong>" + esc(task.getTitle()) + "</strong> has been successfully created.";
        String body = buildCrudTemplate(creator, task, creator, changeDesc);
        sendAsync(creator.getEmail(), subject, body);
    }

    /**
     * Gửi email CRUD khi thông tin task thay đổi (title, description, …).
     *
     * @param updatedBy  người thực hiện thay đổi
     * @param changeDesc mô tả thay đổi (HTML cho phép), ví dụ "Due date changed to
     *                   March 28"
     * @param recipients danh sách người nhận
     */
    public void notifyTaskUpdated(Task task, User updatedBy, String changeDesc,
            Collection<User> recipients) {
        if (task == null || isEmpty(recipients))
            return;

        String subject = "[Task Updated] " + safe(task.getTitle());
        String desc = changeDesc != null ? changeDesc : "Task details have been updated.";
        sendToAllPersonalized(recipients, subject,
                recipient -> buildCrudTemplate(recipient, task, updatedBy, desc));
    }

    /**
     * Gửi email CRUD khi trạng thái task thay đổi.
     *
     * @param oldStatus  trạng thái cũ (nullable)
     * @param newStatus  trạng thái mới
     * @param changedBy  người thực hiện thay đổi
     * @param recipients danh sách người nhận
     */
    public void notifyStatusChanged(Task task, String oldStatus, String newStatus,
            User changedBy, Collection<User> recipients) {
        if (task == null || isEmpty(recipients))
            return;

        String changeDesc = (oldStatus != null && !oldStatus.isBlank())
                ? "Status changed from <strong>" + esc(oldStatus) + "</strong>"
                        + " to <strong>" + esc(newStatus) + "</strong>"
                : "Status changed to <strong>" + esc(newStatus) + "</strong>";

        String subject = "[Task Status: " + safe(newStatus) + "] " + safe(task.getTitle());
        sendToAllPersonalized(recipients, subject,
                recipient -> buildCrudTemplate(recipient, task, changedBy, changeDesc));
    }

    /** Backward-compat: không có changedBy. */
    public void notifyStatusChanged(Task task, String oldStatus, String newStatus,
            Collection<User> recipients) {
        notifyStatusChanged(task, oldStatus, newStatus, null, recipients);
    }

    /**
     * Gửi email CRUD khi tiến độ task cập nhật.
     *
     * @param progress   phần trăm tiến độ mới (0–100)
     * @param changedBy  người thực hiện cập nhật
     * @param recipients danh sách người nhận
     */
    public void notifyProgressUpdated(Task task, int progress, User changedBy,
            Collection<User> recipients) {
        if (task == null || isEmpty(recipients))
            return;

        String changeDesc = "Progress updated to <strong>" + progress + "%</strong>";
        String subject = "[Task Progress " + progress + "%] " + safe(task.getTitle());
        sendToAllPersonalized(recipients, subject,
                recipient -> buildCrudTemplate(recipient, task, changedBy, changeDesc));
    }

    /** Backward-compat: không có changedBy. */
    public void notifyProgressUpdated(Task task, int progress, Collection<User> recipients) {
        notifyProgressUpdated(task, progress, null, recipients);
    }

    /**
     * Gửi email CRUD khi người dùng bị gỡ khỏi task.
     *
     * @param removedAssignee người bị gỡ (người nhận email)
     * @param removedBy       người thực hiện gỡ
     */
    public void notifyTaskUnassigned(Task task, User removedAssignee, User removedBy) {
        if (task == null || !hasEmail(removedAssignee))
            return;

        String subject = "[Task Unassigned] " + safe(task.getTitle());
        String changeDesc = "You have been <strong>removed</strong> from this task.";
        String body = buildCrudTemplate(removedAssignee, task, removedBy, changeDesc);
        sendAsync(removedAssignee.getEmail(), subject, body);
    }

    /** Backward-compat: không có removedBy. */
    public void notifyTaskUnassigned(Task task, User removedAssignee) {
        notifyTaskUnassigned(task, removedAssignee, null);
    }

    /**
     * Gửi email CRUD khi task bị xóa.
     * PHẢI gọi TRƯỚC khi xóa để vẫn còn thông tin task.
     *
     * @param deletedBy  người thực hiện xóa
     * @param recipients danh sách người nhận (creator + assignees, trừ người xóa)
     */
    public void notifyTaskDeleted(Task task, User deletedBy, Collection<User> recipients) {
        if (task == null || isEmpty(recipients))
            return;

        String subject = "[Task Deleted] " + safe(task.getTitle());
        String changeDesc = "This task has been <strong>permanently deleted</strong>.";
        sendToAllPersonalized(recipients, subject,
                recipient -> buildCrudTemplate(recipient, task, deletedBy, changeDesc));
    }

    /** Backward-compat: không có deletedBy. */
    public void notifyTaskDeleted(Task task, Collection<User> recipients) {
        notifyTaskDeleted(task, null, recipients);
    }

    // =========================================================================
    // TEMPLATE 3 – REMINDER
    // Áp dụng: task quá hạn, subtask được tạo / hoàn thành.
    // =========================================================================

    /**
     * Gửi email REMINDER khi task quá hạn (urgent).
     *
     * @param recipients danh sách người nhận
     */
    public void notifyTaskOverdue(Task task, Collection<User> recipients) {
        if (task == null || isEmpty(recipients))
            return;

        String subject = "[OVERDUE] " + safe(task.getTitle());
        String note = "one of your tasks has <strong>passed its due date</strong>. "
                + "Please take action immediately.";
        sendToAllPersonalized(recipients, subject,
                recipient -> buildReminderTemplate(recipient, task, note));
    }

    /**
     * Gửi email REMINDER khi có work item mới được thêm vào task.
     *
     * @param author     người thêm work item
     * @param recipients danh sách người nhận
     */
    public void notifySubtaskCreated(Task task, TaskComment subtask,
            User author, Collection<User> recipients) {
        if (task == null || subtask == null || isEmpty(recipients))
            return;

        String from = esc(displayName(author));
        String subject = "[New Work Item] " + safe(task.getTitle());
        String note = "<strong>" + from + "</strong> added a new work item: "
                + "<em>&ldquo;" + esc(truncate(subtask.getContent(), 200)) + "&rdquo;</em>";
        sendToAllPersonalized(recipients, subject,
                recipient -> buildReminderTemplate(recipient, task, note));
    }

    /**
     * Gửi email REMINDER khi một work item được đánh dấu hoàn thành.
     *
     * @param completedBy người hoàn thành
     * @param recipients  danh sách người nhận
     */
    public void notifySubtaskCompleted(Task task, TaskComment subtask,
            User completedBy, Collection<User> recipients) {
        if (task == null || subtask == null || isEmpty(recipients))
            return;

        String from = esc(displayName(completedBy));
        String subject = "[Work Item Done] " + safe(task.getTitle());
        String note = "<strong>" + from + "</strong> completed the work item: "
                + "<em>&ldquo;" + esc(truncate(subtask.getContent(), 200)) + "&rdquo;</em>";
        sendToAllPersonalized(recipients, subject,
                recipient -> buildReminderTemplate(recipient, task, note));
    }

    // =========================================================================
    // TEMPLATE BUILDERS – mỗi phương thức render một template HTML hoàn chỉnh
    // =========================================================================

    /**
     * TEMPLATE 1 – ASSIGNED
     * 
     * <pre>
     * Hello [User Name],
     * You have been assigned a new task in the system.
     * Task details:
     *   * Task name:   [Task title]
     *   * Assigned by: [Manager / Team leader name]
     *   * Priority:    [High / Medium / Low]
     *   * Due date:    [Deadline]
     *   * Description: [Short description]
     * Please click the link below to view the task and update your progress: [Task link]
     * Kindly check it and start working as soon as possible.
     * Best regards, CRM System
     * </pre>
     */
    private String buildAssignedTemplate(User recipient, Task task, User assignedBy) {
        String name = esc(displayName(recipient));
        String taskName = esc(safe(task.getTitle()));
        String assignerName = esc(displayName(assignedBy));
        String priority = esc(safe(task.getPriority()));
        String dueDate = task.getDueDate() != null
                ? esc(task.getDueDate().toString().replace('T', ' '))
                : "Not set";
        String description = (task.getDescription() != null && !task.getDescription().isBlank())
                ? esc(truncate(task.getDescription(), 300))
                : "No description provided.";
        String taskLink = buildTaskLink(task);

        String content = greeting(name)
                + para("You have been assigned a new task in the system.")
                + sectionHeader("Task Details")
                + bulletList(
                        bullet("Task name", taskName),
                        bullet("Assigned by", assignerName),
                        bullet("Priority", priority),
                        bullet("Due date", dueDate),
                        bullet("Description", description))
                + para("Please click the link below to view the task and update your progress:")
                + ctaButton(taskLink, "View Task")
                + para("Kindly check it and start working as soon as possible.");

        return wrapLayout("New Task Assigned", "#2563eb", content);
    }

    /**
     * TEMPLATE 2 – CRUD
     * 
     * <pre>
     * Hello [User Name],
     * A task that you are responsible for has been updated.
     * Updated information:
     *   * Task name:  [Task title]
     *   * Updated by: [User who updated the task]
     *   * Changes:    [Description of changes]
     * You can view the updated task here: [Task link]
     * Please review the changes to avoid missing the deadline.
     * Best regards, CRM System
     * </pre>
     */
    private String buildCrudTemplate(User recipient, Task task, User updatedBy,
            String changeDesc) {
        String name = esc(displayName(recipient));
        String taskName = esc(safe(task.getTitle()));
        String updaterName = esc(displayName(updatedBy));
        String taskLink = buildTaskLink(task);

        String content = greeting(name)
                + para("A task that you are responsible for has been updated.")
                + sectionHeader("Updated Information")
                + bulletList(
                        bullet("Task name", taskName),
                        bullet("Updated by", updaterName),
                        bulletRaw("Changes", changeDesc))
                + para("You can view the updated task here:")
                + ctaButton(taskLink, "View Task")
                + para("Please review the changes to avoid missing the deadline.");

        return wrapLayout("Task Update Notification", "#0f766e", content);
    }

    /**
     * TEMPLATE 3 – REMINDER
     * 
     * <pre>
     * Hello [User Name],
     * This is a reminder that [reminderNote].
     * Task details:
     *   * Task name:      [Task title]
     *   * Due date:       [Deadline]
     *   * Current status: [Status]
     * Please make sure to complete the task before the deadline.
     * Click here to view the task: [Task link]
     * Best regards, CRM System
     * </pre>
     */
    private String buildReminderTemplate(User recipient, Task task, String reminderNote) {
        String name = esc(displayName(recipient));
        String taskName = esc(safe(task.getTitle()));
        String dueDate = task.getDueDate() != null
                ? esc(task.getDueDate().toString().replace('T', ' '))
                : "Not set";
        String status = esc(safe(task.getStatus()));
        String taskLink = buildTaskLink(task);

        String content = greeting(name)
                + para("This is a reminder that " + reminderNote)
                + sectionHeader("Task Details")
                + bulletList(
                        bullet("Task name", taskName),
                        bullet("Due date", dueDate),
                        bullet("Current status", status))
                + para("Please make sure to complete the task before the deadline.")
                + para("Click here to view the task:")
                + ctaButton(taskLink, "View Task");

        return wrapLayout("Task Reminder", "#dc2626", content);
    }

    // =========================================================================
    // HTML COMPONENT HELPERS
    // =========================================================================

    /** Bọc nội dung trong layout HTML responsive hoàn chỉnh. */
    private static String wrapLayout(String headerTitle, String accentColor, String content) {
        return "<!DOCTYPE html>"
                + "<html lang='en'><head><meta charset='UTF-8'>"
                + "<meta name='viewport' content='width=device-width,initial-scale=1'>"
                + "<title>" + esc(headerTitle) + "</title></head>"
                + "<body style='margin:0;padding:0;background:#f1f5f9;"
                + "font-family:Arial,Helvetica,sans-serif;'>"
                + "<table width='100%' cellpadding='0' cellspacing='0' border='0'>"
                + "<tr><td align='center' style='padding:32px 16px;'>"
                + "<table width='600' cellpadding='0' cellspacing='0' border='0'"
                + " style='max-width:600px;width:100%;background:#ffffff;"
                + "border-radius:12px;overflow:hidden;"
                + "box-shadow:0 2px 8px rgba(0,0,0,0.08);'>"

                // ── Header bar ──
                + "<tr><td style='background:" + accentColor + ";padding:20px 28px;'>"
                + "<p style='margin:0;font-size:11px;font-weight:600;"
                + "color:rgba(255,255,255,0.75);text-transform:uppercase;letter-spacing:1px;'>"
                + "CRM System</p>"
                + "<h1 style='margin:4px 0 0;font-size:20px;font-weight:700;color:#ffffff;'>"
                + esc(headerTitle) + "</h1>"
                + "</td></tr>"

                // ── Content area ──
                + "<tr><td style='padding:28px 28px 8px;'>"
                + content
                + "</td></tr>"

                // ── Footer ──
                + "<tr><td style='background:#f8fafc;padding:16px 28px;"
                + "border-top:1px solid #e2e8f0;'>"
                + "<p style='margin:0;font-size:13px;color:#64748b;line-height:1.6;'>"
                + "Best regards,<br>"
                + "<strong style='color:#1e293b;'>CRM System</strong>"
                + "</p>"
                + "<p style='margin:8px 0 0;font-size:11px;color:#cbd5e1;'>"
                + "You received this email because you are associated with this task. "
                + "Please do not reply directly to this email."
                + "</p>"
                + "</td></tr>"

                + "</table></td></tr></table>"
                + "</body></html>";
    }

    private static String greeting(String escapedName) {
        return "<p style='margin:0 0 16px;font-size:15px;color:#1e293b;'>"
                + "Hello <strong>" + escapedName + "</strong>,</p>";
    }

    private static String para(String html) {
        return "<p style='margin:0 0 16px;font-size:14px;color:#475569;line-height:1.6;'>"
                + html + "</p>";
    }

    private static String sectionHeader(String label) {
        return "<p style='margin:0 0 8px;font-size:12px;font-weight:700;color:#64748b;"
                + "text-transform:uppercase;letter-spacing:0.8px;'>" + esc(label) + ":</p>";
    }

    private static String bulletList(String... rows) {
        StringBuilder sb = new StringBuilder(
                "<ul style='margin:0 0 20px;padding:0;list-style:none;"
                        + "background:#f8fafc;border-radius:8px;padding:14px 18px;'>");
        for (String row : rows)
            sb.append(row);
        sb.append("</ul>");
        return sb.toString();
    }

    /** Bullet row: value được HTML-escape từ trước. */
    private static String bullet(String label, String escapedValue) {
        return "<li style='padding:5px 0;font-size:14px;color:#334155;line-height:1.5;'>"
                + "<span style='color:#94a3b8;display:inline-block;width:110px;"
                + "font-size:13px;'>* " + esc(label) + ":</span>"
                + "<strong style='color:#1e293b;'>" + escapedValue + "</strong>"
                + "</li>";
    }

    /** Bullet row: value là raw HTML (ví dụ changeDesc đã chứa <strong>). */
    private static String bulletRaw(String label, String rawHtml) {
        return "<li style='padding:5px 0;font-size:14px;color:#334155;line-height:1.5;'>"
                + "<span style='color:#94a3b8;display:inline-block;width:110px;"
                + "font-size:13px;'>* " + esc(label) + ":</span>"
                + "<strong style='color:#1e293b;'>"
                + (rawHtml != null ? rawHtml : "") + "</strong>"
                + "</li>";
    }

    /** Nút CTA xanh + plain-text fallback link. */
    private static String ctaButton(String url, String label) {
        return "<div style='text-align:center;margin:20px 0 16px;'>"
                + "<a href='" + url + "'"
                + " style='display:inline-block;padding:12px 36px;background:#2563eb;"
                + "color:#ffffff;text-decoration:none;font-size:14px;font-weight:600;"
                + "border-radius:6px;letter-spacing:0.3px;'>"
                + esc(label) + "</a>"
                + "</div>"
                + "<p style='text-align:center;margin:0 0 20px;font-size:12px;color:#94a3b8;'>"
                + "Or copy this link: <a href='" + url
                + "' style='color:#3b82f6;word-break:break-all;'>" + url + "</a>"
                + "</p>";
    }

    // =========================================================================
    // SEND HELPERS
    // =========================================================================

    // ── Rate Limiter ──────────────────────────────────────────────────────────
    //
    // Gmail giới hạn: 500 email/ngày (tài khoản thường), 2000/ngày (Workspace).
    // Chúng ta đặt ngưỡng an toàn thấp hơn (mặc định 400/ngày, ~16/giờ).
    //
    // Cơ chế:
    // 1. HOURLY_LIMIT – token bucket theo giờ, reset mỗi giờ bởi scheduler
    // 2. DAILY_LIMIT – đếm tổng, reset lúc nửa đêm bởi scheduler
    // 3. Circuit breaker – khi nhận SMTPSendFailedException do rate-limit,
    // dừng gửi thêm 60 phút để tránh lãng phí retry
    //
    // Cấu hình qua System Property:
    // -Demail.daily.limit=400
    // -Demail.hourly.limit=30

    private static final int DAILY_LIMIT = Integer.getInteger("email.daily.limit", 400);
    private static final int HOURLY_LIMIT = Integer.getInteger("email.hourly.limit", 30);

    /** Số email đã gửi trong giờ hiện tại. */
    private static final java.util.concurrent.atomic.AtomicInteger hourlySent = new java.util.concurrent.atomic.AtomicInteger(
            0);
    /** Số email đã gửi trong ngày hiện tại. */
    private static final java.util.concurrent.atomic.AtomicInteger dailySent = new java.util.concurrent.atomic.AtomicInteger(
            0);

    /**
     * Circuit-breaker timestamp: nếu > System.currentTimeMillis()
     * thì đang trong trạng thái "tạm dừng gửi".
     */
    private static final java.util.concurrent.atomic.AtomicLong circuitOpenUntil = new java.util.concurrent.atomic.AtomicLong(
            0L);

    /** Circuit-breaker pause = 60 phút khi bị Gmail rate-limit. */
    private static final long CIRCUIT_PAUSE_MS = 60 * 60 * 1_000L;

    static {
        // Reset bộ đếm giờ mỗi 60 phút
        java.util.concurrent.Executors
                .newSingleThreadScheduledExecutor(r -> {
                    Thread t = new Thread(r, "email-rate-reset-hourly");
                    t.setDaemon(true);
                    return t;
                })
                .scheduleAtFixedRate(
                        () -> {
                            int prev = hourlySent.getAndSet(0);
                            if (prev > 0)
                                LOG.info("TaskEmailService: hourly counter reset (sent=" + prev + ")");
                        },
                        60, 60, java.util.concurrent.TimeUnit.MINUTES);

        // Reset bộ đếm ngày mỗi 24 giờ (lúc deploy hoặc nửa đêm)
        java.util.concurrent.Executors
                .newSingleThreadScheduledExecutor(r -> {
                    Thread t = new Thread(r, "email-rate-reset-daily");
                    t.setDaemon(true);
                    return t;
                })
                .scheduleAtFixedRate(
                        () -> {
                            int prev = dailySent.getAndSet(0);
                            LOG.info("TaskEmailService: daily counter reset (sent=" + prev + ")");
                        },
                        24, 24, java.util.concurrent.TimeUnit.HOURS);
    }

    /**
     * Kiểm tra xem có thể gửi email không.
     * 
     * @return true nếu còn quota và circuit chưa mở
     */
    private static boolean canSend() {
        // Circuit breaker đang mở?
        if (System.currentTimeMillis() < circuitOpenUntil.get()) {
            LOG.warning("TaskEmailService: circuit breaker OPEN – email suppressed until "
                    + new java.util.Date(circuitOpenUntil.get()));
            return false;
        }
        // Vượt ngưỡng ngày?
        if (dailySent.get() >= DAILY_LIMIT) {
            LOG.warning("TaskEmailService: DAILY limit reached (" + DAILY_LIMIT
                    + "). Email suppressed.");
            return false;
        }
        // Vượt ngưỡng giờ?
        if (hourlySent.get() >= HOURLY_LIMIT) {
            LOG.warning("TaskEmailService: HOURLY limit reached (" + HOURLY_LIMIT
                    + "). Email suppressed until next hour.");
            return false;
        }
        return true;
    }

    /**
     * Ghi nhận một email đã gửi thành công vào bộ đếm.
     */
    private static void recordSent() {
        hourlySent.incrementAndGet();
        dailySent.incrementAndGet();
    }

    /**
     * Xử lý lỗi SMTP – phát hiện lỗi rate-limit của Gmail và mở circuit breaker.
     */
    private static void handleSendFailure(Exception e, String to, String subject) {
        String msg = e.getMessage() != null ? e.getMessage() : "";
        if (msg.contains("550-5.4.5") || msg.contains("Daily user sending limit")
                || msg.contains("rate limit") || msg.contains("4.7.28")) {
            // Gmail rate-limit → mở circuit breaker 60 phút
            long openUntil = System.currentTimeMillis() + CIRCUIT_PAUSE_MS;
            circuitOpenUntil.set(openUntil);
            LOG.severe("TaskEmailService: Gmail RATE LIMIT hit! Circuit breaker opened for 60 min. "
                    + "Email to [" + to + "] dropped. Subject: " + subject);
        } else {
            LOG.log(Level.WARNING,
                    "TaskEmailService: failed sending to [" + to + "] subject: " + subject, e);
        }
    }

    // ── Send strategies ───────────────────────────────────────────────────────

    /** Functional interface để build nội dung email riêng cho từng recipient. */
    @FunctionalInterface
    private interface BodyBuilder {
        String build(User recipient);
    }

    /**
     * Gửi email GROUP qua BCC:
     * Thay vì N email riêng lẻ → chỉ 1 email duy nhất với:
     * TO = recipient đầu tiên có email
     * BCC = tất cả recipient còn lại
     *
     * Lời chào sẽ là "Hello Team," thay vì tên cá nhân.
     * Dùng cho các sự kiện CRUD/REMINDER có nhiều người nhận.
     *
     * Tiết kiệm quota: 10 assignees = 1 email thay vì 10.
     */
    private void sendToAllPersonalized(Collection<User> recipients,
            String subject, BodyBuilder bodyBuilder) {
        if (isEmpty(recipients))
            return;

        // Lọc những người có email hợp lệ, bỏ trùng
        java.util.List<User> valid = recipients.stream()
                .filter(this::hasEmail)
                .distinct()
                .collect(java.util.stream.Collectors.toList());

        if (valid.isEmpty())
            return;

        if (valid.size() == 1) {
            // Chỉ 1 người → gửi cá nhân hóa bình thường
            User u = valid.get(0);
            sendAsync(u.getEmail(), null, subject, bodyBuilder.build(u));
        } else {
            // Nhiều người → BCC: 1 lần gửi, tiết kiệm quota
            // Body dùng tên người đầu tiên + note "và các thành viên khác"
            User primary = valid.get(0);
            String to = primary.getEmail();
            String bcc = valid.stream()
                    .skip(1)
                    .map(User::getEmail)
                    .collect(java.util.stream.Collectors.joining(","));
            // Build body với lời chào chung (không nêu tên riêng)
            String body = bodyBuilder.build(buildTeamUser());
            sendAsync(to, bcc, subject, body);
        }
    }

    /**
     * Tạo một User giả "Team" dùng cho lời chào chung khi gửi BCC.
     * Email được render với "Hello Team Member," thay vì tên riêng.
     */
    private static User buildTeamUser() {
        User team = new User();
        team.setFullName("Team Member");
        return team;
    }

    /**
     * Gửi một email đơn bất đồng bộ (TO duy nhất, không BCC).
     * Dùng cho ASSIGNED template – cá nhân hóa đầy đủ.
     */
    private void sendAsync(String to, String subject, String htmlBody) {
        sendAsync(to, null, subject, htmlBody);
    }

    /**
     * Gửi email bất đồng bộ với optional BCC.
     * Kiểm tra rate limit & circuit breaker trước khi submit vào pool.
     *
     * @param to       địa chỉ TO (bắt buộc)
     * @param bcc      địa chỉ BCC phân cách bởi dấu phẩy (nullable)
     * @param subject  tiêu đề email
     * @param htmlBody nội dung HTML
     */
    private void sendAsync(String to, String bcc, String subject, String htmlBody) {
        if (to == null || to.isBlank())
            return;

        // Kiểm tra rate limit TRƯỚC KHI đưa vào queue
        // (tránh tích lũy task trong pool khi đã biết sẽ bị reject)
        if (!canSend()) {
            LOG.warning("TaskEmailService: email suppressed (rate limit / circuit breaker). "
                    + "To=[" + to + "] Subject=" + subject);
            return;
        }

        Email email = new Email()
                .setTo(to)
                .setSubject(subject)
                .setBodyHtml(htmlBody);
        if (bcc != null && !bcc.isBlank()) {
            email.setBcc(bcc);
        }

        POOL.submit(() -> {
            // Kiểm tra lại bên trong worker (có thể đã thay đổi khi chờ trong queue)
            if (!canSend()) {
                LOG.warning("TaskEmailService: worker dropped email – limit exceeded. To=[" + to + "]");
                return;
            }
            try {
                boolean ok = EmailService.send(email);
                if (ok) {
                    recordSent();
                    LOG.fine("TaskEmailService: sent OK to [" + to + "]"
                            + (bcc != null && !bcc.isBlank() ? " BCC=[" + bcc + "]" : ""));
                }
            } catch (Exception e) {
                handleSendFailure(e, to, subject);
            }
        });
    }

    // =========================================================================
    // UTILITY
    // =========================================================================

    private static String buildTaskLink(Task task) {
        if (task == null || task.getTaskId() == null)
            return APP_BASE_URL;
        return APP_BASE_URL + "/tasks/details?id=" + task.getTaskId();
    }

    private boolean hasEmail(User u) {
        return u != null && u.getEmail() != null && !u.getEmail().isBlank();
    }

    private static boolean isEmpty(Collection<?> c) {
        return c == null || c.isEmpty();
    }

    private static String safe(String s) {
        return s != null ? s : "";
    }

    /** HTML-escape, an toàn với mọi input. */
    private static String esc(String s) {
        if (s == null)
            return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private static String displayName(User u) {
        if (u == null)
            return "Someone";
        String full = u.getFullName();
        return (full != null && !full.isBlank()) ? full : safe(u.getUsername());
    }

    private static String truncate(String s, int max) {
        if (s == null)
            return "";
        return s.length() <= max ? s : s.substring(0, max) + "…";
    }
}