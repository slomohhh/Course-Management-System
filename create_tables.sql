-- ============================================================
-- University Course Management System
-- Author: Mohammad Khan
-- File: schema/create_tables.sql
-- Description: Creates all tables with constraints, foreign keys,
--              and cascading rules for the university database.
-- ============================================================

DROP DATABASE IF EXISTS university_db;
CREATE DATABASE university_db;
USE university_db;

-- ── Departments ───────────────────────────────────────────────
CREATE TABLE Departments (
    dept_id     INT PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(100) NOT NULL UNIQUE,
    building    VARCHAR(100),
    budget      DECIMAL(12, 2)
);

-- ── Instructors ───────────────────────────────────────────────
CREATE TABLE Instructors (
    instructor_id   INT PRIMARY KEY AUTO_INCREMENT,
    first_name      VARCHAR(50)  NOT NULL,
    last_name       VARCHAR(50)  NOT NULL,
    email           VARCHAR(100) NOT NULL UNIQUE,
    dept_id         INT          NOT NULL,
    hire_date       DATE,
    salary          DECIMAL(10, 2),
    CONSTRAINT fk_instructor_dept
        FOREIGN KEY (dept_id) REFERENCES Departments(dept_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- ── Students ──────────────────────────────────────────────────
CREATE TABLE Students (
    student_id      INT PRIMARY KEY AUTO_INCREMENT,
    first_name      VARCHAR(50)  NOT NULL,
    last_name       VARCHAR(50)  NOT NULL,
    email           VARCHAR(100) NOT NULL UNIQUE,
    dept_id         INT          NOT NULL,
    enrollment_year YEAR         NOT NULL,
    gpa             DECIMAL(3,2) DEFAULT 0.00,
    CONSTRAINT fk_student_dept
        FOREIGN KEY (dept_id) REFERENCES Departments(dept_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- ── Courses ───────────────────────────────────────────────────
CREATE TABLE Courses (
    course_id       INT PRIMARY KEY AUTO_INCREMENT,
    course_code     VARCHAR(20)  NOT NULL UNIQUE,
    title           VARCHAR(150) NOT NULL,
    credits         INT          NOT NULL CHECK (credits BETWEEN 1 AND 6),
    dept_id         INT          NOT NULL,
    instructor_id   INT,
    prereq_id       INT          DEFAULT NULL,
    max_enrollment  INT          DEFAULT 30,
    CONSTRAINT fk_course_dept
        FOREIGN KEY (dept_id) REFERENCES Departments(dept_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_course_instructor
        FOREIGN KEY (instructor_id) REFERENCES Instructors(instructor_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT fk_course_prereq
        FOREIGN KEY (prereq_id) REFERENCES Courses(course_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

-- ── Enrollments ───────────────────────────────────────────────
CREATE TABLE Enrollments (
    enrollment_id   INT PRIMARY KEY AUTO_INCREMENT,
    student_id      INT          NOT NULL,
    course_id       INT          NOT NULL,
    semester        VARCHAR(20)  NOT NULL,
    grade           CHAR(2)      DEFAULT NULL,
    enrolled_on     DATE         DEFAULT (CURRENT_DATE),
    CONSTRAINT fk_enrollment_student
        FOREIGN KEY (student_id) REFERENCES Students(student_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_enrollment_course
        FOREIGN KEY (course_id) REFERENCES Courses(course_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT uq_enrollment UNIQUE (student_id, course_id, semester)
);

-- ── Schedules ─────────────────────────────────────────────────
CREATE TABLE Schedules (
    schedule_id     INT PRIMARY KEY AUTO_INCREMENT,
    course_id       INT         NOT NULL,
    day_of_week     ENUM('Monday','Tuesday','Wednesday','Thursday','Friday') NOT NULL,
    start_time      TIME        NOT NULL,
    end_time        TIME        NOT NULL,
    room            VARCHAR(50),
    CONSTRAINT fk_schedule_course
        FOREIGN KEY (course_id) REFERENCES Courses(course_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- ── Indexes for query performance ─────────────────────────────
CREATE INDEX idx_student_dept     ON Students(dept_id);
CREATE INDEX idx_course_dept      ON Courses(dept_id);
CREATE INDEX idx_course_instructor ON Courses(instructor_id);
CREATE INDEX idx_enrollment_student ON Enrollments(student_id);
CREATE INDEX idx_enrollment_course  ON Enrollments(course_id);
CREATE INDEX idx_schedule_course    ON Schedules(course_id);
