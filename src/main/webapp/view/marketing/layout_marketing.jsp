<%@ page contentType="text/html;charset=UTF-8" language="java" %> <%@ taglib
uri="http://java.sun.com/jsp/jstl/core" prefix="c" %> <%@ taglib
uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %> <%@ page
isELIgnored="false" %>
<!DOCTYPE html>
<html lang="vi">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <title>${pageTitle} - CRM System</title>

    <!-- Bootstrap CSS -->
    <link
      href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"
      rel="stylesheet"
    />

    <!-- Bootstrap Icons -->
    <link
      href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css"
      rel="stylesheet"
    />

    <!-- Campaign Module CSS -->
    <link
      rel="stylesheet"
      href="${pageContext.request.contextPath}/assets/css/campaign.css"
    />

    <!-- Font Awesome (optional) -->
    <link
      rel="stylesheet"
      href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"
    />
  </head>

  <body>
    <!-- Navigation Bar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
      <div class="container-fluid">
        <a
          class="navbar-brand fw-bold"
          href="${pageContext.request.contextPath}/"
        >
          <i class="bi bi-briefcase-fill"></i> CRM-Project
        </a>

        <button
          class="navbar-toggler"
          type="button"
          data-bs-toggle="collapse"
          data-bs-target="#navbarNav"
          aria-controls="navbarNav"
          aria-expanded="false"
          aria-label="Toggle navigation"
        >
          <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navbarNav">
          <ul class="navbar-nav ms-auto">
            <li class="nav-item">
              <a
                class="nav-link"
                href="${pageContext.request.contextPath}/marketing/campaign?action=list"
              >
                <i class="bi bi-megaphone"></i> Campaign
              </a>
            </li>
            <li class="nav-item">
              <a
                class="nav-link"
                href="${pageContext.request.contextPath}/marketing/lead?action=list"
              >
                <i class="bi bi-people"></i> Leads
              </a>
            </li>
            <li class="nav-item">
              <a
                class="nav-link"
                href="${pageContext.request.contextPath}/marketing/report"
              >
                <i class="bi bi-graph-up"></i> Reports
              </a>
            </li>
            <li class="nav-item dropdown">
              <a
                class="nav-link dropdown-toggle"
                href="#"
                role="button"
                data-bs-toggle="dropdown"
                aria-expanded="false"
              >
                <i class="bi bi-person-circle"></i> Marketing
              </a>
              <ul class="dropdown-menu dropdown-menu-end">
                <li>
                  <a
                    class="dropdown-item"
                    href="${pageContext.request.contextPath}/profile"
                  >
                    <i class="bi bi-person"></i> Profile
                  </a>
                </li>
                <li><hr class="dropdown-divider" /></li>
                <li>
                  <a
                    class="dropdown-item"
                    href="${pageContext.request.contextPath}/logout"
                  >
                    <i class="bi bi-box-arrow-right"></i> Logout
                  </a>
                </li>
              </ul>
            </li>
          </ul>
        </div>
      </div>
    </nav>

    <!-- Main Content -->
    <main class="main-content">
      <!-- Page Header - Dynamic per page -->
      <jsp:include page="${contentPage}" />
    </main>

    <!-- Footer -->
    <footer class="footer">
      <div class="container-fluid">
        <p class="mb-0">
          &copy; 2026 CRM-Project v1.0 | Marketing Module | All rights reserved
        </p>
      </div>
    </footer>

    <!-- Bootstrap JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <!-- jQuery (if needed) -->
    <script src="${pageContext.request.contextPath}/assets/js/jquery-3.6.0.min.js"></script>

    <!-- Custom Scripts -->
    <script>
      // Add active class to current menu item
      document.addEventListener("DOMContentLoaded", function () {
        const currentLocation = location.pathname;
        const menuItems = document.querySelectorAll(".navbar-nav .nav-link");

        menuItems.forEach(function (item) {
          const link = item.getAttribute("href");
          if (link && currentLocation.includes(link)) {
            item.classList.add("active");
          }
        });
      });
    </script>
  </body>
</html>
