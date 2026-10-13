-- Create a new database 
CREATE  DATABASE IF NOT EXISTS ecom_db;

-- Bring the database in use
USE ecom_db;


--  Creating table in the ecom_db Database

CREATE TABLE IF NOT EXISTS dim_date(
    date_key INT PRIMARY KEY,
    date DATE,
    day INT,
    month INT,
    month_name VARCHAR(20),
    quarter INT,
    year INT,
    is_weekend TINYINT(1)
)

CREATE TABLE IF NOT EXISTS dim_customer(
    customer_key INT PRIMARY KEY,
    customer_id VARCHAR(20),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    gender CHAR(1),
    email VARCHAR(100),
    phone VARCHAR(20),
    country VARCHAR(50),
    state VARCHAR(50),
    city VARCHAR(50),
    join_date DATE
)

CREATE TABLE IF NOT EXISTS dim_product (
    product_key INT PRIMARY KEY,
    product_id VARCHAR(20),
    product_name VARCHAR(100),
    category VARCHAR(50),
    brand VARCHAR(50),
    unit_price DECIMAL(10,2),
    launch_date DATE
);

CREATE TABLE IF NOT EXISTS dim_store (
    store_key INT PRIMARY KEY,
    store_id VARCHAR(20),
    store_name VARCHAR(100),
    region VARCHAR(50),
    country VARCHAR(50),
    city VARCHAR(50)
);


--  Fact Table
CREATE TABLE IF NOT EXISTS fact_sales(
    sales_id INT PRIMARY KEY,
    date_key INT,
    customer_key INT,
    product_key INT,
    store_key INT,
    quantity_sold INT,
    unit_price DECIMAL(10,2),
    discount DECIMAL(10,2),
    total_amount DECIMAL(10,2),
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
    FOREIGN KEY (customer_key) REFERENCES dim_customer(customer_key),
    FOREIGN KEY (product_key) REFERENCES dim_product(product_key),
    FOREIGN KEY (store_key) REFERENCES dim_store(store_key)
)


-- Add entries into all tables in ecom_db DATABASE Tables

-- ###   NOTE --->             THE INSERT STATEMENTS ARE PLACED IN FILE :  insert_values_ecom_db_tables.sql              ###




SELECT * FROM dim_customer