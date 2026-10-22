USE ecom_db;


--  ### WINDOW FUNCTIONS : Window functions in sql are special functions that perform calculations accross set of rows,
--                         but without collapsing them into a single output row (unlike AGGREGATE functions).
--  They allow you to perform things like :
    -- RANKING,
    -- RUNNING TOTALs
    -- MOVING AVERAGES
--  And COMPARISON between rows while still keeping all the rows in the result.

--  Create a new table 
CREATE TABLE IF NOT EXISTS EmployeeSales (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(30),
    salary INT,
    sales INT,
    sale_date DATE
);



--  Insert data into table
-- INSERT INTO EmployeeSales
-- (emp_id, emp_name, department, salary, sales, sale_date)
-- VALUES
-- (1,  'Amit',   'IT',      60000, 5000, '2026-01-01'),
-- (2,  'Priya',  'IT',      75000, 7000, '2026-01-02'),
-- (3,  'Rahul',  'IT',      75000, 6000, '2026-01-03'),
-- (4,  'Neha',   'IT',      50000, 4000, '2026-01-04'),
-- (5,  'Vikas',  'HR',      45000, 3000, '2026-01-01'),
-- (6,  'Sneha',  'HR',      55000, 5000, '2026-01-02'),
-- (7,  'Arjun',  'HR',      55000, 4500, '2026-01-03'),
-- (8,  'Pooja',  'HR',      40000, 2500, '2026-01-04'),
-- (9,  'Karan',  'Finance', 65000, 8000, '2026-01-01'),
-- (10, 'Meera',  'Finance', 70000, 9000, '2026-01-02'),
-- (11, 'Rohit',  'Finance', 65000, 6000, '2026-01-03'),
-- (12, 'Anjali', 'Finance', 50000, 3500, '2026-01-04');



SELECT *
FROM EmployeeSales


--  1. RUNNING SUM :

SELECT 
    *,
    -- calculating RUNNING SUM
    -- 1st approach
    SUM(salary) OVER (ORDER BY emp_id ASC),
    -- 2nd approach 
    SUM(salary) OVER (ORDER BY emp_id  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW )
FROM
    EmployeeSales;



--  2. MOVING AVERAGE
SELECT 
    *,
    AVG(salary) OVER (ORDER BY emp_id  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
FROM 
    EmployeeSales;




--  ### RANKING WINDOW FUNCTIONS :
--  1. ROW NUMBER() : 
--  2. RANK() : 
--  3. DENSE_RANK() :

SELECT 
    *,
    ROW_NUMBER() OVER (ORDER BY salary) AS 'row_number',
    RANK() OVER (ORDER BY salary) AS 'rank',
    DENSE_RANK() OVER (ORDER BY salary) AS 'dense_rank'
FROM 
    EmployeeSales;

SELECT *
FROM 
    EmployeeSales;