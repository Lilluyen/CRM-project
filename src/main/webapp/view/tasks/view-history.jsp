<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, model.Task, model.TaskHistory, model.TaskHistoryDetail, controller.tasks.TaskViewHistoryController.HistoryView" %>
<%
    Task task = (Task) request.getAttribute("task");
    if (task == null) { response.sendError(404); return; }

    @SuppressWarnings("unchecked")
    List<HistoryView> historyViews = (List<HistoryView>) request.getAttribute("historyViews");
    if (historyViews == null) historyViews = new ArrayList<>();

    @SuppressWarnings("unchecked")
    Map<Integer, String> assigneeNames = (Map<Integer, String>) request.getAttribute("assigneeNames");
    if (assigneeNames == null) assigneeNames = new HashMap<>();

    String ctx = request.getContextPath();
%>

<style>
  .timeline-item { padding:10px 12px; border:1px solid #e9ecef; border-radius:10px; margin-bottom:10px; background:#fff; }
  .timeline-line { display:flex; gap:8px; align-items:center; }
  .timeline-time { font-weight:700; color:#0d6efd; white-space:nowrap; }
  .timeline-summary { flex:1; }
  .dropdown-list { display:inline-flex; align-items:center; justify-content:center; width:26px; height:26px;
                   border-radius:8px; border:1px solid #dee2e6; color:#212529; text-decoration:none; }
  .dropdown-list:hover { background:#f8f9fa; }
  .detail-box { margin-top:10px; padding:10px 12px; background:#f8f9fa; border-radius:10px; border:1px dashed #dee2e6; }
  .detail-row { display:flex; gap:10px; font-size:.9rem; padding:4px 0; border-bottom:1px solid rgba(0,0,0,.04); }
  .detail-row:last-child { border-bottom:0; }
  .detail-field { width:160px; color:#6c757d; font-family:ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace; }
  .detail-old { color:#dc3545; }
  .detail-new { color:#198754; }
</style>

<div class="">
  <div class="content">

    <div class="page-header">
      <div class="page-title">
        <h4>Task History</h4>
        <h6><%= task.getTitle() != null ? task.getTitle() : ("Task #" + task.getTaskId()) %></h6>
      </div>
      <div class="d-flex gap-2">
        <a href="<%= ctx %>/tasks/edit?id=<%= task.getTaskId() %>" class="btn btn-outline-warning btn-sm">
          <i class="fa fa-edit me-1"></i>Edit
        </a>
        <a href="<%= ctx %>/tasks/details?id=<%= task.getTaskId() %>" class="btn btn-outline-info btn-sm">
          <i class="fa fa-eye me-1"></i>View
        </a>
        <a href="<%= ctx %>/tasks/list" class="btn btn-outline-secondary btn-sm">
          <i class="fa fa-arrow-left me-1"></i>List
        </a>
      </div>
    </div>

    <% if (historyViews.isEmpty()) { %>
      <div class="alert alert-light border">
        <i class="fa fa-inbox me-1"></i>No change history yet.
      </div>
    <% } %>

    <div>
      <%
        for (HistoryView hv : historyViews) {
            TaskHistory h = hv.getHistory();
            int hid = h != null ? h.getHistoryId() : 0;
            List<TaskHistoryDetail> details = h != null ? h.getDetails() : null;
            if (details == null) details = new ArrayList<>();

            // Build summary labels unique-in-order
            LinkedHashSet<String> labels = new LinkedHashSet<>();
            for (TaskHistoryDetail d : details) {
                String fn = d != null ? d.getFieldName() : null;
                if (fn == null) continue;
                String key = fn.trim();
                if ("progress".equalsIgnoreCase(key)) labels.add("Update Progress");
                else if ("status".equalsIgnoreCase(key)) labels.add("Update Status");
                else if ("priority".equalsIgnoreCase(key)) labels.add("Update Priority");
                else if ("dueDate".equalsIgnoreCase(key)) labels.add("Update Due Date");
                else if ("title".equalsIgnoreCase(key)) labels.add("Update Title");
                else if ("description".equalsIgnoreCase(key)) labels.add("Update Description");
                else if ("assignee_added".equalsIgnoreCase(key) || "assignee_removed".equalsIgnoreCase(key)) labels.add("Update Assignee");
                else if ("created".equalsIgnoreCase(key)) labels.add("Created");
                else labels.add("Update " + key);
            }
            String summary = labels.isEmpty() ? "Update" : String.join(", ", labels);

            String collapseId = "hist_" + hid;
      %>
      <div class="timeline-item">
        <div class="timeline-line">
          <div class="timeline-time"><%= hv.getChangedAtDisplay() %>:</div>
          <div class="timeline-summary">
            <%= summary %>
            <% if (hv.getChangedByName() != null && !hv.getChangedByName().isBlank()) { %>
              <span class="text-muted">by <%= hv.getChangedByName() %></span>
            <% } %>
          </div>
          <a class="dropdown-list" data-bs-toggle="collapse" href="#<%= collapseId %>" role="button"
             aria-expanded="false" aria-controls="<%= collapseId %>" title="View details">
            <i class="fa fa-caret-down"></i>
          </a>
        </div>

        <div class="collapse" id="<%= collapseId %>">
          <div class="detail-box">
            <% if (details.isEmpty()) { %>
              <div class="text-muted small fst-italic">No detail.</div>
            <% } else { 
                 for (TaskHistoryDetail d : details) {
                     String fn = d.getFieldName() != null ? d.getFieldName() : "";
                     String ov = d.getOldValue() != null ? d.getOldValue() : "";
                     String nv = d.getNewValue() != null ? d.getNewValue() : "";

                     // Pretty print assignee changes
                     if ("assignee_added".equalsIgnoreCase(fn)) {
                        try {
                            int uid = Integer.parseInt(nv.trim());
                            String name = assigneeNames.getOrDefault(uid, "User#" + uid);
                            fn = "assignee_added";
                            ov = "";
                            nv = name;
                        } catch (Exception ignored) {}
                     } else if ("assignee_removed".equalsIgnoreCase(fn)) {
                        try {
                            int uid = Integer.parseInt(ov.trim());
                            String name = assigneeNames.getOrDefault(uid, "User#" + uid);
                            fn = "assignee_removed";
                            nv = "";
                            ov = name;
                        } catch (Exception ignored) {}
                     }
            %>
              <div class="detail-row">
                <div class="detail-field"><%= fn %></div>
                <div class="detail-old"><%= ov.isBlank() ? "-" : ov %></div>
                <div class="text-muted">→</div>
                <div class="detail-new"><%= nv.isBlank() ? "-" : nv %></div>
              </div>
            <%   } // end details loop
               } %>
          </div>
        </div>
      </div>
      <% } // end historyViews loop %>
    </div>
  </div>
</div>

