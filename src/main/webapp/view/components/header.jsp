<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page isELIgnored="false" %>
<%@ page import="model.User, model.Notification, service.NotificationService, util.DBContext, java.sql.Connection, java.util.List, java.util.ArrayList" %>
<%
    /* ── Load unread notifications for the current user ── */
    User sessionUser = (User) session.getAttribute("user");
    List<Notification> unreadNotifications = new ArrayList<>();
    int unreadCount = 0;
    if (sessionUser != null) {
        try (Connection _conn = DBContext.getConnection()) {
            NotificationService _ns = new NotificationService(_conn);
            unreadNotifications = _ns.getUnreadForUser(sessionUser.getUserId());
            unreadCount = unreadNotifications.size();
        } catch (Exception _e) {
            _e.printStackTrace();
        }
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

    <!-- Notification Bell -->
    <li class="nav-item dropdown" id="notif-dropdown">
      <a href="javascript:void(0);"
         class="dropdown-toggle nav-link"
         data-bs-toggle="dropdown"
         id="notif-toggle">
        <img src="${pageContext.request.contextPath}/Inventory-Management-Admin-Dashboard-main/assets/img/icons/notification-bing.svg" alt="Notifications" />
        <c:if test="${unreadCount > 0}">
          <span class="badge rounded-pill" id="notif-badge">${unreadCount}</span>
        </c:if>
        <c:if test="${unreadCount == 0}">
          <span class="badge rounded-pill d-none" id="notif-badge">0</span>
        </c:if>
      </a>

      <div class="dropdown-menu notifications">
        <div class="topnav-dropdown-header">
          <span class="notification-title">
            Notifications
            <c:if test="${unreadCount > 0}">
              <span class="badge bg-danger ms-1">${unreadCount}</span>
            </c:if>
          </span>
          <a href="javascript:void(0);" class="clear-noti" id="markAllRead">
            Clear All
          </a>
        </div>

        <div class="noti-content">
          <ul class="notification-list" id="notif-list">
            <c:choose>
              <c:when test="${empty unreadNotifications}">
                <li class="notification-message text-center py-3">
                  <span class="text-muted">No new notifications</span>
                </li>
              </c:when>
              <c:otherwise>
                <c:forEach var="notif" items="${unreadNotifications}">
                  <li class="notification-message" id="notif-item-${notif.notificationId}">
                    <a href="javascript:void(0);"
                       onclick="markNotifRead(${notif.notificationId})">
                      <div class="media d-flex">
                        <span class="avatar flex-shrink-0">
                          <i class="fa fa-bell fa-lg text-primary mt-2"></i>
                        </span>
                        <div class="media-body flex-grow-1 ms-2">
                          <p class="noti-details">
                            <span class="noti-title">${fn:escapeXml(notif.title)}</span>
                            <br/>
                            <small class="text-muted">${fn:escapeXml(notif.content)}</small>
                          </p>
                          <p class="noti-time">
                            <span class="notification-time">
                              <c:if test="${notif.createdAt != null}">
                                ${notif.createdAt}
                              </c:if>
                            </span>
                          </p>
                        </div>
                      </div>
                    </a>
                  </li>
                </c:forEach>
              </c:otherwise>
            </c:choose>
          </ul>
        </div>

        <li class="nav-item dropdown has-arrow main-drop">
          <a
            href="javascript:void(0);"
            class="dropdown-toggle nav-link userset"
            data-bs-toggle="dropdown">
            <span class="user-img"
              ><img
                src="${pageContext.request.contextPath}/Inventory-Management-Admin-Dashboard-main/assets/img/profiles/avator1.jpg"
                alt="" />
              <span class="status online"></span
            ></span>
          </a>
          <div class="dropdown-menu menu-drop-user">
            <div class="profilename">
              <div class="profileset">
                <span class="user-img"
                  ><img
                    src="${pageContext.request.contextPath}/Inventory-Management-Admin-Dashboard-main/assets/img/profiles/avator1.jpg"
                    alt="" />
                  <span class="status online"></span
                ></span>
                <div class="profilesets">
                  <h6>John Doe</h6>
                  <h5>Sale</h5>
                </div>
              </div>
              <hr class="m-0" />
              <a class="dropdown-item" href="profile.html">
                <i class="me-2" data-feather="user"></i> My Profile</a
              >
              <a class="dropdown-item" href="generalsettings.html"
                ><i class="me-2" data-feather="settings"></i>Settings</a
              >
              <hr class="m-0" />
              <a class="dropdown-item logout pb-0" href="${pageContext.request.contextPath}/logout"
                ><img
                  src="${pageContext.request.contextPath}/Inventory-Management-Admin-Dashboard-main/assets/img/icons/log-out.svg"
                  class="me-2"
                  alt="img" />Logout</a
              >
            </div>
          </div>
        </li>
      </ul>

      <div class="dropdown mobile-user-menu">
        <a
          href="javascript:void(0);"
          class="nav-link dropdown-toggle"
          data-bs-toggle="dropdown"
          aria-expanded="false"
          ><i class="fa fa-ellipsis-v"></i
        ></a>
        <div class="dropdown-menu dropdown-menu-right">
          <a class="dropdown-item" href="profile.html">My Profile</a>
          <a class="dropdown-item" href="generalsettings.html">Settings</a>
          <a class="dropdown-item" href="${pageContext.request.contextPath}/logout">Logout</a>
        </div>
      </div>
    </li><!-- /notification -->

    <!-- User Menu -->
    <li class="nav-item dropdown has-arrow main-drop">
      <a href="javascript:void(0);"
         class="dropdown-toggle nav-link userset"
         data-bs-toggle="dropdown">
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
            <i class="me-2" data-feather="user"></i> My Profile
          </a>
          <hr class="m-0" />
          <a class="dropdown-item logout pb-0" href="${pageContext.request.contextPath}/logout">
            <img src="${pageContext.request.contextPath}/Inventory-Management-Admin-Dashboard-main/assets/img/icons/log-out.svg"
                 class="me-2" alt="Logout" />
            Logout
          </a>
        </div>
      </div>
    </li>
  </ul><!-- /user-menu -->
</div>

<!-- Flash message (set in session by controllers) -->
<c:if test="${not empty sessionScope.flashSuccess}">
  <div class="alert alert-success alert-dismissible fade show mx-3 mt-2" role="alert">
    ${fn:escapeXml(sessionScope.flashSuccess)}
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
  </div>
  <% session.removeAttribute("flashSuccess"); %>
</c:if>
<c:if test="${not empty sessionScope.flashError}">
  <div class="alert alert-danger alert-dismissible fade show mx-3 mt-2" role="alert">
    ${fn:escapeXml(sessionScope.flashError)}
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
  </div>
  <% session.removeAttribute("flashError"); %>
</c:if>

<script>
/**
 * Mark one notification as read and remove it from the dropdown.
 */
function markNotifRead(notifId) {
    fetch('${pageContext.request.contextPath}/notifications/markRead?id=' + notifId, {
        method: 'POST'
    })
    .then(r => r.json())
    .then(data => {
        if (data.success) {
            const item = document.getElementById('notif-item-' + notifId);
            if (item) item.remove();
            updateBadge(-1);
        }
    })
    .catch(console.error);
}

/**
 * Mark all notifications as read.
 */
document.getElementById('markAllRead').addEventListener('click', function () {
    fetch('${pageContext.request.contextPath}/notifications/markAll', { method: 'POST' })
    .then(r => r.json())
    .then(() => {
        document.getElementById('notif-list').innerHTML =
            '<li class="notification-message text-center py-3">' +
            '<span class="text-muted">No new notifications</span></li>';
        updateBadge(0, true);
    })
    .catch(console.error);
});

function updateBadge(delta, reset) {
    const badge = document.getElementById('notif-badge');
    if (!badge) return;
    let current = parseInt(badge.textContent) || 0;
    let next = reset ? 0 : current + delta;
    if (next <= 0) {
        badge.textContent = '0';
        badge.classList.add('d-none');
    } else {
        badge.textContent = next;
        badge.classList.remove('d-none');
    }
}
</script>
