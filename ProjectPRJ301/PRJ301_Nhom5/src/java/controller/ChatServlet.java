package controller;

import dal.MessageDAO;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.User;
import models.Message;

@WebServlet(name="ChatServlet", urlPatterns={"/api/chat"})
public class ChatServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            resp.setStatus(401);
            return;
        }

        Integer classId = user.getClassId();
        if ("teacher".equals(user.getRole())) {
            List<models.ClassRoom> myClasses = new dal.ClassDAO().getClassesByTeacher(user.getUserId());
            if (!myClasses.isEmpty()) {
                classId = myClasses.get(0).getClassId();
            }
        }

        if (classId == null || classId == 0) {
            resp.setStatus(401);
            return;
        }

        String lastIdStr = req.getParameter("lastId");
        int lastId = 0;
        try { if(lastIdStr != null) lastId = Integer.parseInt(lastIdStr); } catch(Exception e){}

        List<Message> msgs = new MessageDAO().getMessages(classId, lastId);
        
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        out.print("[");
        SimpleDateFormat sdf = new SimpleDateFormat("HH:mm");
        for (int i=0; i<msgs.size(); i++) {
            Message m = msgs.get(i);
            String text = m.getMessageText().replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
            String sender = m.getSenderName().replace("\\", "\\\\").replace("\"", "\\\"");
            String role = m.getRole();
            boolean isMine = m.getUserId() == user.getUserId();
            
            out.print("{\"id\":" + m.getMessageId() + 
                      ", \"sender\":\"" + sender + 
                      "\", \"role\":\"" + role + 
                      "\", \"text\":\"" + text + 
                      "\", \"time\":\"" + sdf.format(m.getSentAt()) + 
                      "\", \"isMine\":" + isMine + "}");
            if (i < msgs.size() - 1) out.print(",");
        }
        out.print("]");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            resp.setStatus(401);
            return;
        }

        Integer classId = user.getClassId();
        if ("teacher".equals(user.getRole())) {
            List<models.ClassRoom> myClasses = new dal.ClassDAO().getClassesByTeacher(user.getUserId());
            if (!myClasses.isEmpty()) {
                classId = myClasses.get(0).getClassId();
            }
        }

        if (classId == null || classId == 0) {
            resp.setStatus(401);
            return;
        }
        
        String text = req.getParameter("message");
        if (text != null && text.trim().length() > 0) {
            new MessageDAO().sendMessage(classId, user.getUserId(), text.trim());
        }
        resp.setStatus(200);
    }
}
