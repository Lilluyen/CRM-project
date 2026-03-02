package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import model.Role;
import model.User;
import util.DBContext;

public class UserDAO {

    /*
     * =========================
     * MAP RESULTSET → USER
     * =========================
     */
    private User mapUser(ResultSet rs) throws SQLException {

        User user = new User();

        user.setUserId(rs.getInt("user_id"));
        user.setUsername(rs.getString("username"));
        user.setPasswordHash(rs.getString("password_hash"));
        user.setEmail(rs.getString("email"));
        user.setFullName(rs.getString("full_name"));
        user.setPhone(rs.getString("phone"));
        user.setStatus(rs.getString("status"));

        if (rs.getTimestamp("created_at") != null)
            user.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());

        if (rs.getTimestamp("updated_at") != null)
            user.setUpdatedAt(rs.getTimestamp("updated_at").toLocalDateTime());

        if (rs.getTimestamp("last_login_at") != null)
            user.setLastLoginAt(rs.getTimestamp("last_login_at").toLocalDateTime());

        // Map role (1 role duy nhất)
        if (rs.getInt("role_id") != 0) {
            Role role = new Role();
            role.setRoleId(rs.getInt("role_id"));
            role.setRoleName(rs.getString("role_name"));
            role.setDescription(rs.getString("description"));
            user.setRole(role);
        }

        return user;
    }

    /*
     * =========================
     * GET USER BY ID
     * =========================
     */
    public User getUserById(int userId) {

        String sql = """
            SELECT
                u.user_id,
                u.username,
                u.password_hash,
                u.email,
                u.full_name,
                u.phone,
                u.status,
                u.created_at,
                u.updated_at,
                u.last_login_at,
                r.role_id,
                r.role_name,
                r.description
            FROM Users u
            LEFT JOIN Roles r ON u.role_id = r.role_id
            WHERE u.user_id = ?
        """;

        try (PreparedStatement ps = DBContext.getConnection().prepareStatement(sql)) {

            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return mapUser(rs);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    /*
     * =========================
     * GET USER BY USERNAME
     * =========================
     */
    public User getUserByUsername(String username) {

        String sql = """
            SELECT
                u.user_id,
                u.username,
                u.password_hash,
                u.email,
                u.full_name,
                u.phone,
                u.status,
                u.created_at,
                u.updated_at,
                u.last_login_at,
                r.role_id,
                r.role_name,
                r.description
            FROM Users u
            LEFT JOIN Roles r ON u.role_id = r.role_id
            WHERE u.username = ?
        """;

        try (PreparedStatement ps = DBContext.getConnection().prepareStatement(sql)) {

            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return mapUser(rs);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    /*
     * =========================
     * GET USER BY EMAIL
     * =========================
     */
    public User getUserByEmail(String email) {

        String sql = """
            SELECT
                u.user_id,
                u.username,
                u.password_hash,
                u.email,
                u.full_name,
                u.phone,
                u.status,
                u.created_at,
                u.updated_at,
                u.last_login_at,
                r.role_id,
                r.role_name,
                r.description
            FROM Users u
            LEFT JOIN Roles r ON u.role_id = r.role_id
            WHERE u.email = ?
        """;

        try (PreparedStatement ps = DBContext.getConnection().prepareStatement(sql)) {

            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return mapUser(rs);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public boolean updateLastLogin(int userId) {

        String sql = """
        UPDATE Users
        SET last_login_at = ?
        WHERE user_id = ?
    """;

        try (PreparedStatement ps = DBContext.getConnection().prepareStatement(sql)) {

            ps.setTimestamp(1, new java.sql.Timestamp(System.currentTimeMillis()));
            ps.setInt(2, userId);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public List<User> getAllUsers(Connection conn) {
        String sql = """
            SELECT user_id
                  ,username
                  ,password_hash
                  ,email
                  ,full_name
                  ,phone
                  ,role_id
                  ,status
                  ,created_at
                  ,updated_at
                  ,last_login_at
              FROM Users
        """;
        List<User> users=new ArrayList();
        try (PreparedStatement ps = DBContext.getConnection().prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                users.add(mapUser(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return users;
    }
}