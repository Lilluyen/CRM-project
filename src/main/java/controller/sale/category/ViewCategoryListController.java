package controller.sale.category;

import java.io.IOException;
import java.sql.Connection;
import java.util.List;

import dao.CategoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Category;
import util.DBContext;

@WebServlet("/sale/category/list")
public class ViewCategoryListController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        try (Connection conn = DBContext.getConnection()) {

            CategoryDAO dao = new CategoryDAO(conn);

            String search = request.getParameter("search");
            String status = request.getParameter("status");

            int page = 1;
            int pageSize = 5;

            String pageParam = request.getParameter("page");
            if (pageParam != null) {
                page = Integer.parseInt(pageParam);
            }

            List<Category> list =
                dao.getCategoryList(search, status, page, pageSize);

            int total = dao.countCategories(search, status);
            int totalPages =
                (int) Math.ceil((double) total / pageSize);

            request.setAttribute("categoryList", list);
            request.setAttribute("search", search);
            request.setAttribute("status", status);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);

            request.setAttribute("pageTitle", "Category Management - CRM");
            request.setAttribute("contentPage", "sale/category/categoryList.jsp");
            request.setAttribute("pageCss", "category_list.css");
            request.setAttribute("pageJs", "category_list.js");
            request.setAttribute("page", "category-list");
            request.getRequestDispatcher("/view/layout.jsp").forward(request, response);

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}