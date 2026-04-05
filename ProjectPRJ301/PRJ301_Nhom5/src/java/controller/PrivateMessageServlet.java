package controller;

import dal.PrivateMessageDAO;
import dal.UserDAO;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.PrivateMessage;
import models.User;

@WebServlet(name="PrivateMessageServlet", urlPatterns={"/messages"})
public class PrivateMessageServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || (!"parent".equals(user.getRole()) && !"teacher".equals(user.getRole()))) {
            resp.sendRedirect("login");
            return;
        }

        UserDAO userDAO = new UserDAO();
        List<User> contacts = userDAO.getMessageContactsForUser(user);
        req.setAttribute("contacts", contacts);

        String partnerIdStr = req.getParameter("partnerId");
        if (partnerIdStr != null && !partnerIdStr.isEmpty()) {
            int partnerId = Integer.parseInt(partnerIdStr);
            User partner = userDAO.getUserById(partnerId);
            if (partner != null) {
                req.setAttribute("partner", partner);
                PrivateMessageDAO pmd = new PrivateMessageDAO();
                List<PrivateMessage> conversation = pmd.getConversation(user.getUserId(), partnerId);
                req.setAttribute("conversation", conversation);
            }
        }

        req.getRequestDispatcher("messages.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || (!"parent".equals(user.getRole()) && !"teacher".equals(user.getRole()))) {
            resp.sendRedirect("login");
            return;
        }
        
        int partnerId = Integer.parseInt(req.getParameter("partnerId"));
        String content = req.getParameter("content");
        
        if (content != null && !content.trim().isEmpty()) {
            new PrivateMessageDAO().sendMessage(user.getUserId(), partnerId, content.trim());
        }
        
        resp.sendRedirect("messages?partnerId=" + partnerId);
    }
}
