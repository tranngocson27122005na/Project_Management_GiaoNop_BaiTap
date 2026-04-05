package controller;

import dal.AssignmentDAO;
import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import models.Assignment;
import models.User;

@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 50,       // 50MB
    maxRequestSize = 1024 * 1024 * 100    // 100MB
)
public class CreateAssignmentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || !"teacher".equals(user.getRole())) {
            resp.sendRedirect("login");
            return;
        }

        Assignment a = new Assignment();
        a.setTitle(req.getParameter("title"));
        a.setDescription(req.getParameter("description"));
        a.setDueDate(java.sql.Timestamp.valueOf(req.getParameter("due_date") + " 23:59:59"));
        a.setCreatedBy(user.getUserId());
        a.setClassId(Integer.parseInt(req.getParameter("classId")));

        Part filePart = req.getPart("file");
        if (filePart != null && filePart.getSize() > 0) {
            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            String lower = fileName.toLowerCase();
            if (!lower.endsWith(".zip") && !lower.endsWith(".rar")) {
                session.setAttribute("errorMsg", "Hệ thống chỉ chấp nhận file nén định dạng .zip hoặc .rar!");
                resp.sendRedirect("createAssignment.jsp");
                return;
            }
            String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads" + File.separator + "assignments";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdirs();
            
            String uniqueFileName = System.currentTimeMillis() + "_" + fileName;
            filePart.write(uploadPath + File.separator + uniqueFileName);
            a.setFilePath("uploads/assignments/" + uniqueFileName);
        }

        new AssignmentDAO().createAssignment(a);
        resp.sendRedirect("assignments");
    }
}
