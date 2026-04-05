<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    try {
        dal.ClassDAO classDao = new dal.ClassDAO();
        java.util.List<models.ClassRoom> cls = classDao.getAllClasses();
        request.setAttribute("classes", cls);
        if (cls == null || cls.isEmpty()) {
            request.setAttribute("dbError", "Danh sách lớp học đang trống hoặc không thể kết nối CSDL.");
        }
    } catch(Exception e) {
        request.setAttribute("dbError", "Lỗi CSDL: " + e.getMessage());
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Đăng ký QLGNBT</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body class="bg-light">
<div class="container mt-5">
    <div class="row justify-content-center">
        <div class="col-md-6">
            <div class="card shadow">
                <div class="card-header text-center bg-success text-white">
                    <h3><i class="fas fa-user-plus"></i> Đăng ký QLGNBT</h3>
                </div>
                <div class="card-body">
                    <c:if test="${not empty dbError}"><div class="alert alert-warning">${dbError} <a href="setup.jsp">Nhấn vào đây để tự động tạo 5 lớp</a></div></c:if>
                    <c:if test="${not empty error}"><div class="alert alert-danger">${error}</div></c:if>
                    <c:if test="${not empty success}"><div class="alert alert-success">${success}</div></c:if>

                    <form action="register" method="post">
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <input type="text" name="username" class="form-control" placeholder="Tên đăng nhập" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <input type="password" name="password" class="form-control" placeholder="Mật khẩu" required>
                            </div>
                        </div>
                        <div class="mb-3">
                            <input type="text" name="fullName" class="form-control" placeholder="Họ và tên" required>
                        </div>
                        <div class="mb-3">
                            <input type="email" name="email" class="form-control" placeholder="Email" required>
                        </div>
                        <div class="mb-3">
                            <select name="role" class="form-select" required onchange="toggleClass(this)">
                                <option value="">Chọn vai trò</option>
                                <option value="student">Sinh viên</option>
                                <option value="teacher">Giáo viên</option>
                                <option value="parent">Phụ huynh</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <select name="classId" id="classIdSelect" class="form-select" required>
                                <option value="">Chọn lớp học</option>
                                <c:forEach var="c" items="${classes}">
                                    <option value="${c.classId}">${c.className}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <button type="submit" class="btn btn-success w-100">Đăng ký</button>
                    </form>
                    <p class="text-center mt-3">Đã có tài khoản? <a href="login">Đăng nhập</a></p>
                </div>
            </div>
        </div>
    </div>
</div>
<script>
    function toggleClass(select) {
        var classSelect = document.getElementById('classIdSelect');
        if (select.value === 'student') {
            classSelect.required = true;
            classSelect.disabled = false;
        } else {
            classSelect.required = false;
            classSelect.disabled = true;
            classSelect.value = "";
        }
    }
</script>
</body>
</html>