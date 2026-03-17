package controller.sale.deal;

import java.io.IOException;
import java.sql.Connection;
import java.util.List;

import dao.DealDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Deal;
import util.DBContext;

@WebServlet("/sale/deal/list")
public class ViewDealListController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try (Connection conn = DBContext.getConnection()) {

            DealDAO dao = new DealDAO(conn);

            String search = request.getParameter("search");
            String stage = request.getParameter("stage");

            int page = 1;
            int pageSize = 10;

            String pageParam = request.getParameter("page");
            if (pageParam != null && !pageParam.isBlank()) {
                page = Integer.parseInt(pageParam);
            }

            List<Deal> list = dao.getDealList(search, stage, page, pageSize);
            int total = dao.countDeals(search, stage);
            int totalPages = (int) Math.ceil((double) total / pageSize);

            request.setAttribute("dealList", list);
            request.setAttribute("search", search);
            request.setAttribute("stage", stage);
            request.setAttribute("stages", DealDAO.getDefaultStages());
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);

            request.setAttribute("pageTitle", "Deal Management - CRM");
            request.setAttribute("contentPage", "sale/deal/dealList.jsp");
            request.setAttribute("pageCss", "deal_list.css");
            request.setAttribute("page", "deal-list");
            request.getRequestDispatcher("/view/layout.jsp").forward(request, response);
            request.getRequestDispatcher("/view/sale/deal/dealList.jsp").forward(request, response);

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
