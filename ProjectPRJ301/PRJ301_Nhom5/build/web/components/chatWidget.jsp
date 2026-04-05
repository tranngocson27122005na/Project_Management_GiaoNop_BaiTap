<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<div id="classChatWidget" style="position:fixed; bottom:20px; right:20px; z-index:9999; font-family: sans-serif;">
    <button id="chatToggleBtn" class="btn btn-primary rounded-circle shadow-lg d-flex align-items-center justify-content-center" style="width: 60px; height: 60px; font-size: 24px;">
        <i class="fas fa-comments"></i>
    </button>
    
    <div id="chatBoxPanel" class="card shadow-lg d-none" style="width: 340px; height: 480px; position:absolute; bottom: 70px; right: 0; display: flex; flex-direction: column;">
        <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center py-2">
            <h6 class="mb-0"><i class="fas fa-users me-2"></i> Trò Chuyện Lớp Học</h6>
            <button class="btn btn-sm btn-primary py-0 px-2 border-0 shadow-none text-white fs-5" id="chatCloseBtn">&times;</button>
        </div>
        <div class="card-body p-2" id="chatMessages" style="flex:1; overflow-y:auto; background:#f5f6f7; display:flex; flex-direction:column; gap:8px;">
            <div class="text-center text-muted small mt-2">Bắt đầu trò chuyện với giáo viên và các bạn bè của bạn...</div>
        </div>
        <div class="card-footer p-2 bg-white">
            <form id="chatForm" class="d-flex m-0">
                <input type="text" id="chatInput" class="form-control form-control-sm me-2" placeholder="Nhập tin nhắn..." autocomplete="off" required>
                <button type="submit" class="btn btn-primary btn-sm"><i class="fas fa-paper-plane"></i></button>
            </form>
        </div>
    </div>
</div>

<style>
.chat-msg { max-width: 85%; padding: 8px 12px; border-radius: 12px; font-size: 0.9rem; line-height: 1.4; word-wrap: break-word; }
.chat-mine { background: #dcf8c6; margin-left: auto; border-bottom-right-radius: 4px; }
.chat-theirs { background: #ffffff; margin-right: auto; border-bottom-left-radius: 4px; box-shadow: 0 1px 2px rgba(0,0,0,0.1); }
.chat-sender { font-size: 0.75rem; font-weight: bold; margin-bottom: 2px; color: #555; }
.chat-time { font-size: 0.7rem; color: #888; text-align: right; margin-top: 4px; display: block; }
.role-badge { font-size: 0.65rem; background: #e9ecef; padding: 1px 4px; border-radius: 4px; margin-left: 4px; color: #333; }
.role-teacher { background: #ffeeba; color: #856404; font-weight: bold; }
</style>

<script>
    let lastChatId = 0;
    let chatInterval = null;

    document.getElementById('chatToggleBtn').addEventListener('click', function() {
        document.getElementById('chatBoxPanel').classList.toggle('d-none');
        if(!document.getElementById('chatBoxPanel').classList.contains('d-none')) {
            document.getElementById('chatInput').focus();
            scrollToBottom();
            if(!chatInterval) {
                fetchMessages();
                chatInterval = setInterval(fetchMessages, 2500);
            }
        } else {
            if(chatInterval) {
                clearInterval(chatInterval);
                chatInterval = null;
            }
        }
    });

    document.getElementById('chatCloseBtn').addEventListener('click', function() {
        document.getElementById('chatBoxPanel').classList.add('d-none');
        if(chatInterval) {
            clearInterval(chatInterval);
            chatInterval = null;
        }
    });

    document.getElementById('chatForm').addEventListener('submit', function(e) {
        e.preventDefault();
        const input = document.getElementById('chatInput');
        const text = input.value.trim();
        if(!text) return;
        
        input.value = '';
        const formData = new URLSearchParams();
        formData.append('message', text);

        fetch('${pageContext.request.contextPath}/api/chat', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: formData
        }).then(() => fetchMessages());
    });

    function fetchMessages() {
        if(document.getElementById('chatBoxPanel').classList.contains('d-none')) return;
        
        fetch('${pageContext.request.contextPath}/api/chat?lastId=' + lastChatId)
        .then(res => {
            if(!res.ok) throw new Error('Unauthorized');
            return res.json();
        })
        .then(data => {
            if(data && data.length > 0) {
                const container = document.getElementById('chatMessages');
                let shouldScroll = (container.scrollTop + container.clientHeight >= container.scrollHeight - 30);
                
                data.forEach(msg => {
                    lastChatId = Math.max(lastChatId, msg.id);
                    const div = document.createElement('div');
                    div.className = 'chat-msg ' + (msg.isMine ? 'chat-mine' : 'chat-theirs');
                    
                    let senderHtml = '';
                    if(!msg.isMine) {
                        let roleHtml = msg.role === 'teacher' ? '<span class="role-badge role-teacher">Giáo viên</span>' : '';
                        senderHtml = '<div class="chat-sender">' + escapeHtml(msg.sender) + roleHtml + '</div>';
                    }

                    div.innerHTML = senderHtml + 
                                  '<div>' + escapeHtml(msg.text).replace(/\\n/g, '<br>') + '</div>' + 
                                  '<span class="chat-time">' + msg.time + '</span>';
                    container.appendChild(div);
                });
                
                if (shouldScroll) {
                    scrollToBottom();
                }
            }
        })
        .catch(err => {
            console.error(err);
        });
    }

    function scrollToBottom(){
        const container = document.getElementById('chatMessages');
        container.scrollTop = container.scrollHeight;
    }

    function escapeHtml(unsafe) {
        return unsafe.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#039;");
    }
</script>
