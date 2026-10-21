use ecom_db;



--  1. NUMERIC TRANSFORMATION : Numeric operatons are applied on columns are : discount %, Average, round, Addition,
--  Subtractions, Divison, Multiplication, Formulas etc.

SELECT 
    product_name,
    unit_price AS real_price,
    unit_price * 0.90 AS 'discount_price(10%)',
    unit_price + 10 AS 'platform_fee(+10RS)',
    ROUND(unit_price) AS 'rounded_price'
FROM
    dim_product;


--  2. DATE TRANSFORMATIONS : 


-- 1. get current date
SELECT
    -- current user timezone
    now() AS "current_time",
    -- current UTC date
    UTC_DATE() "utc_date",
    --  UTC Time HH:MM:SS
    UTC_TIME() "utc_time",
    -- FULL UTC TIME YYY-MM-DD HH:MM:SS
    UTC_TIMESTAMP "utc_timestamp";


SELECT 
    date,
    -- get year from date column
    YEAR(date) AS 'year',
    -- get month from date column
    MONTH(date) AS 'month',
    -- get day from date column
    DAY(date) AS 'day',
    -- get the day of the week : 1st day, 2nd day, 3rd day etc.
    WEEKDAY(date) AS "x_day_of_week",
    -- get the day name : Sunday, Monday ...
    DAYNAME(date) AS 'day',
    -- Add day in a date 
    ADDDATE(date,1) AS "date_+1_day",
    -- Day gap between two dates
    DATEDIFF(date,now()) AS "day_gap"
FROM
    dim_date;


SELECT 
        --  DATE TYPECASTING : convert to full date timestamp
    CAST('2005-12-01' AS DATETIME) AS 'casted_date';





--  TYPECASTING : Convert one data type to another data type 
SELECT 
    course_id,
    -- converting integer type cplumn to string(char/varchar)
    CAST(course_id AS CHAR(10))
FROM 
    courses;




--  STRING FUNCTIONS :
--  1. CONCAT (combine multiple columns) 

SELECT 
    CONCAT(first_name,' ',last_name) AS 'full_name'
FROM 
    dim_customer;



-- 2. LENGTH : calculate length(total no. of characters in a column)
SELECT 
    *,
    --  Calculate number of characters in first_name
    LENGTH(first_name) AS 'first_name_length'
FROM
    dim_customer;
   



--  3. LOWER/UPPER : convert string values to upper and lower case
SELECT 
    UPPER(first_name),
    LOWER(last_name)
FROM 
    dim_customer;



--  4. SUBSTRING : Slice the strings
SELECT 
    --  get only 3 characters from starting
    SUBSTRING(first_name,1,3)
FROM
    dim_customer;




-- 5. REPLACE : replace an existing value
SELECT
    -- replace @ character in email column with : at 
    REPLACE(email,'@','at')
FROM
    dim_customer;


