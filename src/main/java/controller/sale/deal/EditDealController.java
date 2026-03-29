package controller.sale.deal;

import dao.*;
import dto.DealItemDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.*;
import util.CustomerActivityUtil;
import util.DBContext;
import util.DealActivityUtil;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/sale/deal/edit")
public class EditDealController extends HttpServlet {

    private void forwardForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("pageTitle", "Deal Form - CRM");
        request.setAttribute("contentPage", "sale/deal/dealForm.jsp");
        request.setAttribute("pageCss", "deal_form.css");
        request.setAttribute("page", "deal-form");
        request.getRequestDispatcher("/view/layout.jsp").forward(request, response);
//        request.getRequestDispatcher("/view/sale/deal/dealForm.jsp").forward(request, response);
    }

    private void loadLookups(Connection conn, HttpServletRequest request) throws Exception {
        CustomerLookupDAO customerDAO = new CustomerLookupDAO(conn);
        LeadLookupDAO leadDAO = new LeadLookupDAO(conn);
        ProductLookupDAO productDAO = new ProductLookupDAO(conn);

        List<Customer> customers = customerDAO.getAllCustomersBasic();
        List<Lead> leads = leadDAO.getAllLeadsBasic();
        List<Product> products = productDAO.getAllActiveProductsBasic();
        request.setAttribute("customers", customers);
        request.setAttribute("leads", leads);
        request.setAttribute("products", products);
        request.setAttribute("stages", DealDAO.getDefaultStages());
    }

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

            // Tự set relatedType/relatedId từ deal, không phụ thuộc URL
            if (deal.getLeadId() > 0) {
                request.setAttribute("relatedType", "LEAD");
                request.setAttribute("relatedId", String.valueOf(deal.getLeadId()));
            } else if (deal.getCustomerId() > 0) {
                request.setAttribute("relatedType", "CUSTOMER");
                request.setAttribute("relatedId", String.valueOf(deal.getCustomerId()));
            }

            List<DealItemDTO> items = dealProductDAO.getDealItems(id);

            loadLookups(conn, request);
            request.setAttribute("deal", deal);
            request.setAttribute("items", items);

            forwardForm(request, response);

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int dealId = 0;
        try {
            dealId = Integer.parseInt(request.getParameter("dealId"));
        } catch (Exception ignored) {
        }

        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            Deal deal = extractDealFromRequest(request);
            deal.setDealId(dealId);

            DealDAO dealDAO = new DealDAO(conn);
            DealProductDAO dealProductDAO = new DealProductDAO(conn);
            Deal beforeUpdate = dealDAO.getById(dealId);
            User currentUser = (User) request.getSession().getAttribute("user");

            if (!dealDAO.updateDeal(deal)) {
                throw new RuntimeException("Cập nhật deal thất bại.");
            }
            if ("Closed Won".equalsIgnoreCase(deal.getStage())) {
                handleClosedWon(dealId, conn, currentUser);
            }

            Deal afterUpdate = dealDAO.getById(dealId);
            Integer customerIdForLog = afterUpdate != null ? afterUpdate.getCustomerId() : deal.getCustomerId();
            Integer leadIdForLog = afterUpdate != null ? afterUpdate.getLeadId() : deal.getLeadId();
            String dealNameForLog = afterUpdate != null ? afterUpdate.getDealName() : deal.getDealName();

            DealActivityUtil.logDealUpdated(
                    conn,
                    dealId,
                    dealNameForLog,
                    customerIdForLog,
                    leadIdForLog,
                    currentUser);

            if (beforeUpdate != null) {
                String oldStage = beforeUpdate.getStage();
                String newStage = afterUpdate != null ? afterUpdate.getStage() : deal.getStage();
                if (!safeEqualsIgnoreCase(oldStage, newStage)) {
                    DealActivityUtil.logDealStageUpdated(
                            conn,
                            dealId,
                            oldStage,
                            newStage,
                            customerIdForLog,
                            leadIdForLog,
                            currentUser);
                }
            }
            List<DealItemDTO> items = extractItemsFromRequest(request);
            dealProductDAO.replaceDealItems(dealId, items);

            conn.commit();
            response.sendRedirect(request.getContextPath() + "/sale/deal/detail?id=" + dealId);

        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (Exception ignored) {
                }
            }

            try (Connection lookupConn = DBContext.getConnection()) {
                loadLookups(lookupConn, request);
            } catch (Exception ignored) {
            }

            Deal deal = extractDealFromRequestSafe(request);
            deal.setDealId(dealId);
            request.setAttribute("deal", deal);
            request.setAttribute("items", extractItemsFromRequestSafe(request));
            request.setAttribute("error", e.getMessage());
            forwardForm(request, response);

        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (Exception ignored) {
                }
            }
        }
    }

    private Deal extractDealFromRequest(HttpServletRequest request) {
        String relatedId = request.getParameter("relatedId");
        String relatedType = request.getParameter("relatedType");
        String dealName = request.getParameter("dealName");
        String customerIdStr = "";
        String leadIdStr = "";
        String expectedValueStr = request.getParameter("expectedValue");
        String actualValueStr = request.getParameter("actualValue");
        String stage = request.getParameter("stage");
        String probabilityStr = request.getParameter("probability");
        String expectedCloseDateStr = request.getParameter("expectedCloseDate");

        if (dealName == null || dealName.trim().isEmpty()) {
            throw new IllegalArgumentException("Deal Name không được để trống.");
        }

        Deal d = new Deal();
        d.setDealName(dealName.trim());

        int customerId = parseIntSafe(customerIdStr);
        int leadId = parseIntSafe(leadIdStr);
        if (relatedType.equalsIgnoreCase("lead")) {
            leadId = Integer.parseInt(relatedId);
        } else {
            customerId = Integer.parseInt(relatedId);
        }
        d.setCustomerId(customerId);
        d.setLeadId(leadId);
        d.setExpectedValue(parseBigDecimal(expectedValueStr, BigDecimal.ZERO));

        if (actualValueStr != null && !actualValueStr.isBlank()) {
            d.setActualValue(parseBigDecimal(actualValueStr, null));
        }

        if (stage == null || stage.isBlank()) {
            stage = "Prospecting";
        }
        d.setStage(stage);

        Integer prob = null;
        if (probabilityStr != null && !probabilityStr.isBlank()) {
            prob = parseInt(probabilityStr);
        }
        if (prob == null || prob < 0 || prob > 100) {
            Integer defaultProb = DealDAO.stageToDefaultProbability(stage);
            d.setProbability(defaultProb != null ? defaultProb : 0);
        } else {
            d.setProbability(prob);
        }

        if (expectedCloseDateStr != null && !expectedCloseDateStr.isBlank()) {
            d.setExpectedCloseDate(LocalDate.parse(expectedCloseDateStr));
        }

        String ownerIdStr = request.getParameter("ownerId");
        d.setOwnerId(parseIntSafe(ownerIdStr));

        if (d.getOwnerId() <= 0) {
            throw new IllegalArgumentException("Owner không hợp lệ.");
        }

        return d;
    }

    private Deal extractDealFromRequestSafe(HttpServletRequest request) {
        Deal d = new Deal();
        d.setDealName(request.getParameter("dealName"));
        String relatedId = request.getParameter("relatedId");
        String relatedType = request.getParameter("relatedType");
//        String customerIdStr = "";
//        String leadIdStr = "";
//        d.setCustomerId(parseIntSafe(customerIdStr));
//        d.setLeadId(parseIntSafe(leadIdStr));
        if ("lead".equalsIgnoreCase(relatedType)) {
            d.setLeadId(parseIntSafe(relatedId));
        } else {
            d.setCustomerId(parseIntSafe(relatedId));
        }
        try {
            d.setExpectedValue(parseBigDecimal(request.getParameter("expectedValue"), BigDecimal.ZERO));
        } catch (Exception ignored) {
        }
        try {
            String actual = request.getParameter("actualValue");
            if (actual != null && !actual.isBlank()) {
                d.setActualValue(parseBigDecimal(actual, null));
            }
        } catch (Exception ignored) {
        }
        d.setStage(request.getParameter("stage"));
        d.setProbability(parseIntSafe(request.getParameter("probability")));
        try {
            String close = request.getParameter("expectedCloseDate");
            if (close != null && !close.isBlank()) {
                d.setExpectedCloseDate(LocalDate.parse(close));
            }
        } catch (Exception ignored) {
        }
        d.setOwnerId(parseIntSafe(request.getParameter("ownerId")));
        return d;
    }

    private List<DealItemDTO> extractItemsFromRequest(HttpServletRequest request) {
        String[] productIds = request.getParameterValues("productId");
        String[] quantities = request.getParameterValues("quantity");
        String[] unitPrices = request.getParameterValues("unitPrice");
        String[] discounts = request.getParameterValues("discount");

        List<DealItemDTO> items = new ArrayList<>();
        if (productIds == null) {
            return items;
        }

        for (int i = 0; i < productIds.length; i++) {
            int productId = parseIntSafe(productIds[i]);
            int qty = (quantities != null && i < quantities.length) ? parseIntSafe(quantities[i]) : 0;
            BigDecimal unit = (unitPrices != null && i < unitPrices.length)
                    ? parseBigDecimal(unitPrices[i], BigDecimal.ZERO)
                    : BigDecimal.ZERO;
            BigDecimal disc = (discounts != null && i < discounts.length)
                    ? parseBigDecimal(discounts[i], BigDecimal.ZERO)
                    : BigDecimal.ZERO;

            if (productId <= 0 || qty <= 0) {
                continue;
            }

            if (disc.compareTo(BigDecimal.ZERO) < 0 || disc.compareTo(new BigDecimal("100")) > 0) {
                throw new IllegalArgumentException("Discount phải trong khoảng 0-100.");
            }

            BigDecimal total = unit.multiply(new BigDecimal(qty))
                    .multiply(BigDecimal.ONE.subtract(disc.divide(new BigDecimal("100"))));

            DealItemDTO item = new DealItemDTO();
            item.setProductId(productId);
            item.setQuantity(qty);
            item.setUnitPrice(unit);
            item.setDiscount(disc);
            item.setTotalPrice(total);
            items.add(item);
        }

        return items;
    }

    private List<DealItemDTO> extractItemsFromRequestSafe(HttpServletRequest request) {
        try {
            return extractItemsFromRequest(request);
        } catch (Exception e) {
            return new ArrayList<>();
        }
    }

    private Integer parseInt(String s) {
        if (s == null || s.isBlank()) {
            return null;
        }
        return Integer.parseInt(s.trim());
    }

    private int parseIntSafe(String s) {
        try {
            Integer v = parseInt(s);
            return v == null ? 0 : v;
        } catch (Exception e) {
            return 0;
        }
    }

    private BigDecimal parseBigDecimal(String s, BigDecimal defaultValue) {
        if (s == null || s.isBlank()) {
            return defaultValue;
        }
        return new BigDecimal(s.trim());
    }

    private boolean safeEqualsIgnoreCase(String left, String right) {
        if (left == null && right == null) {
            return true;
        }
        if (left == null || right == null) {
            return false;
        }
        return left.equalsIgnoreCase(right);
    }

    private void handleClosedWon(int dealId, Connection conn, User currentUser) throws SQLException {

        DealDAO dealDAO = new DealDAO(conn);
        LeadDAO leadDAO = new LeadDAO();
        CustomerDAO customerDAO = new CustomerDAO();
        CustomerContactDAO contactDAO = new CustomerContactDAO();

        // 1. Lấy deal
        Deal deal = dealDAO.getById(dealId);


        if (deal.getCustomerId() != null && deal.getCustomerId() > 0) {

            int customerId = deal.getCustomerId();

            // 1. update last_purchase
            customerDAO.updateLastPurchase(conn, customerId);

            // 2. tính lại RFM
            customerDAO.updateTotalSpent(conn, customerId);
            customerDAO.updateLoyaltyTier(conn, customerId);

        }

        // 3. Nếu có lead → convert và tính lại total_spent và loyalty_tier
        if (deal.getLeadId() > 0) {
            Lead lead = leadDAO.getLeadById(deal.getLeadId());

            // tránh convert lại
            if (lead.isConverted()) {
                // chỉ cần gắn lại customer vào deal
                dealDAO.updateCustomerForDeal(dealId, lead.getConvertedCustomerId());
                TaskDAO taskDAO = new TaskDAO(conn);
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

            contactDAO.insertCustomerContact(conn, new CustomerContact(customerId, true, "PHONE", lead.getPhone()));
            contactDAO.insertCustomerContact(conn, new CustomerContact(customerId, true, "EMAIL", lead.getEmail()));
            CustomerActivityUtil.logCustomerActivity(
                    customerId,
                    "UPDATE",
                    "Lead converted",
                    "Converted lead #" + lead.getLeadId() + " to customer via deal #" + dealId + ".",
                    currentUser);
        }
    }
}
