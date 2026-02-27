package controller.api;

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
                    case "user":
                        sql = "SELECT user_id as id, full_name as name FROM Users ORDER BY full_name";
                        break;
                    default:
                        sql = "SELECT customer_id as id, name FROM Customers WHERE 1=0"; // empty
                }

                if (sql != null) {
                    try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            Map<String, Object> row = new HashMap<>();
                            row.put("id", rs.getInt("id"));
                            row.put("name", rs.getString("name"));
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
