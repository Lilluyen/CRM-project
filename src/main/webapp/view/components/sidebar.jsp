<%@ page contentType="text/html;charset=UTF-8" language="java" %> <%@ taglib
uri="http://java.sun.com/jsp/jstl/core" prefix="c" %> <%@ taglib
uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %> <%@ page
isELIgnored="false" %> <%-- Xác định role prefix dựa trên role của user --%>
<c:set var="userRole" value="${sessionScope.user.role.roleName}" />
<c:choose>
  <c:when test="${fn:toUpperCase(userRole) eq 'ADMIN'}">
    <c:set var="rolePrefix" value="/admin" />
  </c:when>
  <c:when test="${fn:toUpperCase(userRole) eq 'MANAGER'}">
    <c:set var="rolePrefix" value="/manager" />
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

<div class="sidebar" id="sidebar">
  <div class="sidebar-inner slimscroll">
    <div id="sidebar-menu" class="sidebar-menu">
      <ul>
        <!-- DASHBOARD -->
        <li>
          <a href="${pageContext.request.contextPath}${rolePrefix}/dashboard">
            <i class="fas fa-home"></i>
            <span>Dashboard</span>
          </a>
        </li>

        <!-- CAMPAIGN -->
        <li class="submenu">
          <a href="javascript:void(0);">
            <i class="fas fa-bullhorn"></i>
            <span>Campaign</span>
            <span class="menu-arrow"></span>
          </a>
          <ul
            style="${fn:startsWith(page, 'campaign-') ? 'display:block;' : ''}">
            <li>
              <a
                class="${page eq 'campaign-list' ? 'active' : ''}"
                href="${pageContext.request.contextPath}/marketing/campaign">
                Campaign List
              </a>
            </li>
            <li>
              <a
                class="${page eq 'campaign-form' ? 'active' : ''}"
                href="${pageContext.request.contextPath}/marketing/campaign/form">
                Add New Campaign
              </a>
            </li>
            <li>
              <a
                class="${page eq 'campaign-detail' ? 'active' : ''}"
                href="${pageContext.request.contextPath}/marketing/campaign">
                Campaign Update
              </a>
            </li>
          </ul>
        </li>

        <!-- LEADS -->
        <li class="submenu">
          <a href="javascript:void(0);">
            <i class="fas fa-user-plus"></i>
            <span>Leads</span>
            <span class="menu-arrow"></span>
          </a>
          <ul style="${fn:startsWith(page, 'lead-') ? 'display:block;' : ''}">
            <li>
              <a
                class="${page eq 'lead-list' ? 'active' : ''}"
                href="${pageContext.request.contextPath}/marketing/leads">
                Lead List
              </a>
            </li>
            <li>
              <a
                class="${page eq 'lead-form' ? 'active' : ''}"
                href="${pageContext.request.contextPath}/marketing/leads/form">
                Add New Lead
              </a>
            </li>
            <li>
              <a
                class="${page eq 'lead-detail' ? 'active' : ''}"
                href="${pageContext.request.contextPath}/marketing/leads">
                Update Lead
              </a>
            </li>
            <li>
              <a
                class="${page eq 'lead-import' ? 'active' : ''}"
                href="${pageContext.request.contextPath}/marketing/leads/import">
                Import Leads
              </a>
            </li>
          </ul>
        </li>

        <!-- SALES -->
        <li class="submenu">
          <a href="javascript:void(0);">
            <i class="fas fa-handshake"></i>
            <span>Sales</span>
            <span class="menu-arrow"></span>
          </a>
          <ul
            style="${fn:startsWith(page, 'product-') || fn:startsWith(page, 'deal-') || fn:startsWith(page, 'category-') || page eq 'sales-funnel' || page eq 'revenue-forecast' ? 'display:block;' : ''}">
            <li>
              <a
                class="${fn:startsWith(page, 'category-') ? 'active' : ''}"
                href="${pageContext.request.contextPath}/sale/category/list"
                >Category</a
              >
            </li>
            <li>
              <a
                class="${fn:startsWith(page, 'product-') ? 'active' : ''}"
                href="${pageContext.request.contextPath}/sale/product/list"
                >Product</a
              >
            </li>
            <li>
              <a
                class="${fn:startsWith(page, 'deal-') ? 'active' : ''}"
                href="${pageContext.request.contextPath}/sale/deal/list"
                >Deals</a
              >
            </li>
            <li>
              <a
                class="${page eq 'sales-funnel' ? 'active' : ''}"
                href="${pageContext.request.contextPath}/funnel"
                >Sales Funnel</a
              >
            </li>
            <li>
              <a
                class="${page eq 'revenue-forecast' ? 'active' : ''}"
                href="${pageContext.request.contextPath}/forecast"
                >Revenue Forecast</a
              >
            </li>
          </ul>
        </li>

        <!-- CUSTOMERS -->
        <li class="submenu">
          <a href="javascript:void(0);">
            <i class="fas fa-users"></i>
            <span>People</span>
            <span class="menu-arrow"></span>
          </a>

          <ul style="${page eq 'customer-list' ? 'display:block;' : ''}">
            <li>
              <a
                class="${page eq 'customer-list' ? 'active' : ''}"
                href="${pageContext.request.contextPath}/customers">
                Customer List
              </a>
            </li>
            <li>
              <a
                class="${page eq 'customer-add' ? 'active' : ''}"
                href="${pageContext.request.contextPath}/customers/add-customer">
                Add New Customer
              </a>
            </li>
            <li>
              <a
                class="${page eq 'customer-detail' ? 'active' : ''}"
                href="${pageContext.request.contextPath}/customers">
                Customer View 360
              </a>
            </li>
            <li>
              <a
                class="${page eq 'customer-segments' ? 'active' : ''}"
                href="${pageContext.request.contextPath}/customers/segments">
                Customer Segments
              </a>
            </li>
            <li>
              <a
                class="${page eq 'merge-customers' ? 'active' : ''}"
                href="${pageContext.request.contextPath}/customers/merge-request/list">
                Merge Customers
              </a>
            </li>
          </ul>
        </li>

        <!-- ACTIVITIES -->
        <li class="submenu">
          <a href="javascript:void(0);">
            <i class="fas fa-history"></i>
            <span>Activities</span>
            <span class="menu-arrow"></span>
          </a>

          <ul style="${page eq 'activity-list' ? 'display:block;' : ''}">
            <li>
              <a
                class="${page eq 'activity-list' ? 'active' : ''}"
                href="${pageContext.request.contextPath}/activities/list">
                Activities List
              </a>
            </li>
            <li>
              <a
                class="${page eq 'activity-create' ? 'active' : ''}"
                href="${pageContext.request.contextPath}/activities/create">
                Create Activity
              </a>
            </li>
            <li>
              <a
                class="${page eq 'activity-details' ? 'active' : ''}"
                href="${pageContext.request.contextPath}/activities/details">
                Activity Details
              </a>
            </li>
            <li>
              <a
                class="${page eq 'activity-edit' ? 'active' : ''}"
                href="${pageContext.request.contextPath}/activities/edit">
                Edit Activity
              </a>
            </li>
          </ul>
        </li>
        <!-- NOTIFICATIONS -->
        <li class="submenu">
          <a href="javascript:void(0);">
            <i class="fas fa-bell"></i>
            <span>Notifications</span>
            <span class="menu-arrow"></span>
          </a>

          <ul
            style="${fn:startsWith(page, 'notification-') ? 'display:block;' : ''}">
            <li>
              <a
                class="${page eq 'notification-list' ? 'active' : ''}"
                href="${pageContext.request.contextPath}/notifications/list">
                <i class="fas fa-inbox"></i>
                Notification Inbox
              </a>
            </li>
            <li>
              <a
                class="${page eq 'notification-rules' ? 'active' : ''}"
                href="${pageContext.request.contextPath}/notifications/rules">
                <i class="fas fa-clock"></i>
                Alarm Rules
              </a>
            </li>
          </ul>
        </li>
        <!-- TASKS -->
        <li class="submenu">
          <a href="javascript:void(0);">
            <i class="fas fa-tasks"></i>
            <span>Tasks</span>
            <span class="menu-arrow"></span>
          </a>

          <ul
            style="${page eq 'task-list' || page eq 'task-schedule' ? 'display:block;' : ''}">
            <li>
              <a
                class="${page eq 'task-list' ? 'active' : ''}"
                href="${pageContext.request.contextPath}/tasks/list">
                Tasks List
              </a>
            </li>
            <li>
              <a
                class="${page eq 'task-schedule' ? 'active' : ''}"
                href="${pageContext.request.contextPath}/tasks/schedule">
                Schedule
              </a>
            </li>
            <li>
              <a
                class="${page eq 'task-create' ? 'active' : ''}"
                href="${pageContext.request.contextPath}/tasks/create">
                Create Task
              </a>
            </li>
            <li>
              <a
                class="${page eq 'task-details' ? 'active' : ''}"
                href="${pageContext.request.contextPath}/tasks/details">
                Task Details
              </a>
            </li>
            <li>
              <a
                class="${page eq 'task-edit' ? 'active' : ''}"
                href="${pageContext.request.contextPath}/tasks/edit">
                Edit Task
              </a>
            </li>
          </ul>
        </li>
        <!-- SUPPORT -->
        <li>
          <a href="${pageContext.request.contextPath}/ticket">
            <i class="fas fa-life-ring"></i>
            <span>Support Tickets</span>
          </a>
        </li>

        <!-- REPORT -->
        <c:if
          test="${fn:toUpperCase(userRole) eq 'ADMIN' || fn:toUpperCase(userRole) eq 'MARKETING'}">
          <li>
            <a href="${pageContext.request.contextPath}/marketing/report">
              <i class="fas fa-chart-bar"></i>
              <span>Reports</span>
            </a>
          </li>
        </c:if>

        <!-- ADMIN -->
        <li class="submenu">
          <a href="javascript:void(0);">
            <i class="fas fa-cog"></i>
            <span>Administration</span>
            <span class="menu-arrow"></span>
          </a>
          <ul>
            <li><a href="${pageContext.request.contextPath}/user">Users</a></li>
            <li>
              <a href="${pageContext.request.contextPath}/monitor"
                >Monitoring</a
              >
            </li>
            <li>
              <a href="${pageContext.request.contextPath}/settings">Settings</a>
            </li>
          </ul>
        </li>
      </ul>
    </div>
  </div>
</div>
