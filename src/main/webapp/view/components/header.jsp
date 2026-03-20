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

<c:set var="userRole" value="${sessionScope.user.role.roleName}" />
<c:choose>
    <c:when test="${fn:toUpperCase(userRole) eq 'ADMIN'}">
        <c:set var="rolePrefix" value="/admin" />
    </c:when>
    <c:when test="${fn:toUpperCase(userRole) eq 'SALE'}">
        <c:set var="rolePrefix" value="/sale" />
    </c:when>
    <c:when test="${fn:toUpperCase(userRole) eq 'MARKETING'}">
        <c:set var="rolePrefix" value="/marketing" />
    </c:when>
    <c:when test="${fn:toUpperCase(userRole) eq 'CS'}">
        <c:set var="rolePrefix" value="/cs" />
    </c:when>
    <c:otherwise>
        <c:set var="rolePrefix" value="" />
    </c:otherwise>
</c:choose>
<div class="header">
    <div class="header-left active">
        <a href="${pageContext.request.contextPath}${rolePrefix}/dashboard" class="logo">
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
                        <span class="badge bg-danger ms-1 ${unreadCount == 0 ? 'd-none' : ''}" 
                              id="notif-count-badge">
                            ${unreadCount}
                        </span>
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
                                        <a href="${pageContext.request.contextPath}/notifications/view?id=${notif.notificationId}">
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

                <div class="topnav-dropdown-footer">
                    <a href="${pageContext.request.contextPath}/notifications/list">View all notifications</a>
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
    <%-- <a href="javascript:void(0);"
       class="dropdown-toggle nav-link userset"
       data-bs-toggle="dropdown">
      <span class="user-img">
        <img src="${pageContext.request.contextPath}/Inventory-Management-Admin-Dashboard-main/assets/img/profiles/avator1.jpg" alt="" />
        <span class="status online"></span>
      </span>
    </a> --%>
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
    function updateBadge(delta, reset) {
        const badge = document.getElementById('notif-badge');
        if (!badge)
            return;
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

    /* ── Real-time updates via WebSocket (no polling, no fetch) ──────────── */
    (() => {
        const CTX = '${pageContext.request.contextPath}';
        const USER_ID = Number('${sessionScope.user.userId}');
        const badge = document.getElementById('notif-badge');
        const listEl = document.getElementById('notif-list');
        const markAllBtn = document.getElementById('markAllRead');
        if (!badge || !listEl || !USER_ID)
            return;

        let lastIds = new Set(
                Array.from(listEl.querySelectorAll('li[id^="notif-item-"]'))
                .map(li => parseInt(li.id.replace('notif-item-', '')))
                .filter(n => !isNaN(n))
                );
        let ws = null;
        let reconnectTimer = null;
        let reconnectAttempts = 0;
        const MAX_DELAY_MS = 15000;

        function esc(s) {
            const d = document.createElement('div');
            d.textContent = s || '';
            return d.innerHTML;
        }

        function wsUrl() {
            var proto = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
            var base = proto + "//" + window.location.host + CTX;
            return base + "/ws/notifications/" + USER_ID;
        }

        function setBadgeCount(count) {
            const c = Number(count) || 0;
            badge.textContent = String(c);
            if (c <= 0)
                badge.classList.add('d-none');
            else
                badge.classList.remove('d-none');
        }
        function setHeaderNotification(count) {

            const badge = document.getElementById("notif-count-badge");
            if (!badge)
                return;

            const c = Number(count) || 0;

            badge.textContent = c;

            if (c <= 0)
                badge.classList.add("d-none");
            else
                badge.classList.remove("d-none");
        }

        function render(items) {
            if (!items || !items.length) {
                listEl.innerHTML =
                        '<li class="notification-message text-center py-3">' +
                        '<span class="text-muted">No new notifications</span></li>';
                return;
            }
            let html = '';
            items.forEach(n => {
                html +=
                        '<li class="notification-message" id="notif-item-' + n.id + '">' +
                        '  <a href="' + CTX + '/notifications/view?id=' + n.id + '">' +
                        '    <div class="media d-flex">' +
                        '      <span class="avatar flex-shrink-0">' +
                        '        <i class="fa fa-bell fa-lg text-primary mt-2"></i>' +
                        '      </span>' +
                        '      <div class="media-body flex-grow-1 ms-2">' +
                        '        <p class="noti-details">' +
                        '          <span class="noti-title">' + esc(n.title) + '</span><br/>' +
                        '          <small class="text-muted">' + esc(n.content) + '</small>' +
                        '        </p>' +
                        '        <p class="noti-time"><span class="notification-time">' + esc(n.createdAt || '') + '</span></p>' +
                        '      </div>' +
                        '    </div>' +
                        '  </a>' +
                        '</li>';
            });
            listEl.innerHTML = html;
        }

        function prepend(item) {
            if (!item || !item.id)
                return;
            const liId = 'notif-item-' + item.id;
            if (document.getElementById(liId))
                return;

            // Remove "No new notifications" placeholder if present
            const placeholder = listEl.querySelector('li.notification-message.text-center');
            if (placeholder)
                placeholder.remove();

            const li = document.createElement('li');
            li.className = 'notification-message';
            li.id = liId;
            li.innerHTML =
                    '  <a href="' + CTX + '/notifications/view?id=' + item.id + '">' +
                    '    <div class="media d-flex">' +
                    '      <span class="avatar flex-shrink-0">' +
                    '        <i class="fa fa-bell fa-lg text-primary mt-2"></i>' +
                    '      </span>' +
                    '      <div class="media-body flex-grow-1 ms-2">' +
                    '        <p class="noti-details">' +
                    '          <span class="noti-title">' + esc(item.title) + '</span><br/>' +
                    '          <small class="text-muted">' + esc(item.content) + '</small>' +
                    '        </p>' +
                    '        <p class="noti-time"><span class="notification-time">' + esc(item.createdAt || '') + '</span></p>' +
                    '      </div>' +
                    '    </div>' +
                    '  </a>';
            listEl.insertBefore(li, listEl.firstChild);
        }

        function toast(title, content) {
            const id = 'toast_' + Date.now();
            const div = document.createElement('div');
            div.id = id;
            div.className = 'alert alert-primary alert-dismissible fade show';
            div.style.cssText = 'position:fixed;top:70px;right:20px;z-index:9999;min-width:320px;max-width:420px;';
            div.innerHTML =
                    '<div class="fw-semibold mb-1">' + esc(title) + '</div>' +
                    '<div class="small">' + esc(content) + '</div>' +
                    '<button type="button" class="btn-close" data-bs-dismiss="alert"></button>';
            document.body.appendChild(div);
            setTimeout(() => {
                const el = document.getElementById(id);
                if (el)
                    el.remove();
            }, 30000);
        }

        function connect() {
            if (reconnectTimer) {
                clearTimeout(reconnectTimer);
                reconnectTimer = null;
            }
            try {
                ws = new WebSocket(wsUrl());
            } catch (e) {
                scheduleReconnect();
                return;
            }

            ws.onopen = () => {
                reconnectAttempts = 0;
            };

            ws.onmessage = (ev) => {
                let data;
                try {
                    data = JSON.parse(ev.data);
                } catch {
                    return;
                }
                const event = (data.event || '').toLowerCase();

                if (event === 'sync') {
                    const items = data.items || [];
                    lastIds = new Set(items.map(x => x.id));
                    setBadgeCount(data.count);
                    setHeaderNotification(data.count);
                    render(items);
                    return;
                }

                if (event === 'reset') {
                    lastIds = new Set();
                    setBadgeCount(0);
                    setHeaderNotification(0);
                    render([]);
                    return;
                }

                if (event === 'new') {
                    const item = data.item;
                    if (item && item.id && !lastIds.has(item.id)) {
                        lastIds.add(item.id);
                        toast(item.title || 'New notification', item.content || '');
                        prepend(item);
                    }
                    setBadgeCount(data.count);
                    setHeaderNotification(data.count); // cập nhật badge header
                }
            };

            ws.onclose = () => scheduleReconnect();
            ws.onerror = () => {
                try {
                    ws.close();
                } catch (e) {
                }
            };
        }

        function scheduleReconnect() {
            if (reconnectTimer)
                return;
            reconnectAttempts++;
            const delay = Math.min(1000 * Math.pow(2, Math.min(reconnectAttempts, 4)), MAX_DELAY_MS);
            reconnectTimer = setTimeout(() => {
                reconnectTimer = null;
                connect();
            }, delay);
        }

        if (markAllBtn) {
            markAllBtn.addEventListener('click', function (e) {
                e.preventDefault();
                if (ws && ws.readyState === WebSocket.OPEN) {
                    ws.send(JSON.stringify({action: 'mark_all_read'}));
                }
            });
        }

        connect();
    })();
</script>
