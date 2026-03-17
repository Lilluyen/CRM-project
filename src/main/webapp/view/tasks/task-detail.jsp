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
.info-table th{width:140px;color:#6c757d;font-weight:600;vertical-align:middle}
.info-table td{vertical-align:middle}
.wi-root{border:1px solid #e3e8ef;border-radius:10px;margin-bottom:10px;background:#fff;overflow:hidden}
.wi-done .wi-content{text-decoration:line-through;color:#adb5bd}
.wi-header{display:flex;align-items:flex-start;gap:10px;padding:12px 14px}
.wi-replies{padding:4px 14px 10px 52px}
.wi-reply{border-left:2px solid #dee2e6;padding:8px 12px;margin-bottom:6px;border-radius:0 8px 8px 0;background:#f8f9fb}
.wi-reply.r-done .wi-content{text-decoration:line-through;color:#adb5bd}
.av{width:32px;height:32px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-weight:700;font-size:.78rem;flex-shrink:0;color:#fff}
.av-sm{width:24px;height:24px;font-size:.68rem}
.wi-check{width:18px;height:18px;accent-color:#198754;cursor:pointer;flex-shrink:0;margin-top:3px}
.assignee-badge{display:inline-flex;align-items:center;gap:4px;background:#e7f5ff;color:#1864ab;border:1px solid #74c0fc;border-radius:20px;padding:1px 8px;font-size:.75rem}
.mention-box{position:relative}
#mentionDrop{position:absolute;bottom:calc(100% + 4px);left:0;z-index:999;background:#fff;border:1px solid #dee2e6;border-radius:10px;min-width:240px;max-height:210px;overflow-y:auto;box-shadow:0 6px 20px rgba(0,0,0,.13);display:none}
#mentionDrop .mi{padding:8px 12px;cursor:pointer;display:flex;align-items:center;gap:8px;border-bottom:1px solid #f1f3f5}
#mentionDrop .mi:last-child{border-bottom:0}
#mentionDrop .mi:hover,.mi.active{background:#e7f5ff}
.mention-tag{color:#1864ab;font-weight:600}
.tl-item{padding:10px 14px;border:1px solid #e9ecef;border-radius:10px;margin-bottom:8px;background:#fff}
.tl-line{display:flex;gap:8px;align-items:flex-start}
.tl-time{font-weight:700;color:#0d6efd;white-space:nowrap;font-size:.82rem;min-width:95px}
.tl-sum{flex:1}
.tl-tog{display:inline-flex;align-items:center;justify-content:center;width:26px;height:26px;border-radius:8px;border:1px solid #dee2e6;text-decoration:none;color:#212529;flex-shrink:0}
.tl-tog:hover{background:#f8f9fa}
.det-box{margin-top:10px;padding:10px;background:#f8f9fa;border-radius:8px;border:1px dashed #dee2e6}
.det-row{display:flex;gap:10px;font-size:.85rem;padding:4px 0;border-bottom:1px solid #f1f3f5}
.det-row:last-child{border-bottom:0}
.d-f{width:150px;color:#6c757d;font-family:monospace;font-size:.8rem}
.d-o{color:#dc3545}.d-n{color:#198754}
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

<div class="row g-3">
  <!-- Task info -->
  <div class="col-lg-8">
    <div class="card">
      <div class="card-header"><h5 class="card-title mb-0">Task Information</h5></div>
      <div class="card-body p-0">
        <table class="table table-borderless info-table mb-0">
          <tr><th>Title</th><td><strong><%= fn.escapeXml(task.getTitle()) %></strong></td></tr>
          <tr><th>Description</th><td><%= task.getDescription()!=null&&!task.getDescription().isBlank()
              ?fn.escapeXml(task.getDescription()):"<span class='text-muted fst-italic'>—</span>" %></td></tr>
          <tr><th>Status</th><td><span class="badge <%= statusCls %>"><%= task.getStatus() %></span></td></tr>
          <tr><th>Priority</th><td><span class="badge <%= priCls %>"><%= task.getPriority() %></span></td></tr>
          <tr><th>Due Date</th><td><%= task.getDueDate()!=null?task.getDueDate().toString().replace("T"," ").substring(0,16):"—" %></td></tr>
          <tr><th>Start Date</th><td><%= task.getStartDate()!=null?task.getStartDate().toString().replace("T"," ").substring(0,16):"—" %></td></tr>
          <tr><th>Completed</th><td><%= task.getCompletedAt()!=null?task.getCompletedAt().toString().replace("T"," ").substring(0,16):"—" %></td></tr>
          <tr><th>Created By</th><td><%= task.getCreatedBy()!=null&&task.getCreatedBy().getFullName()!=null
              ?fn.escapeXml(task.getCreatedBy().getFullName()):"—" %></td></tr>
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
            <div><div class="fw-semibold"><%= fn.escapeXml(nm) %></div><small class="text-muted"><%= fn.escapeXml(em) %></small></div>
            <div class="ms-auto"><small class="text-muted"><%= ta.getAssignedAt()!=null?ta.getAssignedAt().toString().replace("T"," ").substring(0,16):"" %></small></div>
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
              <option value="<%= u.getUserId() %>"><%= fn.escapeXml(un) %></option>
            <% } %>
          </select>
        </div>
        <div class="mention-box">
          <div id="mentionDrop">
            <% for(User u:allUsers){String mn=u.getFullName()!=null&&!u.getFullName().isBlank()?u.getFullName():u.getUsername(); %>
              <div class="mi" data-uid="<%= u.getUserId() %>"
                   data-name="<%= fn.escapeXml(mn) %>"
                   data-uname="<%= fn.escapeXml(u.getUsername()!=null?u.getUsername():"") %>"
                   onclick="insertMention(this)">
                <div class="av av-sm" style="background:#<%= String.format("%06x",(Math.abs(mn.hashCode()))%0xAAAAAA+0x404040) %>">
                  <%= mn.substring(0,1).toUpperCase() %></div>
                <div>
                  <div class="fw-semibold" style="font-size:.83rem"><%= fn.escapeXml(mn) %></div>
                  <div class="text-muted" style="font-size:.73rem">@<%= fn.escapeXml(u.getUsername()!=null?u.getUsername():"") %></div>
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
              <span class="text-muted small"> by <%= fn.escapeXml(hv.getChangedByName()) %></span>
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
                  <div class="d-f"><%= fn.escapeXml(d.getFieldName()!=null?d.getFieldName():"") %></div>
                  <div class="d-o"><%= d.getOldValue()!=null&&!d.getOldValue().isBlank()?fn.escapeXml(d.getOldValue()):"—" %></div>
                  <div class="text-muted">→</div>
                  <div class="d-n"><%= d.getNewValue()!=null&&!d.getNewValue().isBlank()?fn.escapeXml(d.getNewValue()):"—" %></div>
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
    <% for(Activity act:activities){
         String at=act.getActivityDate()!=null?act.getActivityDate().toString().replace("T"," ").substring(0,16):"";
         String ty=act.getActivityType()!=null?act.getActivityType().replace('_',' '):""; %>
      <div class="tl-item"><div class="tl-line">
        <div class="tl-time"><%= at %></div>
        <div class="tl-sum">
          <span class="badge bg-light text-dark border me-1"><%= ty %></span>
          <%= act.getSubject()!=null?fn.escapeXml(act.getSubject()):"" %>
        </div>
      </div></div>
    <% } %>
    <% if(actPag.getTotalPages()>1){ %>
      <nav><ul class="pagination pagination-sm mb-0 justify-content-center mt-2">
        <li class="page-item <%= actPag.getCurrentPage()==1?"disabled":"" %>">
          <a class="page-link" href="?id=<%= task.getTaskId() %>&activityPage=<%= actPag.getCurrentPage()-1 %>">‹</a></li>
        <% for(int ap=actPag.getStartPage();ap<=actPag.getEndPage();ap++){ %>
          <li class="page-item <%= ap==actPag.getCurrentPage()?"active":"" %>">
            <a class="page-link" href="?id=<%= task.getTaskId() %>&activityPage=<%= ap %>"><%= ap %></a></li>
        <% } %>
        <li class="page-item <%= actPag.getCurrentPage()==actPag.getTotalPages()?"disabled":"" %>">
          <a class="page-link" href="?id=<%= task.getTaskId() %>&activityPage=<%= actPag.getCurrentPage()+1 %>">›</a></li>
      </ul></nav>
    <% } %>
  </div>
</div>
<% } %>

</div></div>

<script>
const CTX='${pageContext.request.contextPath}';
const TASK_ID=<%= task.getTaskId() %>;
const CUR_UID=<%= currentUid %>;
const IS_MGR=<%= isManager %>;
const TASK_STATUS='<%= task.getStatus() %>';
let allItems=[];

function loadWorkTree(){
  fetch(CTX+'/api/task-comments?taskId='+TASK_ID)
    .then(r=>r.json()).then(d=>{
      allItems=d.items||[];
      renderTree();
      updateProgress(d.progressPct,d.completed,d.total);
    }).catch(()=>{});
}

function renderTree(){
  const box=document.getElementById('workTree');
  const cnt=document.getElementById('wiCount');
  const roots=allItems.filter(i=>!i.parentCommentId);
  cnt.textContent=allItems.length;
  if(!allItems.length){
    box.innerHTML='<p class="text-muted small mb-0"><i class="fa fa-inbox me-1"></i>No work items yet.</p>';
    return;
  }
  box.innerHTML=roots.map(i=>renderItem(i)).join('');
}

function renderItem(item){
  const children=allItems.filter(i=>i.parentCommentId===item.commentId);
  const done=item.isCompleted;
  const canChk=IS_MGR||item.userId===CUR_UID||item.assignedTo===CUR_UID;
  const canDel=IS_MGR||item.userId===CUR_UID;
  const av=avColor(item.authorName||'?');
  const body=esc(item.content||'').replace(/@([\S]+)/g,'<span class="mention-tag">@$1</span>');
  const pill=item.assignedTo?`<span class="assignee-badge ms-1"><i class="fa fa-user-tag"></i>esc(${item.assignedName||''})</span>`:'';
  const stamp=done&&item.completedAt?`<small class="text-success ms-1"><i class="fa fa-check-circle"></i>esc(${item.completedAt})</small>`:'';
  const childHtml=children.length?`<div class="wi-replies">'$'{children.map(c=>renderReply(c)).join('')}</div>`:'';
  return `<div class="wi-root ${done?'wi-done':''}">
    <div class="wi-header">
      '$'{canChk?`<input type="checkbox" class="wi-check" ${done?'checked':''} onchange="toggleDone(${item.commentId},this.checked)">`:'<div style="width:18px;flex-shrink:0"></div>'}
      <div class="av" style="background:${av}">${(item.authorName||'?').charAt(0).toUpperCase()}</div>
      <div class="flex-grow-1">
        <div class="d-flex align-items-center flex-wrap gap-1 mb-1">
          <strong style="font-size:.87rem">esc(${item.authorName||'?'})</strong>
          <small class="text-muted">esc(${item.createdAt})</small>${pill}${stamp}
        </div>
        <div class="wi-content">${body}</div>
      </div>
      <div class="d-flex gap-1 flex-shrink-0">
        <button class="btn btn-xs btn-outline-secondary" style="padding:2px 7px;font-size:.74rem"
                onclick="showReply(${item.commentId})" title="Reply"><i class="fa fa-reply"></i></button>
        '$'{canDel?`<button class="btn btn-xs btn-outline-danger" style="padding:2px 7px;font-size:.74rem"
                          onclick="delItem(${item.commentId})"><i class="fa fa-trash"></i></button>`:''}
      </div>
    </div>
    ${childHtml}
    <div class="wi-replies d-none" id="rb-${item.commentId}">
      <div class="d-flex gap-2 mt-1">
        <input id="ri-${item.commentId}" class="form-control form-control-sm flex-grow-1" placeholder="Reply…"
               onkeydown="if(event.key==='Enter'){addReply(${item.commentId});event.preventDefault();}">
        <button class="btn btn-sm btn-primary" onclick="addReply(${item.commentId})">Send</button>
        <button class="btn btn-sm btn-outline-secondary" onclick="hideReply(${item.commentId})">✕</button>
      </div>
    </div>
  </div>`;
}

function renderReply(item){
  const done=item.isCompleted;
  const canChk=IS_MGR||item.userId===CUR_UID||item.assignedTo===CUR_UID;
  const canDel=IS_MGR||item.userId===CUR_UID;
  const body=esc(item.content||'').replace(/@([\S]+)/g,'<span class="mention-tag">@$1</span>');
  const pill=item.assignedTo?`<span class="assignee-badge ms-1"><i class="fa fa-user-tag"></i>esc(${item.assignedName||''})</span>`:'';
  const av=avColor(item.authorName||'?');
  return `<div class="wi-reply ${done?'r-done':''}">
    <div class="d-flex gap-2 align-items-flex-start">
      '$'{canChk?`<input type="checkbox" class="wi-check" ${done?'checked':''} onchange="toggleDone(${item.commentId},this.checked)">`:'<div style="width:18px"></div>'}
      <div class="av av-sm" style="background:${av}">${(item.authorName||'?').charAt(0).toUpperCase()}</div>
      <div class="flex-grow-1">
        <div class="d-flex align-items-center gap-1 flex-wrap mb-1">
          <strong style="font-size:.82rem">esc(${item.authorName||'?'})</strong>
          <small class="text-muted">esc(${item.createdAt})</small>${pill}
        </div>
        <div class="wi-content">${body}</div>
      </div>
      '$'{canDel?`<button class="btn btn-xs btn-outline-danger ms-auto" style="padding:1px 6px;font-size:.72rem"
                        onclick="delItem(${item.commentId})"><i class="fa fa-trash"></i></button>`:''}
    </div>
  </div>`;
}

function addWorkItem(){
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

function showReply(id){document.getElementById('rb-'+id).classList.remove('d-none');document.getElementById('ri-'+id).focus();}
function hideReply(id){document.getElementById('rb-'+id).classList.add('d-none');}
function addReply(parentId){
  const inp=document.getElementById('ri-'+parentId);
  const text=(inp.value||'').trim();if(!text)return;
  fetch(CTX+'/api/task-comments',{method:'POST',
    headers:{'Content-Type':'application/json'},
    body:JSON.stringify({taskId:TASK_ID,content:text,parentCommentId:parentId})})
    .then(r=>r.json()).then(res=>{if(res.success)loadWorkTree();else toast(res.message||'Failed','danger');});
}

function toggleDone(id,done){
  fetch(CTX+'/api/task-comments?id='+id+'&done='+done,{method:'PUT'})
    .then(r=>r.json()).then(res=>{loadWorkTree();});
}

function delItem(id){
  if(!confirm('Delete this work item?'))return;
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
function toast(msg,type){const id='t'+Date.now();const div=document.createElement('div');div.id=id;div.className=`alert alert-${type} alert-dismissible fade show`;div.style.cssText='position:fixed;top:70px;right:20px;z-index:9999;min-width:260px;';div.innerHTML=msg+'<button type="button" class="btn-close" data-bs-dismiss="alert"></button>';document.body.appendChild(div);setTimeout(()=>{const el=document.getElementById(id);if(el)el.remove();},3500);}

document.addEventListener('DOMContentLoaded',loadWorkTree);
</script>
