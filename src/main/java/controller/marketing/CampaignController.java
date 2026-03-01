package controller.marketing;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Campaign;
import model.User;
import service.CampaignService;

@WebServlet("/marketing/campaign")
public class CampaignController extends HttpServlet {

    private CampaignService campaignService = new CampaignService();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("create".equals(action)) {
            try {
                String name = request.getParameter("name");
                String description = request.getParameter("description");
                String budgetStr = request.getParameter("budget");

                // Kiểm tra required fields
                if (name == null || name.trim().isEmpty()) {
                    throw new IllegalArgumentException("Tên campaign không được để trống.");
                }

                BigDecimal budget;
                try {
                    budget = new BigDecimal(budgetStr);
                    if (budget.compareTo(BigDecimal.ZERO) <= 0) {
                        throw new IllegalArgumentException("Ngân sách phải lớn hơn 0.");
                    }
                } catch (NumberFormatException e) {
                    throw new IllegalArgumentException("Ngân sách không hợp lệ.");
                }

                LocalDate startDate = LocalDate.parse(request.getParameter("startDate"));
                LocalDate endDate = LocalDate.parse(request.getParameter("endDate"));

                // Kiểm tra date logic
                if (endDate.isBefore(startDate) || endDate.isEqual(startDate)) {
                    throw new IllegalArgumentException("Ngày kết thúc phải sau ngày bắt đầu.");
                }

                String channel = request.getParameter("channel");
                if (channel == null || channel.trim().isEmpty()) {
                    throw new IllegalArgumentException("Kênh marketing không được để trống.");
                }

                int createdBy = ((User) request.getSession().getAttribute("user")).getUserId();

                Campaign campaign = new Campaign(0, name, description, budget, startDate, endDate,
                        channel, "ACTIVE", createdBy, null, null);

                int campaignId = campaignService.createCampaign(campaign);
                response.sendRedirect("campaign?action=list");
            } catch (Exception e) {
                request.setAttribute("error", e.getMessage());
                request.getRequestDispatcher("/view/marketing/campaign_form.jsp").forward(request, response);
            }
        } else if ("update".equals(action)) {
            try {
                int campaignId = Integer.parseInt(request.getParameter("campaignId"));
                String name = request.getParameter("name");
                String description = request.getParameter("description");
                String budgetStr = request.getParameter("budget");

                // Kiểm tra required fields
                if (name == null || name.trim().isEmpty()) {
                    throw new IllegalArgumentException("Tên campaign không được để trống.");
                }

                BigDecimal budget;
                try {
                    budget = new BigDecimal(budgetStr);
                    if (budget.compareTo(BigDecimal.ZERO) <= 0) {
                        throw new IllegalArgumentException("Ngân sách phải lớn hơn 0.");
                    }
                } catch (NumberFormatException e) {
                    throw new IllegalArgumentException("Ngân sách không hợp lệ.");
                }

                LocalDate startDate = LocalDate.parse(request.getParameter("startDate"));
                LocalDate endDate = LocalDate.parse(request.getParameter("endDate"));

                // Kiểm tra date logic
                if (endDate.isBefore(startDate) || endDate.isEqual(startDate)) {
                    throw new IllegalArgumentException("Ngày kết thúc phải sau ngày bắt đầu.");
                }

                String channel = request.getParameter("channel");
                if (channel == null || channel.trim().isEmpty()) {
                    throw new IllegalArgumentException("Kênh marketing không được để trống.");
                }

                String status = request.getParameter("status");
                if (status == null || status.trim().isEmpty()) {
                    throw new IllegalArgumentException("Trạng thái không được để trống.");
                }

                Campaign campaign = new Campaign(campaignId, name, description, budget, startDate,
                        endDate, channel, status, 0, null, null);

                if (campaignService.updateCampaign(campaign)) {
                    response.sendRedirect("campaign?action=detail&id=" + campaignId);
                } else {
                    throw new Exception("Cập nhật campaign thất bại.");
                }
            } catch (Exception e) {
                // Lấy campaign cũ để hiển thị lại form với dữ liệu
                int campaignId = Integer.parseInt(request.getParameter("campaignId"));
                Campaign campaign = campaignService.getCampaignById(campaignId);
                request.setAttribute("campaign", campaign);
                request.setAttribute("error", e.getMessage());
                request.getRequestDispatcher("/view/marketing/campaign_form.jsp").forward(request, response);
            }
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("list".equals(action) || action == null) {
            // ===== FIX: Lấy parameters search & status =====
            String searchName = request.getParameter("search");
            String status = request.getParameter("status");

            List<Campaign> campaigns;

            // Nếu có search hoặc filter status thì dùng search
            if ((searchName != null && !searchName.trim().isEmpty())
                    || (status != null && !status.trim().isEmpty())) {
                campaigns = campaignService.searchCampaigns(searchName, status);

                // ===== NEW: Nếu tìm thấy đúng 1 kết quả, auto-forward đến detail =====
                if (campaigns.size() == 1) {
                    Campaign campaign = campaigns.get(0);
                    request.setAttribute("campaign", campaign);
                    request.getRequestDispatcher("/view/marketing/campaign_detail.jsp").forward(request, response);
                    return;
                }

            } else {
                // Ngược lại lấy tất cả campaigns
                campaigns = campaignService.getAllCampaigns();
            }

            request.setAttribute("campaigns", campaigns);
            request.setAttribute("searchName", searchName);
            request.setAttribute("filterStatus", status);
            request.getRequestDispatcher("/view/marketing/campaign_list.jsp").forward(request, response);
        } else if ("detail".equals(action)) {
            int campaignId = Integer.parseInt(request.getParameter("id"));
            Campaign campaign = campaignService.getCampaignById(campaignId);
            request.setAttribute("campaign", campaign);
            request.getRequestDispatcher("/view/marketing/campaign_detail.jsp").forward(request, response);
        } else if ("create".equals(action)) {
            request.getRequestDispatcher("/view/marketing/campaign_form.jsp").forward(request, response);
        } else if ("edit".equals(action)) {
            int campaignId = Integer.parseInt(request.getParameter("id"));
            Campaign campaign = campaignService.getCampaignById(campaignId);
            request.setAttribute("campaign", campaign);
            request.getRequestDispatcher("/view/marketing/campaign_form.jsp").forward(request, response);
        }
        // else if ("delete".equals(action)) {
        //     int campaignId = Integer.parseInt(request.getParameter("id"));
        //     campaignService.deleteCampaign(campaignId);
        //     response.sendRedirect("campaign?action=list");
        // }
    }
}
