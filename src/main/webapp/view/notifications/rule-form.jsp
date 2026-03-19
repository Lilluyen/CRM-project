<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="java.time.format.DateTimeFormatter, java.util.List, model.NotificationRuleEngine, model.User" %>
<%
    NotificationRuleEngine rule = (NotificationRuleEngine) request.getAttribute("rule");
    @SuppressWarnings("unchecked")
    List<User> allUsers = (List<User>) request.getAttribute("allUsers");
    if (allUsers == null) allUsers = new java.util.ArrayList<>();

    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
    String nextRunVal = "";
    if (rule != null && rule.getNextRunAt() != null) {
        nextRunVal = rule.getNextRunAt().format(dtf);
    }
    boolean isEdit = rule != null && rule.getRuleId() > 0;

    String ruleType = rule != null && rule.getRuleType() != null ? rule.getRuleType() : "";
    String recipientType = rule != null && rule.getRecipientType() != null ? rule.getRecipientType() : "";
    String priority = rule != null && rule.getNotificationPriority() != null ? rule.getNotificationPriority() : "normal";
    String condUnit = rule != null && rule.getConditionUnit() != null ? rule.getConditionUnit() : "";
    String condOp = rule != null && rule.getConditionOperator() != null ? rule.getConditionOperator() : "";
    String entityType = rule != null && rule.getEntityType() != null ? rule.getEntityType() : "";
    String condField = rule != null && rule.getConditionField() != null ? rule.getConditionField() : "";
    String error = (String) request.getAttribute("error");
%>

<div class="content">
  <div class="page-header">
    <div class="page-title">
      <h4><%= isEdit ? "Edit Alarm Rule" : "Create Alarm Rule" %></h4>
      <h6>Configure notification rules like an alarm clock</h6>
    </div>
    <div class="d-flex gap-2">
      <a href="${pageContext.request.contextPath}/notifications/rules" class="btn btn-outline-secondary btn-sm">
        <i class="fa fa-arrow-left me-1"></i>Back to list
      </a>
    </div>
  </div>

  <% if (error != null) { %>
    <div class="alert alert-danger"><%= error %></div>
  <% } %>

  <form method="post" action="${pageContext.request.contextPath}/notifications/rules/manage" id="ruleForm">
    <% if (isEdit) { %>
      <input type="hidden" name="ruleId" value="<%= rule.getRuleId() %>" />
    <% } %>

    <div class="row">
      <!-- LEFT: Basic Info -->
      <div class="col-lg-6">
        <div class="card">
          <div class="card-header"><h6 class="mb-0"><i class="fas fa-info-circle me-1"></i>Basic Information</h6></div>
          <div class="card-body">
            <div class="mb-3">
              <label class="form-label">Rule Name <span class="text-danger">*</span></label>
              <input type="text" name="ruleName" class="form-control" required
                     value="<%= rule != null && rule.getRuleName() != null ? rule.getRuleName().replace("\"", "&quot;") : "" %>"
                     placeholder="e.g., Daily Task Reminder" />
            </div>

            <div class="mb-3">
              <label class="form-label">Rule Type <span class="text-danger">*</span></label>
              <select name="ruleType" id="ruleType" class="form-select" onchange="toggleRuleTypeFields()">
                <option value="schedule" <%= "schedule".equalsIgnoreCase(ruleType) ? "selected" : "" %>>Schedule (Recurring)</option>
                <option value="condition" <%= "condition".equalsIgnoreCase(ruleType) ? "selected" : "" %>>Condition (Business Rule)</option>
                <option value="event_trigger" <%= "event_trigger".equalsIgnoreCase(ruleType) ? "selected" : "" %>>Event Trigger (Realtime)</option>
              </select>
              <div class="form-text">
                <strong>Schedule:</strong> Runs at regular intervals (like alarm)<br>
                <strong>Condition:</strong> Runs when condition is met<br>
                <strong>Event Trigger:</strong> Runs immediately when event occurs
              </div>
            </div>

            <div class="mb-3">
              <label class="form-label">Description</label>
              <textarea name="description" class="form-control" rows="2"
                        placeholder="Optional description"><%= rule != null && rule.getDescription() != null ? rule.getDescription() : "" %></textarea>
            </div>

            <div class="mb-3">
              <label class="form-label">Active</label>
              <div class="form-check form-switch">
                <input class="form-check-input" type="checkbox" name="active" id="active"
                       <%= rule == null || rule.isActive() ? "checked" : "" %> />
                <label class="form-check-label" for="active">Rule is active</label>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- RIGHT: Notification Template -->
      <div class="col-lg-6">
        <div class="card">
          <div class="card-header"><h6 class="mb-0"><i class="fas fa-bell me-1"></i>Notification Content</h6></div>
          <div class="card-body">
            <div class="mb-3">
              <label class="form-label">Notification Title <span class="text-danger">*</span></label>
              <input type="text" name="notificationTitle" class="form-control" required
                     value="<%= rule != null && rule.getNotificationTitleTemplate() != null ? rule.getNotificationTitleTemplate().replace("\"", "&quot;") : "" %>"
                     placeholder="e.g., Task Reminder" />
            </div>

            <div class="mb-3">
              <label class="form-label">Notification Content</label>
              <textarea name="notificationContent" class="form-control" rows="3"
                        placeholder="Message content..."><%= rule != null && rule.getNotificationContentTemplate() != null ? rule.getNotificationContentTemplate() : "" %></textarea>
            </div>

            <div class="row">
              <div class="col-md-6 mb-3">
                <label class="form-label">Type</label>
                <select name="notificationType" class="form-select">
                  <option value="info" <%= "info".equalsIgnoreCase(rule != null ? rule.getNotificationType() : "") ? "selected" : "" %>>Info</option>
                  <option value="warning" <%= "warning".equalsIgnoreCase(rule != null ? rule.getNotificationType() : "") ? "selected" : "" %>>Warning</option>
                  <option value="alert" <%= "alert".equalsIgnoreCase(rule != null ? rule.getNotificationType() : "") ? "selected" : "" %>>Alert</option>
                  <option value="reminder" <%= "reminder".equalsIgnoreCase(rule != null ? rule.getNotificationType() : "") ? "selected" : "" %>>Reminder</option>
                </select>
              </div>
              <div class="col-md-6 mb-3">
                <label class="form-label">Priority</label>
                <select name="notificationPriority" class="form-select">
                  <option value="low" <%= "low".equalsIgnoreCase(priority) ? "selected" : "" %>>Low</option>
                  <option value="normal" <%= "normal".equalsIgnoreCase(priority) ? "selected" : "" %>>Normal</option>
                  <option value="high" <%= "high".equalsIgnoreCase(priority) ? "selected" : "" %>>High</option>
                  <option value="urgent" <%= "urgent".equalsIgnoreCase(priority) ? "selected" : "" %>>Urgent</option>
                </select>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- ROW 2: Condition / Schedule -->
    <div class="row mt-3">
      <div class="col-lg-6">
        <div class="card" id="scheduleCard">
          <div class="card-header"><h6 class="mb-0"><i class="fas fa-clock me-1"></i>Schedule / Condition</h6></div>
          <div class="card-body">
            <!-- Schedule fields -->
            <div id="scheduleFields">
              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="form-label">Interval Value</label>
                  <input type="number" name="conditionValue" class="form-control" min="1"
                         value="<%= rule != null && rule.getConditionValue() != null ? rule.getConditionValue() : "1" %>"
                         placeholder="e.g., 1" />
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label">Interval Unit</label>
                  <select name="conditionUnit" class="form-select">
                    <option value="minute" <%= "minute".equalsIgnoreCase(condUnit) ? "selected" : "" %>>Minutes</option>
                    <option value="hour" <%= "hour".equalsIgnoreCase(condUnit) ? "selected" : "" %>>Hours</option>
                    <option value="day" <%= "day".equalsIgnoreCase(condUnit) || "".equals(condUnit) ? "selected" : "" %>>Days</option>
                    <option value="week" <%= "week".equalsIgnoreCase(condUnit) ? "selected" : "" %>>Weeks</option>
                    <option value="month" <%= "month".equalsIgnoreCase(condUnit) ? "selected" : "" %>>Months</option>
                  </select>
                </div>
              </div>
            </div>

            <!-- Event trigger fields -->
            <div id="eventFields" style="display:none;">
              <div class="mb-3">
                <label class="form-label">Trigger Event</label>
                <select name="triggerEvent" class="form-select">
                  <option value="">-- Select Event --</option>
                  <option value="task_created" <%= "task_created".equalsIgnoreCase(rule != null ? rule.getTriggerEvent() : "") ? "selected" : "" %>>Task Created</option>
                  <option value="task_completed" <%= "task_completed".equalsIgnoreCase(rule != null ? rule.getTriggerEvent() : "") ? "selected" : "" %>>Task Completed</option>
                  <option value="task_overdue" <%= "task_overdue".equalsIgnoreCase(rule != null ? rule.getTriggerEvent() : "") ? "selected" : "" %>>Task Overdue</option>
                  <option value="task_assigned" <%= "task_assigned".equalsIgnoreCase(rule != null ? rule.getTriggerEvent() : "") ? "selected" : "" %>>Task Assigned</option>
                  <option value="deal_created" <%= "deal_created".equalsIgnoreCase(rule != null ? rule.getTriggerEvent() : "") ? "selected" : "" %>>Deal Created</option>
                  <option value="deal_won" <%= "deal_won".equalsIgnoreCase(rule != null ? rule.getTriggerEvent() : "") ? "selected" : "" %>>Deal Won</option>
                  <option value="lead_created" <%= "lead_created".equalsIgnoreCase(rule != null ? rule.getTriggerEvent() : "") ? "selected" : "" %>>Lead Created</option>
                </select>
              </div>
            </div>

            <!-- Condition fields -->
            <div id="conditionFields" style="display:none;">
              <div class="mb-3">
                <label class="form-label">Entity Type</label>
                <select name="entityType" class="form-select">
                  <option value="">-- Select Entity --</option>
                  <option value="task" <%= "task".equalsIgnoreCase(entityType) ? "selected" : "" %>>Task</option>
                  <option value="deal" <%= "deal".equalsIgnoreCase(entityType) ? "selected" : "" %>>Deal</option>
                  <option value="lead" <%= "lead".equalsIgnoreCase(entityType) ? "selected" : "" %>>Lead</option>
                  <option value="customer" <%= "customer".equalsIgnoreCase(entityType) ? "selected" : "" %>>Customer</option>
                </select>
              </div>
              <div class="mb-3">
                <label class="form-label">Condition Field</label>
                <input type="text" name="conditionField" class="form-control"
                       value="<%= condField %>"
                       placeholder="e.g., due_date, status, priority" />
              </div>
              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="form-label">Operator</label>
                  <select name="conditionOperator" class="form-select">
                    <option value="">-- Select --</option>
                    <option value="=" <%= "=".equals(condOp) ? "selected" : "" %>>Equal (=)</option>
                    <option value="!=" <%= "!=".equals(condOp) ? "selected" : "" %>>Not Equal (!=)</option>
                    <option value=">" <%= ">".equals(condOp) ? "selected" : "" %>>Greater Than (>)</option>
                    <option value="<" <%= "<".equals(condOp) ? "selected" : "" %>>Less Than (<)</option>
                    <option value=">=" <%= ">=".equals(condOp) ? "selected" : "" %>>Greater or Equal (>=)</option>
                    <option value="<=" <%= "<=".equals(condOp) ? "selected" : "" %>>Less or Equal (<=)</option>
                  </select>
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label">Value</label>
                  <input type="number" name="conditionValue" class="form-control"
                         value="<%= rule != null && rule.getConditionValue() != null ? rule.getConditionValue() : "" %>" />
                </div>
              </div>
            </div>

            <div class="mb-3">
              <label class="form-label">Next Run</label>
              <input type="datetime-local" name="nextRun" class="form-control" value="<%= nextRunVal %>" />
              <div class="form-text">Leave empty for immediate execution (for event_trigger type)</div>
            </div>
          </div>
        </div>
      </div>

      <div class="col-lg-6">
        <div class="card">
          <div class="card-header"><h6 class="mb-0"><i class="fas fa-users me-1"></i>Recipients & Escalation</h6></div>
          <div class="card-body">
            <div class="mb-3">
              <label class="form-label">Recipient Type</label>
              <select name="recipientType" id="recipientType" class="form-select" onchange="toggleRecipientFields()">
                <option value="">-- Select --</option>
                <option value="specific_user" <%= "specific_user".equalsIgnoreCase(recipientType) ? "selected" : "" %>>Specific User</option>
                <option value="owner" <%= "owner".equalsIgnoreCase(recipientType) ? "selected" : "" %>>Owner</option>
                <option value="assignee" <%= "assignee".equalsIgnoreCase(recipientType) ? "selected" : "" %>>Assignee</option>
                <option value="manager" <%= "manager".equalsIgnoreCase(recipientType) ? "selected" : "" %>>Manager</option>
              </select>
            </div>

            <div id="specificUserField" class="mb-3" style="display:none;">
              <label class="form-label">Select User</label>
              <select name="recipientUserId" class="form-select">
                <option value="">-- Select User --</option>
                <% for (User u : allUsers) {
                     String uName = (u.getFullName() != null && !u.getFullName().isBlank()) ? u.getFullName() : u.getUsername();
                     boolean selected = rule != null && rule.getRecipientUserId() != null && rule.getRecipientUserId() == u.getUserId();
                %>
                  <option value="<%= u.getUserId() %>" <%= selected ? "selected" : "" %>><%= uName %></option>
                <% } %>
              </select>
            </div>

            <hr/>

            <div class="mb-3">
              <label class="form-label">Escalate After (minutes)</label>
              <input type="number" name="escalateAfterMinutes" class="form-control" min="0"
                     value="<%= rule != null && rule.getEscalateAfterMinutes() != null ? rule.getEscalateAfterMinutes() : "" %>"
                     placeholder="e.g., 30" />
              <div class="form-text">If no action taken, escalate after X minutes</div>
            </div>

            <div class="mb-3">
              <label class="form-label">Escalate To User</label>
              <select name="escalateToUserId" class="form-select">
                <option value="">-- Select Escalation User --</option>
                <% for (User u : allUsers) {
                     String uName = (u.getFullName() != null && !u.getFullName().isBlank()) ? u.getFullName() : u.getUsername();
                     boolean selected = rule != null && rule.getEscalateToUserId() != null && rule.getEscalateToUserId() == u.getUserId();
                %>
                  <option value="<%= u.getUserId() %>" <%= selected ? "selected" : "" %>><%= uName %></option>
                <% } %>
              </select>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Submit -->
    <div class="row mt-3 mb-4">
      <div class="col-12 text-end">
        <button type="submit" class="btn btn-primary btn-lg">
          <i class="fas fa-save me-1"></i><%= isEdit ? "Update Rule" : "Create Rule" %>
        </button>
      </div>
    </div>
  </form>
</div>

<script>
function toggleRuleTypeFields() {
    var type = document.getElementById('ruleType').value;
    document.getElementById('scheduleFields').style.display = (type === 'schedule') ? 'block' : 'none';
    document.getElementById('conditionFields').style.display = (type === 'condition') ? 'block' : 'none';
    document.getElementById('eventFields').style.display = (type === 'event_trigger') ? 'block' : 'none';
}

function toggleRecipientFields() {
    var type = document.getElementById('recipientType').value;
    document.getElementById('specificUserField').style.display = (type === 'specific_user') ? 'block' : 'none';
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', function() {
    toggleRuleTypeFields();
    toggleRecipientFields();
});
</script>
