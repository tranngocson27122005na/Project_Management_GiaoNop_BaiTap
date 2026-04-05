-- =================================================================================
-- KHỞI TẠO DATABASE
-- =================================================================================
USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'QLGNBT')
BEGIN
    ALTER DATABASE QLGNBT SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE QLGNBT;
END
GO

CREATE DATABASE QLGNBT;
GO

USE QLGNBT;
GO

-- =================================================================================
-- TẠO CÁC BẢNG (TABLES)
-- =================================================================================

-- 1. Users table
CREATE TABLE Users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name NVARCHAR(100),
    email VARCHAR(100) UNIQUE,
    role VARCHAR(20) NOT NULL CHECK (role IN ('student','teacher','admin','parent')),
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING', -- PENDING / ACTIVE / LOCKED / BANNED
    class_id INT NULL
);

-- 2. Parent_Student table (1 parent -> N students)
CREATE TABLE Parent_Student (
    parent_id INT NOT NULL,
    student_id INT NOT NULL,
    PRIMARY KEY (parent_id, student_id),
    CONSTRAINT FK_PS_Parent FOREIGN KEY (parent_id) REFERENCES Users(user_id),
    CONSTRAINT FK_PS_Student FOREIGN KEY (student_id) REFERENCES Users(user_id)
);

-- 3. Classes table
CREATE TABLE Classes (
    class_id INT IDENTITY(1,1) PRIMARY KEY,
    class_name NVARCHAR(100) NOT NULL,
    teacher_id INT NOT NULL,
    CONSTRAINT FK_Classes_Teacher FOREIGN KEY (teacher_id) REFERENCES Users(user_id)
);

-- 4. Class_Enrollments (Nhiều sinh viên - Nhiều lớp học)
CREATE TABLE Class_Enrollments (
    class_id INT NOT NULL,
    student_id INT NOT NULL,
    enrolled_date DATETIME DEFAULT GETDATE(),
    PRIMARY KEY (class_id, student_id),
    CONSTRAINT FK_CE_Class FOREIGN KEY (class_id) REFERENCES Classes(class_id),
    CONSTRAINT FK_CE_Student FOREIGN KEY (student_id) REFERENCES Users(user_id)
);

-- 5. Assignments
CREATE TABLE Assignments (
    assignment_id INT IDENTITY(1,1) PRIMARY KEY,
    title NVARCHAR(200) NOT NULL,
    description NVARCHAR(MAX),
    due_date DATETIME,
    created_by INT NOT NULL,
    class_id INT NULL,
    assignment_file NVARCHAR(500) NULL,
    created_date DATETIME DEFAULT GETDATE(),
    is_deleted BIT DEFAULT 0,
    CONSTRAINT FK_Assignments_Teacher FOREIGN KEY (created_by) REFERENCES Users(user_id),
    CONSTRAINT FK_Assignments_Class FOREIGN KEY (class_id) REFERENCES Classes(class_id)
);

-- 6. Submissions
CREATE TABLE Submissions (
    submission_id INT IDENTITY(1,1) PRIMARY KEY,
    assignment_id INT NOT NULL,
    student_id INT NOT NULL,
    file_path NVARCHAR(500) NULL,
    text_content NVARCHAR(MAX) NULL,
    submit_date DATETIME DEFAULT GETDATE(),
    status NVARCHAR(50) DEFAULT N'Chưa nộp',
    score DECIMAL(3,1) NULL,
    teacher_feedback NVARCHAR(MAX) NULL,
    extended_deadline DATETIME NULL,
    CONSTRAINT FK_Submissions_Assignment FOREIGN KEY (assignment_id) REFERENCES Assignments(assignment_id),
    CONSTRAINT FK_Submissions_Student FOREIGN KEY (student_id) REFERENCES Users(user_id)
);

-- 7. Assignment_Comments (Hỏi bài / Trả lời câu hỏi)
CREATE TABLE Assignment_Comments (
    comment_id INT IDENTITY(1,1) PRIMARY KEY,
    assignment_id INT NOT NULL,
    user_id INT NOT NULL,
    content NVARCHAR(MAX) NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_AC_Assignment FOREIGN KEY (assignment_id) REFERENCES Assignments(assignment_id),
    CONSTRAINT FK_AC_User FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- 8. Messages (Liên hệ giáo viên / Phụ huynh)
CREATE TABLE Messages (
    message_id INT IDENTITY(1,1) PRIMARY KEY,
    sender_id INT NOT NULL,
    receiver_id INT NOT NULL,
    content NVARCHAR(MAX) NOT NULL,
    is_read BIT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Msg_Sender FOREIGN KEY (sender_id) REFERENCES Users(user_id),
    CONSTRAINT FK_Msg_Receiver FOREIGN KEY (receiver_id) REFERENCES Users(user_id)
);

-- 9. Activity_Logs (Log hoạt động)
CREATE TABLE Activity_Logs (
    log_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    action NVARCHAR(200) NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Log_User FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- 10. Notifications (Cảnh báo trễ, điểm thấp...)
CREATE TABLE Notifications (
    notif_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    message NVARCHAR(500) NOT NULL,
    action_url NVARCHAR(200) NULL,
    is_read BIT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Notif_User FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- =================================================================================
-- SAMPLE DATA (DỮ LIỆU MẪU)
-- =================================================================================

-- 1. USERS (Tổng cộng 13 users)
INSERT INTO Users(username, password, full_name, email, role, status) VALUES
-- Admin (ID: 1)
('admin', 'admin', 'Admin System', 'admin@mizhoang.com', 'admin', 'ACTIVE'),

-- Teachers (ID: 2, 3, 4)
('teacher1', '123', N'Giáo viên Hoàng', 'teacher1@mizhoang.com', 'teacher', 'ACTIVE'),
('teacher2', '123', N'Giáo viên Lan', 'teacher2@mizhoang.com', 'teacher', 'ACTIVE'),
('teacher3', '123', N'Giáo viên Nam', 'teacher3@mizhoang.com', 'teacher', 'ACTIVE'),

-- Students (ID: 5, 6, 7, 8, 9, 10)
('student1', '123', N'Huy Hoàng', 'student1@mizhoang.com', 'student', 'ACTIVE'),
('student2', '123', N'Nguyễn Văn A', 'student2@mizhoang.com', 'student', 'ACTIVE'),
('student3', '123', N'Phạm Văn D', 'student3@mizhoang.com', 'student', 'ACTIVE'),
('student4', '123', N'Hoàng Văn E', 'student4@mizhoang.com', 'student', 'ACTIVE'),
('student5', '123', N'Nguyễn Thị F', 'student5@mizhoang.com', 'student', 'ACTIVE'),
('student6', '123', N'Trần Văn G', 'student6@mizhoang.com', 'student', 'ACTIVE'),

-- Parents (ID: 11, 12, 13)
('parent1', '123', N'Phụ Huynh Huy Hoàng', 'parent1@mizhoang.com', 'parent', 'ACTIVE'),
('parent2', '123', N'Phụ huynh D & E', 'parent2@mizhoang.com', 'parent', 'ACTIVE'),
('parent3', '123', N'Phụ huynh F & G', 'parent3@mizhoang.com', 'parent', 'ACTIVE');

-- 2. PARENT - STUDENT MAPPING
-- Ghép nối Phụ huynh với Học sinh dựa theo ID ở trên
INSERT INTO Parent_Student(parent_id, student_id) VALUES 
(11, 5),  -- Parent 1 -> Student 1
(12, 7),  -- Parent 2 -> Student 3 (D)
(12, 8),  -- Parent 2 -> Student 4 (E)
(13, 9),  -- Parent 3 -> Student 5 (F)
(13, 10); -- Parent 3 -> Student 6 (G)

-- 3. CLASSES
INSERT INTO Classes(class_name, teacher_id) VALUES 
(N'Lớp CEA', 2),           -- Class ID 1 (Teacher Hoàng)
(N'Lớp PRJ', 2),           -- Class ID 2 (Teacher Hoàng)
(N'Lớp OOP Java', 3),      -- Class ID 3 (Teacher Lan)
(N'Lớp Web nâng cao', 4);  -- Class ID 4 (Teacher Nam)

-- 4. CLASS ENROLLMENTS
INSERT INTO Class_Enrollments(class_id, student_id) VALUES 
(1, 5), (2, 5), (2, 6),           -- Học sinh 1, 2 học lớp của thầy Hoàng
(3, 7), (3, 8), (3, 9),           -- Học sinh 3, 4, 5 học lớp OOP Java
(4, 8), (4, 9), (4, 10);          -- Học sinh 4, 5, 6 học lớp Web nâng cao

-- 5. ASSIGNMENTS
INSERT INTO Assignments(title, description, due_date, created_by, class_id) VALUES 
(N'Bài tập lớn CEA', N'Viết essay 1000 từ', '2026-06-01', 2, 1),                 -- Assignment 1
(N'Mini Project Web', N'Thiết kế web tin tức', '2026-07-01', 2, 2),             -- Assignment 2
(N'Bài tập OOP 1', N'Tạo class quản lý sinh viên', '2026-06-05', 3, 3),         -- Assignment 3
(N'Bài tập OOP 2', N'Áp dụng kế thừa + đa hình', '2026-06-12', 3, 3),           -- Assignment 4
(N'Bài tập Servlet', N'Viết CRUD bằng Servlet', '2026-06-20', 4, 4),            -- Assignment 5
(N'Bài tập JSP', N'Tạo form đăng ký + validation', '2026-06-25', 4, 4),         -- Assignment 6
(N'Project Web MVC', N'Làm website theo mô hình MVC', '2026-07-15', 4, 4);      -- Assignment 7

-- 6. SUBMISSIONS
INSERT INTO Submissions(assignment_id, student_id, text_content, status, score, teacher_feedback) VALUES 
(1, 5, N'Trong essay này em sẽ trình bày...', N'Đã chấm', 8.5, N'Khá tốt nhưng thiếu reference.'),
(3, 7, N'Em đã làm xong bài OOP 1', N'Đã chấm', 8.0, N'Tốt'),
(3, 8, N'Bài em đầy đủ chức năng', N'Đã chấm', 9.2, N'Rất tốt'),
(4, 7, N'Bài OOP 2 của em', N'Đã chấm', 7.5, N'Cần cải thiện cấu trúc'),
(5, 8, N'CRUD servlet hoàn chỉnh', N'Đã chấm', 8.8, N'Ổn định'),
(6, 9, N'Form JSP đã validate', N'Đã chấm', 9.0, N'Giao diện đẹp'),
(7, 10, N'Project MVC đang làm', N'Chưa chấm', NULL, NULL);

-- 7. ASSIGNMENT COMMENTS
INSERT INTO Assignment_Comments(assignment_id, user_id, content) VALUES 
(3, 7, N'Cô ơi em chưa hiểu đa hình ở bài này'),
(3, 7, N'Cô giải thích thêm giúp em ạ'),
(4, 8, N'Có cần dùng interface không ạ?'),
(5, 8, N'Em bị lỗi servlet mapping ở file web.xml'),
(6, 9, N'Validation dùng JS hay Java thuần ạ?');

-- 8. MESSAGES
INSERT INTO Messages(sender_id, receiver_id, content) VALUES 
(3, 7, N'Nhắc nhở: Em nhớ nộp bài OOP 2 đúng hạn nhé.'),     -- Teacher Lan gửi Student D
(7, 3, N'Vâng thưa cô, em sắp nộp rồi ạ.'),                 -- Student D phản hồi
(12, 3, N'Cô cho tôi hỏi tình hình học của cháu dạo này?'), -- Parent 2 hỏi Teacher Lan
(3, 12, N'Cháu D dạo này học tốt, cần chăm làm bài tập hơn.'); -- Teacher Lan trả lời

-- 9. NOTIFICATIONS
INSERT INTO Notifications(user_id, message) VALUES 
(7, N'Bạn có bài tập mới từ lớp OOP Java'),
(8, N'Bài tập Servlet của bạn đã được chấm điểm'),
(12, N'Bạn có tin nhắn mới từ Giáo viên Lan'),
(10, N'Cảnh báo: Sắp đến hạn deadline Project Web MVC');

-- 10. ACTIVITY LOGS
INSERT INTO Activity_Logs(user_id, action) VALUES 
(3, N'Tạo lớp học OOP Java'),
(4, N'Giao bài tập Project Web MVC'),
(7, N'Nộp bài tập OOP 1'),
(3, N'Chấm bài tập OOP 1 của học viên Phạm Văn D');