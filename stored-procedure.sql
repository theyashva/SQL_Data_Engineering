-- # Stored Procedure : A stored procedure in my sql is a predefined set of sql statements that are stored in the database 
--                      and can be executed(called) whenever needed.
--                     Think of it like a function programming - you write a logic logic as function and reuse it multiple times.


-- Unlike views Stored procedures are capable of performing DML, input/output parameters.

USE ecom_db;


CREATE TABLE IF NOT EXISTS full_name_table(
    name_ VARCHAR(50),
    age_ INT
);



DELIMITER //
CREATE PROCEDURE full_name_age(IN name_ VARCHAR(50), IN age_ INT)
BEGIN 
    INSERT INTO full_name_table
    VALUES
    (name_, age_);
END //


DELIMITER ;



CALL full_name_age('Yash', 25);

SELECT * FROM full_name_table;


