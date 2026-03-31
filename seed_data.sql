-- ============================================================
-- University Course Management System
-- Author: Moh Khan
-- File: data/seed_data.sql
-- Description: Seeds the database with departments, instructors,
--              courses, 10,000+ students, enrollments, and schedules.
-- ============================================================

USE university_db;

-- ── Departments ───────────────────────────────────────────────
INSERT INTO Departments (name, building, budget) VALUES
('Computer Science',        'Engineering Hall',   1500000.00),
('Mathematics',             'Science Building',    900000.00),
('Electrical Engineering',  'Tech Center',        1200000.00),
('Business Administration', 'Business Hall',      1100000.00),
('Biology',                 'Life Sciences',       800000.00),
('Physics',                 'Science Building',    750000.00),
('English',                 'Humanities Hall',     500000.00),
('Psychology',              'Social Sciences',     600000.00);

-- ── Instructors (200+) ────────────────────────────────────────
INSERT INTO Instructors (first_name, last_name, email, dept_id, hire_date, salary) VALUES
('James',    'Anderson',  'j.anderson@university.edu',  1, '2010-08-15', 95000.00),
('Sarah',    'Mitchell',  's.mitchell@university.edu',  1, '2012-01-20', 92000.00),
('Robert',   'Chen',      'r.chen@university.edu',      1, '2015-09-01', 88000.00),
('Emily',    'Johnson',   'e.johnson@university.edu',   1, '2018-08-20', 82000.00),
('Michael',  'Davis',     'm.davis@university.edu',     2, '2009-08-10', 91000.00),
('Linda',    'Martinez',  'l.martinez@university.edu',  2, '2013-01-15', 87000.00),
('David',    'Wilson',    'd.wilson@university.edu',    3, '2011-08-20', 96000.00),
('Karen',    'Thompson',  'k.thompson@university.edu',  3, '2016-09-05', 89000.00),
('Steven',   'Garcia',    's.garcia@university.edu',    4, '2014-01-10', 93000.00),
('Nancy',    'White',     'n.white@university.edu',     4, '2017-08-25', 85000.00),
('Paul',     'Harris',    'p.harris@university.edu',    5, '2010-09-01', 84000.00),
('Sandra',   'Clark',     's.clark@university.edu',     5, '2015-01-20', 81000.00),
('Mark',     'Lewis',     'm.lewis@university.edu',     6, '2012-08-15', 90000.00),
('Betty',    'Robinson',  'b.robinson@university.edu',  6, '2019-09-01', 80000.00),
('Donald',   'Walker',    'd.walker@university.edu',    7, '2008-01-10', 78000.00),
('Helen',    'Hall',      'h.hall@university.edu',      7, '2016-08-20', 75000.00),
('Richard',  'Allen',     'r.allen@university.edu',     8, '2013-09-05', 82000.00),
('Carol',    'Young',     'c.young@university.edu',     8, '2018-01-15', 79000.00),
('Joseph',   'King',      'j.king@university.edu',      1, '2020-08-20', 80000.00),
('Ruth',     'Wright',    'r.wright@university.edu',    2, '2021-01-10', 77000.00);

-- Generate remaining 180+ instructors via procedure
DELIMITER $$
CREATE PROCEDURE seed_instructors()
BEGIN
    DECLARE i INT DEFAULT 21;
    DECLARE dept INT;
    WHILE i <= 210 DO
        SET dept = (i MOD 8) + 1;
        INSERT IGNORE INTO Instructors (first_name, last_name, email, dept_id, hire_date, salary)
        VALUES (
            CONCAT('Instructor', i),
            CONCAT('Last', i),
            CONCAT('instructor', i, '@university.edu'),
            dept,
            DATE_ADD('2005-01-01', INTERVAL (i * 47) DAY),
            75000 + (i MOD 25) * 1000
        );
        SET i = i + 1;
    END WHILE;
END$$
DELIMITER ;
CALL seed_instructors();
DROP PROCEDURE seed_instructors;

-- ── Courses (500+) ────────────────────────────────────────────
INSERT INTO Courses (course_code, title, credits, dept_id, instructor_id, prereq_id, max_enrollment) VALUES
('CS101',  'Intro to Computer Science',       3, 1, 1,  NULL, 35),
('CS201',  'Data Structures',                 3, 1, 2,  1,    30),
('CS301',  'Algorithms',                      3, 1, 3,  2,    30),
('CS401',  'Operating Systems',               3, 1, 4,  3,    25),
('CS450',  'Database Management Systems',     3, 1, 1,  2,    25),
('CS460',  'Networks & Data Communications',  3, 1, 2,  2,    25),
('CS470',  'Software Engineering',            3, 1, 3,  3,    30),
('CS480',  'Machine Learning',                3, 1, 4,  4,    20),
('MATH101','Calculus I',                      5, 2, 5,  NULL, 40),
('MATH201','Calculus II',                     5, 2, 6,  9,    35),
('MATH301','Linear Algebra',                  3, 2, 5,  9,    30),
('MATH401','Discrete Mathematics',            3, 2, 6,  9,    30),
('EE101',  'Circuits I',                      3, 3, 7,  NULL, 30),
('EE201',  'Circuits II',                     3, 3, 8,  13,   25),
('EE301',  'Digital Systems',                 3, 3, 7,  13,   25),
('BUS101', 'Principles of Management',        3, 4, 9,  NULL, 40),
('BUS201', 'Financial Accounting',            3, 4, 10, NULL, 35),
('BIO101', 'General Biology I',               4, 5, 11, NULL, 40),
('BIO201', 'Cell Biology',                    4, 5, 12, 18,   30),
('PHYS101','Physics I',                       3, 6, 13, NULL, 35);

-- Generate remaining 480+ courses
DELIMITER $$
CREATE PROCEDURE seed_courses()
BEGIN
    DECLARE i INT DEFAULT 21;
    DECLARE dept INT;
    DECLARE instr INT;
    WHILE i <= 510 DO
        SET dept  = (i MOD 8) + 1;
        SET instr = (i MOD 20) + 1;
        INSERT IGNORE INTO Courses (course_code, title, credits, dept_id, instructor_id, max_enrollment)
        VALUES (
            CONCAT('COURSE', i),
            CONCAT('Course Title ', i),
            (i MOD 4) + 1,
            dept,
            instr,
            20 + (i MOD 20)
        );
        SET i = i + 1;
    END WHILE;
END$$
DELIMITER ;
CALL seed_courses();
DROP PROCEDURE seed_courses;

-- ── Students (10,000+) ────────────────────────────────────────
DELIMITER $$
CREATE PROCEDURE seed_students()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE dept INT;
    WHILE i <= 10200 DO
        SET dept = (i MOD 8) + 1;
        INSERT IGNORE INTO Students (first_name, last_name, email, dept_id, enrollment_year, gpa)
        VALUES (
            CONCAT('Student', i),
            CONCAT('Lastname', i),
            CONCAT('student', i, '@university.edu'),
            dept,
            2018 + (i MOD 7),
            ROUND(2.0 + (RAND() * 2.0), 2)
        );
        SET i = i + 1;
    END WHILE;
END$$
DELIMITER ;
CALL seed_students();
DROP PROCEDURE seed_students;

-- ── Enrollments ───────────────────────────────────────────────
DELIMITER $$
CREATE PROCEDURE seed_enrollments()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE sid INT;
    DECLARE cid INT;
    DECLARE sem VARCHAR(20);
    DECLARE grades VARCHAR(20);
    WHILE i <= 40000 DO
        SET sid = (i MOD 10200) + 1;
        SET cid = (i MOD 20)    + 1;
        SET sem = CONCAT(ELT((i MOD 3)+1,'Fall','Spring','Summer'), ' ', 2020 + (i MOD 5));
        SET grades = ELT((i MOD 5)+1,'A','B','C','D','F');
        INSERT IGNORE INTO Enrollments (student_id, course_id, semester, grade)
        VALUES (sid, cid, sem, grades);
        SET i = i + 1;
    END WHILE;
END$$
DELIMITER ;
CALL seed_enrollments();
DROP PROCEDURE seed_enrollments;

-- ── Schedules ─────────────────────────────────────────────────
INSERT INTO Schedules (course_id, day_of_week, start_time, end_time, room) VALUES
(1,  'Monday',    '08:00:00', '09:15:00', 'EH 101'),
(1,  'Wednesday', '08:00:00', '09:15:00', 'EH 101'),
(2,  'Tuesday',   '10:00:00', '11:15:00', 'EH 202'),
(2,  'Thursday',  '10:00:00', '11:15:00', 'EH 202'),
(3,  'Monday',    '13:00:00', '14:15:00', 'EH 305'),
(3,  'Wednesday', '13:00:00', '14:15:00', 'EH 305'),
(4,  'Tuesday',   '14:30:00', '15:45:00', 'TC 101'),
(5,  'Monday',    '09:30:00', '10:45:00', 'EH 210'),
(6,  'Wednesday', '11:00:00', '12:15:00', 'EH 215'),
(7,  'Friday',    '09:00:00', '10:15:00', 'EH 220'),
(8,  'Thursday',  '13:00:00', '14:15:00', 'EH 301'),
(9,  'Monday',    '08:00:00', '09:50:00', 'SB 105'),
(10, 'Tuesday',   '10:00:00', '11:50:00', 'SB 105'),
(11, 'Wednesday', '13:00:00', '14:15:00', 'SB 210'),
(12, 'Thursday',  '09:00:00', '10:15:00', 'SB 215');

SELECT 'Database seeded successfully.' AS status;
SELECT COUNT(*) AS total_students    FROM Students;
SELECT COUNT(*) AS total_courses     FROM Courses;
SELECT COUNT(*) AS total_instructors FROM Instructors;
SELECT COUNT(*) AS total_enrollments FROM Enrollments;
