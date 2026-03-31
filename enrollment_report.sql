-- ============================================================
-- University Course Management System
-- Author: Mohammad Khan
-- File: queries/enrollment_report.sql
-- Description: Full SQL query library for administrative reporting —
--              enrollment trends, prerequisite mapping, scheduling
--              conflict detection, and role-based audit queries.
-- ============================================================

USE university_db;

-- ─────────────────────────────────────────────────────────────
-- 1. ENROLLMENT COUNT BY DEPARTMENT
-- ─────────────────────────────────────────────────────────────
SELECT
    d.name                      AS department,
    COUNT(e.enrollment_id)      AS total_enrollments
FROM Departments d
JOIN Courses c     ON d.dept_id   = c.dept_id
JOIN Enrollments e ON c.course_id = e.course_id
GROUP BY d.name
ORDER BY total_enrollments DESC;

-- ─────────────────────────────────────────────────────────────
-- 2. ENROLLMENT TREND BY SEMESTER
-- ─────────────────────────────────────────────────────────────
SELECT
    semester,
    COUNT(enrollment_id)        AS enrollments
FROM Enrollments
GROUP BY semester
ORDER BY semester;

-- ─────────────────────────────────────────────────────────────
-- 3. TOP 10 MOST ENROLLED COURSES
-- ─────────────────────────────────────────────────────────────
SELECT
    c.course_code,
    c.title,
    COUNT(e.enrollment_id)      AS enrolled_students,
    c.max_enrollment,
    ROUND(COUNT(e.enrollment_id) / c.max_enrollment * 100, 1) AS fill_rate_pct
FROM Courses c
JOIN Enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_code, c.title, c.max_enrollment
ORDER BY enrolled_students DESC
LIMIT 10;

-- ─────────────────────────────────────────────────────────────
-- 4. STUDENTS WITH UNMET PREREQUISITES
-- ─────────────────────────────────────────────────────────────
SELECT
    CONCAT(s.first_name, ' ', s.last_name)  AS student,
    s.email,
    c.course_code,
    c.title                                  AS enrolled_course,
    prereq.course_code                       AS required_prereq
FROM Students s
JOIN Enrollments e  ON s.student_id  = e.student_id
JOIN Courses c      ON e.course_id   = c.course_id
JOIN Courses prereq ON c.prereq_id   = prereq.course_id
WHERE c.prereq_id IS NOT NULL
  AND c.prereq_id NOT IN (
      SELECT course_id
      FROM Enrollments
      WHERE student_id = s.student_id
  )
ORDER BY s.last_name, s.first_name;

-- ─────────────────────────────────────────────────────────────
-- 5. SCHEDULING CONFLICT DETECTION
--    Students enrolled in two courses that meet at the same time
-- ─────────────────────────────────────────────────────────────
SELECT
    CONCAT(s.first_name, ' ', s.last_name)  AS student,
    c1.course_code                           AS course_1,
    c2.course_code                           AS course_2,
    sc1.day_of_week                          AS conflict_day,
    sc1.start_time                           AS start_time,
    sc1.end_time                             AS end_time
FROM Enrollments e1
JOIN Enrollments e2  ON  e1.student_id  = e2.student_id
                     AND e1.course_id   < e2.course_id
                     AND e1.semester    = e2.semester
JOIN Students s      ON  s.student_id   = e1.student_id
JOIN Courses c1      ON  c1.course_id   = e1.course_id
JOIN Courses c2      ON  c2.course_id   = e2.course_id
JOIN Schedules sc1   ON  sc1.course_id  = e1.course_id
JOIN Schedules sc2   ON  sc2.course_id  = e2.course_id
                     AND sc2.day_of_week = sc1.day_of_week
WHERE sc1.start_time < sc2.end_time
  AND sc2.start_time < sc1.end_time
ORDER BY s.last_name, conflict_day;

-- ─────────────────────────────────────────────────────────────
-- 6. GRADE DISTRIBUTION PER COURSE
-- ─────────────────────────────────────────────────────────────
SELECT
    c.course_code,
    c.title,
    SUM(CASE WHEN e.grade = 'A' THEN 1 ELSE 0 END) AS grade_A,
    SUM(CASE WHEN e.grade = 'B' THEN 1 ELSE 0 END) AS grade_B,
    SUM(CASE WHEN e.grade = 'C' THEN 1 ELSE 0 END) AS grade_C,
    SUM(CASE WHEN e.grade = 'D' THEN 1 ELSE 0 END) AS grade_D,
    SUM(CASE WHEN e.grade = 'F' THEN 1 ELSE 0 END) AS grade_F,
    COUNT(e.enrollment_id)                           AS total_enrolled
FROM Courses c
JOIN Enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_code, c.title
ORDER BY total_enrolled DESC;

-- ─────────────────────────────────────────────────────────────
-- 7. INSTRUCTOR WORKLOAD REPORT
-- ─────────────────────────────────────────────────────────────
SELECT
    CONCAT(i.first_name, ' ', i.last_name)  AS instructor,
    d.name                                   AS department,
    COUNT(DISTINCT c.course_id)              AS courses_teaching,
    SUM(c.credits)                           AS total_credit_hours,
    COUNT(e.enrollment_id)                   AS total_students
FROM Instructors i
JOIN Departments d  ON i.dept_id   = d.dept_id
JOIN Courses c      ON c.instructor_id = i.instructor_id
LEFT JOIN Enrollments e ON e.course_id = c.course_id
GROUP BY i.instructor_id, instructor, department
ORDER BY total_students DESC;

-- ─────────────────────────────────────────────────────────────
-- 8. STUDENT GPA RANKING BY DEPARTMENT
-- ─────────────────────────────────────────────────────────────
SELECT
    d.name                                   AS department,
    CONCAT(s.first_name, ' ', s.last_name)   AS student,
    s.gpa,
    RANK() OVER (
        PARTITION BY d.dept_id
        ORDER BY s.gpa DESC
    )                                        AS dept_rank
FROM Students s
JOIN Departments d ON s.dept_id = d.dept_id
ORDER BY d.name, dept_rank
LIMIT 50;

-- ─────────────────────────────────────────────────────────────
-- 9. COURSES WITH ZERO ENROLLMENT (Audit)
-- ─────────────────────────────────────────────────────────────
SELECT
    c.course_code,
    c.title,
    d.name                                   AS department,
    CONCAT(i.first_name,' ',i.last_name)     AS instructor
FROM Courses c
JOIN Departments d   ON c.dept_id       = d.dept_id
LEFT JOIN Instructors i ON c.instructor_id = i.instructor_id
LEFT JOIN Enrollments e ON c.course_id  = e.course_id
WHERE e.enrollment_id IS NULL
ORDER BY d.name, c.course_code;

-- ─────────────────────────────────────────────────────────────
-- 10. DATA INTEGRITY AUDIT
--     Verifies referential integrity across all key relationships
-- ─────────────────────────────────────────────────────────────
SELECT 'Enrollments with invalid student_id' AS check_name,
       COUNT(*) AS violations
FROM Enrollments e
LEFT JOIN Students s ON e.student_id = s.student_id
WHERE s.student_id IS NULL

UNION ALL

SELECT 'Enrollments with invalid course_id',
       COUNT(*)
FROM Enrollments e
LEFT JOIN Courses c ON e.course_id = c.course_id
WHERE c.course_id IS NULL

UNION ALL

SELECT 'Courses with invalid dept_id',
       COUNT(*)
FROM Courses c
LEFT JOIN Departments d ON c.dept_id = d.dept_id
WHERE d.dept_id IS NULL

UNION ALL

SELECT 'Instructors with invalid dept_id',
       COUNT(*)
FROM Instructors i
LEFT JOIN Departments d ON i.dept_id = d.dept_id
WHERE d.dept_id IS NULL;
