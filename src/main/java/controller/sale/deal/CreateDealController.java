package controller.sale.deal;

import dao.*;
import dto.DealItemDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.*;
import service.NotificationService;
import service.TaskService;
import util.CustomerActivityUtil;
import util.DBContext;
import util.DealActivityUtil;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@WebServlet("/sale/deal/create")
public class CreateDealController extends HttpServlet {

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

        String relatedId = request.getParameter("relatedId");
        String relatedType = request.getParameter("relatedType");
        if ("customer".equalsIgnoreCase(relatedType)) {
            request.setAttribute("relatedType", "CUSTOMER");
        } else if ("lead".equalsIgnoreCase(relatedType)) {
            request.setAttribute("relatedType", "LEAD");
        }
        request.setAttribute("relatedId", relatedId);
        request.setAttribute("customers", customers);
        request.setAttribute("leads", leads);
        request.setAttribute("products", products);
        request.setAttribute("stages", DealDAO.getDefaultStages());
        loadLeadCampaignOptions(request, relatedType, relatedId);

    }

    private void loadLeadCampaignOptions(HttpServletRequest request, String relatedType, String relatedId) {
        Integer selectedCampaignId = parseInt(request.getParameter("campaignId"));
        if (selectedCampaignId != null) {
            request.setAttribute("selectedCampaignId", selectedCampaignId);
        }

        if (!"lead".equalsIgnoreCase(relatedType)) {
            return;
        }

        int leadId = parseIntSafe(relatedId);
        if (leadId <= 0) {
            return;
        }

        CampaignLeadDAO campaignLeadDAO = new CampaignLeadDAO();
        request.setAttribute("leadCampaigns", campaignLeadDAO.getCampaignsByLeadEmail(leadId));
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try (Connection conn = DBContext.getConnection()) {
            loadLookups(conn, request);

            request.setAttribute("deal", new Deal());
            request.setAttribute("items", new ArrayList<DealItemDTO>());
            forwardForm(request, response);

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            Deal deal = extractDealFromRequest(request);
            deal.setOwnerId(request.getSession().getAttribute("user") != null
                    ? ((model.User) request.getSession().getAttribute("user")).getUserId()
                    : 0);
            if (deal.getOwnerId() <= 0) {
                throw new IllegalArgumentException("Owner không hợp lệ. Vui lòng đăng nhập lại.");
            }
            validateCampaignBinding(conn, deal);

            List<DealItemDTO> items = extractItemsFromRequest(request);

            DealDAO dealDAO = new DealDAO(conn);
            DealProductDAO dealProductDAO = new DealProductDAO(conn);

            int newId = dealDAO.createDeal(deal);
            if (newId <= 0) {
                throw new RuntimeException("Tạo deal thất bại.");
            }
            TaskDAO taskDAO = new TaskDAO(conn);
            User user = (User) request.getSession().getAttribute("user");
            if (user == null) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
            Task task = buildTask(request, user);

            TaskService svc = new TaskService(conn);

            boolean ok = svc.createTask(task, request.getParameter("relatedType"), parseInt(request.getParameter("relatedId")));
            svc.assignTask(task.getTaskId(), user.getUserId(), task, user.getUserId());

            if (task.getDueDate() != null) {
                new NotificationService(conn).createForUserWithRule(
                        user.getUserId(),
                        "Task Reminder",
                        "Task \"" + nvl(task.getTitle(), "") + "\" is due at "
                        + task.getDueDate().toString().replace('T', ' '),
                        "TASK", "Task", task.getTaskId(),
                        "ONCE", null, null, task.getDueDate()
                );
            }
            if ("Closed Won".equalsIgnoreCase(deal.getStage())) {
                handleClosedWon(newId, conn, (model.User) request.getSession().getAttribute("user"));
            }
            dealProductDAO.replaceDealItems(newId, items);
            User createdBy = (User) request.getSession().getAttribute("user");
            DealActivityUtil.logDealCreated(
                    conn,
                    newId,
                    deal.getDealName(),
                    deal.getCustomerId(),
                    deal.getLeadId(),
                    createdBy);

            conn.commit();
            response.sendRedirect(request.getContextPath() + "/sale/deal/detail?id=" + newId);

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

            request.setAttribute("error", e.getMessage());
            request.setAttribute("deal", extractDealFromRequestSafe(request));
            request.setAttribute("items", extractItemsFromRequestSafe(request));
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
        String campaignIdStr = request.getParameter("campaignId");
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
        if (relatedType == null || relatedType.isBlank()) {
            throw new IllegalArgumentException("Related Type không được để trống.");
        }
        if (relatedId == null || relatedId.isBlank()) {
            throw new IllegalArgumentException("Related Name không được để trống.");
        }

        if (relatedType.equalsIgnoreCase("lead")) {
            leadId = parseIntSafe(relatedId);
            if (leadId <= 0) {
                throw new IllegalArgumentException("Lead không hợp lệ.");
            }
            d.setCampaignId(parseInt(campaignIdStr));
        } else if (relatedType.equalsIgnoreCase("customer")) {
            customerId = parseIntSafe(relatedId);
            if (customerId <= 0) {
                throw new IllegalArgumentException("Customer không hợp lệ.");
            }
            d.setCampaignId(null);
        } else {
            throw new IllegalArgumentException("Related Type không hợp lệ.");
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

        return d;
    }

    private Deal extractDealFromRequestSafe(HttpServletRequest request) {
        Deal d = new Deal();
        String relatedId = request.getParameter("relatedId");
        String relatedType = request.getParameter("relatedType");
        String campaignIdStr = request.getParameter("campaignId");
        String customerIdStr = "";
        String leadIdStr = "";
        d.setCustomerId(parseIntSafe(customerIdStr));
        d.setLeadId(parseIntSafe(leadIdStr));
        if ("lead".equalsIgnoreCase(relatedType)) {
            d.setLeadId(parseIntSafe(relatedId));
            d.setCampaignId(parseInt(campaignIdStr));
        } else {
            d.setCustomerId(parseIntSafe(relatedId));
            d.setCampaignId(null);
        }
        d.setDealName(request.getParameter("dealName"));

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
        return d;
    }

    private List<DealItemDTO> extractItemsFromRequest(HttpServletRequest request) {
        String[] productIds = request.getParameterValues("productId");
        String[] quantities = request.getParameterValues("quantity");
        String[] unitPrices = request.getParameterValues("unitPrice");
        String[] discounts = request.getParameterValues("discount");

        List<DealItemDTO> items = new ArrayList<>();
        Set<Integer> selectedProductIds = new HashSet<>();
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

            if (!selectedProductIds.add(productId)) {
                throw new IllegalArgumentException("Mỗi sản phẩm chỉ được chọn một lần trong một deal. Vui lòng tăng số lượng thay vì thêm dòng trùng.");
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

    private void validateCampaignBinding(Connection conn, Deal deal) throws SQLException {
        if (deal.getLeadId() <= 0) {
            deal.setCampaignId(null);
            return;
        }

        Integer campaignId = deal.getCampaignId();
        if (campaignId == null || campaignId <= 0) {
            throw new IllegalArgumentException("Vui lòng chọn campaign khi tạo deal cho lead.");
        }

        String sql = "SELECT COUNT(*) "
                + "FROM Campaign_Leads cl "
                + "WHERE cl.campaign_id = ? "
                + "AND cl.lead_id IN ( "
                + "    SELECT l2.lead_id "
                + "    FROM Leads l2 "
                + "    WHERE l2.email = (SELECT l1.email FROM Leads l1 WHERE l1.lead_id = ?) "
                + ")";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, campaignId);
            ps.setInt(2, deal.getLeadId());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    return;
                }
            }
        }

        throw new IllegalArgumentException("Lead không thuộc campaign đã chọn.");
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
                TaskDAO taskDAO = new TaskDAO(conn);
                taskDAO.updateTaskLeadToCus(lead.getConvertedCustomerId(), deal.getLeadId());
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

            TaskDAO taskDAO = new TaskDAO(conn);
            taskDAO.updateTaskLeadToCus(customerId, lead.getLeadId());
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

    private static final DateTimeFormatter DT_FMT
            = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

    private Task buildTask(HttpServletRequest req, User creator) {
        Task t = new Task();
        t.setTitle("Consulting Deal");
        t.setDescription("Consulting Deal of" + req.getParameter("relatedType") + " #" + req.getParameter("relatedId"));
        t.setStatus("In Progress");
        t.setPriority(nvl(req.getParameter("priority"), "Medium"));
        t.setCreatedBy(creator);
        String progress = req.getParameter("progress");
        t.setProgress(progress != null && !progress.isBlank()
                ? Integer.parseInt(progress) : 0);

        String due = req.getParameter("dueDate");
//        if (due != null && !due.isBlank())
        t.setDueDate(LocalDateTime.now().plusWeeks(1));

        String start = req.getParameter("startDate");
//        if (start != null && !start.isBlank())
        t.setStartDate(LocalDateTime.now());

        return t;
    }

    private static String nvl(String s, String def) {
        return s != null ? s : def;
    }
}
