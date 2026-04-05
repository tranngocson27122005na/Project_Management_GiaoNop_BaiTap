<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    models.User user = (models.User) session.getAttribute("user");
    if (user != null && "teacher".equals(user.getRole())) {
        dal.ClassDAO classDao = new dal.ClassDAO();
        java.util.List<models.ClassRoom> myClasses = classDao.getClassesByTeacher(user.getUserId());
        request.setAttribute("myClasses", myClasses);
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Giao bài tập mới</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container mt-5">
    <div class="card">
        <div class="card-header bg-success text-white">
            <h4>Giao bài tập mới</h4>
        </div>
        <div class="card-body">
            <c:if test="${not empty sessionScope.errorMsg}">
                <div class="alert alert-danger">${sessionScope.errorMsg}</div>
                <c:remove var="errorMsg" scope="session"/>
            </c:if>
            <c:choose>
                <c:when test="${empty myClasses}">
                    <div class="alert alert-warning text-center">
                        <h5>Bạn chưa được phân công lớp học nào</h5>
                        <p>Vui lòng đăng nhập bằng tài khoản <strong>Admin</strong> để tạo Lớp, phân công bạn làm Giáo viên chủ nhiệm và duyệt Học sinh vào lớp trước khi thực hiện giao bài tập mới.</p>
                        <a href="assignments" class="btn btn-secondary mt-3">Quay lại Danh sách</a>
                    </div>
                </c:when>
                <c:otherwise>
                    <form action="createAssignment" method="post" enctype="multipart/form-data">
                        <div class="mb-3">
                            <label>Tiêu đề</label>
                            <input type="text" name="title" class="form-control" required>
                        </div>
                        <div class="mb-3">
                            <label>Mô tả</label>
                            <textarea name="description" class="form-control" rows="5"></textarea>
                        </div>
                        <div class="mb-3">
                            <label>Lớp học</label>
                            <select name="classId" class="form-select" required>
                                <option value="" disabled selected>-- Chọn lớp để giao bài --</option>
                                <c:forEach var="c" items="${myClasses}">
                                    <option value="${c.classId}">${c.className}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label>Tài liệu đính kèm (Đề bài)</label>
                            <input type="file" name="file" class="form-control">
                        </div>
                        <div class="mb-3">
                            <label>Hạn nộp</label>
                            <input type="date" name="due_date" class="form-control" required>
                        </div>
                        <button type="submit" class="btn btn-success">Giao bài</button>
                        <a href="assignments" class="btn btn-secondary">Quay lại</a>
                    </form>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>
</body>
</html>