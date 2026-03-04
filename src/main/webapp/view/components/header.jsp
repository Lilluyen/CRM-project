<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page isELIgnored="false" %>
<%@ page import="model.User, model.Notification, service.NotificationService, util.DBContext, java.sql.Connection, java.util.List, java.util.ArrayList" %>
<%
    /* ── Initial load: fetch unread count for first render ── */
    User sessionUser = (User) session.getAttribute("user");
    List<Notification> unreadNotifications = new ArrayList<>();
    int unreadCount = 0;
    if (sessionUser != null) {
        try (Connection _conn = DBContext.getConnection()) {
            NotificationService _ns = new NotificationService(_conn);
            unreadNotifications = _ns.getUnreadForUser(sessionUser.getUserId());
            unreadCount = unreadNotifications.size();
        } catch (Exception _e) { _e.printStackTrace(); }
    }
    request.setAttribute("unreadNotifications", unreadNotifications);
    request.setAttribute("unreadCount", unreadCount);
%>

<div class="header">
  <div class="header-left active">
    <a href="${pageContext.request.contextPath}/dashboard" class="logo">
      <img src="${pageContext.request.contextPath}/assets/img/logo.jpeg" alt="CRM Logo" />
    </a>
    <a id="toggle_btn" href="javascript:void(0);"></a>
  </div>

  <a id="mobile_btn" class="mobile_btn" href="#sidebar">
    <span class="bar-icon"><span></span><span></span><span></span></span>
  </a>

  <ul class="nav user-menu">
    <!-- Search -->
    <li class="nav-item">
      <div class="top-nav-search">
        <form action="#">
          <div class="searchinputs">
            <input type="text" placeholder="Search Here ..." />
          </div>
        </form>
      </div>
    </li>

    <!-- ── Notification Bell ───────────────────────────────────────── -->
    <li class="nav-item dropdown" id="notif-dropdown">
      <a href="javascript:void(0);" class="dropdown-toggle nav-link"
         data-bs-toggle="dropdown" id="notif-toggle">
        <img src="${pageContext.request.contextPath}/Inventory-Management-Admin-Dashboard-main/assets/img/icons/notification-bing.svg"
             alt="Notifications" />
        <span class="badge rounded-pill <%= unreadCount > 0 ? "" : "d-none" %>"
              id="notif-badge"><%= unreadCount %></span>
      </a>

      <div class="dropdown-menu notifications" style="min-width:340px;max-width:400px">
        <div class="topnav-dropdown-header d-flex justify-content-between align-items-center px-3 py-2">
          <span class="notification-title fw-semibold">
            Notifications
            <span class="badge bg-danger ms-1 <%= unreadCount > 0 ? "" : "d-none" %>"
                  id="notif-count-badge"><%= unreadCount %></span>
          </span>
          <a href="javascript:void(0);" id="markAllRead" class="text-muted small">
            <i class="fa fa-check-double me-1"></i>Clear all
          </a>
        </div>

        <div class="noti-content" style="max-height:320px;overflow-y:auto;">
          <ul class="notification-list list-unstyled mb-0" id="notif-list">
            <c:choose>
              <c:when test="${empty unreadNotifications}">
                <li id="notif-empty" class="text-center py-4 text-muted">
                  <i class="fa fa-bell-slash d-block mb-1 fa-lg"></i>No new notifications
                </li>
              </c:when>
              <c:otherwise>
                <c:forEach var="notif" items="${unreadNotifications}">
                  <li class="notification-message px-3 py-2 border-bottom"
                      id="notif-item-${notif.notificationId}">
                    <a href="javascript:void(0);" onclick="markNotifRead(${notif.notificationId})"
                       class="d-flex gap-2 text-decoration-none text-dark">
                      <span class="flex-shrink-0 mt-1">
                        <i class="fa fa-bell text-primary"></i>
                      </span>
                      <div class="flex-grow-1">
                        <div class="fw-semibold" style="font-size:.85rem">${notif.title}</div>
                        <div class="text-muted" style="font-size:.78rem">${notif.content}</div>
                        <div class="text-muted" style="font-size:.72rem;margin-top:2px">
                          <c:if test="${notif.createdAt != null}">
                            <i class="fa fa-clock me-1"></i>${notif.createdAt}
                          </c:if>
                        </div>
                      </div>
                      <i class="fa fa-times text-muted align-self-start mt-1 ms-1" style="font-size:.75rem"></i>
                    </a>
                  </li>
                </c:forEach>
              </c:otherwise>
            </c:choose>
          </ul>
        </div>

        <div class="topnav-dropdown-footer text-center py-2 border-top">
          <a href="${pageContext.request.contextPath}/notifications" class="text-primary small">
            View all notifications
          </a>
        </div>
      </div>
    </li>
    <!-- /notification bell -->

    <!-- User Menu -->
    <li class="nav-item dropdown has-arrow main-drop">
      <a href="javascript:void(0);" class="dropdown-toggle nav-link userset" data-bs-toggle="dropdown">
        <span class="user-img">
          <img src="${pageContext.request.contextPath}/Inventory-Management-Admin-Dashboard-main/assets/img/profiles/avator1.jpg" alt="" />
          <span class="status online"></span>
        </span>
      </a>
      <div class="dropdown-menu menu-drop-user">
        <div class="profilename">
          <div class="profileset">
            <span class="user-img">
              <img src="${pageContext.request.contextPath}/Inventory-Management-Admin-Dashboard-main/assets/img/profiles/avator1.jpg" alt="" />
              <span class="status online"></span>
            </span>
            <div class="profilesets">
              <h6>${sessionScope.user.fullName}</h6>
              <h5>${sessionScope.user.role.roleName}</h5>
            </div>
          </div>
          <hr class="m-0" />
          <a class="dropdown-item" href="${pageContext.request.contextPath}/profile">
            <i class="me-2" data-feather="user"></i>My Profile
          </a>
          <hr class="m-0" />
          <a class="dropdown-item logout pb-0" href="${pageContext.request.contextPath}/logout">
            <img src="${pageContext.request.contextPath}/Inventory-Management-Admin-Dashboard-main/assets/img/icons/log-out.svg"
                 class="me-2" alt="Logout" />Logout
          </a>
        </div>
      </div>
    </li>
  </ul>
</div><!-- /header -->

<!-- Flash messages -->
<c:if test="${not empty sessionScope.flashSuccess}">
  <div class="alert alert-success alert-dismissible fade show mx-3 mt-2" role="alert">
    <i class="fa fa-check-circle me-1"></i>${sessionScope.flashSuccess}
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
  </div>
  <% session.removeAttribute("flashSuccess"); %>
</c:if>
<c:if test="${not empty sessionScope.flashError}">
  <div class="alert alert-danger alert-dismissible fade show mx-3 mt-2" role="alert">
    <i class="fa fa-exclamation-circle me-1"></i>${sessionScope.flashError}
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
  </div>
  <% session.removeAttribute("flashError"); %>
</c:if>

<script>
/* ════════════════════════════════════════════════════════════════════
   REALTIME NOTIFICATIONS via Server-Sent Events (SSE)
   Connects to /notifications/stream which polls the DB every ~8s.
   Falls back to 10s fetch polling if EventSource is unavailable.
════════════════════════════════════════════════════════════════════ */
(function initNotifications() {
    const CTX        = '${pageContext.request.contextPath}';
    const badge      = document.getElementById('notif-badge');
    const countBadge = document.getElementById('notif-count-badge');
    const list       = document.getElementById('notif-list');
    const emptyEl    = document.getElementById('notif-empty');

    /* Track IDs we already show so we don't duplicate */
    const shownIds = new Set();
    document.querySelectorAll('#notif-list .notification-message').forEach(el => {
        const id = el.id.replace('notif-item-', '');
        if (id) shownIds.add(parseInt(id));
    });

    function updateBadge(count) {
        if (!badge) return;
        if (count <= 0) {
            badge.textContent = '0';
            badge.classList.add('d-none');
            if (countBadge) { countBadge.textContent = '0'; countBadge.classList.add('d-none'); }
        } else {
            badge.textContent = count;
            badge.classList.remove('d-none');
            if (countBadge) { countBadge.textContent = count; countBadge.classList.remove('d-none'); }
        }
    }

    function renderItem(n) {
        if (shownIds.has(n.id)) return;
        shownIds.add(n.id);

        /* Remove empty placeholder */
        if (emptyEl) emptyEl.style.display = 'none';

        const li = document.createElement('li');
        li.className = 'notification-message px-3 py-2 border-bottom notification-new';
        li.id = 'notif-item-' + n.id;
        li.style.animation = 'notifFadeIn .4s ease';
        li.innerHTML = `
          <a href="javascript:void(0);" onclick="markNotifRead(${n.id})"
             class="d-flex gap-2 text-decoration-none text-dark">
            <span class="flex-shrink-0 mt-1"><i class="fa fa-bell text-primary"></i></span>
            <div class="flex-grow-1">
              <div class="fw-semibold" style="font-size:.85rem">${n.title}</div>
              <div class="text-muted" style="font-size:.78rem">${n.content}</div>
              <div class="text-muted" style="font-size:.72rem;margin-top:2px">
                <i class="fa fa-clock me-1"></i>${n.createdAt || ''}
              </div>
            </div>
            <i class="fa fa-times text-muted align-self-start mt-1 ms-1" style="font-size:.75rem"></i>
          </a>`;
        list.insertBefore(li, list.firstChild);

        /* Desktop toast for new notifications */
        showDesktopToast(n.title, n.content);
    }

    function processData(data) {
        try {
            const obj = JSON.parse(data);
            updateBadge(obj.count);
            if (obj.items && obj.items.length) {
                obj.items.forEach(renderItem);
            }
        } catch (e) { /* malformed json – ignore */ }
    }

    /* ── SSE connection ───────────────────────────────────────────── */
    if (typeof EventSource !== 'undefined') {
        let es = null;

        function connectSSE() {
            es = new EventSource(CTX + '/notifications/stream');
            es.onmessage = e => processData(e.data);
            es.onerror   = () => {
                es.close();
                /* Reconnect after 15s on error */
                setTimeout(connectSSE, 15000);
            };
        }

        connectSSE();

        /* Close SSE when tab goes hidden to save server threads */
        document.addEventListener('visibilitychange', () => {
            if (document.hidden) { if (es) es.close(); }
            else connectSSE();
        });
    } else {
        /* Fallback: plain polling every 10s */
        setInterval(() => {
            fetch(CTX + '/notifications/unreadJson')
                .then(r => r.json())
                .then(processData)
                .catch(() => {});
        }, 10000);
    }

    /* ── Desktop notification toast ──────────────────────────────── */
    function showDesktopToast(title, body) {
        const id  = 'nt_' + Date.now();
        const div = document.createElement('div');
        div.id    = id;
        div.style.cssText =
            'position:fixed;bottom:24px;right:24px;z-index:10000;min-width:280px;' +
            'background:#fff;border:1px solid #dee2e6;border-radius:8px;' +
            'box-shadow:0 4px 16px rgba(0,0,0,.15);padding:12px 16px;' +
            'animation:notifFadeIn .4s ease;';
        div.innerHTML = `
          <div class="d-flex align-items-start gap-2">
            <i class="fa fa-bell text-primary mt-1"></i>
            <div class="flex-grow-1">
              <div class="fw-semibold" style="font-size:.85rem">${title}</div>
              <div class="text-muted" style="font-size:.78rem">${body}</div>
            </div>
            <button type="button" class="btn-close btn-sm" style="font-size:.65rem"
                    onclick="document.getElementById('${id}').remove()"></button>
          </div>`;
        document.body.appendChild(div);
        setTimeout(() => { const el = document.getElementById(id); if (el) el.style.opacity = '0'; }, 4500);
        setTimeout(() => { const el = document.getElementById(id); if (el) el.remove(); }, 5000);
    }
/* Expose globally for onclick handlers */
    window._notifUpdateBadge = updateBadge;
})();

/* ── Mark single notification as read ─────────────────────────── */
function markNotifRead(notifId) {
    fetch('${pageContext.request.contextPath}/notifications/markRead', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'id=' + notifId
    })
    .then(r => r.json())
    .then(data => {
        if (data.success) {
            const item = document.getElementById('notif-item-' + notifId);
            if (item) item.remove();
            const badge = document.getElementById('notif-badge');
            if (badge) {
                let cur = parseInt(badge.textContent) || 0;
                if (window._notifUpdateBadge) window._notifUpdateBadge(Math.max(0, cur - 1));
            }
        }
    })
    .catch(console.error);
}

/* ── Mark all as read ──────────────────────────────────────────── */
document.getElementById('markAllRead')?.addEventListener('click', () => {
    fetch('${pageContext.request.contextPath}/notifications/markAll', { method: 'POST' })
    .then(r => r.json())
    .then(() => {
        document.getElementById('notif-list').innerHTML =
            '<li id="notif-empty" class="text-center py-4 text-muted">' +
            '<i class="fa fa-bell-slash d-block mb-1 fa-lg"></i>No new notifications</li>';
        if (window._notifUpdateBadge) window._notifUpdateBadge(0);
    })
    .catch(console.error);
});

/* ── CSS animation ─────────────────────────────────────────────── */
const _style = document.createElement('style');
_style.textContent = `
@keyframes notifFadeIn { from { opacity:0; transform:translateY(-6px); } to { opacity:1; transform:none; } }
.notification-new { background: linear-gradient(90deg,#f0f7ff,transparent 60%); }
`;
document.head.appendChild(_style);
</script>
