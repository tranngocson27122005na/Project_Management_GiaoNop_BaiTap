package controller;

import dal.UserDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.User;

public class AdminServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User loggedInUser = (User) session.getAttribute("user");
        if (loggedInUser == null || !"admin".equals(loggedInUser.getRole())) {
            resp.sendRedirect("login");
            return;
        }

        UserDAO userDAO = new UserDAO();
        List<User> users = userDAO.getAllUsers();
        
        List<User> activeUsers = users.stream().filter(u -> "ACTIVE".equals(u.getStatus())).collect(java.util.stream.Collectors.toList());
        List<User> pendingUsers = users.stream().filter(u -> "PENDING".equals(u.getStatus())).collect(java.util.stream.Collectors.toList());
        List<User> lockedTeachers = users.stream().filter(u -> ("LOCKED".equals(u.getStatus()) || "BANNED".equals(u.getStatus())) && "teacher".equals(u.getRole())).collect(java.util.stream.Collectors.toList());
        List<User> lockedStudents = users.stream().filter(u -> ("LOCKED".equals(u.getStatus()) || "BANNED".equals(u.getStatus())) && "student".equals(u.getRole())).collect(java.util.stream.Collectors.toList());
        List<User> parentUsers = users.stream().filter(u -> "parent".equals(u.getRole())).collect(java.util.stream.Collectors.toList());
        List<User> students = users.stream().filter(u -> "student".equals(u.getRole())).collect(java.util.stream.Collectors.toList());
        
        dal.ParentStudentDAO psDAO = new dal.ParentStudentDAO();
        java.util.Map<Integer, List<User>> parentLinkedStudents = new java.util.HashMap<>();
        for (User p : parentUsers) {
            parentLinkedStudents.put(p.getUserId(), psDAO.getStudentsOfParent(p.getUserId()));
        }

        dal.ClassDAO classDAO = new dal.ClassDAO();
        req.setAttribute("classes", classDAO.getAllClasses());

        req.setAttribute("users", users); // keep Original for Edit Modals to loop over!
        req.setAttribute("allStudents", students);
        req.setAttribute("parents", parentUsers);
        req.setAttribute("parentLinkedStudents", parentLinkedStudents);
        req.setAttribute("activeUsers", activeUsers);
        req.setAttribute("pendingUsers", pendingUsers);
        req.setAttribute("lockedTeachers", lockedTeachers);
        req.setAttribute("lockedStudents", lockedStudents);
        
        String errorMsg = (String) session.getAttribute("errorMsg");
        if (errorMsg != null) {
            req.setAttribute("errorMsg", errorMsg);
            session.removeAttribute("errorMsg");
        }
        String successMsg = (String) session.getAttribute("successMsg");
        if (successMsg != null) {
            req.setAttribute("successMsg", successMsg);
            session.removeAttribute("successMsg");
        }

        req.getRequestDispatcher("adminPanel.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User loggedInUser = (User) session.getAttribute("user");
        if (loggedInUser == null || !"admin".equals(loggedInUser.getRole())) {
            resp.sendRedirect("login");
            return;
        }

        String action = req.getParameter("action");
        String targetStr = req.getParameter("targetUserId");
        int targetUserId = (targetStr != null && !targetStr.trim().isEmpty()) ? Integer.parseInt(targetStr) : 0;
        UserDAO userDAO = new UserDAO();

        if ("approve".equals(action)) {
            userDAO.updateUserStatus(targetUserId, "ACTIVE");
            session.setAttribute("successMsg", "Đã duyệt tài khoản thành công!");
        } else if ("reject".equals(action)) {
            userDAO.updateUserStatus(targetUserId, "REJECTED");
            session.setAttribute("successMsg", "Đã từ chối tài khoản thành công!");
        } else if ("lock".equals(action)) {
            userDAO.updateUserStatus(targetUserId, "LOCKED");
            session.setAttribute("successMsg", "Đã khóa tạm thời tài khoản!");
        } else if ("ban".equals(action)) {
            userDAO.updateUserStatus(targetUserId, "BANNED");
            session.setAttribute("successMsg", "Đã khóa vĩnh viễn tài khoản!");
        } else if ("unlock".equals(action)) {
            userDAO.updateUserStatus(targetUserId, "ACTIVE");
            session.setAttribute("successMsg", "Đã mở khóa tài khoản thành công!");
        } else if ("delete".equals(action)) {
            if (userDAO.deleteUser(targetUserId)) {
                session.setAttribute("successMsg", "Đã xóa tài khoản thành công!");
            } else {
                session.setAttribute("errorMsg", "Không thể xóa tài khoản này! Người dùng có thể đang liên kết với dữ liệu bài tập hoặc bài nộp.");
            }
        } else if ("create_user".equals(action)) {
            // ... (keep create user logic)
            String username = req.getParameter("username");
            String password = req.getParameter("password");
            String fullName = req.getParameter("fullName");
            String email = req.getParameter("email");
            String role = req.getParameter("role");
            String classIdStr = req.getParameter("classId");
            Integer classId = (classIdStr != null && !classIdStr.trim().isEmpty()) ? Integer.parseInt(classIdStr) : null;
            
            User newUser = new User(0, username, password, fullName, email, role, "ACTIVE", classId);
            if (userDAO.createActiveUser(newUser)) {
                session.setAttribute("successMsg", "Đã tạo tài khoản mới thành công!");
            } else {
                session.setAttribute("errorMsg", "Không thể tạo tài khoản. Tên đăng nhập có thể đã tồn tại.");
            }
        } else if ("edit_user".equals(action)) {
            String fullName = req.getParameter("fullName");
            String email = req.getParameter("email");
            String role = req.getParameter("role");
            String classIdStr = req.getParameter("classId");
            Integer classId = (classIdStr != null && !classIdStr.trim().isEmpty()) ? Integer.parseInt(classIdStr) : null;
            
            User editUser = new User();
            editUser.setUserId(targetUserId);
            editUser.setFullName(fullName);
            editUser.setEmail(email);
            editUser.setRole(role);
            editUser.setClassId(classId);
            
            if (userDAO.updateUser(editUser)) {
                session.setAttribute("successMsg", "Đã cập nhật thông tin tài khoản thành công!");
            } else {
                session.setAttribute("errorMsg", "Cập nhật thông tin thất bại!");
            }
        } else if ("reset_password".equals(action)) {
            String newPassword = req.getParameter("newPassword");
            userDAO.updatePassword(targetUserId, newPassword);
            session.setAttribute("successMsg", "Đã đặt lại mật khẩu thành công!");
        } else if ("create_class".equals(action)) {
            String className = req.getParameter("className");
            int teacherId = Integer.parseInt(req.getParameter("teacherId"));
            dal.ClassDAO classDAO = new dal.ClassDAO();
            if (classDAO.createClass(className, teacherId)) {
                session.setAttribute("successMsg", "Đã tạo lớp mới thành công!");
            } else {
                session.setAttribute("errorMsg", "Không thể tạo lớp mới!");
            }
        } else if ("link_student".equals(action)) {
            int parentId = Integer.parseInt(req.getParameter("targetParentId"));
            int studentId = Integer.parseInt(req.getParameter("studentId"));
            dal.ParentStudentDAO psDAO = new dal.ParentStudentDAO();
            if (psDAO.linkParentStudent(parentId, studentId)) {
                session.setAttribute("successMsg", "Đã gán học sinh thành công!");
            } else {
                session.setAttribute("errorMsg", "Không thể gán học sinh. Hoặc học sinh này đã được gán.");
            }
        } else if ("unlink_student".equals(action)) {
            int parentId = Integer.parseInt(req.getParameter("targetParentId"));
            int studentId = Integer.parseInt(req.getParameter("studentId"));
            dal.ParentStudentDAO psDAO = new dal.ParentStudentDAO();
            if (psDAO.unlinkParentStudent(parentId, studentId)) {
                session.setAttribute("successMsg", "Đã gỡ liên kết học sinh!");
            } else {
                session.setAttribute("errorMsg", "Lỗi gỡ liên kết.");
            }
        }

        resp.sendRedirect("admin");
    }
}
