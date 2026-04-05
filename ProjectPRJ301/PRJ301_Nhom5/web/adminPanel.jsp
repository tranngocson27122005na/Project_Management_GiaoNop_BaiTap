<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Quyền Quản Trị - QLGNBT</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        body { background-color: #f8f9fa; }
        .table-responsive { background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
    </style>
</head>
<body>
<!-- Navbar -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark mb-4">
    <div class="container">
        <a class="navbar-brand" href="#">QLGNBT Admin</a>
        <div class="d-flex">
            <span class="navbar-text me-3 text-white">Xin chào, Admin!</span>
            <a href="logout" class="btn btn-outline-danger btn-sm">Đăng xuất</a>
        </div>
    </div>
</nav>

<div class="container">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="mb-0"><i class="fas fa-users-cog"></i> Quản Lý Tài Khoản</h2>
        <div>
            <button class="btn btn-primary shadow me-2" data-bs-toggle="modal" data-bs-target="#createClassModal"><i class="fas fa-plus"></i> Tạo Lớp Mới</button>
            <button class="btn btn-success shadow me-2" data-bs-toggle="modal" data-bs-target="#createUserModal"><i class="fas fa-plus"></i> Thêm Tài Khoản Mới</button>
            <a href="assignments" class="btn btn-info shadow"><i class="fas fa-tasks"></i> Danh Sách Bài Tập (Quản Trị)</a>
        </div>
    </div>
    
    <c:if test="${not empty errorMsg}"><div class="alert alert-danger">${errorMsg}</div></c:if>
    <c:if test="${not empty successMsg}"><div class="alert alert-success">${successMsg}</div></c:if>
    
    <h4 class="mt-4 text-warning"><i class="fas fa-user-clock"></i> Tài Khoản Chờ Duyệt</h4>
    <div class="table-responsive mb-4">
        <table class="table table-hover align-middle">
            <thead class="table-dark">
                <tr>
                    <th>ID</th>
                    <th>Tài Khỏan</th>
                    <th>Họ Tên</th>
                    <th>Vai Trò</th>
                    <th>Lớp (ID)</th>
                    <th>Trạng Thái</th>
                    <th>Thao Tác</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="u" items="${pendingUsers}">
                    <tr>
                        <td>${u.userId}</td>
                        <td>${u.username}</td>
                        <td>${u.fullName}</td>
                        <td>
                            <span class="badge bg-${u.role == 'admin' ? 'danger' : (u.role == 'teacher' ? 'primary' : 'secondary')}">${u.role}</span>
                        </td>
                        <td>${u.classId != null ? u.classId : '-'}</td>
                        <td>
                            <span class="badge bg-warning text-dark">${u.status}</span>
                        </td>
                        <td>
                            <div class="btn-group btn-group-sm">
                                <form action="admin" method="post" class="d-inline">
                                    <input type="hidden" name="action" value="approve">
                                    <input type="hidden" name="targetUserId" value="${u.userId}">
                                    <button type="submit" class="btn btn-success me-1" title="Duyệt"><i class="fas fa-check"></i></button>
                                </form>
                                <form action="admin" method="post" class="d-inline">
                                    <input type="hidden" name="action" value="reject">
                                    <input type="hidden" name="targetUserId" value="${u.userId}">
                                    <button type="submit" class="btn btn-warning me-1" title="Từ chối"><i class="fas fa-times"></i></button>
                                </form>
                                <form action="admin" method="post" class="d-inline" onsubmit="return confirm('Bạn có chắc chắn muốn xóa tài khoản này?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="targetUserId" value="${u.userId}">
                                    <button type="submit" class="btn btn-danger" title="Xóa"><i class="fas fa-trash"></i></button>
                                </form>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty pendingUsers}">
                    <tr><td colspan="7" class="text-center text-muted">Không có tài khoản nào chờ duyệt</td></tr>
                </c:if>
            </tbody>
        </table>
    </div>

    <h4 class="mt-4 text-success"><i class="fas fa-user-check"></i> Tài Khoản Hoạt Động</h4>
    <div class="table-responsive">
        <table class="table table-hover align-middle">
            <thead class="table-dark">
                <tr>
                    <th>ID</th>
                    <th>Tài Khỏan</th>
                    <th>Họ Tên</th>
                    <th>Vai Trò</th>
                    <th>Lớp (ID)</th>
                    <th>Trạng Thái</th>
                    <th>Thao Tác</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="u" items="${activeUsers}">
                    <tr>
                        <td>${u.userId}</td>
                        <td>${u.username}</td>
                        <td>${u.fullName}</td>
                        <td>
                            <span class="badge bg-${u.role == 'admin' ? 'danger' : (u.role == 'teacher' ? 'primary' : 'secondary')}">${u.role}</span>
                        </td>
                        <td>${u.classId != null ? u.classId : '-'}</td>
                        <td>
                            <span class="badge bg-${u.status == 'ACTIVE' ? 'success' : (u.status == 'PENDING' ? 'warning' : 'danger')}">${u.status}</span>
                        </td>
                        <td>
                            <div class="btn-group btn-group-sm">
                                <c:if test="${u.role != 'admin'}">
                                    <!-- Edit Info Btn -->
                                    <button class="btn btn-primary me-1" data-bs-toggle="modal" data-bs-target="#editUserModal${u.userId}" title="Sửa Thông Tin"><i class="fas fa-edit"></i></button>
                                    <!-- Edit Password Btn -->
                                    <button class="btn btn-info text-white me-1" data-bs-toggle="modal" data-bs-target="#editPasswordModal${u.userId}" title="Đổi Mật Khẩu"><i class="fas fa-key"></i></button>

                                    <!-- Removed Pending Actions as they now have their own table -->
                                    <c:choose>
                                        <c:when test="${u.status == 'ACTIVE'}">
                                            <form action="admin" method="post" class="d-inline" onsubmit="return confirm('Khóa tạm thời tài khoản này?');">
                                                <input type="hidden" name="action" value="lock">
                                                <input type="hidden" name="targetUserId" value="${u.userId}">
                                                <button type="submit" class="btn btn-warning me-1" title="Khóa Tạm Thời"><i class="fas fa-lock"></i></button>
                                            </form>
                                            <form action="admin" method="post" class="d-inline" onsubmit="return confirm('Khóa VĨNH VIỄN tài khoản này?');">
                                                <input type="hidden" name="action" value="ban">
                                                <input type="hidden" name="targetUserId" value="${u.userId}">
                                                <button type="submit" class="btn btn-dark me-1" title="Khóa Vĩnh Viễn"><i class="fas fa-ban"></i></button>
                                            </form>
                                        </c:when>

                                        <c:when test="${u.status == 'LOCKED' || u.status == 'BANNED'}">
                                            <form action="admin" method="post" class="d-inline">
                                                <input type="hidden" name="action" value="unlock">
                                                <input type="hidden" name="targetUserId" value="${u.userId}">
                                                <button type="submit" class="btn btn-success me-1" title="Mở Khóa"><i class="fas fa-unlock"></i></button>
                                            </form>
                                        </c:when>
                                    </c:choose>

                                    <!-- Delete Btn -->
                                    <form action="admin" method="post" class="d-inline" onsubmit="return confirm('Bạn có chắc chắn muốn xóa tài khoản này?');">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="targetUserId" value="${u.userId}">
                                        <button type="submit" class="btn btn-danger" title="Xóa"><i class="fas fa-trash"></i></button>
                                    </form>
                                </c:if>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

    <h4 class="mt-5 text-info"><i class="fas fa-user-friends"></i> Quản Lý Liên Kết Phụ Huynh - Học Sinh</h4>
    <div class="table-responsive mb-4">
        <table class="table table-hover align-middle">
            <thead class="table-dark">
                <tr>
                    <th>ID</th>
                    <th>Phụ Huynh</th>
                    <th>Email</th>
                    <th>Học Sinh Đã Liên Kết</th>
                    <th>Thêm Liên Kết</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="p" items="${parents}">
                    <tr>
                        <td>${p.userId}</td>
                        <td>${p.fullName} (${p.username})</td>
                        <td>${p.email != null ? p.email : '-'}</td>
                        <td>
                            <c:set var="linkedList" value="${parentLinkedStudents[p.userId]}" />
                            <c:if test="${empty linkedList}">
                                <span class="text-muted fst-italic">Chưa có liên kết</span>
                            </c:if>
                            <c:if test="${not empty linkedList}">
                                <ul class="list-unstyled mb-0">
                                    <c:forEach var="ls" items="${linkedList}">
                                        <li class="mb-1">
                                            <span class="badge bg-secondary">${ls.fullName} (${ls.username})</span>
                                            <form action="admin" method="post" class="d-inline" onsubmit="return confirm('Gỡ số dư liên kết này?');">
                                                <input type="hidden" name="action" value="unlink_student">
                                                <input type="hidden" name="targetParentId" value="${p.userId}">
                                                <input type="hidden" name="studentId" value="${ls.userId}">
                                                <button type="submit" class="btn btn-sm btn-outline-danger border-0 p-0 ms-1" title="Gỡ liên kết"><i class="fas fa-times-circle"></i></button>
                                            </form>
                                        </li>
                                    </c:forEach>
                                </ul>
                            </c:if>
                        </td>
                        <td>
                            <form action="admin" method="post" class="d-flex align-items-center">
                                <input type="hidden" name="action" value="link_student">
                                <input type="hidden" name="targetParentId" value="${p.userId}">
                                <select name="studentId" class="form-select form-select-sm me-2" required>
                                    <option value="" disabled selected>-- Chọn HS --</option>
                                    <c:forEach var="s" items="${allStudents}">
                                        <option value="${s.userId}">${s.fullName} (${s.username})</option>
                                    </c:forEach>
                                </select>
                                <button type="submit" class="btn btn-sm btn-primary"><i class="fas fa-link"></i> Gán</button>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

    <h4 class="mt-5 text-danger"><i class="fas fa-user-lock"></i> Tài Khoản Giáo Viên Bị Khóa</h4>
    <div class="table-responsive mb-4">
        <table class="table table-hover align-middle">
            <thead class="table-dark">
                <tr>
                    <th>ID</th>
                    <th>Tài Khỏan</th>
                    <th>Họ Tên</th>
                    <th>Vai Trò</th>
                    <th>Lớp (ID)</th>
                    <th>Trạng Thái</th>
                    <th>Thao Tác</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="u" items="${lockedTeachers}">
                    <tr>
                        <td>${u.userId}</td>
                        <td>${u.username}</td>
                        <td>${u.fullName}</td>
                        <td>
                            <span class="badge bg-${u.role == 'admin' ? 'danger' : (u.role == 'teacher' ? 'primary' : 'secondary')}">${u.role}</span>
                        </td>
                        <td>${u.classId != null ? u.classId : '-'}</td>
                        <td>
                            <span class="badge bg-${u.status == 'ACTIVE' ? 'success' : (u.status == 'PENDING' ? 'warning' : 'danger')}">${u.status}</span>
                        </td>
                        <td>
                            <div class="btn-group btn-group-sm">
                                <form action="admin" method="post" class="d-inline">
                                    <input type="hidden" name="action" value="unlock">
                                    <input type="hidden" name="targetUserId" value="${u.userId}">
                                    <button type="submit" class="btn btn-success me-1" title="Mở Khóa"><i class="fas fa-unlock"></i></button>
                                </form>
                                <form action="admin" method="post" class="d-inline" onsubmit="return confirm('Bạn có chắc chắn muốn xóa tài khoản này?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="targetUserId" value="${u.userId}">
                                    <button type="submit" class="btn btn-danger" title="Xóa"><i class="fas fa-trash"></i></button>
                                </form>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

    <h4 class="mt-5 text-warning"><i class="fas fa-user-times"></i> Tài Khoản Học Sinh Bị Khóa</h4>
    <div class="table-responsive mb-4">
        <table class="table table-hover align-middle">
            <thead class="table-dark">
                <tr>
                    <th>ID</th>
                    <th>Tài Khỏan</th>
                    <th>Họ Tên</th>
                    <th>Vai Trò</th>
                    <th>Lớp (ID)</th>
                    <th>Trạng Thái</th>
                    <th>Thao Tác</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="u" items="${lockedStudents}">
                    <tr>
                        <td>${u.userId}</td>
                        <td>${u.username}</td>
                        <td>${u.fullName}</td>
                        <td>
                            <span class="badge bg-${u.role == 'admin' ? 'danger' : (u.role == 'teacher' ? 'primary' : 'secondary')}">${u.role}</span>
                        </td>
                        <td>${u.classId != null ? u.classId : '-'}</td>
                        <td>
                            <span class="badge bg-${u.status == 'ACTIVE' ? 'success' : (u.status == 'PENDING' ? 'warning' : 'danger')}">${u.status}</span>
                        </td>
                        <td>
                            <div class="btn-group btn-group-sm">
                                <form action="admin" method="post" class="d-inline">
                                    <input type="hidden" name="action" value="unlock">
                                    <input type="hidden" name="targetUserId" value="${u.userId}">
                                    <button type="submit" class="btn btn-success me-1" title="Mở Khóa"><i class="fas fa-unlock"></i></button>
                                </form>
                                <form action="admin" method="post" class="d-inline" onsubmit="return confirm('Bạn có chắc chắn muốn xóa tài khoản này?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="targetUserId" value="${u.userId}">
                                    <button type="submit" class="btn btn-danger" title="Xóa"><i class="fas fa-trash"></i></button>
                                </form>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

    <!-- Modals (Placed outside table to prevent browser DOM nesting bugs) -->
    <c:forEach var="u" items="${users}">
        <c:if test="${u.role != 'admin'}">
            <!-- Edit User Modal -->
            <div class="modal fade" id="editUserModal${u.userId}" tabindex="-1" aria-hidden="true">
                <div class="modal-dialog">
                    <form action="admin" method="post">
                        <input type="hidden" name="action" value="edit_user">
                        <input type="hidden" name="targetUserId" value="${u.userId}">
                        <div class="modal-content">
                            <div class="modal-header bg-primary text-white">
                                <h5 class="modal-title"><i class="fas fa-edit"></i> Sửa Thông Tin: ${u.username}</h5>
                                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                            </div>
                            <div class="modal-body">
                                <div class="mb-3">
                                    <label class="form-label">Họ và Tên</label>
                                    <input type="text" name="fullName" class="form-control" value="${u.fullName}" required>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Email</label>
                                    <input type="email" name="email" class="form-control" value="${u.email}">
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Vai Trò</label>
                                    <select name="role" class="form-select" required>
                                        <option value="student" ${u.role == 'student' ? 'selected' : ''}>Học sinh (student)</option>
                                        <option value="teacher" ${u.role == 'teacher' ? 'selected' : ''}>Giáo viên (teacher)</option>
                                        <option value="parent" ${u.role == 'parent' ? 'selected' : ''}>Phụ huynh (parent)</option>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Chọn Lớp Học</label>
                                    <select name="classId" class="form-select">
                                        <option value="">-- Không tham gia lớp --</option>
                                        <c:forEach var="c" items="${classes}">
                                            <option value="${c.classId}" ${u.classId == c.classId ? 'selected' : ''}>${c.className}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                                <button type="submit" class="btn btn-primary">Lưu Thay Đổi</button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Edit Password Modal -->
            <div class="modal fade" id="editPasswordModal${u.userId}" tabindex="-1" aria-hidden="true">
                <div class="modal-dialog">
                    <form action="admin" method="post">
                        <div class="modal-content">
                            <div class="modal-header bg-dark text-white">
                                <h5 class="modal-title">Đổi mật khẩu cho: ${u.username}</h5>
                                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                            </div>
                            <div class="modal-body">
                                <input type="hidden" name="action" value="reset_password">
                                <input type="hidden" name="targetUserId" value="${u.userId}">
                                <div class="mb-3">
                                    <label class="form-label">Mật khẩu mới</label>
                                    <input type="password" name="newPassword" class="form-control" required minlength="3">
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                                <button type="submit" class="btn btn-primary">Lưu thay đổi</button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </c:if>
    </c:forEach>

    <!-- Create User Modal -->
    <div class="modal fade" id="createUserModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <form action="admin" method="post">
                <input type="hidden" name="action" value="create_user">
                <!-- targetUserId requirement override since we don't have it for new user -->
                <input type="hidden" name="targetUserId" value="0">
                <div class="modal-content">
                    <div class="modal-header bg-success text-white">
                        <h5 class="modal-title"><i class="fas fa-user-plus"></i> Tạo Tài Khoản Mới</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label">Tên Đăng Nhập</label>
                            <input type="text" name="username" class="form-control" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Mật Khẩu</label>
                            <input type="password" name="password" class="form-control" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Họ và Tên</label>
                            <input type="text" name="fullName" class="form-control" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Email</label>
                            <input type="email" name="email" class="form-control">
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Vai Trò</label>
                            <select name="role" class="form-select" required>
                                <option value="student">Học sinh (student)</option>
                                <option value="teacher">Giáo viên (teacher)</option>
                                <option value="admin">Quản trị viên (admin)</option>
                                <option value="parent">Phụ huynh (parent)</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Chọn Lớp Học (Chỉ dành cho học sinh/giáo viên)</label>
                            <select name="classId" class="form-select">
                                <option value="">-- Không tham gia lớp --</option>
                                <c:forEach var="c" items="${classes}">
                                    <option value="${c.classId}">${c.className}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-success">Tạo Tài Khoản</button>
                    </div>
                </div>
            </form>
        </div>
    </div>
    <!-- Create Class Modal -->
    <div class="modal fade" id="createClassModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <form action="admin" method="post">
                <input type="hidden" name="action" value="create_class">
                <div class="modal-content">
                    <div class="modal-header bg-primary text-white">
                        <h5 class="modal-title"><i class="fas fa-plus-circle"></i> Tạo Lớp Học Mới</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label">Tên Lớp</label>
                            <input type="text" name="className" class="form-control" required placeholder="VD: Lớp 10A1">
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Chọn Giáo Viên Chủ Nhiệm</label>
                            <select name="teacherId" class="form-select" required>
                                <option value="" disabled selected>-- Chọn Giáo Viên --</option>
                                <c:forEach var="t" items="${users}">
                                    <c:if test="${t.role == 'teacher'}">
                                        <option value="${t.userId}">${t.fullName} (${t.username})</option>
                                    </c:if>
                                </c:forEach>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-primary">Tạo Lớp</button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
