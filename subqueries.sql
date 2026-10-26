--  ### SUBQUERIES : SQL subqueries are queries that are written inside another query - basically a query within a query,
--                   they are used when you need to get a result from one query and use it inside another.

USE ecom_db;


-- QNS : Find the all unit prices which are more than AVG
SELECT *
FROM
    dim_product
WHERE 
    unit_price > (
     SELECT 
        AVG(unit_price) AS 'avg_unit_price'
    FROM 
    dim_product
);







-- QUERY from a result as table
SELECT *
FROM 
(
       SELECT *
FROM
    dim_product
WHERE 
    unit_price > (
     SELECT 
        AVG(unit_price) AS 'avg_unit_price'
    FROM 
    dim_product
) 
) AS sub_query
WHERE 
    product_name = 'Huge Change';



