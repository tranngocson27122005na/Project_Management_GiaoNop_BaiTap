package dal;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import models.User;

public class ParentStudentDAO extends DBContext {
    
    // Link a parent to a student
    public boolean linkParentStudent(int parentId, int studentId) {
        String sql = "INSERT INTO Parent_Student(parent_id, student_id) VALUES(?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, parentId);
            ps.setInt(2, studentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Unlink a parent from a student
    public boolean unlinkParentStudent(int parentId, int studentId) {
        String sql = "DELETE FROM Parent_Student WHERE parent_id = ? AND student_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, parentId);
            ps.setInt(2, studentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Get all students linked to a specific parent
    public List<User> getStudentsOfParent(int parentId) {
        List<User> list = new ArrayList<>();
        String sql = "SELECT u.user_id, u.username, u.full_name, u.email " +
                     "FROM Users u " +
                     "INNER JOIN Parent_Student ps ON u.user_id = ps.student_id " +
                     "WHERE ps.parent_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, parentId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                User u = new User();
                u.setUserId(rs.getInt("user_id"));
                u.setUsername(rs.getString("username"));
                u.setFullName(rs.getString("full_name"));
                u.setEmail(rs.getString("email"));
                list.add(u);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
