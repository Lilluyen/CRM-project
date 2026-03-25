package controller.sale.deal;

import dao.CustomerDAO;
import dao.DealDAO;
import dao.LeadDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Customer;
import model.Deal;
import model.Lead;
import model.User;
import util.DBContext;
import util.CustomerActivityUtil;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;

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
            Deal beforeUpdate = dao.getById(dealId);
            dao.updateDealStage(dealId, stage, probability, actualValue);

            //xử lý Closed Won
            if ("Closed Won".equalsIgnoreCase(stage)) {
                handleClosedWon(dealId, conn, (User) request.getSession().getAttribute("user"));
            }

            if (beforeUpdate != null) {
                Deal afterUpdate = dao.getById(dealId);
                Integer customerId = afterUpdate != null ? afterUpdate.getCustomerId() : beforeUpdate.getCustomerId();
                if (customerId != null && customerId > 0) {
                    String oldStage = beforeUpdate.getStage() == null ? "(none)" : beforeUpdate.getStage();
                    String newStage = stage == null ? "(none)" : stage;
                    if (!oldStage.equalsIgnoreCase(newStage)) {
                        CustomerActivityUtil.logCustomerActivity(
                                customerId,
                                "UPDATE",
                                "Deal stage updated",
                                "Updated deal #" + dealId + " stage: " + oldStage + " -> " + newStage + ".",
                                (User) request.getSession().getAttribute("user"));
                    }
                }
            }
            conn.commit();
            String redirect = request.getHeader("Referer");
            if (redirect == null || redirect.isBlank()) {
                redirect = request.getContextPath() + "/sale/deal/list";
            }
            response.sendRedirect(redirect);

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private void handleClosedWon(int dealId, Connection conn, User currentUser) throws SQLException {

        DealDAO dealDAO = new DealDAO(conn);
        LeadDAO leadDAO = new LeadDAO();
        CustomerDAO customerDAO = new CustomerDAO();

        // 1. Lấy deal
        Deal deal = dealDAO.getById(dealId);


        if (deal.getCustomerId() != null && deal.getCustomerId() > 0) {

            int customerId = deal.getCustomerId();

            // 1. update last_purchase
            customerDAO.updateLastPurchase(conn, customerId);

            // 2. tính lại total_spent
           customerDAO.updateTotalSpent(conn, customerId);

           // 3. tính lại loyalty_tier
           customerDAO.updateLoyaltyTier(conn, customerId);
        }

        // 3. Nếu có lead → convert
        if (deal.getLeadId() > 0) {

            Lead lead = leadDAO.getLeadById(deal.getLeadId());

            //  tránh convert lại
            if (lead.isConverted()) {
                // chỉ cần gắn lại customer vào deal
                dealDAO.updateCustomerForDeal(dealId, lead.getConvertedCustomerId());
                return;
            }

            // 4. Check duplicate customer (theo phone/email)
            Customer existing = customerDAO.findByPhoneOrEmail(conn, lead.getPhone(), lead.getEmail());

            int customerId;

            if (existing != null) {
                customerId = existing.getCustomerId();
            } else {
                // 5. Tạo customer mới
                customerId = customerDAO.insertFromLead(conn, lead);
            }

            // 6. Update lead
            leadDAO.markConverted(conn, lead.getLeadId(), customerId);

            // 7. Update deal
            dealDAO.updateCustomerForDeal(dealId, customerId);

            // 8. tính lại total_spent
            customerDAO.updateTotalSpent(conn, customerId);
            // 9. tính lại loyalty_tier
            customerDAO.updateLoyaltyTier(conn, customerId);
            CustomerActivityUtil.logCustomerActivity(
                    customerId,
                    "UPDATE",
                    "Lead converted",
                    "Converted lead #" + lead.getLeadId() + " to customer via deal #" + dealId + ".",
                    currentUser);
        }
    }
}
