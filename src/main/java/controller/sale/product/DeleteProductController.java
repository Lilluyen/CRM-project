package controller.sale.product;

import java.io.IOException;
import java.sql.Connection;

import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import util.DBContext;

@WebServlet("/sale/product/delete")
public class DeleteProductController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try (Connection conn = DBContext.getConnection()) {

            ProductDAO dao = new ProductDAO(conn);

            int id = Integer.parseInt(request.getParameter("id"));
            dao.deleteProduct(id);

            response.sendRedirect(request.getContextPath() + "/sale/product/list");

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
