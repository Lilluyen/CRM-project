package controller.activities;

import model.User;
import service.ActivityService;
import util.DBContext;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * POST /activities/delete
 * Xóa một activity (AJAX JSON).
 *
 * Request params:
 *   id (int) – activity_id cần xóa
 *
 * Response JSON: {"success": true} | {"success": false, "message": "..."}
 */
@WebServlet("/activities/delete")
public class ActivityDeleteController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            writeJson(resp, "{\"success\":false,\"message\":\"Chưa đăng nhập\"}");
            return;
        }
        if (req.getParameter("id") == null) {
            resp.sendRedirect(req.getContextPath()+"/activities/list");
        }
        int id = Integer.parseInt(req.getParameter("id"));

        try (Connection conn = DBContext.getConnection()) {
            boolean ok = new ActivityService(conn).deleteActivity(id);
            writeJson(resp, ok
                    ? "{\"success\":true}"
                    : "{\"success\":false,\"message\":\"Xóa activity thất bại\"}");
        } catch (SQLException ex) {
            Logger.getLogger(ActivityDeleteController.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    private void writeJson(HttpServletResponse resp, String json) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        try (PrintWriter w = resp.getWriter()) {
            w.write(json);
        }
    }
}
