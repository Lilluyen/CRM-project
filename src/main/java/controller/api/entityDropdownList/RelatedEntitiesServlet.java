package controller.api.entityDropdownList;

import com.google.gson.Gson;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import util.DBContext;

@WebServlet(name = "RelatedEntitiesServlet", urlPatterns = {"/api/related-entities"})
public class RelatedEntitiesServlet extends HttpServlet {

    private static final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json; charset=UTF-8");
        PrintWriter out = resp.getWriter();

        String type = req.getParameter("type");
        if (type == null || type.isEmpty()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print(gson.toJson(Map.of("error", "type parameter is required")));
            return;
        }

        List<Map<String, Object>> results = new ArrayList<>();

        try {
            try (Connection conn = DBContext.getConnection()) {
                String sql = null;
                switch (type) {
                    case "customer":
                        sql = "SELECT customer_id as id, name FROM Customers ORDER BY name";
                        break;
                    case "lead":
                        sql = "SELECT lead_id as id, full_name as name FROM Leads ORDER BY full_name";
                        break;
                    case "deal":
                        sql = "SELECT deal_id as id, deal_name as name FROM Deals ORDER BY deal_name";
                        break;
                    case "task":
                        sql = "SELECT task_id as id, title as name FROM Tasks ORDER BY title";
                        break;
                    case "user":
                        sql = "SELECT user_id as id, COALESCE(full_name, username) as name, email FROM Users WHERE status = 'Active' ORDER BY full_name";
                        break;
                    case "lead-campaign":
                        String leadIdParam = req.getParameter("leadId");
                        if (leadIdParam == null || leadIdParam.isBlank()) {
                            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                            out.print(gson.toJson(Map.of("error", "leadId parameter is required")));
                            return;
                        }
                        int leadId;
                        try {
                            leadId = Integer.parseInt(leadIdParam);
                        } catch (NumberFormatException ex) {
                            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                            out.print(gson.toJson(Map.of("error", "leadId parameter must be numeric")));
                            return;
                        }
                        sql = "SELECT DISTINCT c.campaign_id as id, c.name "
                                + "FROM Campaign_Leads cl "
                                + "INNER JOIN Campaigns c ON c.campaign_id = cl.campaign_id "
                                + "WHERE cl.lead_id IN ( "
                                + "    SELECT l2.lead_id "
                                + "    FROM Leads l2 "
                                + "    WHERE l2.email = (SELECT l1.email FROM Leads l1 WHERE l1.lead_id = ?) "
                                + ") "
                                + "ORDER BY c.name";
                        try (PreparedStatement ps = conn.prepareStatement(sql)) {
                            ps.setInt(1, leadId);
                            try (ResultSet rs = ps.executeQuery()) {
                                while (rs.next()) {
                                    Map<String, Object> row = new HashMap<>();
                                    row.put("id", rs.getInt("id"));
                                    row.put("name", rs.getString("name"));
                                    results.add(row);
                                }
                            }
                        }
                        sql = null;
                        break;
                    default:
                        sql = "SELECT customer_id as id, name FROM Customers WHERE 1=0"; // empty
                }

                if (sql != null) {
                    boolean isUserType = "user".equals(type);
                    try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            Map<String, Object> row = new HashMap<>();
                            row.put("id", rs.getInt("id"));
                            row.put("name", rs.getString("name"));
                            if (isUserType) {
                                try {
                                    row.put("email", rs.getString("email"));
                                } catch (Exception ignored) {
                                }
                            }
                            results.add(row);
                        }
                    }
                }
            }
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print(gson.toJson(Map.of("error", e.getMessage())));
            return;
        }

        out.print(gson.toJson(results));
    }

}
