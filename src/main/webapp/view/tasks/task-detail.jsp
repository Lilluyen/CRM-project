<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="
         model.Task, model.TaskAssignee, model.TaskHistory, model.TaskHistoryDetail,
         model.Activity, model.User, dto.Pagination,
         controller.tasks.TaskViewHistoryController.HistoryView,
         java.util.List, java.util.ArrayList" %>
<%
    Task task = (Task) request.getAttribute("task");
    if (task == null) { response.sendError(404); return; }

    @SuppressWarnings("unchecked") List<HistoryView> historyViews =
        (List<HistoryView>) request.getAttribute("historyViews");
    if (historyViews == null) historyViews = new ArrayList<>();

    @SuppressWarnings("unchecked") List<Activity> activities =
        (List<Activity>) request.getAttribute("activities");
    if (activities == null) activities = new ArrayList<>();

    Pagination actPag = (Pagination) request.getAttribute("activityPagination");

    @SuppressWarnings("unchecked") List<User> allUsers =
        (List<User>) request.getAttribute("allUsers");
    if (allUsers == null) allUsers = new ArrayList<>();

    boolean isManager   = Boolean.TRUE.equals(request.getAttribute("isManager"));
    User    currentUser = (User) session.getAttribute("user");
    int     currentUid  = currentUser != null ? currentUser.getUserId() : 0;
    String  ctx         = request.getContextPath();

    String statusCls = "Done".equalsIgnoreCase(task.getStatus())        ? "bg-success"
                     : "In Progress".equalsIgnoreCase(task.getStatus()) ? "bg-primary"
                     : "Overdue".equalsIgnoreCase(task.getStatus())     ? "bg-danger"
                     : "Cancelled".equalsIgnoreCase(task.getStatus())   ? "bg-dark"
                     : "Reopened".equalsIgnoreCase(task.getStatus())    ? "bg-info text-dark"
                     : "bg-warning text-dark";
    String priCls = "High".equalsIgnoreCase(task.getPriority()) ? "bg-danger"
                  : "Low".equalsIgnoreCase(task.getPriority())  ? "bg-success"
                  : "bg-warning text-dark";
    boolean canReopen = isManager && (
        "Done".equalsIgnoreCase(task.getStatus()) ||
        "Cancelled".equalsIgnoreCase(task.getStatus()) ||
        "Overdue".equalsIgnoreCase(task.getStatus()));
%>
<style>
    .info-table th{
        width:140px;
        color:#6c757d;
        font-weight:600;
        vertical-align:middle
    }
    .info-table td{
        vertical-align:middle
    }
    .wi-root{
        border:1px solid #e3e8ef;
        border-radius:10px;
        margin-bottom:10px;
        background:#fff;
        overflow:hidden
    }
    .wi-done .wi-content{
        text-decoration:line-through;
        color:#adb5bd
    }
    .wi-header{
        display:flex;
        align-items:flex-start;
        gap:10px;
        padding:12px 14px
    }
    .wi-replies{
        padding:4px 14px 10px 52px
    }
    .wi-reply{
        border-left:2px solid #dee2e6;
        padding:8px 12px;
        margin-bottom:6px;
        border-radius:0 8px 8px 0;
        background:#f8f9fb
    }
    .wi-reply.r-done .wi-content{
        text-decoration:line-through;
        color:#adb5bd
    }
    .av{
        width:32px;
        height:32px;
        border-radius:50%;
        display:flex;
        align-items:center;
        justify-content:center;
        font-weight:700;
        font-size:.78rem;
        flex-shrink:0;
        color:#fff
    }
    .av-sm{
        width:24px;
        height:24px;
        font-size:.68rem
    }
    .wi-check{
        width:18px;
        height:18px;
        accent-color:#198754;
        cursor:pointer;
        flex-shrink:0;
        margin-top:3px
    }
    .assignee-badge{
        display:inline-flex;
        align-items:center;
        gap:4px;
        background:#e7f5ff;
        color:#1864ab;
        border:1px solid #74c0fc;
        border-radius:20px;
        padding:1px 8px;
        font-size:.75rem
    }
    .mention-box{
        position:relative
    }
    #mentionDrop{
        position:absolute;
        bottom:calc(100% + 4px);
        left:0;
        z-index:999;
        background:#fff;
        border:1px solid #dee2e6;
        border-radius:10px;
        min-width:240px;
        max-height:210px;
        overflow-y:auto;
        box-shadow:0 6px 20px rgba(0,0,0,.13);
        display:none
    }
    #mentionDrop .mi{
        padding:8px 12px;
        cursor:pointer;
        display:flex;
        align-items:center;
        gap:8px;
        border-bottom:1px solid #f1f3f5
    }
    #mentionDrop .mi:last-child{
        border-bottom:0
    }
    #mentionDrop .mi:hover,.mi.active{
        background:#e7f5ff
    }
    .mention-tag{
        color:#1864ab;
        font-weight:600
    }
    .tl-item{
        padding:10px 14px;
        border:1px solid #e9ecef;
        border-radius:10px;
        margin-bottom:8px;
        background:#fff
    }
    .tl-line{
        display:flex;
        gap:8px;
        align-items:flex-start
    }
    .tl-time{
        font-weight:700;
        color:#0d6efd;
        white-space:nowrap;
        font-size:.82rem;
        min-width:95px
    }
    .tl-sum{
        flex:1
    }
    .tl-tog{
        display:inline-flex;
        align-items:center;
        justify-content:center;
        width:26px;
        height:26px;
        border-radius:8px;
        border:1px solid #dee2e6;
        text-decoration:none;
        color:#212529;
        flex-shrink:0
    }
    .tl-tog:hover{
        background:#f8f9fa
    }
    .det-box{
        margin-top:10px;
        padding:10px;
        background:#f8f9fa;
        border-radius:8px;
        border:1px dashed #dee2e6
    }
    .det-row{
        display:flex;
        gap:10px;
        font-size:.85rem;
        padding:4px 0;
        border-bottom:1px solid #f1f3f5
    }
    .det-row:last-child{
        border-bottom:0
    }
    .d-f{
        width:150px;
        color:#6c757d;
        font-family:monospace;
        font-size:.8rem
    }
    .d-o{
        color:#dc3545
    }
    .d-n{
        color:#198754
    }
</style>
<div><div class="content">

        <div class="page-header">
            <div class="page-title"><h4>Task Details</h4><h6>${fn:escapeXml(task.title)}</h6></div>
            <div class="page-btn d-flex gap-2 flex-wrap">
                <% if (canReopen) { %>
                <button class="btn btn-outline-success btn-sm" onclick="reopenTask()">
                    <i class="fa fa-undo me-1"></i>Reopen
                </button>
                <% } %>
                <a href="<%= ctx %>/tasks/edit?id=<%= task.getTaskId() %>" class="btn btn-warning btn-sm">
                    <i class="fa fa-edit me-1"></i>Edit</a>
                <a href="<%= ctx %>/tasks/list" class="btn btn-outline-secondary btn-sm">
                    <i class="fa fa-arrow-left me-1"></i>Back</a>
            </div>
        </div>

        <c:if test="${not empty sessionScope.flashSuccess}">
            <div class="alert alert-success alert-dismissible fade show">
                ${fn:escapeXml(sessionScope.flashSuccess)}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <% session.removeAttribute("flashSuccess"); %>
        </c:if>

        <% if ("Overdue".equalsIgnoreCase(task.getStatus())) { %>
        <div class="alert alert-danger d-flex align-items-center" role="alert">
            <i class="fa fa-exclamation-circle me-2" style="font-size:1.2rem"></i>
            <div>
                <strong>This task is overdue.</strong>
                <% if (isManager || (task.getCreatedBy() != null && task.getCreatedBy().getUserId() == currentUid)) { %>
                    You can still modify work items as a manager/owner.
                <% } else { %>
                    Work items are locked. Only the manager or task owner can make changes.
                <% } %>
            </div>
        </div>
        <% } %>

        <div class="row g-3">
            <!-- Task info -->
            <div class="col-lg-8">
                <div class="card">
                    <div class="card-header"><h5 class="card-title mb-0">Task Information</h5></div>
                    <div class="card-body p-0">
                        <table class="table table-borderless info-table mb-0">
                            <td><strong>${fn:escapeXml(task.title)}</strong></td>
                            <tr><th>Description</th><td><c:choose>
                                        <c:when test="${not empty task.description}">
                                            ${fn:escapeXml(task.description)}
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-muted fst-italic">—</span>
                                        </c:otherwise>
                                    </c:choose></td></tr>
                            <tr><th>Status</th><td><span class="badge <%= statusCls %>"><%= task.getStatus() %></span></td></tr>
                            <tr><th>Priority</th><td><span class="badge <%= priCls %>"><%= task.getPriority() %></span></td></tr>
                            <tr><th>Due Date</th><td><%= task.getDueDate()!=null?task.getDueDate().toString().replace("T"," ").substring(0,16):"—" %></td></tr>
                            <tr><th>Start Date</th><td><%= task.getStartDate()!=null?task.getStartDate().toString().replace("T"," ").substring(0,16):"—" %></td></tr>
                            <tr><th>Completed</th><td><%= task.getCompletedAt()!=null?task.getCompletedAt().toString().replace("T"," ").substring(0,16):"—" %></td></tr>
                            <tr><th>Created By</th><td><c:choose>
                                        <c:when test="${not empty task.createdBy.fullName}">
                                            ${fn:escapeXml(task.createdBy.fullName)}
                                        </c:when>
                                            <c:otherwise>—</c:otherwise>
                                    </c:choose></td></tr>
                        </table>
                    </div>
                </div>
                <!-- Assignees -->
                <div class="card">
                    <div class="card-header"><h5 class="card-title mb-0">Assignees</h5></div>
                    <div class="card-body">
                        <% List<TaskAssignee> asgn=task.getAssignees();
           if(asgn==null||asgn.isEmpty()){ %><p class="text-muted mb-0">No assignees.</p>
                        <% }else{for(TaskAssignee ta:asgn){
                              String nm=ta.getUser()!=null&&ta.getUser().getFullName()!=null?ta.getUser().getFullName():"Unknown";
                              String em=ta.getUser()!=null&&ta.getUser().getEmail()!=null?ta.getUser().getEmail():"";
                              String col="#"+String.format("%06x",(Math.abs(nm.hashCode()))%0xAAAAAA+0x404040); %>
                        <div class="d-flex align-items-center gap-3 py-2 border-bottom">
                            <div class="av" style="background:<%= col %>"><%= nm.substring(0,1).toUpperCase() %></div>
                            <div><div class="fw-semibold">${fn:escapeXml(nm)}</div><small class="text-muted">${fn:escapeXml(em)}</small></div>
                            <div class="ms-auto"><small class="text-muted">${not empty act.subject ? fn:escapeXml(act.subject) : ""}</small></div>
                        </div>
                        <% }}%>
                    </div>
                </div>
            </div>
            <!-- Progress -->
            <div class="col-lg-4">
                <div class="card">
                    <div class="card-header"><h5 class="card-title mb-0">Progress</h5></div>
                    <div class="card-body text-center">
                        <svg width="120" height="120" viewBox="0 0 120 120" class="mb-2">
                        <circle cx="60" cy="60" r="50" fill="none" stroke="#e9ecef" stroke-width="12"/>
                        <circle id="progArc" cx="60" cy="60" r="50" fill="none" stroke="#0d6efd" stroke-width="12"
                                stroke-linecap="round" stroke-dasharray="314.16" stroke-dashoffset="314.16"
                                transform="rotate(-90 60 60)" style="transition:stroke-dashoffset .4s ease"/>
                        </svg>
                        <div id="progPct" style="font-size:2rem;font-weight:700;color:#0d6efd;margin-top:-8px">0%</div>
                        <div id="progSub" class="text-muted small mt-1">0 / 0 work items done</div>
                        <div id="progAlert" class="alert alert-warning mt-3 py-2 px-3 d-none" style="font-size:.82rem">
                            <i class="fa fa-lock me-1"></i>Complete all work items to close this task.
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- WORK TREE -->
        <div class="card mt-2">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="card-title mb-0"><i class="fa fa-sitemap me-1"></i>Work Items
                    <span class="badge bg-secondary ms-1" id="wiCount">…</span>
                </h5>
            </div>
            <div class="card-body">
                <div id="workTree"></div>
                <!-- Add work item form -->
                <div class="card bg-light border-0 mt-3">
                    <div class="card-body p-3">
                        <h6 class="fw-semibold mb-2"><i class="fa fa-plus-circle me-1 text-primary"></i>Add Work Item</h6>
                        <div class="mb-2">
                            <label class="form-label small fw-semibold mb-1"><i class="fa fa-user-tag me-1"></i>Tag Supporter</label>
                            <select id="assignedToSelect" class="form-select form-select-sm">
                                <option value="">— none —</option>
                                <% for(User u:allUsers){String un=u.getFullName()!=null&&!u.getFullName().isBlank()?u.getFullName():u.getUsername(); %>
                                <option value="<%= u.getUserId() %>"><%= org.apache.taglibs.standard.functions.Functions.escapeXml(un) %></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="mention-box">
                            <div id="mentionDrop">
                                <% for(User u:allUsers){String mn=u.getFullName()!=null&&!u.getFullName().isBlank()?u.getFullName():u.getUsername(); %>
                                <div class="mi"
                                     data-uid="<%= u.getUserId() %>"
                                     data-name="<%= org.apache.taglibs.standard.functions.Functions.escapeXml(mn) %>"
                                     data-uname="<%= org.apache.taglibs.standard.functions.Functions.escapeXml(u.getUsername()) %>"
                                     onclick="insertMention(this)">

                                    <div class="av av-sm"
                                         style="background:#<%= String.format("%06x",(Math.abs(mn.hashCode()))%0xAAAAAA+0x404040) %>">
                                        <%= mn.substring(0,1).toUpperCase() %>
                                    </div>

                                    <div>
                                        <div class="fw-semibold" style="font-size:.83rem">
                                            <%= org.apache.taglibs.standard.functions.Functions.escapeXml(mn) %>
                                        </div>

                                        <div class="text-muted" style="font-size:.73rem">
                                            @<%= org.apache.taglibs.standard.functions.Functions.escapeXml(u.getUsername()) %>
                                        </div>
                                    </div>
                                </div>
                                <% } %>
                            </div>
                            <textarea id="wiInput" class="form-control form-control-sm" rows="2"
                                      placeholder="Describe the work item… type @ to mention someone"
                                      oninput="handleMention(this)" onkeydown="mentionKeydown(event)"></textarea>
                        </div>
                        <div class="d-flex align-items-center gap-2 mt-2">
                            <small class="text-muted flex-grow-1"><kbd>@</kbd> to tag a colleague</small>
                            <button class="btn btn-primary btn-sm" onclick="addWorkItem()">
                                <i class="fa fa-paper-plane me-1"></i>Add</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- HISTORY -->
        <div class="card mt-2">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="card-title mb-0"><i class="fa fa-history me-1"></i>Change History</h5>
                <a href="<%= ctx %>/tasks/view-history?id=<%= task.getTaskId() %>" class="btn btn-sm btn-outline-dark">Full History</a>
            </div>
            <div class="card-body">
                <% if(historyViews.isEmpty()){ %>
                <div class="alert alert-light border mb-0"><i class="fa fa-inbox me-1"></i>No history yet.</div>
                <% }else{for(HistoryView hv:historyViews){
                     TaskHistory h=hv.getHistory();int hid=h!=null?h.getHistoryId():0;
                     List<TaskHistoryDetail> dets=h!=null?h.getDetails():new ArrayList<>();
                     if(dets==null)dets=new ArrayList<>();
                     java.util.LinkedHashSet<String> lbls=new java.util.LinkedHashSet<>();
                     for(TaskHistoryDetail d:dets){
                       String fname=d!=null&&d.getFieldName()!=null?d.getFieldName().trim().toLowerCase():"";
                       switch(fname){
                         case"progress"->lbls.add("Progress updated");case"status"->lbls.add("Status changed");
                         case"priority"->lbls.add("Priority changed");case"duedate"->lbls.add("Due date changed");
                         case"title"->lbls.add("Title changed");case"description"->lbls.add("Description changed");
                         case"assignee_added"->lbls.add("Assignee added");case"assignee_removed"->lbls.add("Assignee removed");
                         case"created"->lbls.add("Task created");
                         default->{if(!fname.isEmpty())lbls.add(fname.replace('_',' '));}
                       }
                     }
                     String summary=lbls.isEmpty()?"Updated":String.join(" · ",lbls);
                     String cid="h_"+hid; %>
                <div class="tl-item">
                    <div class="tl-line">
                        <div class="tl-time"><%= hv.getChangedAtDisplay() %></div>
                        <div class="tl-sum"><%= summary %>
                            <% if(hv.getChangedByName()!=null&&!hv.getChangedByName().isBlank()){ %>
                            <span class="text-muted small">
                                by ${fn:escapeXml(hv.changedByName)}
                            </span>
                            <% } %>
                        </div>
                        <% if(!dets.isEmpty()){ %>
                        <a class="tl-tog" data-bs-toggle="collapse" href="#<%= cid %>"><i class="fa fa-caret-down"></i></a>
                            <% } %>
                    </div>
                    <% if(!dets.isEmpty()){ %>
                    <div class="collapse" id="<%= cid %>">
                        <div class="det-box">
                            <% for(TaskHistoryDetail d:dets){ %>
                            <div class="det-row">
                                <div class="d-f">
                                    ${fn:escapeXml(d.fieldName)}
                                </div>

                                <div class="d-o">
                                    ${not empty d.oldValue ? fn:escapeXml(d.oldValue) : "—"}
                                </div>

                                <div class="text-muted">→</div>

                                <div class="d-n">
                                    ${not empty d.newValue ? fn:escapeXml(d.newValue) : "—"}
                                </div>
                            </div>
                            <% } %>
                        </div>
                    </div>
                    <% } %>
                </div>
                <% }}%>
            </div>
        </div>

        <% if(actPag!=null&&actPag.getTotalItems()>0){ %>
        <div class="card mt-2">
            <div class="card-header"><h5 class="card-title mb-0"><i class="fa fa-stream me-1"></i>Activity Timeline</h5></div>
            <div class="card-body">
                <c:forEach var="act" items="${activities}">
                    <div class="tl-item">
                        <div class="tl-line">

                            <div class="tl-time">
                                ${act.activityDate != null ? fn:substringBefore(fn:replace(act.activityDate, 'T', ' '), '') : ""}
                            </div>

                            <div class="tl-sum">
                                <span class="badge bg-light text-dark border me-1">
                                    ${act.activityType != null ? fn:replace(act.activityType, '_', ' ') : ""}
                                </span>

                                ${not empty act.subject ? fn:escapeXml(act.subject) : ""}
                            </div>

                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
        <% } %>

    </div></div>

<script>
    const CTX = '${pageContext.request.contextPath}';
    const TASK_ID =<%= task.getTaskId() %>;
    const CUR_UID =<%= currentUid %>;
    const IS_MGR =<%= isManager %>;
    const TASK_STATUS = '<%= task.getStatus() %>';
    const TASK_OWNER_ID = <%= task.getCreatedBy() != null ? task.getCreatedBy().getUserId() : 0 %>;

    // Lock state - will be set after loading work items
    let IS_OVERDUE = false;
    let CAN_MODIFY = true;
    let allItems = [];

    // All users for dynamic subtask tag selector
    const ALL_USERS = [
        <% for (User u : allUsers) {
            String un = u.getFullName() != null && !u.getFullName().isBlank() ? u.getFullName() : u.getUsername();
            String safeUn = un.replace("\\", "\\\\").replace("\"", "\\\""); %>
        {uid: <%= u.getUserId() %>, name: "<%= safeUn %>"},
        <% } %>
    ];

    function loadWorkTree(){
    fetch(CTX + '/api/task-comments?taskId=' + TASK_ID)
            .then(r => r.json()).then(d => {
    allItems = d.items || [];
    IS_OVERDUE = d.isOverdue || false;
    CAN_MODIFY = d.canModify !== false; // default true
    renderTree();
    updateProgress(d.progressPct, d.completed, d.total);
    updateUIForOverdue();
    }).catch(() => {});
    }

    // Update UI based on overdue status and permissions
    function updateUIForOverdue() {
        const addForm = document.querySelector('.card.bg-light');
        if (addForm) {
            if (!CAN_MODIFY) {
                addForm.classList.add('opacity-50');
                const textarea = addForm.querySelector('textarea');
                const select = addForm.querySelector('select');
                const buttons = addForm.querySelectorAll('button');
                if (textarea) { textarea.disabled = true; textarea.placeholder = 'Task is overdue - no modifications allowed'; }
                if (select) select.disabled = true;
                buttons.forEach(b => b.disabled = true);
            } else if (IS_OVERDUE && CAN_MODIFY) {
                // Manager/owner can modify - show warning
                const existingWarning = document.getElementById('overdueWarning');
                if (!existingWarning && addForm) {
                    const warn = document.createElement('div');
                    warn.id = 'overdueWarning';
                    warn.className = 'alert alert-warning py-2 px-3 mb-2';
                    warn.innerHTML = '<i class="fa fa-exclamation-triangle me-1"></i>Task is overdue. Only manager or owner can modify.';
                    addForm.querySelector('.card-body').insertBefore(warn, addForm.querySelector('.card-body').firstChild);
                }
            }
        }
    }

    function renderTree(){
    const box = document.getElementById('workTree');
    const cnt = document.getElementById('wiCount');
    cnt.textContent = allItems.length;
    if (!allItems.length){
    box.innerHTML = '<p class="text-muted small mb-0"><i class="fa fa-inbox me-1"></i>No work items yet.</p>';
    return;
    }
    // Build tree structure with unlimited nesting levels
    const rootItems = allItems.filter(i => !i.parentCommentId);
    box.innerHTML = rootItems.map((item, idx) => renderItem(item, 0, idx)).join('');
    }

    // Recursive function to render nested subtasks at any depth
    function renderItem(item, level, index) {
    const children = allItems.filter(i => i.parentCommentId === item.commentId);
    const done = item.isCompleted;
    const av = avColor(item.authorName || '?');
    const body = esc(item.content || '').replace(/@([\S]+)/g, '<span class="mention-tag">@$1</span>');
    const pill = item.assignedTo ? '<span class="assignee-badge ms-1"><i class="fa fa-user-tag"></i>' + esc(item.assignedName || '') + '</span>' : '';
    const stamp = done && item.completedAt ? '<small class="text-success ms-1"><i class="fa fa-check-circle"></i>' + esc(item.completedAt) + '</small>' : '';

    // Permission checks
    const canChk = CAN_MODIFY && (IS_MGR || item.userId === CUR_UID || item.assignedTo === CUR_UID);
    const canDel = CAN_MODIFY && (IS_MGR || item.userId === CUR_UID);
    const canReply = CAN_MODIFY;

    const checkbox = canChk
        ? '<input type="checkbox" class="wi-check" ' + (done ? 'checked' : '') + ' onchange="toggleDone(' + item.commentId + ',this.checked)">'
        : '<div style="width:18px;flex-shrink:0"></div>';

    const deleteBtn = canDel
        ? '<button class="btn btn-xs btn-outline-danger" style="padding:2px 7px;font-size:.74rem" onclick="delItem(' + item.commentId + ')"><i class="fa fa-trash"></i></button>'
        : '';

    // Visual indent based on nesting level (each level adds 24px indent)
    const levelIndicator = level > 0 ? '<span class="badge bg-secondary ms-2" style="font-size:0.65rem">L' + level + '</span>' : '';

    // Build user options for the subtask tag selector
    const userOpts = '<option value="">— Tag someone (optional) —</option>' +
        ALL_USERS.map(u => '<option value="' + u.uid + '">' + esc(u.name) + '</option>').join('');

    // Render children recursively if any exist
    let childHtml = '';
    if (children.length > 0) {
        const childItemsHtml = children.map((child, childIdx) => renderItem(child, level + 1, childIdx)).join('');
        childHtml = '<div class="wi-replies" style="margin-left:24px;border-left:2px solid #e9ecef;padding-left:8px;">' + childItemsHtml + '</div>';
    }

    // ── Subtask form (Add Subtask button) ─────────────────────────────────────
    const subtaskForm = canReply ? (
        '<div class="d-none" id="rb-' + item.commentId + '" style="padding:6px 14px 10px 52px">' +
        '<div class="border rounded p-2 bg-white shadow-sm">' +
        '<div class="fw-semibold mb-2" style="font-size:.8rem;color:#1864ab"><i class="fa fa-plus-circle me-1"></i>New Subtask</div>' +
        '<div class="mb-2"><label class="form-label mb-1" style="font-size:.78rem;font-weight:600"><i class="fa fa-user-tag me-1"></i>Tag Supporter</label>' +
        '<select id="rs-' + item.commentId + '" class="form-select form-select-sm">' + userOpts + '</select></div>' +
        '<div class="mb-2"><label class="form-label mb-1" style="font-size:.78rem;font-weight:600"><i class="fa fa-pen me-1"></i>Content</label>' +
        '<textarea id="ri-' + item.commentId + '" class="form-control form-control-sm" rows="2" placeholder="Describe the subtask…"></textarea></div>' +
        '<div class="d-flex justify-content-end gap-2">' +
        '<button class="btn btn-sm btn-outline-secondary" onclick="hideReply(' + item.commentId + ')">Cancel</button>' +
        '<button class="btn btn-sm btn-primary" onclick="addReply(' + item.commentId + ')"><i class="fa fa-plus me-1"></i>Add Subtask</button>' +
        '</div></div></div>'
    ) : '';

    // ── Response form (Response button – no tagging) ──────────────────────────
    const responseForm = canReply ? (
        '<div class="d-none" id="rsp-' + item.commentId + '" style="padding:6px 14px 10px 52px">' +
        '<div class="border rounded p-2 bg-light shadow-sm">' +
        '<div class="fw-semibold mb-2" style="font-size:.8rem;color:#198754"><i class="fa fa-reply me-1"></i>Response</div>' +
        '<div class="mb-2">' +
        '<textarea id="rspt-' + item.commentId + '" class="form-control form-control-sm" rows="2" placeholder="Write your response…"></textarea></div>' +
        '<div class="d-flex justify-content-end gap-2">' +
        '<button class="btn btn-sm btn-outline-secondary" onclick="hideResponse(' + item.commentId + ')">Cancel</button>' +
        '<button class="btn btn-sm btn-success" onclick="addResponse(' + item.commentId + ')"><i class="fa fa-reply me-1"></i>Send Response</button>' +
        '</div></div></div>'
    ) : '';

    return '<div class="wi-root ' + (done ? 'wi-done' : '') + '" data-comment-id="' + item.commentId + '" data-level="' + level + '">' +
        '<div class="wi-header">' +
        checkbox +
        '<div class="av" style="background:' + av + '">' + (item.authorName || '?').charAt(0).toUpperCase() + '</div>' +
        '<div class="flex-grow-1">' +
        '<div class="d-flex align-items-center flex-wrap gap-1 mb-1">' +
        '<strong style="font-size:.87rem">' + esc(item.authorName || '?') + '</strong>' +
        '<small class="text-muted">' + esc(item.createdAt) + '</small>' + pill + stamp + levelIndicator +
        '</div>' +
        '<div class="wi-content">' + body + '</div>' +
        '</div>' +
        '<div class="d-flex gap-1 flex-shrink-0">' +
        (canReply ? '<button class="btn btn-xs btn-outline-secondary" style="padding:2px 7px;font-size:.74rem" onclick="showReply(' + item.commentId + ')" title="Add subtask"><i class="fa fa-plus"></i></button>' : '') +
        (canReply ? '<button class="btn btn-xs btn-outline-success" style="padding:2px 7px;font-size:.74rem" onclick="showResponse(' + item.commentId + ')" title="Response"><i class="fa fa-reply"></i></button>' : '') +
        deleteBtn +
        '</div></div>' +
        childHtml +
        subtaskForm +
        responseForm +
        '</div>';
    }

function addWorkItem(){
  if (!CAN_MODIFY) { toast('Task is overdue - modifications not allowed', 'warning'); return; }
  const inp=document.getElementById('wiInput');
  const sel=document.getElementById('assignedToSelect');
  const text=(inp.value||'').trim();if(!text){inp.focus();return;}
  const assignedTo=sel&&sel.value?parseInt(sel.value):null;
  fetch(CTX+'/api/task-comments',{method:'POST',
    headers:{'Content-Type':'application/json'},
    body:JSON.stringify({taskId:TASK_ID,content:text,assignedTo})})
    .then(r=>r.json()).then(res=>{
      if(res.success){inp.value='';if(sel)sel.value='';loadWorkTree();}
      else toast(res.message||'Failed','danger');
    }).catch(()=>toast('Network error','danger'));
}

function showReply(id){
  // Hide response form if open
  const rsp = document.getElementById('rsp-'+id);
  if (rsp) rsp.classList.add('d-none');
  const el = document.getElementById('rb-'+id);
  if (el) { el.classList.remove('d-none'); const ta = document.getElementById('ri-'+id); if(ta) ta.focus(); }
}
function hideReply(id){ const el=document.getElementById('rb-'+id); if(el) el.classList.add('d-none'); }
function addReply(parentId){
  if (!CAN_MODIFY) { toast('Task is overdue - modifications not allowed', 'warning'); return; }
  const ta = document.getElementById('ri-'+parentId);
  const sel = document.getElementById('rs-'+parentId);
  const text = (ta ? ta.value : '').trim();
  if (!text) { if(ta) ta.focus(); return; }
  const assignedTo = sel && sel.value ? parseInt(sel.value) : null;
  fetch(CTX+'/api/task-comments',{method:'POST',
    headers:{'Content-Type':'application/json'},
    body:JSON.stringify({taskId:TASK_ID,content:text,parentCommentId:parentId,assignedTo})})
    .then(r=>r.json()).then(res=>{
      if(res.success){ if(ta) ta.value=''; if(sel) sel.value=''; hideReply(parentId); loadWorkTree(); }
      else toast(res.message||'Failed','danger');
    }).catch(()=>toast('Network error','danger'));
}

function showResponse(id){
  // Hide subtask form if open
  const rb = document.getElementById('rb-'+id);
  if (rb) rb.classList.add('d-none');
  const el = document.getElementById('rsp-'+id);
  if (el) { el.classList.remove('d-none'); const ta = document.getElementById('rspt-'+id); if(ta) ta.focus(); }
}
function hideResponse(id){ const el=document.getElementById('rsp-'+id); if(el) el.classList.add('d-none'); }
function addResponse(parentId){
  if (!CAN_MODIFY) { toast('Task is overdue - modifications not allowed', 'warning'); return; }
  const ta = document.getElementById('rspt-'+parentId);
  const text = (ta ? ta.value : '').trim();
  if (!text) { if(ta) ta.focus(); return; }
  fetch(CTX+'/api/task-comments',{method:'POST',
    headers:{'Content-Type':'application/json'},
    body:JSON.stringify({taskId:TASK_ID,content:text,parentCommentId:parentId,assignedTo:null})})
    .then(r=>r.json()).then(res=>{
      if(res.success){ if(ta) ta.value=''; hideResponse(parentId); loadWorkTree(); }
      else toast(res.message||'Failed','danger');
    }).catch(()=>toast('Network error','danger'));
}

function toggleDone(id,done){
  if (!CAN_MODIFY) { toast('Task is overdue - modifications not allowed', 'warning'); return; }
  fetch(CTX+'/api/task-comments?id='+id+'&done='+done,{method:'PUT'})
    .then(r=>r.json()).then(res=>{
        if (res.success) loadWorkTree();
        else toast(res.message || 'Failed', 'danger');
    });
}

function delItem(id){
  if (!CAN_MODIFY) { toast('Task is overdue - modifications not allowed', 'warning'); return; }
  if(!confirm('Delete this work item and all subtasks?'))return;
  fetch(CTX+'/api/task-comments?id='+id,{method:'DELETE'})
    .then(r=>r.json()).then(res=>{if(res.success)loadWorkTree();else toast(res.message||'Failed','danger');});
}

function updateProgress(pct,completed,total){
  const arc=document.getElementById('progArc');
  const pEl=document.getElementById('progPct');
  const sEl=document.getElementById('progSub');
  const aEl=document.getElementById('progAlert');
  pct=pct||0;
  const c=2*Math.PI*50;
  if(arc){arc.style.strokeDashoffset=c-(pct/100)*c;arc.setAttribute('stroke',pct>=75?'#198754':pct>=40?'#fd7e14':'#dc3545');}
  if(pEl)pEl.textContent=pct+'%';
  if(sEl)sEl.textContent=(completed||0)+' / '+(total||0)+' work items done';
  if(aEl)aEl.classList.toggle('d-none',!(total>0&&(completed||0)<total));
}

function reopenTask(){
  if(!confirm('Reopen this task?'))return;
  fetch(CTX+'/tasks/edit',{method:'POST',
    headers:{'Content-Type':'application/x-www-form-urlencoded'},
    body:'subAction=status&taskId='+TASK_ID+'&status=Reopened'})
    .then(r=>r.json()).then(res=>{
      if(res.success){toast('Task reopened.','success');setTimeout(()=>location.reload(),900);}
      else toast(res.message||'Failed','danger');
    });
}

/* @mention */
let mPos=-1,mIdx=0;
function handleMention(ta){
  if (!CAN_MODIFY) return;
  const val=ta.value,pos=ta.selectionStart;
  let at=-1;
  for(let i=pos-1;i>=0;i--){if(val[i]==='@'){at=i;break;}if(val[i]===' '||val[i]==='\n')break;}
  const drop=document.getElementById('mentionDrop');
  if(at===-1){drop.style.display='none';mPos=-1;return;}
  mPos=at;const q=val.substring(at+1,pos).toLowerCase();
  let vis=0;
  drop.querySelectorAll('.mi').forEach(mi=>{
    const ok=!q||(mi.dataset.name||'').toLowerCase().includes(q)||(mi.dataset.uname||'').toLowerCase().includes(q);
    mi.style.display=ok?'':'none';if(ok)vis++;
  });
  drop.style.display=vis?'':'none';mIdx=0;updMention();
}
function mentionKeydown(e){
  const drop=document.getElementById('mentionDrop');
  if(drop.style.display==='none')return;
  const vis=[...drop.querySelectorAll('.mi:not([style*="none"])')];
  if(!vis.length)return;
  if(e.key==='ArrowDown'){e.preventDefault();mIdx=(mIdx+1)%vis.length;updMention();}
  else if(e.key==='ArrowUp'){e.preventDefault();mIdx=(mIdx-1+vis.length)%vis.length;updMention();}
  else if(e.key==='Enter'||e.key==='Tab'){if(vis[mIdx]){e.preventDefault();insertMention(vis[mIdx]);}}
  else if(e.key==='Escape')drop.style.display='none';
}
function updMention(){
  [...document.querySelectorAll('#mentionDrop .mi:not([style*="none"])')].forEach((el,i)=>el.classList.toggle('active',i===mIdx));
}
function insertMention(el){
  const ta=document.getElementById('wiInput');
  const pos=ta.selectionStart;const name=el.dataset.name;
  ta.value=ta.value.substring(0,mPos)+'@'+name+' '+ta.value.substring(pos);
  ta.selectionStart=ta.selectionEnd=mPos+name.length+2;ta.focus();
  const sel=document.getElementById('assignedToSelect');
  if(sel&&el.dataset.uid)sel.value=el.dataset.uid;
  document.getElementById('mentionDrop').style.display='none';mPos=-1;
}
document.addEventListener('click',e=>{if(!e.target.closest('.mention-box'))document.getElementById('mentionDrop').style.display='none';});

function avColor(n){let h=0;for(let i=0;i<n.length;i++)h=n.charCodeAt(i)+((h<<5)-h);return'#'+(((h&0xFFFFFF)+0x404040)&0xFFFFFF).toString(16).padStart(6,'0');}
function esc(s){const d=document.createElement('div');d.textContent=s||'';return d.innerHTML;}
function toast(msg,type){const id='t'+Date.now();const div=document.createElement('div');div.id=id;div.className='alert alert-'+type+' alert-dismissible fade show';div.style.cssText='position:fixed;top:70px;right:20px;z-index:9999;min-width:260px;';div.innerHTML=msg+'<button type="button" class="btn-close" data-bs-dismiss="alert"></button>';document.body.appendChild(div);setTimeout(()=>{const el=document.getElementById(id);if(el)el.remove();},3500);}

document.addEventListener('DOMContentLoaded',loadWorkTree);
                                </script>
