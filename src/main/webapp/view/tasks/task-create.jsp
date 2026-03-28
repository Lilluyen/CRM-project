<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="model.User, java.util.List" %>
<%
  boolean isManager   = Boolean.TRUE.equals(request.getAttribute("isManager"));
  User    currentUser = (User) session.getAttribute("user");

  // Get users from server-side (loaded by controller for managers)
  List<User> allUsers = (List<User>) request.getAttribute("allUsers");
  if (allUsers == null) allUsers = java.util.Collections.emptyList();
%>
<div><div class="content">

        <div class="page-header">
            <div class="page-title"><h4>Create Task</h4><h6>Add a new task</h6></div>
            <a href="${pageContext.request.contextPath}/tasks/list" class="btn btn-outline-secondary">
                <i class="fa fa-arrow-left me-1"></i>Back to List</a>
        </div>

        <c:if test="${not empty error}">
            <div class="alert alert-danger">${fn:escapeXml(error)}</div>
        </c:if>

        <div class="card"><div class="card-body">
                <form method="post" action="${pageContext.request.contextPath}/tasks/create">
                    <input type="hidden" name="progress" value="0">

                    <div class="row g-3">
                        <div class="col-md-8">
                            <label for="taskTitle" class="form-label fw-semibold">Title <span class="text-danger">*</span></label>
                            <input type="text" id="taskTitle" name="title" class="form-control" required maxlength="200" placeholder="Enter task title">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Priority</label>
                            <select name="priority" class="form-select">
                                <option value="Low">Low</option>
                                <option value="Medium" selected>Medium</option>
                                <option value="High">High</option>
                            </select>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold">Description</label>
                            <textarea name="description" class="form-control" rows="4" placeholder="Describe the task…"></textarea>
                        </div>

                        <div class="col-md-3">
                            <label class="form-label fw-semibold">Status</label>
                            <% if(isManager){ %>
                            <select name="status" class="form-select">
                                <option value="Pending">Pending</option>
                                <option value="In Progress" selected>In Progress</option>
                                <option value="Done">Done</option>
                                <option value="Cancelled">Cancelled</option>
                            </select>
                            <small class="text-muted d-block mt-1"><i class="fa fa-info-circle me-1"></i>Managers may set any status.</small>
                            <% }else{ %>
                            <input type="hidden" name="status" value="In Progress">
                            <div class="status-fixed"><i class="fa fa-play-circle"></i> In Progress</div>
                            <small class="text-muted d-block mt-1"><i class="fa fa-lock me-1"></i>Fixed for new tasks. Managers can change.</small>
                            <% } %>
                        </div>

                        <div class="col-md-3">
                            <label class="form-label fw-semibold">Start Date</label>
                            <input type="datetime-local" name="startDate" class="form-control">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-semibold">Due Date</label>
                            <input type="datetime-local" name="dueDate" class="form-control">
                        </div>

                        <div class="col-md-3">
                            <label class="form-label fw-semibold">Progress</label>
                            <div class="d-flex align-items-center gap-2 mt-1">
                                <div class="progress flex-grow-1" style="height:10px">
                                    <div class="progress-bar bg-secondary" style="width:0%"></div>
                                </div>
                                <small class="fw-semibold text-muted">0%</small>
                            </div>
                            <small class="text-muted d-block mt-1"><i class="fa fa-calculator me-1"></i>Auto-calculated from work items.</small>
                        </div>

                        <div class="col-12">
                            <label class="form-label fw-semibold">Assign To</label>
                            <% if(isManager){ %>
                            <div id="assignList" class="border rounded" style="max-height: 250px; overflow-y: auto;">
                                <% for(User u : allUsers) {
                                    String uName = (u.getFullName() != null && !u.getFullName().isBlank()) ? u.getFullName() : u.getUsername();
                                    String uEmail = u.getEmail() != null ? u.getEmail() : "";
                                    String initial = uName.substring(0, 1).toUpperCase();
                                    // Generate color based on name
                                    int hash = uName.hashCode();
                                    String color = String.format("#%06x", (Math.abs(hash) % 0xAAAAAA) + 0x404040);
                                %>
                                <div class="user-item" data-uid="<%= u.getUserId() %>"
                                     data-name="<%= uName.toLowerCase() %>"
                                     data-email="<%= uEmail.toLowerCase() %>"
                                     onclick="toggleUser(this)" onkeydown="if(event.key==='Enter'||event.key===' '){event.preventDefault();toggleUser(this);}"
                                     role="checkbox" aria-checked="false" tabindex="0"
                                     style="padding: 8px 12px; cursor: pointer; border-bottom: 1px solid #f1f3f5; display: flex; align-items: center; gap: 8px;">
                                    <div style="width: 32px; height: 32px; border-radius: 50%; background: <%= color %>; color: #fff; display: flex; align-items: center; justify-content: center; font-weight: 700; flex-shrink: 0;"><%= initial %></div>
                                    <div>
                                        <div class="fw-semibold" style="font-size: .88rem"><%= org.apache.taglibs.standard.functions.Functions.escapeXml(uName) %></div>
                                        <div class="text-muted" style="font-size: .78rem"><%= org.apache.taglibs.standard.functions.Functions.escapeXml(uEmail) %></div>
                                    </div>
                                    <i class="fa fa-circle text-muted ms-auto"></i>
                                </div>
                                <% } %>
                            </div>
                            <small class="text-muted d-block mt-1">Click to select assignees.</small>
                            <div id="assigneeHidden"></div>
                            <% }else{ %>
                            <div class="d-flex align-items-center gap-2 p-2 bg-light border rounded">
                                <i class="fa fa-user-circle text-primary"></i>
                                <span class="fw-semibold">
                                    <%= currentUser != null ? ((currentUser.getFullName() != null && !currentUser.getFullName().isBlank()) ? org.apache.taglibs.standard.functions.Functions.escapeXml(currentUser.getFullName()) : org.apache.taglibs.standard.functions.Functions.escapeXml(currentUser.getUsername())) : "-" %>
                                </span>
                                <span class="text-muted small">(auto-assigned to you)</span>
                            </div>
                            <% } %>
                        </div>

                        <%-- Related Entity (like activity-create.jsp) --%>
                        <div class="col-md-3">
                            <label for="taskRelatedType" class="form-label fw-semibold">Related Type</label>
                            <select name="relatedType" class="form-select" id="taskRelatedType" onchange="loadRelatedEntities()">
                                <option value="">-- None --</option>
                                <option value="CUSTOMER">Customer</option>
                                <option value="LEAD">Lead</option>
<!--                                <option value="DEAL">Deal</option>
                                <option value="TASK">Task</option>
                                <option value="CAMPAIGN">Campaign</option>
                                <option value="INTERNAL">Internal</option>-->
                            </select>
                        </div>

                        <div class="col-md-3">
                            <label for="taskRelatedId" class="form-label fw-semibold">Related Name</label>
                            <select name="relatedId" class="form-select" id="taskRelatedId" disabled>
                                <option value="">Select type first</option>
                            </select>
                        </div>

                    </div>

                    <div class="d-flex gap-2 mt-4">
                        <button type="submit" class="btn btn-primary"><i class="fa fa-save me-1"></i>Create Task</button>
                        <a href="${pageContext.request.contextPath}/tasks/list" class="btn btn-outline-secondary">Cancel</a>
                    </div>
                </form>
            </div></div>
    </div></div>

<style>
.status-fixed{
    display:inline-flex;
    align-items:center;
    gap:8px;
    padding:7px 14px;
    background:#0d6efd15;
    border:1px solid #0d6efd40;
    border-radius:6px;
    font-weight:600;
    color:#0d6efd
}
#assignList .user-item:hover{
    background:#f8f9fa
}
#assignList .user-item.selected{
    background:#e7f5ff
}
</style>

<script>
const CTX = '${pageContext.request.contextPath}';
const IS_MGR = <%= isManager %>;

function esc(s) {
    const d = document.createElement('div');
    d.textContent = s || '';
    return d.innerHTML;
}

function toggleUser(el) {
    el.classList.toggle('selected');
    const ic = el.querySelector('i.fa');
    if (ic) {
        ic.className = el.classList.contains('selected') ? 'fa fa-check-circle text-success ms-auto' : 'fa fa-circle text-muted ms-auto';
    }
    syncHidden();
}

function syncHidden() {
    const box = document.getElementById('assigneeHidden');
    if (!box) return;
    box.innerHTML = '';
    document.querySelectorAll('#assignList .user-item.selected').forEach(i => {
        const inp = document.createElement('input');
        inp.type = 'hidden';
        inp.name = 'assigneeIds';
        inp.value = i.dataset.uid;
        box.appendChild(inp);
    });
}

// Search filter
const searchInput = document.getElementById('assignSearch');
if (searchInput) {
    searchInput.addEventListener('input', function(e) {
        const q = (e.target.value || '').toLowerCase();
        document.querySelectorAll('#assignList .user-item').forEach(i => {
            const name = i.dataset.name || '';
            const email = i.dataset.email || '';
            i.style.display = (name.includes(q) || email.includes(q)) ? '' : 'none';
        });
    });
}

// Load related entities for dropdown (same as activity-create.jsp)
function loadRelatedEntities() {
    const typeSelect = document.getElementById('taskRelatedType');
    const idSelect  = document.getElementById('taskRelatedId');
    const selectedType = typeSelect.value;

    idSelect.innerHTML = '<option value="">Loading...</option>';
    idSelect.disabled = true;

    if (!selectedType) {
        idSelect.innerHTML = '<option value="">Select type first</option>';
        return;
    }
    if (selectedType === 'INTERNAL') {
        idSelect.innerHTML = '<option value="">No entities</option>';
        return;
    }

    const apiType = selectedType.toLowerCase();
    fetch(CTX + '/api/related-entities?type=' + apiType)
        .then(r => r.json())
        .then(data => {
            idSelect.innerHTML = '<option value="">-- Select --</option>';
            data.forEach(item => {
                const opt = document.createElement('option');
                opt.value = item.id;
                opt.textContent = item.name + (item.email ? ' (' + item.email + ')' : '');
                idSelect.appendChild(opt);
            });
            idSelect.disabled = false;
        })
        .catch(() => {
            idSelect.innerHTML = '<option value="">Error loading</option>';
        });
}
</script>
