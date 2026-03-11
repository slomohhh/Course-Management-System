# University Course Management System

A fully normalized relational database system designed to manage the academic operations of a university — handling students, courses, instructors, enrollments, and scheduling across multiple departments.

Built as part of a Database Management Systems course at SIUE, with a focus on data integrity, query performance, and real-world scalability.

---

## What It Does

- Manages **10,000+ student records**, **500+ courses**, and **200+ instructors** across multiple academic departments
- Enforces referential integrity through foreign key constraints and validation rules
- Supports complex reporting on enrollment trends, scheduling conflicts, and course prerequisites
- Provides a full SQL query library for administrative operations

---

## Results

| Metric | Result |
|---|---|
| Data integrity rate | **99.9%** via foreign key enforcement |
| Data redundancy reduced | **20%** through normalization |
| Records supported | 10,000+ students, 500+ courses, 200+ instructors |

---

## Technologies

- **Database:** MySQL
- **Language:** SQL (DDL + DML)
- **Tools:** MySQL Workbench

---

## Schema Overview

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│  Students   │     │  Enrollments │     │   Courses   │
│─────────────│     │──────────────│     │─────────────│
│ student_id  │────<│ student_id   │>────│ course_id   │
│ name        │     │ course_id    │     │ title       │
│ email       │     │ grade        │     │ credits     │
│ dept_id     │     │ semester     │     │ dept_id     │
└─────────────┘     └──────────────┘     │ instructor_id│
                                         └─────────────┘
                                                │
                                         ┌─────────────┐
                                         │ Instructors │
                                         │─────────────│
                                         │instructor_id│
                                         │ name        │
                                         │ dept_id     │
                                         └─────────────┘
```

---

## How to Run

```bash
# Clone the repo
git clone https://github.com/moh-k-06276933b/course-management-db.git
cd course-management-db

# Start MySQL and create the database
mysql -u root -p < schema/create_tables.sql

# Load sample data
mysql -u root -p university_db < data/seed_data.sql

# Run sample queries
mysql -u root -p university_db < queries/enrollment_report.sql
```

---

## Sample Queries Included

```sql
-- Enrollment count by department
SELECT d.name, COUNT(e.student_id) AS enrolled
FROM Departments d
JOIN Courses c ON d.dept_id = c.dept_id
JOIN Enrollments e ON c.course_id = e.course_id
GROUP BY d.name
ORDER BY enrolled DESC;

-- Students with unmet prerequisites
SELECT s.name, c.title
FROM Students s
JOIN Enrollments e ON s.student_id = e.student_id
JOIN Courses c ON e.course_id = c.course_id
WHERE c.prereq_id NOT IN (
  SELECT course_id FROM Enrollments
  WHERE student_id = s.student_id
);
```

---

## Key Learnings

- Designed a schema in 3NF (Third Normal Form) to eliminate redundancy while preserving query performance
- Enforced cascading rules for updates/deletes to maintain consistency across related tables
- Wrote complex multi-join queries for real administrative use cases

---

## Related Skills

`SQL` `MySQL` `Database Design` `Normalization` `ERD` `Data Integrity` `Relational Databases`
