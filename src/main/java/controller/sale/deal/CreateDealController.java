package controller.sale.deal;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import dao.CustomerLookupDAO;
import dao.DealDAO;
import dao.DealProductDAO;
import dao.LeadLookupDAO;
import dao.ProductLookupDAO;
import dto.DealItemDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Customer;
import model.Deal;
import model.Lead;
import model.Product;
import util.DBContext;

@WebServlet("/sale/deal/create")
public class CreateDealController extends HttpServlet {

    private void forwardForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("pageTitle", "Deal Form - CRM");
        request.setAttribute("contentPage", "sale/deal/dealForm.jsp");
        request.setAttribute("pageCss", "deal_form.css");
        request.setAttribute("page", "deal-form");
        request.getRequestDispatcher("/view/layout.jsp").forward(request, response);
        request.getRequestDispatcher("/view/sale/deal/dealForm.jsp").forward(request, response);
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

            List<DealItemDTO> items = extractItemsFromRequest(request);

            DealDAO dealDAO = new DealDAO(conn);
            DealProductDAO dealProductDAO = new DealProductDAO(conn);

            int newId = dealDAO.createDeal(deal);
            if (newId <= 0) {
                throw new RuntimeException("Tạo deal thất bại.");
            }

            dealProductDAO.replaceDealItems(newId, items);

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
        String dealName = request.getParameter("dealName");
        String customerIdStr = request.getParameter("customerId");
        String leadIdStr = request.getParameter("leadId");
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

        int customerId = parseInt(customerIdStr);
        int leadId = parseInt(leadIdStr);
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
        d.setDealName(request.getParameter("dealName"));
        d.setCustomerId(parseIntSafe(request.getParameter("customerId")));
        d.setLeadId(parseIntSafe(request.getParameter("leadId")));
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
}
