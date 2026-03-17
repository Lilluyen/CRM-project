package service;

import dao.ConfigSegmentDAO;
import dao.SegmentDetailDAO;
import dto.CustomerListDTO;
import model.CustomerSegment;
import model.SegmentConfig;
import model.SegmentHistory;
import util.DBContext;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

public class SegmentDetailService {
    private final SegmentDetailDAO dao = new SegmentDetailDAO();
    private final ConfigSegmentDAO configDao = new ConfigSegmentDAO();

    public CustomerSegment getSegmentDetailById(int id) throws SQLException {
        try (Connection conn = DBContext.getConnection()) {
            return dao.getSegmentById(conn, id);
        }
    }

    public List<SegmentHistory> getSegmentHistory(int id) throws SQLException {
        try (Connection conn = DBContext.getConnection()) {
            return dao.getSegmentHistory(conn, id);
        }
    }

    public List<CustomerListDTO> getListInDetailSegment(int id) throws SQLException {
        try (Connection conn = DBContext.getConnection()) {
            return dao.getListInDetailSegment(conn, id);
        }
    }

    public List<SegmentConfig> getFilters(int id) throws SQLException {
        try (Connection conn = DBContext.getConnection()) {
            return configDao.getFilters(conn, id);
        }
    }

    public void updateSegmentation(int id, String name, String logic, String segmentType, int updater, String currentName, String currentType, String currentLogic) throws SQLException {
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            int row = dao.updateSegmentation(conn, id, name, logic, segmentType, updater, currentName, currentType, currentLogic);
            if (row <= 0) {
                conn.rollback();
            } else {
                conn.commit();
            }
        }
    }

}
