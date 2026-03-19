package controller.sale.deal;

import dao.CustomerLookupDAO;
import dao.DealDAO;
import dao.DealProductDAO;
import dao.LeadLookupDAO;
import dto.DealItemDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Customer;
import model.Deal;
import model.Lead;
import util.DBContext;

import java.io.IOException;
import java.sql.Connection;
import java.util.List;

@WebServlet("/sale/deal/detail")
public class DealDetailController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try (Connection conn = DBContext.getConnection()) {

            int id = Integer.parseInt(request.getParameter("id"));

            DealDAO dealDAO = new DealDAO(conn);
            DealProductDAO dealProductDAO = new DealProductDAO(conn);

            Deal deal = dealDAO.getById(id);
            if (deal == null) {
                response.sendRedirect(request.getContextPath() + "/sale/deal/list");
                return;
            }

            List<DealItemDTO> items = dealProductDAO.getDealItems(id);

            Customer customer = null;
            if (deal.getCustomerId() > 0) {
                CustomerLookupDAO customerDAO = new CustomerLookupDAO(conn);
                for (Customer c : customerDAO.getAllCustomersBasic()) {
                    if (c.getCustomerId() == deal.getCustomerId()) {
                        customer = c;
                        break;
                    }
                }
            }

            Lead lead = null;
            if (deal.getLeadId() > 0) {
                LeadLookupDAO leadDAO = new LeadLookupDAO(conn);
                for (Lead l : leadDAO.getAllLeadsBasic()) {
                    if (l.getLeadId() == deal.getLeadId()) {
                        lead = l;
                        break;
                    }
                }
            }

            request.setAttribute("deal", deal);
            request.setAttribute("items", items);
            request.setAttribute("customer", customer);
            request.setAttribute("lead", lead);

            request.setAttribute("pageTitle", "Deal Detail - CRM");
            request.setAttribute("contentPage", "sale/deal/dealDetail.jsp");
            request.setAttribute("pageCss", "deal_detail.css");
            request.setAttribute("page", "deal-detail");
            request.getRequestDispatcher("/view/layout.jsp").forward(request, response);
//            request.getRequestDispatcher("/view/sale/deal/dealDetail.jsp").forward(request, response);

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
