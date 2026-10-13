-- # DDL stand for DATA Defination Language, These are SQL commands used to define, modify, or delete the structure of the database 
-- such as Tables, Indexes, and Schemas


-- COMMANDS : 
-- 1. CREATE : used to create Database, Schema, Table etc.
-- 2. ALTER  : Modify the structure of existing objects.
-- 3. DROP   : Deletes the whole database and the whole defination.
-- 4. TRUNCATE : Deletes the all entris from a databse, but the structure remains in existence.





-- # Constraints :  Constraints in sql are rules applied to table columns to enforce the data integrity and accuracy.
-- they ensure that the data entered into a database is valid, consistent and follows the rules you define.


-- CONSTRAINTS : 
-- 1. NOT NULL
-- 2. UNIQUE
-- 3. PRIMARY KEY
-- 4. CHECK 
-- 5. DEFAULT




-- ### KEYS :  


-- 1. UNIQUE  KEYS : Ensure that all values in a column (or combination of columns ) are unique,
--   It can have one NULL (in most databases) per Column,
--   You can have multiple unique keys in a table


-- 2. PRIMARY KEY : Uniquely identifies the each record in a table,
--                  cannot have null values,
--                  Only one PRIMARY KEY per table is allowed


-- 3. FOREIGN KEY : Creates a link between two TABLES,
--                 Ensure that values in a column exist in another's table primary ke



-- 4. CANDIDATE KEY : The columns which are eligible to become  PRIMARY KEY are candidate keys,
--                     A table can have multiple candidate key,
--                     Primary KEY is chosen from CANDIDATE KEY


-- 5. COMPOSITE KEY : A PRIMARY KEY made of two or more columns,
--                   Uniquily identifies a record using a combination of columns.


-- 6. SURROGATE KEY : It is an Artificial Key, usually an auto increment number,
--                     used when natural key are too long or inconvenient.


