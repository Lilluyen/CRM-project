package controller.sale.product;

import dao.CategoryDAO;
import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Category;
import model.Product;
import util.DBContext;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/sale/product/create")
public class CreateProductController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try (Connection conn = DBContext.getConnection()) {

            CategoryDAO categoryDAO = new CategoryDAO(conn);
            List<Category> categories = categoryDAO.getAllCategories("ACTIVE");
            request.setAttribute("categories", categories);

            request.setAttribute("pageTitle", "Add Product - CRM");
            request.setAttribute("contentPage", "sale/product/productForm.jsp");
            request.setAttribute("pageCss", "product_form.css");
            request.setAttribute("page", "product-form");
            request.getRequestDispatcher("/view/layout.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try (Connection conn = DBContext.getConnection()) {

            ProductDAO productDAO = new ProductDAO(conn);

            Product p = extractProductFromRequest(request);

            if (productDAO.skuExists(p.getSku(), null)) {
                throw new IllegalArgumentException("SKU đã tồn tại.");
            }

            List<Integer> categoryIds = extractCategoryIds(request);

            int newId = productDAO.createProduct(p, categoryIds);
            if (newId <= 0) {
                throw new RuntimeException("Tạo sản phẩm thất bại.");
            }

            response.sendRedirect(request.getContextPath() + "/sale/product/list");

        } catch (Exception e) {
            try (Connection conn = DBContext.getConnection()) {
                CategoryDAO categoryDAO = new CategoryDAO(conn);
                request.setAttribute("categories", categoryDAO.getAllCategories("ACTIVE"));
            } catch (Exception ignored) {
            }

            request.setAttribute("error", e.getMessage());
            request.setAttribute("product", extractProductFromRequestSafe(request));
            request.setAttribute("pageTitle", "Add Product - CRM");
            request.setAttribute("contentPage", "sale/product/productForm.jsp");
            request.setAttribute("pageCss", "product_form.css");
            request.setAttribute("page", "product-form");
            request.getRequestDispatcher("/view/layout.jsp").forward(request, response);
        }
    }

    private Product extractProductFromRequest(HttpServletRequest request) {
        String name = request.getParameter("name");
        String sku = request.getParameter("sku");
        String priceStr = request.getParameter("price");
        String status = request.getParameter("status");
        String description = request.getParameter("description");

        if (name == null || name.trim().isEmpty()) {
            throw new IllegalArgumentException("Product Name không được để trống.");
        }
        if (sku == null || sku.trim().isEmpty()) {
            throw new IllegalArgumentException("SKU không được để trống.");
        }

        BigDecimal price = BigDecimal.ZERO;
        if (priceStr != null && !priceStr.isBlank()) {
            try {
                price = new BigDecimal(priceStr.trim());
            } catch (NumberFormatException ex) {
                throw new IllegalArgumentException("Price không hợp lệ.");
            }
        }

        if (status == null || status.isBlank()) {
            status = "ACTIVE";
        }

        Product p = new Product();
        p.setName(name.trim());
        p.setSku(sku.trim());
        p.setPrice(price);
        p.setStatus(status.trim());
        p.setDescription(description != null ? description.trim() : "");
        return p;
    }

    private Product extractProductFromRequestSafe(HttpServletRequest request) {
        Product p = new Product();
        p.setName(request.getParameter("name"));
        p.setSku(request.getParameter("sku"));
        try {
            String priceStr = request.getParameter("price");
            if (priceStr != null && !priceStr.isBlank()) {
                p.setPrice(new BigDecimal(priceStr.trim()));
            }
        } catch (Exception ignored) {
        }
        p.setStatus(request.getParameter("status"));
        p.setDescription(request.getParameter("description"));
        return p;
    }

    private List<Integer> extractCategoryIds(HttpServletRequest request) {
        String[] values = request.getParameterValues("categoryIds");
        List<Integer> ids = new ArrayList<>();
        if (values == null) {
            return ids;
        }

        for (String v : values) {
            try {
                ids.add(Integer.parseInt(v));
            } catch (NumberFormatException ignored) {
            }
        }
        return ids;
    }
}
