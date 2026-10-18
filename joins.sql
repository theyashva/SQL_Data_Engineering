USE ecom_db;


-- 1. INNER JOIN (Intersection) : When INNER JOIN is applied on table A & B : The common entries that are matching in both tables
--  will be returned as new resultant table.


--  CREATE TABLES
CREATE TABLE courses(
    course_id INT PRIMARY KEY,
    course_name VARCHAR(50),
    fees INT
);


CREATE TABLE students(
    student_id INT PRIMARY KEY,
    student_name VARCHAR(50) NOT NULL,
    course_id INT,
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);


CREATE TABLE payments(
    payment_id INT PRIMARY KEY,
    student_id INT,
    amount INT,
    FOREIGN KEY (student_id) REFERENCES students(student_id)
);




-- INSERT DATA INTO TABLES  
-- # courses
INSERT INTO courses (course_id, course_name, fees)
VALUES
(101, 'Computer Science', 50000),
(102, 'Data Science', 60000),
(103, 'Cyber Security', 55000),
(104, 'Artificial Intelligence', 70000);


--  # students
INSERT INTO students (student_id, student_name, course_id)
VALUES 
(1, 'Aarav', 101),
(2, 'Priya', 102),
(3, 'Rahul', 101),
(4, 'Sneha', 103),
(5, 'Vikram', NULL);

-- # Payments
INSERT INTO payments (payment_id, student_id, amount)
VALUES
(1001, 1, 25000),
(1002, 1, 25000),
(1003, 2, 60000),
(1004, 3, 20000),
(1005, 5, 15000);



(
SELECT 
    c.course_id,
    c.course_name,
    c.fees,
    s.student_id,
    s.student_name,
    p.payment_id,
    p.amount
FROM
    courses c
INNER JOIN
    students s
ON
c.course_id = s.course_id

INNER JOIN
    payments p 
ON
s.student_id = p.student_id
)


