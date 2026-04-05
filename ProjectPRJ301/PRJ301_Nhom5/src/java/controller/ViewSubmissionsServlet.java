package controller;

import dal.SubmissionDAO;
import dal.AssignmentDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.User;
import models.Submission;
import models.Assignment;

@WebServlet(name="ViewSubmissionsServlet", urlPatterns={"/viewSubmissions"})
public class ViewSubmissionsServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || (!"teacher".equals(user.getRole()) && !"admin".equals(user.getRole()))) {
            resp.sendRedirect("login");
            return;
        }
        
        String idStr = req.getParameter("assignmentId");
        if (idStr == null) {
            resp.sendRedirect("assignments");
            return;
        }
        
        int assignmentId = Integer.parseInt(idStr);
        Assignment a = new AssignmentDAO().getAssignmentById(assignmentId);
        
        if (a == null) {
            resp.sendRedirect("assignments");
            return;
        }
        
        req.setAttribute("assignment", a);
        List<Submission> submissions = new SubmissionDAO().getSubmissionsByAssignment(assignmentId);
        req.setAttribute("submissions", submissions);
        req.getRequestDispatcher("viewSubmissions.jsp").forward(req, resp);
    }
}
