package controller.sale.category;

import java.io.IOException;
import java.sql.Connection;
import java.util.List;

import dao.CategoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
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
            if (search == null) search = "";

            List<Category> list = dao.getCategoryList(search);

            request.setAttribute("categoryList", list);

            request.getRequestDispatcher(
                    "/view/sale/category/categoryList.jsp")
                    .forward(request, response);

        } catch (Exception e) {
            throw new ServletException("Error loading category list", e);
        }
    }
}