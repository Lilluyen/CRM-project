package service;

import dao.ConfigSegmentDAO;
import dao.CustomerSegmentDAO;
import dao.SegmentDetailDAO;
import dao.UserDAO;
import dto.*;
import model.CustomerSegment;
import model.User;
import util.DBContext;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;


public class CustomerSegmentService {

    private final CustomerSegmentDAO dao = new CustomerSegmentDAO();
    private final ConfigSegmentDAO configSegmentDAO = new ConfigSegmentDAO();
    private final SegmentDetailDAO segmentDetailDAO = new SegmentDetailDAO();
    private final UserDAO userDAO = new UserDAO();

    // ── KPI ──────────────────────────────────────────────────────
    public KpiSummaryDTO getKpi(LocalDate monthA, LocalDate monthB) throws Exception {
        try (Connection conn = DBContext.getConnection()) {
            return dao.kpiSummarySegment(conn, monthA, monthB);
        }
    }

    // ── Segment cards ─────────────────────────────────────────────
    public List<SegmentCardDTO> getSegmentCards(LocalDate monthA, LocalDate monthB) throws SQLException, Exception {
        try (Connection conn = DBContext.getConnection()) {
            return dao.getSegmentCards(conn, monthA, monthB);
        }
    }

    // ── Segment detail ────────────────────────────────────────────
    public SegmentDetailDTO getSegmentDetail(int segmentId, LocalDate monthA) throws SQLException {
        try (Connection conn = DBContext.getConnection()) {
            return CustomerSegmentDAO.segmentDetail(conn, segmentId, monthA);
        }
    }

    // ── Customer list (keyset pagination) ─────────────────────────
    //
    // sessionId = null  → page 1, đếm lại total
    // anchorRfm = null  → page 1, không dùng keyset WHERE
    //
    public CustomerPageDTO getCustomerPage(
            Integer segmentId,
            int pageSize,
            String keyword,
            String sessionId,
            String anchorRfm,
            Integer anchorId,
            int page
    ) throws SQLException {

        pageSize = (pageSize < 1 || pageSize > 100) ? 20 : pageSize;
        page = Math.max(1, page);
        String kw = (keyword != null && !keyword.isBlank()) ? keyword.trim() : null;

        boolean isPage1 = sessionId == null || sessionId.isBlank()
                || anchorRfm == null || anchorRfm.isBlank()
                || anchorId == null;

        int total = 0, totalPages = 0;
        String sid = sessionId;

        if (isPage1) {
            total = dao.count(segmentId, kw);
            totalPages = (int) Math.ceil((double) total / pageSize);
            sid = UUID.randomUUID().toString();
        }

        BigDecimal anchorBd = null;
        if (!isPage1) {
            try {
                anchorBd = new BigDecimal(anchorRfm);
            } catch (NumberFormatException ignored) {
            }
        }

        List<CustomerSegmentListDTO> data = dao.getPage(
                segmentId, kw, pageSize,
                anchorBd,
                isPage1 ? null : anchorId
        );

        // Anchor trang kế = dòng cuối trang hiện tại
        String nextRfm = null;
        int nextId = 0;
        if (!data.isEmpty()) {
            CustomerSegmentListDTO last = data.get(data.size() - 1);
            nextRfm = String.valueOf(last.getRfmScore());
            nextId = last.getCustomerId();
        }

        return new CustomerPageDTO(data, total, totalPages, page, pageSize,
                sid, nextRfm, nextId);
    }

    public int countAllSegmentations(String keyword, String segmentType, Integer creator, Integer updater, LocalDate fromDate, LocalDate toDate) throws SQLException {
        try (Connection conn = DBContext.getConnection()) {
            int total = dao.countAllSegmentations(conn, keyword, segmentType, creator, updater, fromDate, toDate);
            return total;
        }

    }

    public List<CustomerSegment> getAllSegmentations(int page, int size) throws SQLException {
        try (Connection conn = DBContext.getConnection()) {
            List<CustomerSegment> cs = dao.getAllSegmentations(conn, page, size);
            return cs;
        }
    }

    public List<CustomerSegment> filterCustomerSegment(String keyword, String segmentType, Integer creator, Integer updater, LocalDate fromDate, LocalDate toDate, int page, int size) throws SQLException {
        try (Connection conn = DBContext.getConnection();) {
            List<CustomerSegment> cs = dao.filterCustomerSegment(conn, keyword, segmentType, creator, updater, fromDate, toDate, page, size);
            return cs;
        }
    }

    public boolean createSegmentation(String name, String logic, String type, int userId) throws SQLException {
        try (Connection conn = DBContext.getConnection()) {
            boolean isExisted = dao.isSegmentExisted(conn, name);
            if (!isExisted) {
                dao.createSegmentation(conn, name, logic, type, userId);
                return true;
            }
            return false;
        }
    }

    public boolean removeSegmentation(int segmentId) throws SQLException {
        try (Connection conn = DBContext.getConnection()) {
            boolean isRemoved = dao.removeSegmentation(conn, segmentId);
            return isRemoved;
        }
    }

    public List<CustomerSegment> getStaticSegments() throws SQLException {
        try (Connection conn = DBContext.getConnection()) {
            return dao.getStaticSegments(conn);
        }
    }

    public void insertCustomersToSegment(int id, String empty) throws SQLException {
        try (Connection conn = DBContext.getConnection()) {
            try {
                conn.setAutoCommit(false);
                configSegmentDAO.insertCustomersToSegment(conn, id, empty);
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw new RuntimeException(e);
            }
        }
    }

    public boolean isCustomerInSegment(int segmentId, int customerId) throws SQLException {
        try (Connection conn = DBContext.getConnection()) {
            return configSegmentDAO.isCustomerInSegment(conn, segmentId, customerId);
        }
    }

    public void updateSegmentCount(int id) throws SQLException {
        try (Connection conn = DBContext.getConnection()) {
            segmentDetailDAO.updateSegmentCount(conn, id);
        }
    }

    public void removeCustomer(int customerId, int segmentId) throws SQLException {
        try (Connection conn = DBContext.getConnection()) {
            try {
                conn.setAutoCommit(false);
                dao.removeCustomer(conn, customerId, segmentId);
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw new RuntimeException(e);
            }
        }
    }

    public List<User> getActiveStaffsUnderManagerLevel() throws SQLException {
        try (Connection conn = DBContext.getConnection()) {
            return userDAO.getActiveStaffsUnderManagerLevel();
        }
    }

    public void changeOwner(int segmentId, int customerId, int newOner) throws SQLException {
        try (Connection conn = DBContext.getConnection()) {
            try {
                conn.setAutoCommit(false);
                dao.changeOwner(conn, customerId, segmentId, newOner);
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw new RuntimeException(e);
            }
        }
    }
}