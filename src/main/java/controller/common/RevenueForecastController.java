package controller.common;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.util.List;

import dao.RevenueForecastDAO;
import dto.report.RevenueForecastDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import util.DBContext;

@WebServlet(name = "RevenueForecastController", urlPatterns = { "/forecast" })
public class RevenueForecastController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        int roleId = user.getRole() != null ? user.getRole().getRoleId() : 0;
        if (roleId != 1) {
            response.sendRedirect(request.getContextPath() + "/login?error=accessDenied");
            return;
        }

        String groupBy = request.getParameter("groupBy");
        if (groupBy == null || groupBy.isBlank()) {
            groupBy = "month";
        }

        try (Connection conn = DBContext.getConnection()) {
            RevenueForecastDAO dao = new RevenueForecastDAO(conn);

            List<RevenueForecastDTO> rows;
            switch (groupBy.toLowerCase()) {
                case "quarter":
                    rows = dao.getForecastByQuarter();
                    break;
                case "year":
                    rows = dao.getForecastByYear();
                    break;
                default:
                    groupBy = "month";
                    rows = dao.getForecastByMonth();
                    break;
            }

            int totalDeals = 0;
            BigDecimal totalExpected = BigDecimal.ZERO;
            BigDecimal totalForecasted = BigDecimal.ZERO;

            for (RevenueForecastDTO r : rows) {
                totalDeals += r.getDealCount();
                totalExpected = totalExpected.add(r.getExpectedSum());
                totalForecasted = totalForecasted.add(r.getForecastedRevenue());
            }

            request.setAttribute("rows", rows);
            request.setAttribute("groupBy", groupBy);
            request.setAttribute("totalDeals", totalDeals);
            request.setAttribute("totalExpected", totalExpected);
            request.setAttribute("totalForecasted", totalForecasted);

            request.setAttribute("pageTitle", "Revenue Forecast - CRM");
            request.setAttribute("contentPage", "sale/forecast/revenueForecast.jsp");
            request.setAttribute("pageCss", "revenue_forecast.css");
            request.setAttribute("page", "revenue-forecast");
            request.getRequestDispatcher("/view/layout.jsp").forward(request, response);

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
