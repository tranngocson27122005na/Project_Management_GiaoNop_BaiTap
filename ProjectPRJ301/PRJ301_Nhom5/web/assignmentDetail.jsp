<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Chi tiết bài tập - QLGNBT</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
        <style>
            .comment-box {
                background: #f8f9fa;
                border-radius: 8px;
                padding: 15px;
                margin-bottom: 15px;
            }
            .comment-header {
                font-weight: bold;
                margin-bottom: 5px;
            }
            .comment-time {
                font-size: 0.8em;
                color: #6c757d;
            }
            .role-badge {
                font-size: 0.7em;
                vertical-align: middle;
                margin-left: 5px;
            }
        </style>
    </head>
    <body class="bg-light">
        <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
            <div class="container">
                <a class="navbar-brand" href="assignments">QLGNBT</a>
                <div class="navbar-text text-white me-3">
                    Xin chào, <strong>${user.fullName}</strong> (${user.role})
                </div>
                <a href="assignments" class="btn btn-outline-light me-2">Quay lại danh sách</a>
                <a href="logout" class="btn btn-outline-light">Đăng xuất</a>
            </div>
        </nav>

        <div class="container mt-4">
            <c:if test="${not empty sessionScope.errorMsg}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    ${sessionScope.errorMsg}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <c:remove var="errorMsg" scope="session"/>
            </c:if>
            <c:if test="${not empty sessionScope.successMsg}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    ${sessionScope.successMsg}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <c:remove var="successMsg" scope="session"/>
            </c:if>

            <div class="row">
                <!-- Cột trái: Chi tiết bài và Nộp bài -->
                <div class="col-md-8">
                    <div class="card mb-4 shadow-sm">
                        <div class="card-header bg-dark text-white d-flex justify-content-between align-items-center">
                            <h4 class="mb-0">${assignment.title}</h4>
                            <span class="badge bg-danger">Hạn nộp: <fmt:formatDate value="${assignment.dueDate}" pattern="dd/MM/yyyy HH:mm"/></span>
                        </div>
                        <div class="card-body">
                            <p><strong>Mô tả:</strong></p>
                            <p>${assignment.description}</p>
                            
                            <c:if test="${not empty assignment.filePath}">
                                <hr>
                                <strong>File đính kèm:</strong> 
                                <a href="${assignment.filePath}" class="btn btn-outline-info btn-sm" download>
                                    <i class="fas fa-download"></i> Tải Đề Bài
                                </a>
                            </c:if>
                        </div>
                    </div>

                    <!-- Phần Nộp bài của Học sinh -->
                    <c:if test="${user.role == 'student' || user.role == 'parent'}">
                        <div class="card mb-4 shadow-sm border-primary">
                            <div class="card-header bg-primary text-white">
                                <h5 class="mb-0"><i class="fas fa-upload"></i> ${user.role == 'student' ? 'Bài Nộp Của Bạn' : 'Bài Nộp Của Học Sinh'}</h5>
                            </div>
                            <div class="card-body">
                                <c:if test="${not empty submission}">
                                    <div class="mb-3">
                                        <strong>Trạng thái:</strong> 
                                        <span class="badge bg-${submission.status == 'Đã nộp' ? 'success' : (submission.status == 'Quá hạn' ? 'danger' : 'warning')}">${submission.status}</span>
                                        <c:if test="${not empty submission.score}">
                                            <span class="badge bg-primary ms-2"><i class="fas fa-star text-warning"></i> Điểm: ${submission.score}/10</span>
                                        </c:if>
                                    </div>
                                    <c:if test="${not empty submission.filePath}">
                                        <div class="mb-3">
                                            <strong>File đã nộp:</strong>
                                            <a href="${submission.filePath}" download class="badge bg-info text-decoration-none"><i class="fas fa-download"></i> Tải về</a>
                                        </div>
                                    </c:if>
                                    <c:if test="${not empty submission.textContent}">
                                        <div class="mb-3">
                                            <strong>Nội dung đã nộp:</strong>
                                            <div class="p-2 border rounded bg-light">${submission.textContent}</div>
                                        </div>
                                    </c:if>
                                    <c:if test="${not empty submission.teacherFeedback}">
                                        <div class="mb-3">
                                            <strong class="text-danger">Nhận xét của Giáo viên:</strong>
                                            <div class="p-2 border border-danger rounded bg-white text-danger">${submission.teacherFeedback}</div>
                                        </div>
                                    </c:if>
                                    <hr>
                                </c:if>

                                <c:if test="${user.role == 'student'}">
                                    <form action="submit" method="post" enctype="multipart/form-data">
                                        <input type="hidden" name="assignmentId" value="${assignment.assignmentId}">
                                        <div class="mb-3">
                                            <label class="form-label fw-bold">Nội dung trả lời (không bắt buộc nếu có file):</label>
                                            <textarea name="textContent" class="form-control" rows="4" placeholder="Nhập câu trả lời..."></textarea>
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label fw-bold">File đính kèm (không bắt buộc nếu nhập nội dung): <small class="text-muted">.zip, .rar</small></label>
                                            <input type="file" name="file" class="form-control">
                                        </div>
                                        <button type="submit" class="btn btn-${not empty submission ? 'warning' : 'primary'} w-100">
                                            <i class="fas fa-paper-plane"></i> ${not empty submission ? 'Nộp Lại Bài' : 'Nộp Bài'}
                                        </button>
                                    </form>
                                </c:if>
                            </div>
                        </div>
                    </c:if>

                    <!-- Phần Quản lý của Giáo viên -->
                    <c:if test="${user.role == 'teacher' || user.role == 'admin'}">
                        <div class="card mb-4 shadow-sm border-success">
                            <div class="card-body text-center">
                                <h5 class="card-title">Quản lý lớp học</h5>
                                <a href="viewSubmissions?assignmentId=${assignment.assignmentId}" class="btn btn-success btn-lg">
                                    <i class="fas fa-users"></i> Xem Bài Nộp & Chấm Điểm
                                </a>
                            </div>
                        </div>
                    </c:if>

                </div>

                <!-- Cột phải: Hỏi Đáp -->
                <div class="col-md-4">
                    <div class="card shadow-sm">
                        <div class="card-header bg-info text-white">
                            <h5 class="mb-0"><i class="fas fa-comments"></i> Hỏi Đáp / Bình Luận</h5>
                        </div>
                        <div class="card-body" style="max-height: 500px; overflow-y: auto;">
                            <c:if test="${empty comments}">
                                <p class="text-muted text-center fst-italic">Chưa có câu hỏi nào.</p>
                            </c:if>
                            
                            <c:forEach var="c" items="${comments}">
                                <div class="comment-box">
                                    <div class="comment-header">
                                        ${c.userName} 
                                        <c:if test="${c.userRole == 'teacher'}">
                                            <span class="badge bg-success role-badge">Giáo viên</span>
                                        </c:if>
                                        <c:if test="${c.userRole == 'student'}">
                                            <span class="badge bg-secondary role-badge">Học sinh</span>
                                        </c:if>
                                        <br>
                                        <span class="comment-time"><fmt:formatDate value="${c.createdAt}" pattern="dd/MM/yyyy HH:mm"/></span>
                                    </div>
                                    <div>${c.content}</div>
                                </div>
                            </c:forEach>
                        </div>
                        <div class="card-footer">
                            <form action="assignmentDetail" method="post">
                                <input type="hidden" name="action" value="comment">
                                <input type="hidden" name="assignmentId" value="${assignment.assignmentId}">
                                <div class="input-group">
                                    <input type="text" name="content" class="form-control" placeholder="Nhập câu hỏi..." required>
                                    <button class="btn btn-info text-white" type="submit"><i class="fas fa-paper-plane"></i> Gửi</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <jsp:include page="components/chatWidget.jsp" />
    </body>
</html>
