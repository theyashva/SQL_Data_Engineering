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




