/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller;

import dal.UserDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.User;

/**
 *
 * @author Admin
 */
public class LoginServlet extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet LoginServlet</title>");  
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet LoginServlet at " + request.getContextPath () + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    } 

   @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");

        UserDAO dao = new UserDAO();
        User user = dao.checkLogin(username, password);

        if (user != null) {
            String status = user.getStatus();
            if ("PENDING".equals(status)) {
                req.setAttribute("error", "Tài khoản của bạn đang chờ duyệt!");
                req.getRequestDispatcher("login.jsp").forward(req, resp);
                return;
            } else if ("REJECTED".equals(status)) {
                req.setAttribute("error", "Tài khoản của bạn đã bị từ chối!");
                req.getRequestDispatcher("login.jsp").forward(req, resp);
                return;
            } else if ("LOCKED".equals(status)) {
                req.setAttribute("error", "Tài khoản của bạn đã bị KHÓA TẠM THỜI. Vui lòng liên hệ Admin!");
                req.getRequestDispatcher("login.jsp").forward(req, resp);
                return;
            } else if ("BANNED".equals(status)) {
                req.setAttribute("error", "Tài khoản của bạn đã bị KHÓA VĨNH VIỄN do vi phạm!");
                req.getRequestDispatcher("login.jsp").forward(req, resp);
                return;
            }

            HttpSession session = req.getSession();
            session.setAttribute("user", user);
            if ("admin".equals(user.getRole())) {
                resp.sendRedirect("admin");
            } else if ("parent".equals(user.getRole())) {
                resp.sendRedirect("messages");
            } else {
                resp.sendRedirect("assignments");
            }
        } else {
            req.setAttribute("error", "Sai tài khoản hoặc mật khẩu!");
            req.getRequestDispatcher("login.jsp").forward(req, resp);
        }
    }

}
