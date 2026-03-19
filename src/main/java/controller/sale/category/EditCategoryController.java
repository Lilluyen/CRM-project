package controller.sale.category;

import java.io.IOException;
import java.sql.Connection;

import dao.CategoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Category;
import util.DBContext;

@WebServlet("/sale/category/edit")
public class EditCategoryController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        try (Connection conn = DBContext.getConnection()) {

            CategoryDAO dao = new CategoryDAO(conn);

            int id = Integer.parseInt(request.getParameter("id"));
            Category c = dao.getById(id);

            request.setAttribute("category", c);
            request.setAttribute("pageTitle", "Edit Category - CRM");
            request.setAttribute("contentPage", "sale/category/categoryForm.jsp");
            request.setAttribute("pageCss", "category_form.css");
            request.setAttribute("pageJs", "category_form.js");
            request.setAttribute("page", "category-form");
            request.getRequestDispatcher("/view/layout.jsp").forward(request, response);

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        try (Connection conn = DBContext.getConnection()) {

            CategoryDAO dao = new CategoryDAO(conn);

            Category c = new Category();
            c.setCategoryId(Integer.parseInt(request.getParameter("id")));
            c.setCategoryName(request.getParameter("name"));
            c.setDescription(request.getParameter("description"));
            c.setStatus(request.getParameter("status"));

            dao.update(c);

            response.sendRedirect("list");

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}