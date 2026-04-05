package dal;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import models.PrivateMessage;
import models.User;

public class PrivateMessageDAO extends DBContext {
    public boolean sendMessage(int senderId, int receiverId, String content) {
        String sql = "INSERT INTO Messages(sender_id, receiver_id, content) VALUES(?,?,?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, senderId);
            ps.setInt(2, receiverId);
            ps.setString(3, content);
            return ps.executeUpdate() > 0;
        } catch(SQLException e) { e.printStackTrace(); }
        return false;
    }

    public List<PrivateMessage> getConversation(int user1, int user2) {
        List<PrivateMessage> list = new ArrayList<>();
        String sql = "SELECT m.*, s.full_name as sender_name, r.full_name as receiver_name " +
                     "FROM Messages m " +
                     "INNER JOIN Users s ON m.sender_id = s.user_id " +
                     "INNER JOIN Users r ON m.receiver_id = r.user_id " +
                     "WHERE (sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?) " +
                     "ORDER BY created_at ASC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, user1);
            ps.setInt(2, user2);
            ps.setInt(3, user2);
            ps.setInt(4, user1);
            ResultSet rs = ps.executeQuery();
            while(rs.next()) {
                PrivateMessage m = new PrivateMessage();
                m.setMessageId(rs.getInt("message_id"));
                m.setSenderId(rs.getInt("sender_id"));
                m.setReceiverId(rs.getInt("receiver_id"));
                m.setContent(rs.getString("content"));
                m.setIsRead(rs.getBoolean("is_read"));
                m.setCreatedAt(rs.getTimestamp("created_at"));
                m.setSenderName(rs.getString("sender_name"));
                m.setReceiverName(rs.getString("receiver_name"));
                list.add(m);
            }
        } catch(SQLException e) { e.printStackTrace(); }
        return list;
    }
}
