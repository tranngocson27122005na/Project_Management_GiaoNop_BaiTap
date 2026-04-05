<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Danh sách bài tập - QLGNBT</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    </head>
    <body class="bg-light">
        <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
            <div class="container">
                <a class="navbar-brand" href="#">QLGNBT</a>
                <div class="navbar-text text-white me-3">
                    Xin chào, <strong>${user.fullName}</strong> (${user.role})
                </div>
                <c:if test="${user.role == 'admin'}">
                    <a href="admin" class="btn btn-warning me-2">Quản trị</a>
                </c:if>
                <c:if test="${user.role == 'teacher'}">
                    <a href="messages" class="btn btn-info me-2 text-white"><i class="fas fa-comments"></i> Tin nhắn</a>
                </c:if>
                <a href="logout" class="btn btn-outline-light">Đăng xuất</a>
            </div>
        </nav>

        <div class="container mt-4">
            <div class="d-flex justify-content-between mb-3">
                <form class="d-flex" method="get" action="assignments">
                    <input type="text" name="search" class="form-control me-2" placeholder="Tìm kiếm bài tập..." value="${param.search}">
                    <button class="btn btn-primary"><i class="fas fa-search"></i></button>
                </form>

                <div class="d-flex">
                    <c:if test="${user.role == 'teacher'}">
                        <a href="createAssignment.jsp" class="btn btn-success me-2">
                            <i class="fas fa-plus"></i> Giao bài mới
                        </a>
                    </c:if>
                    <c:if test="${user.role != 'student'}">
                        <a href="trash" class="btn btn-secondary">
                            <i class="fas fa-trash"></i> Thùng Rác
                        </a>
                    </c:if>
                </div>
            </div>

            <c:if test="${not empty sessionScope.errorMsg}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    ${sessionScope.errorMsg}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <c:remove var="errorMsg" scope="session"/>
            </c:if>
            <c:if test="${not empty sessionScope.successMsg}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    ${sessionScope.successMsg}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <c:remove var="successMsg" scope="session"/>
            </c:if>

            <table class="table table-hover align-middle">
                <thead class="table-dark">
                    <tr>
                        <th>Tiêu đề</th>
                        <th>Lớp</th>
                        <th>Mô tả</th>
                        <th>Hạn nộp</th>
                        <th>Trạng thái</th>
                        <th>Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="a" items="${list}">
                        <tr>
                            <td>
                                <strong>${a.title}</strong>
                                <c:if test="${not empty a.filePath}">
                                    <br><a href="${a.filePath}" class="badge bg-info text-decoration-none mt-1" download><i class="fas fa-download"></i> Tải Đề Bài</a>
                                </c:if>
                            </td>
                            <td>
                                <span class="badge bg-secondary">${a.className}</span>
                                <c:if test="${user.role == 'parent'}">
                                    <br><small class="text-muted mt-1 d-inline-block"><i class="fas fa-user-graduate"></i> Học sinh: <strong>${a.studentName}</strong></small>
                                </c:if>
                            </td>
                            <td>${a.description}</td>
                            <td><fmt:formatDate value="${a.dueDate}" pattern="dd/MM/yyyy HH:mm"/></td>
                            <td>
                                <c:if test="${user.role == 'student' || user.role == 'parent'}">
                                    <c:choose>
                                        <c:when test="${a.status == 'Đã nộp'}">
                                            <span class="badge bg-success">Đã nộp</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-danger">Chưa nộp</span>
                                        </c:otherwise>
                                    </c:choose>
                                    <c:if test="${not empty a.score}">
                                        <br><span class="badge bg-primary mt-1"><i class="fas fa-star text-warning"></i> Điểm: ${a.score}/10</span>
                                    </c:if>
                                </c:if>
                                <c:if test="${user.role == 'teacher' || user.role == 'admin'}">
                                    <span class="badge bg-info">Đã Giao</span>
                                </c:if>
                            </td>
                            <td>
                                <!-- STUDENT & PARENT -->
                                <c:if test="${user.role == 'student' || user.role == 'parent'}">
                                    <a href="assignmentDetail?id=${a.assignmentId}&studentId=${a.studentId}" class="btn btn-info btn-sm text-white">
                                        <i class="fas fa-info-circle"></i> Chi tiết
                                    </a>
                                </c:if>

                                <!-- TEACHER & ADMIN -->
                                <c:if test="${user.role == 'teacher' || user.role == 'admin'}">
                                    <a href="assignmentDetail?id=${a.assignmentId}" class="btn btn-info btn-sm text-white mb-1">
                                        <i class="fas fa-info-circle"></i> Chi tiết & Q&A
                                    </a>
                                    <a href="viewSubmissions?assignmentId=${a.assignmentId}" class="btn btn-primary btn-sm mb-1">
                                        <i class="fas fa-eye"></i> Xem Bài & Chấm Điểm
                                    </a>
                                    <a href="delete-assignment?id=${a.assignmentId}" 
                                       onclick="return confirm('Bạn có chắc muốn xóa bài này không?')"
                                       class="btn btn-danger btn-sm mb-1">
                                        Xóa
                                    </a>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
        <jsp:include page="components/chatWidget.jsp" />
    </body>
</html>