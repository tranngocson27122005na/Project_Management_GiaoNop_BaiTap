package controller;

import dal.SubmissionDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.User;

@WebServlet(name="GradeSubmissionServlet", urlPatterns={"/gradeSubmission"})
public class GradeSubmissionServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || !"teacher".equals(user.getRole())) {
            resp.sendRedirect("login");
            return;
        }
        
        int assignmentId = Integer.parseInt(req.getParameter("assignmentId"));
        int submissionId = Integer.parseInt(req.getParameter("submissionId"));
        int studentId = Integer.parseInt(req.getParameter("studentId"));
        double score = Double.parseDouble(req.getParameter("score"));
        String teacherFeedback = req.getParameter("teacherFeedback");
        
        new dal.SubmissionDAO().gradeStudent(assignmentId, studentId, submissionId, score, teacherFeedback);
        
        resp.sendRedirect("viewSubmissions?assignmentId=" + assignmentId);
    }
}
