package controller.sale.product;

import java.io.IOException;
import java.sql.Connection;
import java.util.List;

import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Product;
import util.DBContext;

@WebServlet("/sale/product/list")
public class ViewProductListController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try (Connection conn = DBContext.getConnection()) {

            ProductDAO dao = new ProductDAO(conn);

            String search = request.getParameter("search");
            String status = request.getParameter("status");

            int page = 1;
            int pageSize = 10;

            String pageParam = request.getParameter("page");
            if (pageParam != null && !pageParam.isBlank()) {
                page = Integer.parseInt(pageParam);
            }

            List<Product> list = dao.getProductList(search, status, page, pageSize);
            int total = dao.countProducts(search, status);
            int totalPages = (int) Math.ceil((double) total / pageSize);

            request.setAttribute("productList", list);
            request.setAttribute("search", search);
            request.setAttribute("status", status);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);

            request.setAttribute("pageTitle", "Product Management - CRM");
            request.setAttribute("contentPage", "sale/product/productList.jsp");
            request.setAttribute("pageCss", "product_list.css");
            request.setAttribute("pageJs", "product_list.js");
            request.setAttribute("page", "product-list");
            request.getRequestDispatcher("/view/layout.jsp");
            request.getRequestDispatcher("/view/sale/product/productList.jsp")
                    .forward(request, response);

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
