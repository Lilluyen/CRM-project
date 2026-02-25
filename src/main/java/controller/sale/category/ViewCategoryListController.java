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
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Connection conn = null;

        try {
            // 1️⃣ Lấy connection
            conn = DBContext.getConnection();

            if (conn == null) {
                throw new Exception("Cannot connect to database!");
            }

            // 2️⃣ Gọi DAO
            CategoryDAO categoryDAO = new CategoryDAO(conn);

            String search = request.getParameter("search");
            if (search == null) {
                search = "";
            }

            List<Category> categoryList = categoryDAO.getCategoryList(search);

            // 3️⃣ Set attribute cho JSP
            request.setAttribute("categoryList", categoryList);

            // 4️⃣ Forward đúng path
            request.getRequestDispatcher("/view/sale/category/categoryList.jsp")
                    .forward(request, response);

        } catch (Exception e) {

            e.printStackTrace();

            // Hiển thị lỗi ra trình duyệt để bạn biết đang lỗi gì
            response.setContentType("text/html");
            response.getWriter().println("<h2>ERROR:</h2>");
            response.getWriter().println("<pre>");
            e.printStackTrace(response.getWriter());
            response.getWriter().println("</pre>");

        } finally {

            // 5️⃣ Đóng connection tránh leak
            try {
                if (conn != null) conn.close();
            } catch (Exception ignore) {}
        }
    }
}