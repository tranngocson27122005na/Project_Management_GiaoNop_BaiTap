<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Thùng Rác - QLGNBT</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <style>
            body { background-color: #f8f9fc; }
            .card { border: none; box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15); border-radius: 0.35rem; }
            .card-header { background-color: #f8f9fc; border-bottom: 1px solid #e3e6f0; }
            .badge { font-size: 0.85em; }
        </style>
    </head>
    <body>
        <nav class="navbar navbar-expand-lg navbar-dark bg-primary shadow-sm mb-4">
            <div class="container">
                <a class="navbar-brand fw-bold" href="assignments">QLGNBT</a>
                <div class="d-flex align-items-center text-white">
                    <span class="me-3">Xin chào, <strong>${sessionScope.user.fullName}</strong> (${sessionScope.user.role})</span>
                    <a href="logout" class="btn btn-outline-light btn-sm">Đăng xuất</a>
                </div>
            </div>
        </nav>

        <div class="container mt-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h4 class="mb-0 text-secondary"><i class="fas fa-trash"></i> Thùng Rác</h4>
                <div>
                    <a href="assignments" class="btn btn-secondary">
                        <i class="fas fa-arrow-left"></i> Quay lại
                    </a>
                </div>
            </div>

            <div class="card mb-4">
                <div class="card-header py-3 d-flex justify-content-between align-items-center">
                    <h6 class="m-0 font-weight-bold text-secondary">Danh sách bài tập đã bị xóa</h6>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-dark">
                                <tr>
                                    <th>Tiêu đề</th>
                                    <th>Lớp</th>
                                    <th>Mô tả</th>
                                    <th>Hạn nộp</th>
                                    <th>Hành động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${list}" var="a">
                                    <tr>
                                        <td><strong>${a.title}</strong></td>
                                        <td><span class="badge bg-secondary">${a.className}</span></td>
                                        <td>${a.description}</td>
                                        <td><fmt:formatDate value="${a.dueDate}" pattern="dd/MM/yyyy HH:mm"/></td>
                                        <td>
                                            <a href="restore-assignment?id=${a.assignmentId}" class="btn btn-success btn-sm mb-1" onclick="return confirm('Bạn có chắc muốn khôi phục Bài này không?');">
                                                <i class="fas fa-trash-restore"></i> Khôi Phục
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty list}">
                                    <tr>
                                        <td colspan="5" class="text-center text-muted py-4"><i class="fas fa-box-open fa-2x mb-3 text-secondary"></i><br/>Thùng rác trống.</td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
