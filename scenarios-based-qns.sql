USE ecom_db;

-- QNS 1. FINDING THE nTH VALUE : find 6th most expensive product in dim customers
WITH ranking_cte AS(
SELECT 
    *,
    DENSE_RANK() OVER(ORDER BY unit_price ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS 'ranking'
from
    dim_product
)
SELECT 
    *
FROM ranking_cte
WHERE 
    ranking = 6;



-- QNS 2. FINDING THE nTH VALUE in each category : find 9th most expensive product in each product category in dim customers
WITH ranking_cte AS(
SELECT 
    *,
    DENSE_RANK() OVER(PARTITION BY category ORDER BY unit_price ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS 'ranking'
from
    dim_product
)
SELECT 
    *
FROM ranking_cte
WHERE 
    ranking = 9;






-- QNS 3.  Remove dublicate values
CREATE TABLE IF NOT EXISTS employees (
    emp_id INT,
    emp_name VARCHAR(100),
    department VARCHAR(50),
    salary INT,
    city VARCHAR(50)
);

-- INSERT INTO employees (emp_id, emp_name, department, salary, city)
-- VALUES
-- (1, 'Rahul', 'IT', 50000, 'Mumbai'),
-- (2, 'Priya', 'HR', 45000, 'Delhi'),
-- (3, 'Amit', 'IT', 60000, 'Pune'),
-- (4, 'Sneha', 'Finance', 55000, 'Mumbai'),
-- (5, 'Rahul', 'IT', 50000, 'Mumbai'),
-- (6, 'Priya', 'HR', 45000, 'Delhi'),
-- (7, 'Vikas', 'Sales', 40000, 'Bangalore'),
-- (8, 'Amit', 'IT', 60000, 'Pune'),
-- (9, 'Neha', 'Finance', 65000, 'Delhi'),
-- (10, 'Rahul', 'IT', 50000, 'Mumbai'),
-- (11, 'Arjun', 'Sales', 42000, 'Pune'),
-- (12, 'Neha', 'Finance', 65000, 'Delhi'),
-- (13, 'Karan', 'IT', 70000, 'Mumbai'),
-- (14, 'Vikas', 'Sales', 40000, 'Bangalore'),
-- (15, 'Meera', 'HR', 48000, 'Pune');


WITH removed_dublicates AS
(
SELECT 
    *,
    ROW_NUMBER() OVER(PARTITION BY emp_name, department, salary, city ORDER BY emp_id) AS 'rank_'
FROM 
    employees
)
SELECT
    *
FROM 
    removed_dublicates
WHERE
    rank_ = 1;





-- QNS 4.  Count total dublicate values

WITH removed_dublicates AS
(
SELECT 
    *,
    ROW_NUMBER() OVER(PARTITION BY emp_name, department, salary, city ORDER BY emp_id) AS 'rank_'
FROM 
    employees
)
SELECT
    COUNT(*) AS 'total_dublicates'
FROM 
    removed_dublicates
WHERE
    rank_ > 1

