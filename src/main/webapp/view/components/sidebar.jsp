<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page isELIgnored="false" %>
<div class="sidebar" id="sidebar">
    <div class="sidebar-inner slimscroll">
        <div id="sidebar-menu" class="sidebar-menu">
            <ul>

                <!-- DASHBOARD -->
                <li>
                    <a href="${pageContext.request.contextPath}/dashboard">
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
                    <ul>
                        <li><a href="${pageContext.request.contextPath}/campaign/list">Campaign List</a></li>
                        <li><a href="${pageContext.request.contextPath}/campaign/create">Create Campaign</a></li>
                    </ul>
                </li>

                <!-- LEADS -->
                <li class="submenu">
                    <a href="javascript:void(0);">
                        <i class="fas fa-user-plus"></i>
                        <span>Leads</span>
                        <span class="menu-arrow"></span>
                    </a>
                    <ul>
                        <li><a href="${pageContext.request.contextPath}/lead/list">Lead List</a></li>
                        <li><a href="${pageContext.request.contextPath}/lead/import">Import Leads</a></li>
                    </ul>
                </li>

                <!-- SALES -->
                <li class="submenu">
                    <a href="javascript:void(0);">
                        <i class="fas fa-handshake"></i>
                        <span>Sales</span>
                        <span class="menu-arrow"></span>
                    </a>
                    <ul>
                        <li><a href="${pageContext.request.contextPath}/category">Category</a></li>
                        <li><a href="${pageContext.request.contextPath}/product">Product</a></li>
                        <li><a href="${pageContext.request.contextPath}/deal">Deals</a></li>
                        <li><a href="${pageContext.request.contextPath}/funnel">Sales Funnel</a></li>
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
                            <a class="${page eq 'customer-list' ? 'active' : ''}"
                               href="${pageContext.request.contextPath}/customers">
                                Customer List
                            </a>
                        </li>
                        <li>
                            <a class="${page eq 'customer-add' ? 'active' : ''}"
                               href="${pageContext.request.contextPath}/customers/add-customer">
                                Add New Customer
                            </a>
                        </li>
                        <li>
                            <a class="${page eq 'customer-detail' ? 'active' : ''}"
                               href="${pageContext.request.contextPath}/customers/detail">
                                Customer View 360
                            </a>
                        </li>
                        <li>
                            <a class="${page eq 'customer-segments' ? 'active' : ''}"
                               href="${pageContext.request.contextPath}/customers/segments">
                                Customer Segments
                            </a>
                        </li>
                    </ul>
                </li>

                <!-- ACTIVITIES -->
                <li>
                    <a href="${pageContext.request.contextPath}/activity">
                        <i class="fas fa-history"></i>
                        <span>Activities</span>
                    </a>
                </li>

                <!-- TASKS -->
                <li>
                    <a href="${pageContext.request.contextPath}/task">
                        <i class="fas fa-tasks"></i>
                        <span>Tasks</span>
                    </a>
                </li>

                <!-- SUPPORT -->
                <li>
                    <a href="${pageContext.request.contextPath}/ticket">
                        <i class="fas fa-life-ring"></i>
                        <span>Support Tickets</span>
                    </a>
                </li>

                <!-- REPORT -->
                <li>
                    <a href="${pageContext.request.contextPath}/report">
                        <i class="fas fa-chart-bar"></i>
                        <span>Reports</span>
                    </a>
                </li>

                <!-- ADMIN -->
                <li class="submenu">
                    <a href="javascript:void(0);">
                        <i class="fas fa-cog"></i>
                        <span>Administration</span>
                        <span class="menu-arrow"></span>
                    </a>
                    <ul>
                        <li><a href="${pageContext.request.contextPath}/user">Users</a></li>
                        <li><a href="${pageContext.request.contextPath}/monitor">Monitoring</a></li>
                        <li><a href="${pageContext.request.contextPath}/settings">Settings</a></li>
                    </ul>
                </li>

            </ul>
        </div>
    </div>
</div>

