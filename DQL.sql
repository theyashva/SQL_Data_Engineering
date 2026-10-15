USE ecom_db;

-- Print the whole table 
SELECT * FROM dim_customer;

--  Print only specific columns from a table 
SELECT 
    customer_id, phone 
FROM 
    dim_customer;


--  LIMIT COMAND : Returns only the n number of rows (in this case n is only 5 rows)
SELECT *
FROM
    dim_customer
LIMIT 5;


--  WHERE Clause : it is passed as a condition to queries to filter (prune) the data.
SELECT *
FROM
    dim_customer
WHERE 
    gender = 'M';


--  Using Multiple condition under where clause
SELECT *
FROM 
    dim_customer
WHERE 
    ((state = 'montana') AND (gender = 'M')) AND (join_date < '2023-03-26');




--  LIKE operator : Matches the column values and returns them if they follow the given pattern
--  QNS : Print the all entries where name starts from M
SELECT *
FROM
    dim_customer
WHERE 
    first_name LIKE ('m%');


--  QNS : Print the all entries where name starts from M and its third character is u and last character is n
SELECT *
FROM
    dim_customer
WHERE
    first_name LIKE ('m_u%n');




-- Sort the  entries in dim_product table , by default the ORDER BY clause sorts entries in ASCENDING(Increasing order -> lower to high)
SELECT *
FROM
    dim_product
ORDER BY 
    unit_price
DESC;


--  QNS FIND TOP 3 Expensive Products in dim_product (Using LIMIT, WIll use Window Functions in FUTURE Learning)
SELECT *
FROM 
    dim_product
ORDER BY 
    unit_price
DESC
LIMIT 3;



-- GROUPING : calculate avg of unit_price on basis of per category in dim_product Table
SELECT 
    category,
    AVG(unit_price)
FROM 
    dim_product
GROUP BY 
    category

SELECT * FROM dim_product


--  AS : Alias for a given column
SELECT category AS "Categories", unit_price
FROM
    dim_product



