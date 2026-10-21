USE ecom_db;

--  CASE WHEN STATEMENTS : apply multiple conditions

SELECT * FROM dim_product;

SELECT 
    *,
    CASE 
        WHEN unit_price<=100 THEN 'low price'
        WHEN unit_price<=300 THEN 'normal price'
        WHEN unit_price<=500 THEN 'high price'
        ELSE 'expensive'
    END AS 'price_tone'
FROM
    dim_product;