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
    rank_ > 1;




-- QNS 5. LAG()/LEAD()

CREATE TABLE IF NOT EXISTS bank_transactions
(
    transaction_id INT PRIMARY KEY,
    account_id INT,
    transaction_date DATETIME,
    transaction_type VARCHAR(20),
    amount DECIMAL(12,2),
    balance DECIMAL(12,2),
    city VARCHAR(20)
);


-- INSERT INTO bank_transactions
-- (transaction_id, account_id, transaction_date,
--  transaction_type, amount, balance, city)
-- VALUES
-- -- Account 1001
-- (1, 1001, '2026-01-01 09:00:00', 'DEPOSIT',  10000, 10000, 'Mumbai'),
-- (2, 1001, '2026-01-02 11:30:00', 'WITHDRAWAL', 2000, 8000, 'Mumbai'),
-- (3, 1001, '2026-01-03 14:00:00', 'DEPOSIT',   5000, 13000, 'Pune'),
-- (4, 1001, '2026-01-04 16:30:00', 'WITHDRAWAL', 3000, 10000, 'Mumbai'),
-- (5, 1001, '2026-01-05 10:00:00', 'WITHDRAWAL', 1500, 8500, 'Delhi'),
-- -- Account 1002
-- (6, 1002, '2026-01-01 10:00:00', 'DEPOSIT',  20000, 20000, 'Delhi'),
-- (7, 1002, '2026-01-02 12:00:00', 'WITHDRAWAL', 5000, 15000, 'Delhi'),
-- (8, 1002, '2026-01-03 15:00:00', 'DEPOSIT',   8000, 23000, 'Mumbai'),
-- (9, 1002, '2026-01-04 17:00:00', 'WITHDRAWAL', 2000, 21000, 'Delhi'),
-- (10, 1002, '2026-01-05 11:00:00', 'DEPOSIT',   4000, 25000, 'Pune'),
-- -- Account 1003
-- (11, 1003, '2026-01-01 08:30:00', 'DEPOSIT',  15000, 15000, 'Pune'),
-- (12, 1003, '2026-01-02 09:45:00', 'WITHDRAWAL', 3000, 12000, 'Pune'),
-- (13, 1003, '2026-01-03 13:15:00', 'WITHDRAWAL', 2000, 10000, 'Mumbai'),
-- (14, 1003, '2026-01-04 16:00:00', 'DEPOSIT',   7000, 17000, 'Pune'),
-- (15, 1003, '2026-01-05 18:00:00', 'WITHDRAWAL', 4000, 13000, 'Delhi');


SELECT * FROM bank_transactions;

-- A)  Use LAG() to retrieve the previous transaction amount for each bank account.
-- Required columns:
-- - account_id
-- - transaction_date
-- - transaction_type
-- - amount
-- - Previous transaction amount
-- Sort by account ID and transaction date.
SELECT 
    account_id,
    transaction_date,
    transaction_type,
    LAG(amount,1) OVER(PARTITION BY account_id ORDER BY transaction_date) AS 'lag(1days)'
FROM
    bank_transactions;

-- B) Use LEAD() to identify the next transaction for each account.
-- Required columns:
-- - account_id
-- - transaction_date
-- - amount
-- - Next transaction amount
-- - Next transaction type
-- Make sure transactions from different accounts aren't mixed.
SELECT 
    account_id,
    transaction_date,
    LEAD(transaction_type,1) OVER(PARTITION BY account_id ORDER BY transaction_date) AS 'next_day_transaction',
    LEAD(amount,1) OVER(PARTITION BY account_id ORDER BY transaction_date) AS 'next_day_amount'
FROM
    bank_transactions;


-- C) Analyze transaction amounts compared with the previous transaction of the same account.
-- Requirements:
-- - Display account ID and transaction date.
-- - Display current transaction amount.
-- - Display previous transaction amount using LAG().
-- - Calculate the difference between current and previous transaction amounts.
-- - Flag transactions where the current amount is more than 2 times the previous transaction amount.
-- Consider the first transaction of each account separately because it has no previous transaction.

SELECT 
    account_id,
    transaction_date,
    amount AS 'current_amount',
    LAG(amount,1) OVER(PARTITION BY account_id ORDER BY transaction_date) AS 'previous_amount',
    (amount - LAG(amount,1) OVER(PARTITION BY account_id ORDER BY transaction_date)) AS 'difference',
    CASE 
        WHEN (LAG(amount,1) OVER(PARTITION BY account_id ORDER BY transaction_date) is NULL) THEN 'FIRST TRANSACTION' 
        WHEN (amount> 2*LAG(amount,1) OVER(PARTITION BY account_id ORDER BY transaction_date)) THEN  'ANOMALY'
        ELSE  'NORMAL'
    END AS 'flag'
FROM
    bank_transactions;


