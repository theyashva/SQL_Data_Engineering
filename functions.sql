-- FUNCTIONS : Functions in mysql are predefined or user definedroutines that perform operations on data and
--             return a single value. they are very useful for manipulating data, performing calculations and 
--             simplifying queries.

USE ecom_db;
-- DROP FUNCTION discount_10;
-- Define discount function
DELIMITER //
CREATE FUNCTION IF NOT EXISTS discount_10 (x DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN 
    RETURN (x*0.10);
END //


DELIMITER ;



-- use discount function
SELECT 
    unit_price AS 'real price',
    CONCAT(discount_10(unit_price), ' off') AS '10% Off',
    unit_price - discount_10(unit_price) AS 'price after 10% off'
FROM
    dim_product;
