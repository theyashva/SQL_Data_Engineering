USE ecom_db;


--  1. INSERT INTO : Used to add entries in an existing table
CREATE TABLE insert_demo (
    id INT NOT NULL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

--  INSERTING DATA IN insert_demo TABLE
INSERT INTO insert_demo(id, name)
VALUES
(1,"Shubhaman Verma"),
(2,"Venkatesh Padala"),
(3, "Jay sean"),
(4, "Jodha"),
(5, "Steven"),
(6, "Stanly");

SELECT * FROM insert_demo;




--  2. UPDATE : Used to update the entries in the table
UPDATE insert_demo
SET name = "Bilbo"
WHERE 
    id = 4

SELECT * FROM insert_demo ;



-- 3. DELETE : used to delete the existing records from a table (it is highly recomnded to use WHERE clause under the DELETE command)
DELETE 
FROM
    insert_demo
WHERE id = 6;

SELECT * FROM insert_demo;



