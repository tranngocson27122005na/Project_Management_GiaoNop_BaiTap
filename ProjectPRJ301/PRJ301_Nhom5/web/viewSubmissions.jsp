<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>Chấm điểm bài tập - QLGNBT</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        .table-responsive { background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
    </style>
</head>
<body class="bg-light">
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-success mb-4">
        <div class="container">
            <a class="navbar-brand" href="assignments"><i class="fas fa-arrow-left"></i> Quay Lại</a>
            <div class="d-flex">
                <span class="navbar-text me-3 text-white">Xin chào, ${user.fullName} (${user.role})</span>
                <a href="logout" class="btn btn-outline-light btn-sm">Đăng xuất</a>
            </div>
        </div>
    </nav>
    <div class="container">
        <h3 class="mb-3 text-success"><i class="fas fa-clipboard-check"></i> Chấm Điểm: ${assignment.title}</h3>
        <p class="text-muted"><i class="fas fa-info-circle"></i> Vui lòng nhập điểm số (từ 0 đến 10) và bấm Lưu.</p>
        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead class="table-success">
                    <tr>
                        <th>Sinh Viên & Nội Dung</th>
                        <th>Ngày Nộp</th>
                        <th>Trạng Thái</th>
                        <th>Đánh Giá & Chấm Điểm</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="sub" items="${submissions}">
                        <tr>
                            <td>
                                <strong>${sub.studentName}</strong>
                                <c:if test="${not empty sub.textContent}">
                                    <div class="mt-2 text-muted small p-2 bg-light border rounded">
                                        <em>${sub.textContent}</em>
                                    </div>
                                </c:if>
                                <c:if test="${not empty sub.filePath}">
                                    <div class="mt-2">
                                        <a href="${sub.filePath}" class="badge bg-primary text-decoration-none" download><i class="fas fa-download"></i> Tải bài đính kèm</a>
                                    </div>
                                </c:if>
                            </td>
                            <td><fmt:formatDate value="${sub.submitDate}" pattern="dd/MM/yyyy HH:mm"/></td>
                            <td>
                                <span class="badge bg-${sub.status == 'Đã nộp' ? 'success' : (sub.status == 'Quá hạn' ? 'danger' : 'warning')}">${sub.status}</span>
                            </td>
                            <td>
                                <form action="gradeSubmission" method="post">
                                    <input type="hidden" name="submissionId" value="${sub.submissionId}">
                                    <input type="hidden" name="assignmentId" value="${assignment.assignmentId}">
                                    <input type="hidden" name="studentId" value="${sub.studentId}">
                                    <div class="d-flex align-items-center mb-2">
                                        <input type="number" step="0.5" min="0" max="10" name="score" value="${sub.score}" class="form-control form-control-sm me-2" style="width: 80px;" placeholder="Điểm" required>
                                        <button type="submit" class="btn btn-success btn-sm"><i class="fas fa-save"></i> Lưu</button>
                                    </div>
                                    <textarea name="teacherFeedback" class="form-control form-control-sm" rows="2" placeholder="Nhập nhận xét...">${sub.teacherFeedback}</textarea>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty submissions}">
                        <tr>
                            <td colspan="4" class="text-center text-muted">Chưa có sinh viên nào nộp bài.</td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
    
    <jsp:include page="components/chatWidget.jsp" />
</body>
</html>
