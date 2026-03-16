package controller.common;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.util.List;

import dao.SalesFunnelDAO;
import dto.report.SalesFunnelStageDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import util.DBContext;

@WebServlet(name = "SalesFunnelController", urlPatterns = { "/funnel" })
public class SalesFunnelController extends HttpServlet {

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
        if (roleId != 2 && roleId != 5) {
            response.sendRedirect(request.getContextPath() + "/login?error=accessDenied");
            return;
        }

        try (Connection conn = DBContext.getConnection()) {
            SalesFunnelDAO dao = new SalesFunnelDAO(conn);
            List<SalesFunnelStageDTO> stages = dao.getSalesFunnelSummary();

            int totalDeals = 0;
            BigDecimal totalExpected = BigDecimal.ZERO;
            BigDecimal totalWeighted = BigDecimal.ZERO;
            BigDecimal totalActual = BigDecimal.ZERO;

            for (SalesFunnelStageDTO s : stages) {
                totalDeals += s.getDealCount();
                totalExpected = totalExpected.add(s.getExpectedSum());
                totalWeighted = totalWeighted.add(s.getWeightedExpectedSum());
                totalActual = totalActual.add(s.getActualSum());
            }

            request.setAttribute("stages", stages);
            request.setAttribute("totalDeals", totalDeals);
            request.setAttribute("totalExpected", totalExpected);
            request.setAttribute("totalWeighted", totalWeighted);
            request.setAttribute("totalActual", totalActual);

            request.getRequestDispatcher("/view/sale/funnel/salesFunnel.jsp").forward(request, response);

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
