<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>Tin nhắn trực tiếp - QLGNBT</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        .chat-container {
            height: calc(100vh - 150px);
            background: #fff;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        .contact-list {
            border-right: 1px solid #ddd;
            height: 100%;
            overflow-y: auto;
            background: #f8f9fa;
        }
        .contact-item {
            padding: 15px;
            border-bottom: 1px solid #ddd;
            cursor: pointer;
            transition: background 0.2s;
            display: block;
            text-decoration: none;
            color: #333;
        }
        .contact-item:hover, .contact-item.active {
            background: #e9ecef;
        }
        .chat-box {
            height: 100%;
            display: flex;
            flex-direction: column;
        }
        .msg-history {
            flex-grow: 1;
            padding: 20px;
            overflow-y: auto;
            background: #fafafa;
        }
        .message {
            margin-bottom: 15px;
            max-width: 75%;
        }
        .message.mine {
            margin-left: auto;
        }
        .msg-bubble {
            padding: 10px 15px;
            border-radius: 15px;
            display: inline-block;
        }
        .message.mine .msg-bubble {
            background: #0d6efd;
            color: #fff;
            border-bottom-right-radius: 0;
        }
        .message.their .msg-bubble {
            background: #e9ecef;
            color: #000;
            border-bottom-left-radius: 0;
        }
        .msg-time {
            font-size: 0.75em;
            color: #6c757d;
            margin-top: 5px;
        }
        .message.mine .msg-time {
            text-align: right;
            color: #adb5bd;
        }
        .msg-input {
            border-top: 1px solid #ddd;
            padding: 15px;
            background: #fff;
        }
    </style>
</head>
<body class="bg-light">
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-info mb-4">
        <div class="container">
            <a class="navbar-brand" href="assignments"><i class="fas fa-comments"></i> Kênh Liên Hệ</a>
            <div class="d-flex">
                <span class="navbar-text me-3 text-white">Xin chào, ${user.fullName} (${user.role})</span>
                <a href="${user.role == 'admin' ? 'admin' : 'assignments'}" class="btn btn-outline-light btn-sm me-2">Trang chủ</a>
                <a href="logout" class="btn btn-outline-light btn-sm">Đăng xuất</a>
            </div>
        </div>
    </nav>
    
    <div class="container">
        <div class="row chat-container">
            <!-- Left: Contact List -->
            <div class="col-md-4 contact-list p-0">
                <div class="p-3 bg-secondary text-white fw-bold">
                    <i class="fas fa-address-book"></i> Danh bạ liên hệ
                </div>
                <c:if test="${empty contacts}">
                    <div class="p-3 text-muted text-center">Chưa có liên hệ nào.</div>
                </c:if>
                <c:forEach var="c" items="${contacts}">
                    <a href="messages?partnerId=${c.userId}" class="contact-item ${partner != null && partner.userId == c.userId ? 'active' : ''}">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <strong>${c.fullName}</strong><br>
                                <small class="text-muted"><i class="fas fa-user-tag"></i> ${c.role == 'teacher' ? 'Giáo viên' : 'Phụ huynh'}</small>
                            </div>
                            <i class="fas fa-chevron-right text-muted"></i>
                        </div>
                    </a>
                </c:forEach>
            </div>
            
            <!-- Right: Chat Window -->
            <div class="col-md-8 p-0">
                <c:if test="${partner == null}">
                    <div class="d-flex align-items-center justify-content-center h-100 text-muted">
                        <div class="text-center">
                            <i class="fas fa-comments fa-3x mb-3 text-secondary"></i>
                            <br>Chọn một liên hệ bên trái để bắt đầu trò chuyện
                        </div>
                    </div>
                </c:if>
                <c:if test="${partner != null}">
                    <div class="chat-box">
                        <div class="p-3 bg-white border-bottom fw-bold text-primary">
                            <i class="fas fa-user-circle"></i> Trò chuyện với: ${partner.fullName}
                        </div>
                        <div class="msg-history" id="msgHistory">
                            <c:if test="${empty conversation}">
                                <div class="text-center text-muted my-3">Chưa có tin nhắn nào. Hãy gửi lời chào!</div>
                            </c:if>
                            <c:forEach var="m" items="${conversation}">
                                <c:choose>
                                    <c:when test="${m.senderId == user.userId}">
                                        <div class="message mine">
                                            <div class="msg-bubble">${m.content}</div>
                                            <div class="msg-time"><fmt:formatDate value="${m.createdAt}" pattern="dd/MM/yyyy HH:mm"/></div>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="message their">
                                            <div class="msg-bubble">${m.content}</div>
                                            <div class="msg-time"><fmt:formatDate value="${m.createdAt}" pattern="dd/MM/yyyy HH:mm"/></div>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>
                        </div>
                        <div class="msg-input">
                            <form action="messages" method="post" class="d-flex">
                                <input type="hidden" name="partnerId" value="${partner.userId}">
                                <input type="text" name="content" class="form-control me-2" placeholder="Nhập tin nhắn..." required autofocus>
                                <button type="submit" class="btn btn-primary"><i class="fas fa-paper-plane"></i> Gửi</button>
                            </form>
                        </div>
                    </div>
                </c:if>
            </div>
        </div>
    </div>
    
    <script>
        // Scroll to bottom of chat
        var historyDiv = document.getElementById('msgHistory');
        if (historyDiv) {
            historyDiv.scrollTop = historyDiv.scrollHeight;
        }
    </script>
</body>
</html>
