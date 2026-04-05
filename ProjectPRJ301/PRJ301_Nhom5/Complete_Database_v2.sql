CREATE DATABASE QLGNBT;
GO

USE QLGNBT;
GO

-- 1. Users table (Added 'parent' role)
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

-- 2. Parent_Student table mapping (1 parent -> N students)
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

-- 4. Class_Enrollments (If students can join multiple classes, replacing Users.class_id logic)
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
    text_content NVARCHAR(MAX) NULL, -- For text inputs
    submit_date DATETIME DEFAULT GETDATE(),
    status NVARCHAR(50) DEFAULT N'Chưa nộp',
    score DECIMAL(3,1) NULL,
    teacher_feedback NVARCHAR(MAX) NULL, -- Comment / feedback from teacher
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

-- 8. Messages (Liên hệ giáo viên / Phục huynh)
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

-- 9. Activity_Logs (Log hoạt động - Admin)
CREATE TABLE Activity_Logs (
    log_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    action NVARCHAR(200) NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Log_User FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- 10. Notifications (Nhận cảnh báo trễ, điểm thấp...)
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
-- SAMPLE DATA (WITH CLASSES AND ASSIGNMENTS)
-- =================================================================================
INSERT INTO Users(username,password,full_name,email,role,status)
VALUES
('admin','admin','Admin','admin@mizhoang.com','admin','ACTIVE'),
('teacher1','123',N'Giáo viên Hoàng','teacher@mizhoang.com','teacher','ACTIVE'),
('student1','123',N'Huy Hoàng','student1@mizhoang.com','student','ACTIVE'),
('student2','123',N'Nguyễn Văn A','student2@mizhoang.com','student','ACTIVE'),
('parent1','123',N'Phụ Huynh Huy Hoàng','parent1@mizhoang.com','parent','ACTIVE');

-- Link Parent 1 to Student 1
INSERT INTO Parent_Student(parent_id, student_id) VALUES (5, 3); 

-- Classes
INSERT INTO Classes(class_name, teacher_id) VALUES (N'Lớp CEA', 2);
INSERT INTO Classes(class_name, teacher_id) VALUES (N'Lớp PRJ', 2);

-- Enroll Students
INSERT INTO Class_Enrollments(class_id, student_id) VALUES (1, 3);
INSERT INTO Class_Enrollments(class_id, student_id) VALUES (2, 3);
INSERT INTO Class_Enrollments(class_id, student_id) VALUES (2, 4);

-- Assignments
INSERT INTO Assignments(title, description, due_date, created_by, class_id)
VALUES (N'Bài tập lớn CEA', N'Viết essay 1000 từ', '2026-06-01 23:59:00', 2, 1);
INSERT INTO Assignments(title, description, due_date, created_by, class_id)
VALUES (N'Mini Project Web', N'Thiết kế trang web tin tức bằng JSP/Servlet', '2026-07-01 23:59:00', 2, 2);

-- Submit sample data
INSERT INTO Submissions(assignment_id, student_id, text_content, submit_date, status, score, teacher_feedback)
VALUES (1, 3, N'Trong essay này em sẽ trình bày...', GETDATE(), N'Đã chấm', 8.5, N'Bài làm khá tốt nhưng thiếu reference.');
