package dal;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import models.Comment;

public class CommentDAO extends DBContext {
    public boolean addComment(int assignmentId, int userId, String content) {
        String sql = "INSERT INTO Assignment_Comments(assignment_id, user_id, content) VALUES(?,?,?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, assignmentId);
            ps.setInt(2, userId);
            ps.setString(3, content);
            return ps.executeUpdate() > 0;
        } catch(SQLException e) { e.printStackTrace(); }
        return false;
    }

    public List<Comment> getCommentsByAssignment(int assignmentId) {
        List<Comment> list = new ArrayList<>();
        String sql = "SELECT c.*, u.full_name, u.role FROM Assignment_Comments c INNER JOIN Users u ON c.user_id = u.user_id WHERE assignment_id = ? ORDER BY created_at ASC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, assignmentId);
            ResultSet rs = ps.executeQuery();
            while(rs.next()) {
                Comment c = new Comment();
                c.setCommentId(rs.getInt("comment_id"));
                c.setAssignmentId(rs.getInt("assignment_id"));
                c.setUserId(rs.getInt("user_id"));
                c.setContent(rs.getString("content"));
                c.setCreatedAt(rs.getTimestamp("created_at"));
                c.setUserName(rs.getString("full_name"));
                c.setUserRole(rs.getString("role"));
                list.add(c);
            }
        } catch(SQLException e) { e.printStackTrace(); }
        return list;
    }
}
