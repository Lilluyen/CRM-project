package controller.marketing;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import service.LeadService;

@WebServlet(name = "LeadScoreController", urlPatterns = {"/marketing/leads/score"})
public class LeadScoreController extends HttpServlet {

    private final LeadService leadService = new LeadService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            String leadIdStr = request.getParameter("leadId");
            String scoreStr = request.getParameter("score");

            if (leadIdStr == null || scoreStr == null) {
                response.getWriter().write("{\"success\": false, \"message\": \"Thiếu tham số.\"}");
                return;
            }

            int leadId = Integer.parseInt(leadIdStr);
            int score = Integer.parseInt(scoreStr);

            if (leadService.scoreLead(leadId, score)) {
                response.getWriter().write("{\"success\": true, \"message\": \"Cập nhật điểm thành công.\"}");
            } else {
                response.getWriter().write("{\"success\": false, \"message\": \"Lead không tồn tại.\"}");
            }

        } catch (IllegalArgumentException e) {
            response.getWriter().write("{\"success\": false, \"message\": \"" + e.getMessage() + "\"}");
        } catch (Exception e) {
            response.getWriter().write("{\"success\": false, \"message\": \"Lỗi hệ thống.\"}");
        }
    }
}
