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





 -- ## HAVING  : Use having clause when the column is not present in the table, and the column is beaing created in runtime using AS keyword






-- ### FLOW OF EXECUTION (MySQL)

 --- FROM (Table Selection wil happen 1st) -> WHERE (Pruning of rows will take place after table selection) -> GROUP BY  -> HAVING -> SELECT (Select Columns) 
--   -> ORDER BY -> LIMIT




--  ### JOINS  : Join is merging two or more table, and returns a new resultant table.


-- 1. INNER JOIN (Intersection) : When INNER JOIN is applied on table A & B : The common entries that are matching in both tables
--  will be returned as new resultant table.

-- 2. LEFT JOIN (All Data from LEFT table + Common data from both tables): When LEFT JOIN is applid on tables A & B : All the data
-- From table A(LEFT Table) and all the common data between table A & B will be the new resultant table. 
-- NOTE -> THE TABLE THAT HAS FROM CLAUSE IS LEFT TABLE; THE UNMATCHED DATA IN RESULTANT TABLE WILL RETURN NULL.

-- 3. RIGHT JOIN (ALL Data from RIGHT table + Common data from both tables) : When RIGHT JOIN is applid on tables A & B : All the data
-- From table B (RIGHT Table) and all the common data between table A & B will be the new resultant table. 
-- NOTE : WE RARELY USE RIGTH JOIN; BECAUSE RIGHT JOIN IS JUST A REVERSE OF LEFT JOIN, THEREFORE WHEN WE WNAT TO ACHIEVE RIGHT JOIN
--  WE SIMPLY USE THE LEFT JOIN BUT WITH SWAPPED TABLES.

-- 4  FULL JOIN (All data from both tables) : When FULL JOIN is applid on table A & B, the whole data from table A and table B 
--  is returned as new resultant table.
--  NOTE : ALL  THE UNMATCHED DATA WILL RETUN NULL.



