USE ecom_db;

### CTEs (Common Table Expressions)

-- - A CTE is a named temporary result set defined using the `WITH` keyword.
-- - CTEs are an alternative to subqueries and help make complex SQL queries more readable and organized.
-- - A CTE can be referenced like a table in the `FROM` clause and can also be used in joins and other supported query operations.
-- - Unlike a subquery, a CTE has a name that can be referenced multiple times within the same SQL statement.
-- - A CTE is not a permanently stored table; its scope is limited to the statement that immediately follows its definition.

WITH first_cte AS
(
SELECT 
    *,
    ROW_NUMBER() OVER(ORDER BY unit_price ROWS BETWEEN UNBOUNDED  PRECEDING AND CURRENT ROW) AS 'id'
FROM 
    dim_product
),
second_cte AS 
(
SELECT *
FROM
    first_cte
WHERE 
    product_name IN ('Middle Forward', 'My Hard', 'Sea Actually')
)
SELECT * FROM second_cte;






