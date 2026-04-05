package dal;

import java.sql.*;
import java.util.*;
import models.Message;

public class MessageDAO extends DBContext {
    
    public MessageDAO() {
        try (Statement st = connection.createStatement()) {
            String sql = "IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Messages' AND xtype='U') " +
                         "CREATE TABLE Messages (" +
                         "    message_id INT IDENTITY(1,1) PRIMARY KEY," +
                         "    class_id INT," +
                         "    user_id INT," +
                         "    message_text NVARCHAR(MAX)," +
                         "    sent_at DATETIME DEFAULT GETDATE()" +
                         ")";
            st.executeUpdate(sql);
        } catch (Exception e) {}
    }
    
    public List<Message> getMessages(int classId, int lastId) {
        List<Message> list = new ArrayList<>();
        String sql = "SELECT m.*, u.full_name, u.role FROM Messages m JOIN Users u ON m.user_id = u.user_id " +
                     "WHERE m.class_id = ? AND m.message_id > ? ORDER BY m.sent_at ASC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, classId);
            ps.setInt(2, lastId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Message m = new Message();
                m.setMessageId(rs.getInt("message_id"));
                m.setClassId(classId);
                m.setUserId(rs.getInt("user_id"));
                m.setSenderName(rs.getString("full_name"));
                m.setRole(rs.getString("role"));
                m.setMessageText(rs.getString("message_text"));
                m.setSentAt(rs.getTimestamp("sent_at"));
                list.add(m);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    
    public void sendMessage(int classId, int userId, String text) {
        String sql = "INSERT INTO Messages(class_id, user_id, message_text) VALUES(?,?,?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, classId);
            ps.setInt(2, userId);
            ps.setString(3, text);
            ps.executeUpdate();
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
}
