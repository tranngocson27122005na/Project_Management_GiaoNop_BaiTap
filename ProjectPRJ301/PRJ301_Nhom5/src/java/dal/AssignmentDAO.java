package dal;

import models.Assignment;
import java.sql.*;
import java.util.*;

public class AssignmentDAO extends DBContext {

    public AssignmentDAO() {
        super();
        try (Statement st = connection.createStatement()) {
            st.execute("ALTER TABLE Assignments ADD is_deleted BIT DEFAULT 0");
        } catch (Exception e) {
            // Field already exists, ignore
        }
    }

    public List<Assignment> getAllAssignments() {
        List<Assignment> list = new ArrayList<>();
        String sql = "SELECT a.*, c.class_name FROM Assignments a LEFT JOIN Classes c ON a.class_id = c.class_id WHERE ISNULL(a.is_deleted, 0) = 0 ORDER BY a.created_date DESC";
        try (Statement st = connection.createStatement(); ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                list.add(mapRecord(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
            Assignment err = new Assignment();
            err.setTitle("SQL Error Exception");
            err.setDescription(e.toString() + " \n " + e.getMessage());
            list.add(err);
        }
        return list;
    }

    public List<Assignment> getAssignmentsForTeacher(int teacherId) {
        List<Assignment> list = new ArrayList<>();
        String sql = "SELECT a.*, c.class_name FROM Assignments a LEFT JOIN Classes c ON a.class_id = c.class_id WHERE c.teacher_id = ? AND ISNULL(a.is_deleted, 0) = 0 ORDER BY a.created_date DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, teacherId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRecord(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Assignment> getAssignmentsForStudent(int studentId, int classId) {
        List<Assignment> list = new ArrayList<>();
        String sql = "SELECT a.*, ISNULL(s.status, N'Chưa nộp') as status, s.file_path, s.score, c.class_name "
                + "FROM Assignments a LEFT JOIN Submissions s "
                + "ON a.assignment_id = s.assignment_id AND s.student_id = ? "
                + "LEFT JOIN Classes c ON a.class_id = c.class_id "
                + "WHERE a.class_id = ? AND ISNULL(a.is_deleted, 0) = 0 "
                + "ORDER BY a.created_date DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            ps.setInt(2, classId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Assignment a = mapRecord(rs);
                a.setStatus(rs.getString("status"));
                Object scoreObj = rs.getObject("score");
                if (scoreObj != null) {
                    a.setScore(rs.getDouble("score"));
                }
                list.add(a);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Assignment> searchAllAssignments(String keyword) {
        List<Assignment> list = new ArrayList<>();
        String sql = "SELECT a.*, c.class_name FROM Assignments a LEFT JOIN Classes c ON a.class_id = c.class_id WHERE (a.title LIKE ? OR a.description LIKE ?) AND ISNULL(a.is_deleted, 0) = 0 ORDER BY a.created_date DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, "%" + keyword + "%");
            ps.setString(2, "%" + keyword + "%");
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRecord(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Assignment> searchAssignmentsForStudent(String keyword, int classId) {
        List<Assignment> list = new ArrayList<>();
        String sql = "SELECT a.*, c.class_name FROM Assignments a LEFT JOIN Classes c ON a.class_id = c.class_id WHERE (a.title LIKE ? OR a.description LIKE ?) AND a.class_id = ? AND ISNULL(a.is_deleted, 0) = 0 ORDER BY a.created_date DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, "%" + keyword + "%");
            ps.setString(2, "%" + keyword + "%");
            ps.setInt(3, classId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRecord(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Assignment> searchAssignmentsForTeacher(String keyword, int teacherId) {
        List<Assignment> list = new ArrayList<>();
        String sql = "SELECT a.*, c.class_name FROM Assignments a LEFT JOIN Classes c ON a.class_id = c.class_id WHERE (a.title LIKE ? OR a.description LIKE ?) AND c.teacher_id = ? AND ISNULL(a.is_deleted, 0) = 0 ORDER BY a.created_date DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, "%" + keyword + "%");
            ps.setString(2, "%" + keyword + "%");
            ps.setInt(3, teacherId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRecord(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Assignment> getAssignmentsForParent(int parentId) {
        List<Assignment> list = new ArrayList<>();
        String sql = "SELECT a.*, ISNULL(s.status, N'Chưa nộp') as status, s.file_path, s.score, c.class_name, u.full_name as student_name "
                + "FROM Assignments a "
                + "JOIN Users u ON u.class_id = a.class_id AND u.role = 'student' "
                + "JOIN Parent_Student ps ON ps.student_id = u.user_id "
                + "LEFT JOIN Submissions s ON a.assignment_id = s.assignment_id AND s.student_id = u.user_id "
                + "LEFT JOIN Classes c ON a.class_id = c.class_id "
                + "WHERE ps.parent_id = ? AND ISNULL(a.is_deleted, 0) = 0 "
                + "ORDER BY a.created_date DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, parentId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Assignment a = mapRecord(rs);
                a.setStatus(rs.getString("status"));
                Object scoreObj = rs.getObject("score");
                if (scoreObj != null) {
                    a.setScore(rs.getDouble("score"));
                }
                a.setStudentName(rs.getString("student_name"));
                list.add(a);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Assignment> searchAssignmentsForParent(String keyword, int parentId) {
        List<Assignment> list = new ArrayList<>();
        String sql = "SELECT a.*, ISNULL(s.status, N'Chưa nộp') as status, s.file_path, s.score, c.class_name, u.full_name as student_name "
                + "FROM Assignments a "
                + "JOIN Users u ON u.class_id = a.class_id AND u.role = 'student' "
                + "JOIN Parent_Student ps ON ps.student_id = u.user_id "
                + "LEFT JOIN Submissions s ON a.assignment_id = s.assignment_id AND s.student_id = u.user_id "
                + "LEFT JOIN Classes c ON a.class_id = c.class_id "
                + "WHERE ps.parent_id = ? AND (a.title LIKE ? OR a.description LIKE ?) AND ISNULL(a.is_deleted, 0) = 0 "
                + "ORDER BY a.created_date DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, parentId);
            ps.setString(2, "%" + keyword + "%");
            ps.setString(3, "%" + keyword + "%");
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Assignment a = mapRecord(rs);
                a.setStatus(rs.getString("status"));
                Object scoreObj = rs.getObject("score");
                if (scoreObj != null) {
                    a.setScore(rs.getDouble("score"));
                }
                a.setStudentName(rs.getString("student_name"));
                list.add(a);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public void createAssignment(Assignment a) {
        String sql = "INSERT INTO Assignments(title, description, due_date, created_by, class_id, assignment_file) VALUES(?,?,?,?,?,?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, a.getTitle());
            ps.setString(2, a.getDescription());
            ps.setTimestamp(3, new Timestamp(a.getDueDate().getTime()));
            ps.setInt(4, a.getCreatedBy());
            if (a.getClassId() != null) {
                ps.setInt(5, a.getClassId());
            } else {
                ps.setNull(5, java.sql.Types.INTEGER);
            }
            if (a.getFilePath() != null && !a.getFilePath().isEmpty()) {
                ps.setString(6, a.getFilePath());
            } else {
                ps.setNull(6, java.sql.Types.NVARCHAR);
            }
            int rows = ps.executeUpdate();
            if (rows > 0) appendAssignmentCreate(a);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public Assignment getAssignmentById(int assignmentId) {
        String sql = "SELECT a.*, c.class_name FROM Assignments a LEFT JOIN Classes c ON a.class_id = c.class_id WHERE a.assignment_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, assignmentId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapRecord(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public void deleteAssignment(int assignmentId) {
        String sqlUpdate = "UPDATE Assignments SET is_deleted = 1 WHERE assignment_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sqlUpdate)) {
            ps.setInt(1, assignmentId);
            int rows = ps.executeUpdate();
            if (rows > 0) appendAssignmentDelete(assignmentId);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void restoreAssignment(int assignmentId) {
        String sqlUpdate = "UPDATE Assignments SET is_deleted = 0 WHERE assignment_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sqlUpdate)) {
            ps.setInt(1, assignmentId);
            int rows = ps.executeUpdate();
            if (rows > 0) appendAssignmentRestore(assignmentId);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<Assignment> getDeletedAssignments(boolean isAdmin, int teacherId) {
        List<Assignment> list = new ArrayList<>();
        String sql = "SELECT a.*, c.class_name FROM Assignments a LEFT JOIN Classes c ON a.class_id = c.class_id WHERE a.is_deleted = 1 ";
        if (!isAdmin) {
            sql += "AND c.teacher_id = ? ";
        }
        sql += "ORDER BY a.created_date DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            if (!isAdmin) {
                ps.setInt(1, teacherId);
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRecord(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private Assignment mapRecord(ResultSet rs) throws SQLException {
        Assignment a = new Assignment();
        a.setAssignmentId(rs.getInt("assignment_id"));
        a.setTitle(rs.getString("title"));
        a.setDescription(rs.getString("description"));
        a.setDueDate(rs.getTimestamp("due_date"));
        a.setCreatedBy(rs.getInt("created_by"));
        a.setFilePath(rs.getString("assignment_file"));
        a.setClassName(rs.getString("class_name"));
        return a;
    }

    private void appendAssignmentCreate(Assignment a) {
        java.io.File file = new java.io.File("C:\\Users\\Fuc\\Desktop\\databaseprj.sql");
        if (file.exists()) {
            try (java.io.FileWriter fw = new java.io.FileWriter(file, true);
                 java.io.BufferedWriter bw = new java.io.BufferedWriter(fw);
                 java.io.PrintWriter out = new java.io.PrintWriter(bw)) {
                String desc = a.getDescription() != null ? a.getDescription().replace("'", "''") : "";
                String filePath = a.getFilePath() != null ? a.getFilePath().replace("'", "''") : "";
                String classIdStr = a.getClassId() != null ? String.valueOf(a.getClassId()) : "NULL";
                String dueDateStr = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(a.getDueDate());
                String cmd = String.format("INSERT [dbo].[Assignments]([title], [description], [due_date], [created_by], [class_id], [assignment_file]) VALUES(N'%s', N'%s', '%s', %d, %s, N'%s');\n", 
                        a.getTitle().replace("'", "''"), desc, dueDateStr, a.getCreatedBy(), classIdStr, filePath);
                out.println("-- Custom appending via Web Application: Create Assignment");
                out.print(cmd);
            } catch(Exception e) { e.printStackTrace(); }
        }
    }

    private void appendAssignmentDelete(int assignmentId) {
        java.io.File file = new java.io.File("C:\\Users\\Fuc\\Desktop\\databaseprj.sql");
        if (file.exists()) {
            try (java.io.FileWriter fw = new java.io.FileWriter(file, true);
                 java.io.BufferedWriter bw = new java.io.BufferedWriter(fw);
                 java.io.PrintWriter out = new java.io.PrintWriter(bw)) {
                String cmd = String.format("UPDATE [dbo].[Assignments] SET [is_deleted] = 1 WHERE [assignment_id] = %d;\n", assignmentId);
                out.println("-- Custom appending via Web Application: Delete Assignment");
                out.print(cmd);
            } catch(Exception e) { e.printStackTrace(); }
        }
    }

    private void appendAssignmentRestore(int assignmentId) {
        java.io.File file = new java.io.File("C:\\Users\\Fuc\\Desktop\\databaseprj.sql");
        if (file.exists()) {
            try (java.io.FileWriter fw = new java.io.FileWriter(file, true);
                 java.io.BufferedWriter bw = new java.io.BufferedWriter(fw);
                 java.io.PrintWriter out = new java.io.PrintWriter(bw)) {
                String cmd = String.format("UPDATE [dbo].[Assignments] SET [is_deleted] = 0 WHERE [assignment_id] = %d;\n", assignmentId);
                out.println("-- Custom appending via Web Application: Restore Assignment");
                out.print(cmd);
            } catch(Exception e) { e.printStackTrace(); }
        }
    }
}
