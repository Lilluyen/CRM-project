package controller.sale.deal;

import java.io.IOException;
import java.sql.Connection;

import dao.DealDAO;
import dao.DealProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import util.DBContext;

@WebServlet("/sale/deal/delete")
public class DeleteDealController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try (Connection conn = DBContext.getConnection()) {

            int id = Integer.parseInt(request.getParameter("id"));

            DealProductDAO dealProductDAO = new DealProductDAO(conn);
            DealDAO dealDAO = new DealDAO(conn);

            dealProductDAO.deleteDealItems(id);
            dealDAO.deleteDeal(id);

            response.sendRedirect(request.getContextPath() + "/sale/deal/list");

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
