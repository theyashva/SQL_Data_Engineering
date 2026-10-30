-- VIEW : It doesnt hold data, it stores the query, it is used to wrap the big complex queries in a simple view and 
-- allows to query easily
USE ecom_db;

CREATE OR REPLACE VIEW  dedublicate AS
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



SELECT * FROM dedublicate;
