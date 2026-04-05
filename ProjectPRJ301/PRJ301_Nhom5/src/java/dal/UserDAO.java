package dal;

import models.User;
import java.sql.*;

public class UserDAO extends DBContext {

    public User checkLogin(String username, String password) {
        String sql = "SELECT * FROM Users WHERE username = ? AND password = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Integer classId = rs.getObject("class_id") != null ? rs.getInt("class_id") : null;
                return new User(rs.getInt("user_id"), rs.getString("username"),
                        rs.getString("password"), rs.getString("full_name"),
                        rs.getString("email"), rs.getString("role"),
                        rs.getString("status"), classId);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean register(User user) {
        String sql = "INSERT INTO Users(username, password, full_name, email, role, status, class_id) VALUES(?,?,?,?,?,?,?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getPassword());
            ps.setString(3, user.getFullName());
            ps.setString(4, user.getEmail());
            ps.setString(5, user.getRole());
            ps.setString(6, "PENDING");
            if (user.getClassId() != null) {
                ps.setInt(7, user.getClassId());
            } else {
                ps.setNull(7, java.sql.Types.INTEGER);
            }
            boolean success = ps.executeUpdate() > 0;
            if (success) {
                appendSqlToDesktopBackup(user.getUsername(), user.getPassword(), user.getFullName(), user.getEmail(), user.getRole(), "PENDING", user.getClassId());
            }
            return success;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean createActiveUser(User user) {
        String sql = "INSERT INTO Users(username, password, full_name, email, role, status, class_id) VALUES(?,?,?,?,?,?,?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getPassword());
            ps.setString(3, user.getFullName());
            ps.setString(4, user.getEmail());
            ps.setString(5, user.getRole());
            ps.setString(6, "ACTIVE");
            if (user.getClassId() != null) {
                ps.setInt(7, user.getClassId());
            } else {
                ps.setNull(7, java.sql.Types.INTEGER);
            }
            boolean success = ps.executeUpdate() > 0;
            if (success) {
                appendSqlToDesktopBackup(user.getUsername(), user.getPassword(), user.getFullName(), user.getEmail(), user.getRole(), "ACTIVE", user.getClassId());
            }
            return success;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private void appendSqlToDesktopBackup(String username, String password, String fullName, String email, String role, String status, Integer classId) {
        java.io.File file = new java.io.File("C:\\Users\\Fuc\\Desktop\\databaseprj.sql");
        if (file.exists()) {
            try (java.io.FileWriter fw = new java.io.FileWriter(file, true);
                 java.io.BufferedWriter bw = new java.io.BufferedWriter(fw);
                 java.io.PrintWriter out = new java.io.PrintWriter(bw)) {
                
                String clsIdStr = (classId != null) ? String.valueOf(classId) : "NULL";
                
                // Construct the raw INSERT INTO string
                String insertCmd = String.format(
                    "INSERT [dbo].[Users] ([username], [password], [full_name], [email], [role], [status], [class_id]) VALUES (N'%s', N'%s', N'%s', N'%s', N'%s', N'%s', %s);\n",
                    username.replace("'", "''"), 
                    password.replace("'", "''"), 
                    fullName.replace("'", "''"), 
                    (email != null ? email.replace("'", "''") : ""), 
                    role.replace("'", "''"), 
                    status.replace("'", "''"), 
                    clsIdStr
                );
                
                out.println("-- Custom appending via Web Application");
                out.print(insertCmd);
            } catch (java.io.IOException e) {
                System.out.println("Failed to append SQL to desktop file: " + e.getMessage());
            }
        }
    }

    public java.util.List<User> getAllUsers() {
        java.util.List<User> list = new java.util.ArrayList<>();
        String sql = "SELECT * FROM Users";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Integer classId = rs.getObject("class_id") != null ? rs.getInt("class_id") : null;
                list.add(new User(rs.getInt("user_id"), rs.getString("username"),
                        rs.getString("password"), rs.getString("full_name"),
                        rs.getString("email"), rs.getString("role"),
                        rs.getString("status"), classId));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateUserStatus(int userId, String status) {
        String sql = "UPDATE Users SET status = ? WHERE user_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, userId);
            boolean success = ps.executeUpdate() > 0;
            if (success) {
                appendUpdateStatusDesktopBackup(userId, status);
            }
            return success;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateUser(User user) {
        String sql = "UPDATE Users SET full_name=?, email=?, role=?, class_id=? WHERE user_id=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getRole());
            if (user.getClassId() != null) {
                ps.setInt(4, user.getClassId());
            } else {
                ps.setNull(4, java.sql.Types.INTEGER);
            }
            ps.setInt(5, user.getUserId());
            boolean success = ps.executeUpdate() > 0;
            if (success) {
                appendUpdateUserDesktopBackup(user);
            }
            return success;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private void appendUpdateStatusDesktopBackup(int userId, String status) {
        java.io.File file = new java.io.File("C:\\Users\\Fuc\\Desktop\\databaseprj.sql");
        if (file.exists()) {
            try (java.io.FileWriter fw = new java.io.FileWriter(file, true);
                 java.io.BufferedWriter bw = new java.io.BufferedWriter(fw);
                 java.io.PrintWriter out = new java.io.PrintWriter(bw)) {
                String updateCmd = String.format(
                    "UPDATE [dbo].[Users] SET [status] = N'%s' WHERE [user_id] = %d;\n",
                    status.replace("'", "''"), userId
                );
                out.println("-- Custom appending via Web Application: Status Change");
                out.print(updateCmd);
            } catch (java.io.IOException e) {
                System.out.println("Failed to append SQL status update: " + e.getMessage());
            }
        }
    }

    private void appendUpdateUserDesktopBackup(User user) {
        java.io.File file = new java.io.File("C:\\Users\\Fuc\\Desktop\\databaseprj.sql");
        if (file.exists()) {
            try (java.io.FileWriter fw = new java.io.FileWriter(file, true);
                 java.io.BufferedWriter bw = new java.io.BufferedWriter(fw);
                 java.io.PrintWriter out = new java.io.PrintWriter(bw)) {
                
                String clsIdStr = (user.getClassId() != null) ? String.valueOf(user.getClassId()) : "NULL";
                String emailStr = (user.getEmail() != null) ? user.getEmail().replace("'", "''") : "";
                
                String updateCmd = String.format(
                    "UPDATE [dbo].[Users] SET [full_name] = N'%s', [email] = N'%s', [role] = N'%s', [class_id] = %s WHERE [user_id] = %d;\n",
                    user.getFullName().replace("'", "''"), 
                    emailStr, 
                    user.getRole().replace("'", "''"), 
                    clsIdStr,
                    user.getUserId()
                );
                out.println("-- Custom appending via Web Application: Profile Update");
                out.print(updateCmd);
            } catch (java.io.IOException e) {
                System.out.println("Failed to append SQL profile update: " + e.getMessage());
            }
        }
    }

    public boolean updatePassword(int userId, String password) {
        String sql = "UPDATE Users SET password = ? WHERE user_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, password);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteUser(int userId) {
        String sql = "DELETE FROM Users WHERE user_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public java.util.List<User> getMessageContactsForUser(User user) {
        java.util.List<User> list = new java.util.ArrayList<>();
        String sql = "";
        try {
            if ("parent".equals(user.getRole())) {
                sql = "SELECT DISTINCT t.* FROM Users t JOIN Classes c ON t.user_id = c.teacher_id JOIN Users s ON s.class_id = c.class_id JOIN Parent_Student ps ON ps.student_id = s.user_id WHERE ps.parent_id = ? AND t.role = 'teacher'";
            } else if ("teacher".equals(user.getRole())) {
                sql = "SELECT DISTINCT p.* FROM Users p JOIN Parent_Student ps ON p.user_id = ps.parent_id JOIN Users s ON s.user_id = ps.student_id JOIN Classes c ON s.class_id = c.class_id WHERE c.teacher_id = ? AND p.role = 'parent'";
            } else {
                return list;
            }
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, user.getUserId());
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Integer classId = rs.getObject("class_id") != null ? rs.getInt("class_id") : null;
                list.add(new User(rs.getInt("user_id"), rs.getString("username"),
                        rs.getString("password"), rs.getString("full_name"),
                        rs.getString("email"), rs.getString("role"),
                        rs.getString("status"), classId));
            }
        } catch(Exception e) { e.printStackTrace(); }
        return list;
    }

    public User getUserById(int userId) {
        try {
            PreparedStatement ps = connection.prepareStatement("SELECT * FROM Users WHERE user_id = ?");
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Integer classId = rs.getObject("class_id") != null ? rs.getInt("class_id") : null;
                return new User(rs.getInt("user_id"), rs.getString("username"),
                        rs.getString("password"), rs.getString("full_name"),
                        rs.getString("email"), rs.getString("role"),
                        rs.getString("status"), classId);
            }
        } catch(Exception e) { e.printStackTrace(); }
        return null;
    }
}
