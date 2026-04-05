<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="dal.DBContext" %>
<!DOCTYPE html>
<html>
<head>
    <title>Khởi tạo dữ liệu lớp học</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container mt-5 text-center">
<%!
    public class SetupDB extends dal.DBContext {
        public Connection getConn() { 
            return connection; 
        }
    }
%>
<%
    try {
        SetupDB db = new SetupDB();
        Connection conn = db.getConn();
        Statement stmt = conn.createStatement();
        
        // Xóa khóa ngoại constraint nếu có (để teacher_id có thể là NULL)
        try {
            stmt.executeUpdate("ALTER TABLE Classes DROP CONSTRAINT FK_Classes_Teacher");
        } catch(Exception e) {} // Bỏ qua nếu không tồn tại
        
        // Cho phép teacher_id là NULL để các lớp có thể được tạo độc lập với giáo viên
        try {
            stmt.executeUpdate("ALTER TABLE Classes ALTER COLUMN teacher_id INT NULL");
        } catch(Exception e) {}
        
        // Cứu cánh: Khôi phục lại tài khoản admin mặc định nếu bị gán nhầm mật khẩu
        try {
            stmt.executeUpdate("UPDATE Users SET password = 'admin' WHERE username = 'admin'");
        } catch(Exception e) {}
        
        // Kiểm tra xem đã có lớp học nào chưa
        ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM Classes");
        rs.next();
        if (rs.getInt(1) == 0) {
            // Chưa có lớp nào, tạo sẵn 5 lớp
            stmt.executeUpdate("INSERT INTO Classes(class_name) VALUES (N'Lớp KTPM 1')");
            stmt.executeUpdate("INSERT INTO Classes(class_name) VALUES (N'Lớp KTPM 2')");
            stmt.executeUpdate("INSERT INTO Classes(class_name) VALUES (N'Lớp An Toàn Thông Tin')");
            stmt.executeUpdate("INSERT INTO Classes(class_name) VALUES (N'Lớp Trí Tuệ Nhân Tạo')");
            stmt.executeUpdate("INSERT INTO Classes(class_name) VALUES (N'Lớp Hệ Thống Thông Tin')");
            out.println("<h3 class='text-success'>Đã tạo sẵn 5 lớp học thành công!</h3>");
        } else {
            out.println("<h3 class='text-warning'>Trong DB đã có sẵn dữ liệu lớp học rồi!</h3>");
        }
        
    } catch(Exception e) {
        out.println("<h3 class='text-danger'>Lỗi thực thi dữ liệu: " + e.getMessage() + "</h3>");
    }
%>
    <br>
    <a href="register" class="btn btn-primary mt-3">Quay lại trang Đăng Ký</a>
</div>
</body>
</html>
