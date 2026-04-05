package controller;

import dal.AssignmentDAO;
import dal.CommentDAO;
import dal.SubmissionDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.Assignment;
import models.Comment;
import models.Submission;
import models.User;

@WebServlet(name="AssignmentDetailServlet", urlPatterns={"/assignmentDetail"})
public class AssignmentDetailServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            resp.sendRedirect("login");
            return;
        }

        String idStr = req.getParameter("id");
        if (idStr == null) {
            resp.sendRedirect("assignments");
            return;
        }

        int id = Integer.parseInt(idStr);
        AssignmentDAO ad = new AssignmentDAO();
        Assignment a = ad.getAssignmentById(id);
        
        if (a == null) {
            resp.sendRedirect("assignments");
            return;
        }

        CommentDAO cd = new CommentDAO();
        List<Comment> comments = cd.getCommentsByAssignment(id);
        
        int targetStudentId = 0;
        if ("student".equals(user.getRole())) {
             targetStudentId = user.getUserId();
        } else if ("parent".equals(user.getRole())) {
             String sIdStr = req.getParameter("studentId");
             if (sIdStr != null) {
                 try { targetStudentId = Integer.parseInt(sIdStr); } catch (Exception e) {}
             }
        }

        if (targetStudentId > 0) {
            SubmissionDAO sd = new SubmissionDAO();
            Submission sub = sd.getSubmission(id, targetStudentId);
            req.setAttribute("submission", sub);
        }

        req.setAttribute("assignment", a);
        req.setAttribute("comments", comments);
        req.getRequestDispatcher("assignmentDetail.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            resp.sendRedirect("login");
            return;
        }
        
        String action = req.getParameter("action");
        int assignmentId = Integer.parseInt(req.getParameter("assignmentId"));
        
        if ("comment".equals(action)) {
            String content = req.getParameter("content");
            if (content != null && !content.trim().isEmpty()) {
                CommentDAO cd = new CommentDAO();
                cd.addComment(assignmentId, user.getUserId(), content);
            }
        }
        
        resp.sendRedirect("assignmentDetail?id=" + assignmentId);
    }
}
