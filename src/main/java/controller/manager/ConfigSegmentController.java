package controller.manager;

import dao.ConfigSegmentDAO;
import dao.SegmentDetailDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.SegmentConfig;
import util.DBContext;

import java.io.IOException;
import java.sql.Connection;
import java.util.ArrayList;
import java.util.List;

@WebServlet(urlPatterns = "/customers/config-segment")
public class ConfigSegmentController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.sendRedirect(req.getContextPath() + "/customers/segments");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

        Connection conn = null;

        try {

            conn = DBContext.getConnection();

            int segmentId = Integer.parseInt(req.getParameter("segmentId"));
            String assignmentType = req.getParameter("assignmentType");

            String[] fields = req.getParameterValues("field");
            String[] operators = req.getParameterValues("operator");
            String[] values = req.getParameterValues("value");
            String[] logics = req.getParameterValues("logic");

            ConfigSegmentDAO dao = new ConfigSegmentDAO();
            SegmentDetailDAO segmentDetailDAO = new SegmentDetailDAO();

            conn.setAutoCommit(false);

            // 1 delete old filters
            dao.deleteOldConfigs(conn, segmentId);

            List<SegmentConfig> configs = new ArrayList<>();

            if (fields != null) {

                for (int i = 0; i < fields.length; i++) {

                    SegmentConfig f = new SegmentConfig();

                    if (values[i] != null && !(values[i].trim().isEmpty())) {
                        f.setField(fields[i]);
                        f.setOperator(operators[i]);
                        f.setValue(values[i]);

                        if (logics != null && i < logics.length) {
                            f.setLogic(logics[i]);
                        } else {
                            f.setLogic(null);
                        }

                        configs.add(f);
                    }
                }
            }

            // 2 insert filters
            dao.configSegment(conn, segmentId, configs);

            // 3 update assignment type
            dao.updateTypeAssigment(conn, segmentId, assignmentType);

            // 4 rebuild segment
            dao.deleteOldSegmentMap(conn, segmentId);

            String filterSQL = dao.buildFilterSQL(configs);

            if (!filterSQL.isEmpty()) {
                dao.insertCustomersToSegment(conn, segmentId, filterSQL);
            }

            // 5 assign staff
            dao.assignStaff(conn, segmentId);
            segmentDetailDAO.updateSegmentCount(conn, segmentId);

            conn.commit();

            resp.sendRedirect(req.getContextPath() + "/customers/segment-detail?segment_id=" + segmentId);

        } catch (Exception e) {

            try {
                if (conn != null) conn.rollback();
            } catch (Exception ignored) {
            }

            throw new ServletException(e);

        } finally {

            try {
                if (conn != null) conn.close();
            } catch (Exception ignored) {
            }
        }
    }
}
