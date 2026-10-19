USE ecom_db;


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




-- 1. INNER JOIN (Intersection) : When INNER JOIN is applied on table A & B : The common entries that are matching in both tables
--  will be returned as new resultant table.

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



-- 2. LEFT JOIN (All Data from LEFT table + Common data from both tables): When LEFT JOIN is applid on tables A & B : All the data
-- From table A(LEFT Table) and all the common data between table A & B will be the new resultant table. 
-- NOTE -> THE TABLE THAT HAS FROM CLAUSE IS LEFT TABLE; THE UNMATCHED DATA IN RESULTANT TABLE WILL RETURN NULL.

(
SELECT 
    s.student_id,
    s.student_name,
    s.course_id,
    p.payment_id,
    p.amount
FROM
    students s 
LEFT JOIN
    payments p
ON
    s.student_id = p.student_id
)




-- 3. RIGHT JOIN (ALL Data from RIGHT table + Common data from both tables) : When RIGHT JOIN is applid on tables A & B : All the data
-- From table B (RIGHT Table) and all the common data between table A & B will be the new resultant table. 
-- NOTE : WE RARELY USE RIGTH JOIN; BECAUSE RIGHT JOIN IS JUST A REVERSE OF LEFT JOIN, THEREFORE WHEN WE WNAT TO ACHIEVE RIGHT JOIN
--  WE SIMPLY USE THE LEFT JOIN BUT WITH SWAPPED TABLES.


(
SELECT 
    s.student_id,
    s.student_name,
    s.course_id,
    p.payment_id,
    p.amount
FROM
    students s 
RIGHT JOIN
    payments p
ON
    s.student_id = p.student_id
)



-- 4. FULL JOIN (All data from both tables) : When FULL JOIN is applid on table A & B, the whole data from table A and table B 
--  is returned as new resultant table.
--  NOTE : ALL  THE UNMATCHED DATA WILL RETUN NULL.


(
SELECT 
    s.student_id,
	s.student_name,
	c.course_id,
	c.course_name,
	c.fees
FROM 
    students s 
LEFT JOIN
    courses c 
ON 
s.course_id = c.course_id
UNION 
SELECT 
    s.student_id,
	s.student_name,
	c.course_id,
	c.course_name,
	c.fees
FROM 
    students s
RIGHT JOIN
    courses c
ON
c.course_id = s.course_id
)




