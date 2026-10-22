USE ecom_db;


--  ### WINDOW FUNCTIONS : Window functions in sql are special functions that perform calculations accross set of rows,
--                         but without collapsing them into a single output row (unlike AGGREGATE functions).
--  They allow you to perform things like :
    -- RANKING,
    -- RUNNING TOTALs
    -- MOVING AVERAGES
--  And COMPARISON between rows while still keeping all the rows in the result.


--  1. RUNNING SUM :

SELECT 
    *,
    -- calculating RUNNING SUM
    -- 1st approach
    SUM(unit_price) OVER (ORDER BY product_id ASC),
    -- 2nd approach 
    SUM(unit_price) OVER (ORDER BY product_id  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW )
FROM
    dim_product;



--  2. MOVING AVERAGE
SELECT 
    *,
    AVG(unit_price) OVER (ORDER BY product_id  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
FROM 
    dim_product;






--  ### RANKING WINDOW FUNCTIONS :
