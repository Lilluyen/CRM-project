package controller.sale.deal;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;

import dao.DealDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import util.DBContext;

@WebServlet("/sale/deal/stage")
public class UpdateDealStageController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try (Connection conn = DBContext.getConnection()) {

            int dealId = Integer.parseInt(request.getParameter("id"));
            String stage = request.getParameter("stage");

            Integer probability = DealDAO.stageToDefaultProbability(stage);

            BigDecimal actualValue = null;
            String actualValueStr = request.getParameter("actualValue");
            if (actualValueStr != null && !actualValueStr.isBlank()) {
                actualValue = new BigDecimal(actualValueStr.trim());
            }

            DealDAO dao = new DealDAO(conn);
            dao.updateDealStage(dealId, stage, probability, actualValue);

            String redirect = request.getHeader("Referer");
            if (redirect == null || redirect.isBlank()) {
                redirect = request.getContextPath() + "/sale/deal/list";
            }
            response.sendRedirect(redirect);

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
