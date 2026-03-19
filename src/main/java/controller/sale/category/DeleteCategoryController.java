package controller.sale.category;

import java.io.IOException;
import java.sql.Connection;

import dao.CategoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import util.DBContext;

@WebServlet("/sale/category/delete")
public class DeleteCategoryController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        try (Connection conn = DBContext.getConnection()) {

            CategoryDAO dao = new CategoryDAO(conn);

            int id = Integer.parseInt(request.getParameter("id"));
            dao.delete(id);

            response.sendRedirect(request.getContextPath() + "/sale/category/list");

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}