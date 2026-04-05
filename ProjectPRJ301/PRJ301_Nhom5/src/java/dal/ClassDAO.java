package dal;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import models.ClassRoom;

public class ClassDAO extends DBContext {

    public List<ClassRoom> getAllClasses() {
        List<ClassRoom> list = new ArrayList<>();
        String sql = "SELECT * FROM Classes";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new ClassRoom(
                        rs.getInt("class_id"), 
                        rs.getString("class_name"), 
                        rs.getInt("teacher_id")
                ));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<ClassRoom> getClassesByTeacher(int teacherId) {
        List<ClassRoom> list = new ArrayList<>();
        String sql = "SELECT * FROM Classes WHERE teacher_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, teacherId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new ClassRoom(
                        rs.getInt("class_id"), 
                        rs.getString("class_name"), 
                        rs.getInt("teacher_id")
                ));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean createClass(String className, int teacherId) {
        String sql = "INSERT INTO Classes(class_name, teacher_id) VALUES(?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, className);
            ps.setInt(2, teacherId);
            boolean success = ps.executeUpdate() > 0;
            if (success) {
                appendClassBackup(className, teacherId);
            }
            return success;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private void appendClassBackup(String className, int teacherId) {
        java.io.File file = new java.io.File("C:\\Users\\Fuc\\Desktop\\databaseprj.sql");
        if (file.exists()) {
            try (java.io.FileWriter fw = new java.io.FileWriter(file, true);
                 java.io.BufferedWriter bw = new java.io.BufferedWriter(fw);
                 java.io.PrintWriter out = new java.io.PrintWriter(bw)) {
                
                String insertCmd = String.format(
                    "INSERT [dbo].[Classes] ([class_name], [teacher_id]) VALUES (N'%s', %d);\n",
                    className.replace("'", "''"), teacherId
                );
                out.println("-- Custom appending via Web Application: Create Class");
                out.print(insertCmd);
            } catch (java.io.IOException e) {
                System.out.println("Failed to append SQL to desktop file: " + e.getMessage());
            }
        }
    }
}
