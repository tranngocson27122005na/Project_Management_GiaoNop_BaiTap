/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dal.AssignmentDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import models.Assignment;
import models.User;

public class AssignmentListServlet extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet AssignmentListServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet AssignmentListServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            resp.sendRedirect("login");
            return;
        }

        AssignmentDAO dao = new AssignmentDAO();
        List<Assignment> list;
        String keyword = req.getParameter("search");

        if ("admin".equals(user.getRole())) {
            if (keyword != null && !keyword.trim().isEmpty()) {
                list = dao.searchAllAssignments(keyword.trim());
            } else {
                list = dao.getAllAssignments();
            }
        } else {
            int classId = user.getClassId() != null ? user.getClassId() : 0;
            if (keyword != null && !keyword.trim().isEmpty()) {
                if ("student".equals(user.getRole())) {
                    list = dao.searchAssignmentsForStudent(keyword.trim(), classId);
                    for (Assignment a : list) {
                        a.setStatus("Chưa nộp");
                    }
                } else if ("parent".equals(user.getRole())) {
                    list = dao.searchAssignmentsForParent(keyword.trim(), user.getUserId());
                } else {
                    list = dao.searchAssignmentsForTeacher(keyword.trim(), user.getUserId());
                }
            } else {
                if ("student".equals(user.getRole())) {
                    list = dao.getAssignmentsForStudent(user.getUserId(), classId);
                } else if ("parent".equals(user.getRole())) {
                    list = dao.getAssignmentsForParent(user.getUserId());
                } else {
                    list = dao.getAssignmentsForTeacher(user.getUserId());
                }
            }
        }

        req.setAttribute("list", list);
        req.setAttribute("user", user);
        req.getRequestDispatcher("listAssignments.jsp").forward(req, resp);
    }

}
