package dal;
import models.Submission;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SubmissionDAO extends DBContext {

    public SubmissionDAO() {
        super();
        try (Statement st = connection.createStatement()) {
            st.execute("ALTER TABLE Submissions ADD text_content NVARCHAR(MAX)");
        } catch (Exception e) {}
        try (Statement st = connection.createStatement()) {
            st.execute("ALTER TABLE Submissions ADD teacher_feedback NVARCHAR(MAX)");
        } catch (Exception e) {}
    }

    public boolean submitAssignment(int assignmentId, int studentId, String filePath, String textContent) {
        String check = "SELECT 1 FROM Submissions WHERE assignment_id = ? AND student_id = ?";

        try (PreparedStatement psCheck = connection.prepareStatement(check)) {
            psCheck.setInt(1, assignmentId);
            psCheck.setInt(2, studentId);

            ResultSet rs = psCheck.executeQuery();

            if (rs.next()) {
                // ĐÃ TỒN TẠI → UPDATE (NỘP LẠI)
                String update = "UPDATE Submissions SET file_path = ?, text_content = ?, submit_date = GETDATE(), status = N'Đã nộp' WHERE assignment_id = ? AND student_id = ?";
                try (PreparedStatement ps = connection.prepareStatement(update)) {
                    ps.setString(1, filePath);
                    ps.setString(2, textContent);
                    ps.setInt(3, assignmentId);
                    ps.setInt(4, studentId);
                    boolean success = ps.executeUpdate() > 0;
                    if (success) appendSubmitUpdate(assignmentId, studentId, filePath, textContent);
                    return success;
                }
            } else {
                // CHƯA CÓ → INSERT
                String insert = "INSERT INTO Submissions(assignment_id, student_id, file_path, text_content, submit_date, status) VALUES(?,?,?,?,GETDATE(),N'Đã nộp')";
                try (PreparedStatement ps = connection.prepareStatement(insert)) {
                    ps.setInt(1, assignmentId);
                    ps.setInt(2, studentId);
                    ps.setString(3, filePath);
                    ps.setString(4, textContent);
                    boolean success = ps.executeUpdate() > 0;
                    if (success) appendSubmitInsert(assignmentId, studentId, filePath, textContent);
                    return success;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Submission> getSubmissionsByAssignment(int assignmentId) {
        List<Submission> list = new ArrayList<>();
        String sql = "SELECT u.user_id, u.full_name, " +
                     "s.submission_id, s.file_path, s.text_content, s.teacher_feedback, s.submit_date, s.status, s.score, a.due_date " +
                     "FROM Users u " +
                     "INNER JOIN Assignments a ON u.class_id = a.class_id " +
                     "LEFT JOIN Submissions s ON s.student_id = u.user_id AND s.assignment_id = a.assignment_id " +
                     "WHERE a.assignment_id = ? AND u.role = 'student'";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, assignmentId);
            ResultSet rs = ps.executeQuery();
            java.util.Date now = new java.util.Date();
            while (rs.next()) {
                Submission sub = new Submission();
                int submitId = rs.getInt("submission_id");
                sub.setSubmissionId(submitId);
                sub.setAssignmentId(assignmentId);
                sub.setStudentId(rs.getInt("user_id"));
                sub.setStudentName(rs.getString("full_name"));
                
                Timestamp dueDate = rs.getTimestamp("due_date");
                boolean isPastDue = dueDate != null && now.after(dueDate);
                
                if (submitId > 0) {
                    sub.setFilePath(rs.getString("file_path"));
                    sub.setTextContent(rs.getString("text_content"));
                    sub.setTeacherFeedback(rs.getString("teacher_feedback"));
                    sub.setSubmitDate(rs.getTimestamp("submit_date"));
                    sub.setStatus(rs.getString("status"));
                    Object sc = rs.getObject("score");
                    if (sc != null) sub.setScore(rs.getDouble("score"));
                } else {
                    sub.setStatus(isPastDue ? "Quá hạn" : "Chưa làm");
                    if (isPastDue) {
                        sub.setScore(0.0);
                    }
                }
                list.add(sub);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
    
    public Submission getSubmission(int assignmentId, int studentId) {
        String sql = "SELECT * FROM Submissions WHERE assignment_id = ? AND student_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, assignmentId);
            ps.setInt(2, studentId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Submission sub = new Submission();
                sub.setSubmissionId(rs.getInt("submission_id"));
                sub.setAssignmentId(assignmentId);
                sub.setStudentId(studentId);
                sub.setFilePath(rs.getString("file_path"));
                sub.setTextContent(rs.getString("text_content"));
                sub.setTeacherFeedback(rs.getString("teacher_feedback"));
                sub.setSubmitDate(rs.getTimestamp("submit_date"));
                sub.setStatus(rs.getString("status"));
                Object sc = rs.getObject("score");
                if (sc != null) sub.setScore(rs.getDouble("score"));
                return sub;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public boolean gradeStudent(int assignmentId, int studentId, int submissionId, double score, String feedback) {
        if (submissionId > 0) {
            String sql = "UPDATE Submissions SET score = ?, teacher_feedback = ? WHERE submission_id = ?";
            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setDouble(1, score);
                ps.setString(2, feedback);
                ps.setInt(3, submissionId);
                boolean success = ps.executeUpdate() > 0;
                if (success) appendGradeUpdate(submissionId, score, feedback);
                return success;
            } catch (SQLException e) { e.printStackTrace(); }
        } else {
            String sql = "INSERT INTO Submissions(assignment_id, student_id, score, teacher_feedback, status, submit_date) VALUES(?,?,?,?, N'Đã chấm (Quá hạn)', GETDATE())";
            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setInt(1, assignmentId);
                ps.setInt(2, studentId);
                ps.setDouble(3, score);
                ps.setString(4, feedback);
                boolean success = ps.executeUpdate() > 0;
                if (success) appendGradeInsert(assignmentId, studentId, score, feedback);
                return success;
            } catch (SQLException e) { e.printStackTrace(); }
        }
        return false;
    }

    private void appendSubmitUpdate(int assignmentId, int studentId, String filePath, String textContent) {
        java.io.File file = new java.io.File("C:\\Users\\Fuc\\Desktop\\databaseprj.sql");
        if (file.exists()) {
            try (java.io.FileWriter fw = new java.io.FileWriter(file, true);
                 java.io.BufferedWriter bw = new java.io.BufferedWriter(fw);
                 java.io.PrintWriter out = new java.io.PrintWriter(bw)) {
                String cmd = String.format("UPDATE [dbo].[Submissions] SET [file_path] = N'%s', [text_content] = N'%s', [submit_date] = GETDATE(), [status] = N'Đã nộp' WHERE [assignment_id] = %d AND [student_id] = %d;\n", filePath != null ? filePath.replace("'", "''") : "", textContent != null ? textContent.replace("'", "''") : "", assignmentId, studentId);
                out.println("-- Custom appending via Web Application: Resubmit Assignment");
                out.print(cmd);
            } catch(Exception e) { e.printStackTrace(); }
        }
    }

    private void appendSubmitInsert(int assignmentId, int studentId, String filePath, String textContent) {
        java.io.File file = new java.io.File("C:\\Users\\Fuc\\Desktop\\databaseprj.sql");
        if (file.exists()) {
            try (java.io.FileWriter fw = new java.io.FileWriter(file, true);
                 java.io.BufferedWriter bw = new java.io.BufferedWriter(fw);
                 java.io.PrintWriter out = new java.io.PrintWriter(bw)) {
                String cmd = String.format("INSERT [dbo].[Submissions]([assignment_id], [student_id], [file_path], [text_content], [submit_date], [status]) VALUES(%d, %d, N'%s', N'%s', GETDATE(), N'Đã nộp');\n", assignmentId, studentId, filePath != null ? filePath.replace("'", "''") : "", textContent != null ? textContent.replace("'", "''") : "");
                out.println("-- Custom appending via Web Application: Submit Assignment");
                out.print(cmd);
            } catch(Exception e) { e.printStackTrace(); }
        }
    }

    private void appendGradeUpdate(int submissionId, double score, String feedback) {
        java.io.File file = new java.io.File("C:\\Users\\Fuc\\Desktop\\databaseprj.sql");
        if (file.exists()) {
            try (java.io.FileWriter fw = new java.io.FileWriter(file, true);
                 java.io.BufferedWriter bw = new java.io.BufferedWriter(fw);
                 java.io.PrintWriter out = new java.io.PrintWriter(bw)) {
                String cmd = String.format("UPDATE [dbo].[Submissions] SET [score] = %s, [teacher_feedback] = N'%s' WHERE [submission_id] = %d;\n", String.valueOf(score), feedback != null ? feedback.replace("'", "''") : "", submissionId);
                out.println("-- Custom appending via Web Application: Grade Update");
                out.print(cmd);
            } catch(Exception e) { e.printStackTrace(); }
        }
    }

    private void appendGradeInsert(int assignmentId, int studentId, double score, String feedback) {
        java.io.File file = new java.io.File("C:\\Users\\Fuc\\Desktop\\databaseprj.sql");
        if (file.exists()) {
            try (java.io.FileWriter fw = new java.io.FileWriter(file, true);
                 java.io.BufferedWriter bw = new java.io.BufferedWriter(fw);
                 java.io.PrintWriter out = new java.io.PrintWriter(bw)) {
                String cmd = String.format("INSERT [dbo].[Submissions]([assignment_id], [student_id], [score], [teacher_feedback], [status], [submit_date]) VALUES(%d, %d, %s, N'%s', N'Đã chấm (Quá hạn)', GETDATE());\n", assignmentId, studentId, String.valueOf(score), feedback != null ? feedback.replace("'", "''") : "");
                out.println("-- Custom appending via Web Application: Grade Insert");
                out.print(cmd);
            } catch(Exception e) { e.printStackTrace(); }
        }
    }
}