package dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import model.Role;
import model.User;
import util.DBContext;

public class UserDAO extends DBContext {

    /* =========================
       GET USER BY ID
    ========================= */
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
                LEFT JOIN User_Roles ur ON u.user_id = ur.user_id
                LEFT JOIN Roles r ON ur.role_id = r.role_id
                WHERE u.user_id = ?
            """;

        User user = null;
        List<Role> roles = new ArrayList<>();

        try (PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                if (user == null) {
                    user = new User();
                    user.setUserId(rs.getInt("user_id"));
                    user.setUsername(rs.getString("username"));
                    user.setPasswordHash(rs.getString("password_hash"));
                    user.setEmail(rs.getString("email"));
                    user.setFullName(rs.getString("full_name"));
                    user.setPhone(rs.getString("phone"));
                    user.setStatus(rs.getString("status"));

                    user.setCreatedAt(
                            rs.getTimestamp("created_at") != null
                                    ? rs.getTimestamp("created_at").toLocalDateTime()
                                    : null);

                    user.setUpdatedAt(
                            rs.getTimestamp("updated_at") != null
                                    ? rs.getTimestamp("updated_at").toLocalDateTime()
                                    : null);

                    user.setLastLoginAt(
                            rs.getTimestamp("last_login_at") != null
                                    ? rs.getTimestamp("last_login_at").toLocalDateTime()
                                    : null);
                }

                if (rs.getInt("role_id") != 0) {
                    Role role = new Role();
                    role.setRoleId(rs.getInt("role_id"));
                    role.setRoleName(rs.getString("role_name"));
                    role.setDescription(rs.getString("description"));
                    roles.add(role);
                }
            }

            if (user != null) {
                user.setRoles(roles);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return user;
    }

    /* =========================
       GET USER BY USERNAME
    ========================= */
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
                LEFT JOIN User_Roles ur ON u.user_id = ur.user_id
                LEFT JOIN Roles r ON ur.role_id = r.role_id
                WHERE u.username = ?
            """;

        User user = null;
        List<Role> roles = new ArrayList<>();

        try (PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                if (user == null) {
                    user = new User();
                    user.setUserId(rs.getInt("user_id"));
                    user.setUsername(rs.getString("username"));
                    user.setPasswordHash(rs.getString("password_hash"));
                    user.setEmail(rs.getString("email"));
                    user.setFullName(rs.getString("full_name"));
                    user.setPhone(rs.getString("phone"));
                    user.setStatus(rs.getString("status"));

                    user.setCreatedAt(
                            rs.getTimestamp("created_at") != null
                                    ? rs.getTimestamp("created_at").toLocalDateTime()
                                    : null);

                    user.setUpdatedAt(
                            rs.getTimestamp("updated_at") != null
                                    ? rs.getTimestamp("updated_at").toLocalDateTime()
                                    : null);

                    user.setLastLoginAt(
                            rs.getTimestamp("last_login_at") != null
                                    ? rs.getTimestamp("last_login_at").toLocalDateTime()
                                    : null);
                }

                if (rs.getInt("role_id") != 0) {
                    Role role = new Role();
                    role.setRoleId(rs.getInt("role_id"));
                    role.setRoleName(rs.getString("role_name"));
                    role.setDescription(rs.getString("description"));
                    roles.add(role);
                }
            }

            if (user != null) {
                user.setRoles(roles);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return user;
    }

    /* =========================
       GET USER BY EMAIL
    ========================= */
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
                LEFT JOIN User_Roles ur ON u.user_id = ur.user_id
                LEFT JOIN Roles r ON ur.role_id = r.role_id
                WHERE u.email = ?
            """;

        User user = null;
        List<Role> roles = new ArrayList<>();

        try (PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                if (user == null) {
                    user = new User();
                    user.setUserId(rs.getInt("user_id"));
                    user.setUsername(rs.getString("username"));
                    user.setPasswordHash(rs.getString("password_hash"));
                    user.setEmail(rs.getString("email"));
                    user.setFullName(rs.getString("full_name"));
                    user.setPhone(rs.getString("phone"));
                    user.setStatus(rs.getString("status"));

                    user.setCreatedAt(
                            rs.getTimestamp("created_at") != null
                                    ? rs.getTimestamp("created_at").toLocalDateTime()
                                    : null);

                    user.setUpdatedAt(
                            rs.getTimestamp("updated_at") != null
                                    ? rs.getTimestamp("updated_at").toLocalDateTime()
                                    : null);

                    user.setLastLoginAt(
                            rs.getTimestamp("last_login_at") != null
                                    ? rs.getTimestamp("last_login_at").toLocalDateTime()
                                    : null);
                }

                if (rs.getInt("role_id") != 0) {
                    Role role = new Role();
                    role.setRoleId(rs.getInt("role_id"));
                    role.setRoleName(rs.getString("role_name"));
                    role.setDescription(rs.getString("description"));
                    roles.add(role);
                }
            }

            if (user != null) {
                user.setRoles(roles);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return user;
    }
}
