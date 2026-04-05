package controller;

import dal.AssignmentDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.User;

@WebServlet(name="RestoreAssignmentServlet", urlPatterns={"/restore-assignment"})
public class RestoreAssignmentServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || (!"teacher".equals(user.getRole()) && !"admin".equals(user.getRole()))) {
            resp.sendRedirect("login");
            return;
        }

        String idStr = req.getParameter("id");
        if (idStr != null) {
            try {
                int id = Integer.parseInt(idStr);
                AssignmentDAO dao = new AssignmentDAO();
                dao.restoreAssignment(id);
            } catch (Exception e) {}
        }
        resp.sendRedirect("trash");
    }
}
