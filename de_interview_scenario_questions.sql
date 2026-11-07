USE ecom_db;

/*
====================================================================================================
 DATA ENGINEERING SQL INTERVIEW SCENARIOS (REAL-TIME CODING CHALLENGES)
====================================================================================================
 Format:
   - LEVEL 1: EASY    --> QNS 01 to QNS 20 (Aggregations, Filtering, Joins, Window Basics, Cleansing)
   - LEVEL 2: MEDIUM  --> QNS 21 to QNS 40 (Window Functions, MoM, Running Balances, CDC, Funnels)
   - LEVEL 3: HARD    --> QNS 41 to QNS 60 (Gaps & Islands, Recursive CTEs, SCD2, As-Of Joins, Graphs)

 Note:
   - No answers are included. Write your SQL query directly below each question block.
   - Designed to prepare you for technical live-coding rounds at top product companies.
====================================================================================================
*/




-- =================================================================================================
-- LEVEL 1: EASY (QNS 01 TO 20)
-- =================================================================================================

-- QNS 1. Top 5 Highest Spending Customers
-- Scenario / Objective:
--   Find the top 5 customers who have spent the highest total amount across all purchases.
-- Tables to use:
--   - dim_customer (customer_key, first_name, last_name)
--   - fact_sales (customer_key, total_amount)
-- Required columns:
--   - customer_key
--   - customer_name (first_name + last_name)
--   - total_spent
-- Conditions:
--   - Sort by total_spent in descending order and limit to 5.

SELECT
      d.customer_key,
      CONCAT(d.first_name,' ', d.last_name) AS 'customer_name',
      COALESCE(SUM(f.total_amount),0) AS 'total_spent'
FROM
    dim_customer d
LEFT JOIN
          fact_sales f
ON 
  d.customer_key = f.customer_key
GROUP BY
      d.customer_key,
      CONCAT(d.first_name,' ', d.last_name)
ORDER BY
      total_spent DESC
LIMIT 5;




-- QNS 2. Total Revenue and Order Count per Product Category
-- Scenario / Objective:
--   Calculate the total sales revenue, total quantity sold, and distinct order count for each product category.
-- Tables to use:
--   - dim_product (product_key, category)
--   - fact_sales (sales_id, product_key, quantity_sold, total_amount)
-- Required columns:
--   - category
--   - total_revenue
--   - total_quantity_sold
--   - total_orders
-- Conditions:
--   - Order by total_revenue descending.
SELECT 
      d.category,
      COALESCE(SUM(f.total_amount),0) AS 'total_revenue',
      COALESCE(SUM(f.quantity_sold),0) AS 'total_quantity_sold',
      COUNT(f.sales_id) AS 'total_orders'
FROM
    dim_product d
LEFT JOIN
        fact_sales f
ON
  d.product_key = f.product_key
GROUP BY 
        d.category
ORDER BY 
        total_revenue DESC;
        





-- QNS 3. Inactive Customers (Customers with Zero Purchases)
-- Scenario / Objective:
--   Find all registered customers who have NEVER placed any order in the sales database.
-- Tables to use:
--   - dim_customer (customer_key, customer_id, first_name, last_name, email)
--   - fact_sales (customer_key)
-- Required columns:
--   - customer_key
--   - customer_id
--   - customer_name
--   - email
-- Conditions:
--   - Use an anti-join (LEFT JOIN ... WHERE ... IS NULL) or NOT EXISTS.


WITH zero_purchase_customers AS
(
SELECT 
      c.customer_key,
      c.customer_id,
      CONCAT(c.first_name, ' ', c.last_name) AS 'customer_name',
      c.email
FROM
      dim_customer c
LEFT JOIN 
      fact_sales f
ON
      c.customer_key = f.customer_key
WHERE
      f.customer_key is NULL
)
SELECT 
      *
FROM 
      zero_purchase_customers;




-- QNS 4. Month-wise Revenue and Average Order Value (AOV)
-- Scenario / Objective:
--   For each month of the year 2025, calculate the total revenue and the Average Order Value (AOV = total revenue / total orders).
-- Tables to use:
--   - fact_sales (sales_id, date_key, total_amount)
--   - dim_date (date_key, year, month, month_name)
-- Required columns:
--   - year
--   - month
--   - month_name
--   - monthly_revenue
--   - average_order_value (rounded to 2 decimal places)
-- Conditions:
--   - Filter only for year = 2025.
--   - Sort chronologically by month.


SELECT 
      d.year,
      d.month,
      d.month_name,
      SUM(f.total_amount) AS 'monthly_revenue',
      ROUND(SUM(f.total_amount) / NULLIF(COUNT(DISTINCT f.sales_id),0),2) AS 'average_order_value'
FROM 
      fact_sales f
LEFT JOIN
      dim_date d
ON 
      f.date_key = d.date_key
WHERE    
      d.year = 2025
GROUP BY
      d.year,
      d.month,
      d.month_name
ORDER BY
      d.month;




-- QNS 5. Remove Duplicate Customer Records using ROW_NUMBER()
-- Scenario / Objective:
--   In a staging table `customer_stg`, multiple rows exist with the same email due to duplicate ingestion.
--   Write a query to fetch only the first record for each email based on the lowest `customer_key`.
-- Table to use:
--   - dim_customer (customer_key, customer_id, first_name, last_name, email, city)
-- Required columns:
--   - customer_key
--   - customer_id
--   - first_name
--   - last_name
--   - email
--   - city
-- Conditions:
--   - Filter so only rank = 1 is returned per email.



WITH dedub AS
(
SELECT 
      customer_key,
      customer_id,
      first_name,
      last_name,
      email,
      city,
      ROW_NUMBER() OVER(PARTITION BY email, customer_key, customer_id, first_name, last_name, city ORDER BY customer_id) AS 'rank_'
FROM
      dim_customer
)
SELECT 
      *
FROM
      dedub
WHERE
      rank_ = 1;





-- QNS 6. Find the 2nd Highest Salary in Each Department
-- Scenario / Objective:
--   From the `employees` table, find the employee(s) who earn the 2nd highest salary in their respective department.
-- Table to use:
--   - employees (emp_id, emp_name, department, salary, city)
-- Required columns:
--   - department
--   - emp_name
--   - salary
--   - salary_rank
-- Conditions:
--   - Use DENSE_RANK() so ties for 1st place do not skip rank 2.


WITH second_highest AS
(
SELECT 
      department, 
      emp_name,
      salary,
      DENSE_RANK() OVER(PARTITION BY department ORDER BY salary DESC) AS 'salary_rank'
FROM
      employees
)
SELECT
      *
FROM
      second_highest
WHERE 
      salary_rank =2;






-- QNS 7. Products Never Sold in a Specific Region
-- Scenario / Objective:
--   Find all products from the product catalog that have NEVER been sold in any store located in the 'North' region.
-- Tables to use:
--   - dim_product (product_key, product_name, category)
--   - fact_sales (product_key, store_key)
--   - dim_store (store_key, region)
-- Required columns:
--   - product_key
--   - product_name
--   - category
-- Conditions:
--   - Must show products where zero sales exist with dim_store.region = 'North'.



SELECT 
      dp.product_key,
      dp.product_name,
      dp.category

FROM
      dim_product dp
WHERE NOT EXISTS(
      SELECT *
      FROM
            fact_sales fa
      LEFT JOIN
            dim_store ds
      ON 
            fa.store_key = ds.store_key
      WHERE 
            fa.product_key = dp.product_key AND ds.region = 'North'
);







-- QNS 8. Weekend vs Weekday Sales Performance Comparison
-- Scenario / Objective:
--   Compare sales performance between weekends and weekdays to help the operations team plan staffing.
-- Tables to use:
--   - fact_sales (sales_id, date_key, quantity_sold, total_amount)
--   - dim_date (date_key, is_weekend)
-- Required columns:
--   - day_type ('Weekend' when is_weekend = 1, else 'Weekday')
--   - total_orders
--   - total_units_sold
--   - total_revenue
--   - avg_revenue_per_order


SELECT 
      CASE 
            WHEN (dd.is_weekend = 1) THEN  'Weekend'
            ELSE  'Weekday'
      END AS 'day_type',
      COUNT(DISTINCT(fa.sales_id)) AS 'total_orders',
      SUM(fa.quantity_sold) AS 'total_units_sold',
      SUM(fa.total_amount) AS 'total_revenue',
      SUM(fa.total_amount) / COUNT(DISTINCT(fa.sales_id)) AS 'avg_revenue_per_order'
FROM
      fact_sales fa 
LEFT JOIN
      dim_date dd
ON 
      fa.date_key = dd.date_key
GROUP BY
            dd.is_weekend;







-- QNS 9. Customer Spending Tier Segmentation (CASE WHEN)
-- Scenario / Objective:
--   Segment all customers into spending tiers based on their total spend across all time:
--     - 'Tier 1 - High': total_spend >= 50,000
--     - 'Tier 2 - Medium': total_spend between 20,000 and 49,999.99
--     - 'Tier 3 - Low': total_spend < 20,000
-- Tables to use:
--   - dim_customer (customer_key, first_name, last_name)
--   - fact_sales (customer_key, total_amount)
-- Required columns:
--   - customer_key
--   - customer_name
--   - total_spent
--   - spending_tier
-- Conditions:
--   - Include customers with 0 purchases in 'Tier 3 - Low'.




SELECT 
      dc.customer_key,
      CONCAT(dc.first_name, ' ', dc.last_name) AS 'customer_name',
      COALESCE(SUM(fa.total_amount),0) AS 'total_spent',
      CASE
            WHEN COALESCE(SUM(fa.total_amount), 0) >= 50000 THEN 'High'
            WHEN COALESCE(SUM(fa.total_amount), 0) >= 20000 THEN 'Medium'
            ELSE 'Low'
      END AS spending_tier
FROM
      dim_customer dc
LEFT JOIN
      fact_sales fa
ON 
     fa.customer_key = dc.customer_key
GROUP BY
dc.customer_key,
dc.first_name,
dc.last_name
ORDER BY
    COALESCE(SUM(fa.total_amount),0) DESC;  






-- QNS 10. Daily Running Total of Revenue per Store
-- Scenario / Objective:
--   Calculate a continuous running total (cumulative sum) of daily revenue for each store ordered by date.
-- Tables to use:
--   - fact_sales (store_key, date_key, total_amount)
--   - dim_date (date_key, date)
--   - dim_store (store_key, store_name)
-- Required columns:
--   - store_name
--   - date
--   - daily_sales
--   - running_total_sales
-- Conditions:
--   - Use SUM() OVER (PARTITION BY ... ORDER BY ...).

WITH daily_sales AS
(
SELECT 
      ds.store_key,
      ds.store_name,
      dd.date,
      SUM(fa.total_amount) AS 'daily_sales'
FROM
      dim_store ds
LEFT JOIN
      fact_sales fa
ON
      ds.store_key = fa.store_key
LEFT JOIN 
      dim_date dd
ON 
      fa.date_key = dd.date_key
GROUP BY
      ds.store_name,
      ds.store_key,
      dd.date
)
SELECT 
      store_name,
      date,
      daily_sales,
      SUM(daily_sales) OVER(PARTITION BY store_key ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS 'running_total_sales' 
FROM 
      daily_sales
ORDER BY
      store_name,
      date;







-- QNS 11. Employees Earning Above Department Average
-- Scenario / Objective:
--   Find all employees whose salary is strictly greater than the average salary of their own department.
-- Table to use:
--   - employees (emp_id, emp_name, department, salary)
-- Required columns:
--   - emp_id
--   - emp_name
--   - department
--   - salary
--   - dept_avg_salary
-- Conditions:
--   - Display how much extra each employee makes above the department average (`salary - dept_avg_salary`).



WITH department_avg_salary AS
(
SELECT 
      emp_id,
      emp_name,
      salary,
      department,
      AVG(salary) OVER(PARTITION BY department) AS 'dept_avg_salary'
FROM
      employees
),
emp_above_dept_avg AS
(
      SELECT
            emp_id,
            emp_name,
            salary,
            department,
            dept_avg_salary,
            (salary - dept_avg_salary) AS 'extra_salary_above_dept_avg'
      FROM 
            department_avg_salary
      WHERE
            salary > dept_avg_salary
)
SELECT * FROM emp_above_dept_avg;







-- QNS 12. Year-over-Year (YoY) Sales Comparison (2024 vs 2025)
-- Scenario / Objective:
--   Display total revenue for each product category side-by-side for the years 2024 and 2025 in separate columns.
-- Tables to use:
--   - fact_sales (product_key, date_key, total_amount)
--   - dim_product (product_key, category)
--   - dim_date (date_key, year)
-- Required columns:
--   - category
--   - sales_2024
--   - sales_2025
--   - yoy_diff (sales_2025 - sales_2024)
-- Conditions:
--   - Use conditional aggregation (SUM(CASE WHEN ...)).




-- QNS 13. Latest Order Details for Each Customer
-- Scenario / Objective:
--   Find the most recent purchase date, product name, and amount spent for each customer.
-- Tables to use:
--   - dim_customer (customer_key, first_name, last_name)
--   - fact_sales (customer_key, product_key, date_key, total_amount)
--   - dim_product (product_key, product_name)
--   - dim_date (date_key, date)
-- Required columns:
--   - customer_key
--   - customer_name
--   - latest_order_date
--   - product_name
--   - total_amount
-- Conditions:
--   - Use ROW_NUMBER() partitioned by customer_key ordered by date descending.




-- QNS 14. Max, Min, and Price Spread per Category
-- Scenario / Objective:
--   For each product category, find the highest unit price, lowest unit price, and the price difference (spread).
-- Table to use:
--   - dim_product (product_id, product_name, category, unit_price)
-- Required columns:
--   - category
--   - min_price
--   - max_price
--   - price_spread (max_price - min_price)
--   - total_products_in_category




-- QNS 15. Clean Dirty Phone Numbers & Filter Valid Length
-- Scenario / Objective:
--   In `dim_customer`, phone numbers contain characters like dashes, spaces, and brackets.
--   Extract only digits and return records that have exactly 10 digits.
-- Table to use:
--   - dim_customer (customer_key, customer_id, phone)
-- Required columns:
--   - customer_key
--   - original_phone
--   - clean_phone (digits only)
--   - digit_count
-- Conditions:
--   - Filter only rows where digit_count = 10.




-- QNS 16. Stores with Above-Average Regional Sales
-- Scenario / Objective:
--   Find all stores whose total revenue is higher than the average revenue of all stores within their region.
-- Tables to use:
--   - dim_store (store_key, store_name, region)
--   - fact_sales (store_key, total_amount)
-- Required columns:
--   - region
--   - store_name
--   - store_revenue
--   - region_avg_store_revenue




-- QNS 17. Find Customers Who Purchased on Two Consecutive Days
-- Scenario / Objective:
--   Find all customers who made a purchase on two consecutive calendar days.
-- Tables to use:
--   - fact_sales (customer_key, date_key)
--   - dim_date (date_key, date)
-- Required columns:
--   - customer_key
--   - first_purchase_date
--   - next_purchase_date
-- Conditions:
--   - Use LAG() or LEAD() to check if DATEDIFF(next_purchase_date, first_purchase_date) = 1.




-- QNS 18. Pivot Quarterly Sales by Store into Columns
-- Scenario / Objective:
--   Display quarterly sales for each store as separate columns (Q1, Q2, Q3, Q4) for the year 2025.
-- Tables to use:
--   - fact_sales (store_key, date_key, total_amount)
--   - dim_store (store_key, store_name)
--   - dim_date (date_key, year, quarter)
-- Required columns:
--   - store_name
--   - q1_sales
--   - q2_sales
--   - q3_sales
--   - q4_sales
--   - annual_total_sales




-- QNS 19. Percentage Contribution of Each Product to its Category Sales
-- Scenario / Objective:
--   Calculate how much percentage each product's sales contribute to the total sales of its category.
-- Tables to use:
--   - dim_product (product_key, product_name, category)
--   - fact_sales (product_key, total_amount)
-- Required columns:
--   - category
--   - product_name
--   - product_sales
--   - category_total_sales
--   - pct_contribution (round to 2 decimals)




-- QNS 20. Find Missing Sequence Numbers in Transaction IDs
-- Scenario / Objective:
--   In `bank_transactions`, transaction IDs are expected to be strictly consecutive.
--   Write a query to detect any gaps where `transaction_id` skips a number.
-- Table to use:
--   - bank_transactions (transaction_id, transaction_date, amount)
-- Required columns:
--   - current_id
--   - next_expected_id
--   - gap_size (next_actual_id - current_id - 1)
-- Conditions:
--   - Filter only rows where a gap exists (gap_size > 0).





-- =================================================================================================
-- LEVEL 2: MEDIUM (QNS 21 TO 40)
-- =================================================================================================

-- QNS 21. Month-over-Month (MoM) Revenue Growth Percentage
-- Scenario / Objective:
--   Calculate total monthly revenue and the percentage growth compared to the previous month.
-- Tables to use:
--   - fact_sales (sales_id, date_key, total_amount)
--   - dim_date (date_key, year, month, month_name)
-- Required columns:
--   - year
--   - month
--   - month_name
--   - current_month_sales
--   - prev_month_sales
--   - mom_growth_pct (e.g., ((current - prev) / prev) * 100)
-- Conditions:
--   - If prev_month_sales is NULL, display 0.00% or 'FIRST MONTH'.




-- QNS 22. Running Account Balance and Overdraft Flagging
-- Scenario / Objective:
--   Calculate the running balance for each bank account after each transaction in chronological order.
--   Flag any transaction that causes the running balance to drop below zero (Overdraft Anomaly).
-- Table to use:
--   - bank_transactions (transaction_id, account_id, transaction_date, transaction_type, amount)
--   Note: 'DEPOSIT' adds to balance, 'WITHDRAWAL' subtracts from balance.
-- Required columns:
--   - transaction_id
--   - account_id
--   - transaction_date
--   - transaction_type
--   - amount
--   - calculated_running_balance
--   - status_flag ('OVERDRAFT' if balance < 0, else 'NORMAL')




-- QNS 23. 7-Day Moving Average of Daily Store Sales
-- Scenario / Objective:
--   Calculate the 7-day moving average of daily sales for each store.
-- Tables to use:
--   - fact_sales (store_key, date_key, total_amount)
--   - dim_date (date_key, date)
--   - dim_store (store_key, store_name)
-- Required columns:
--   - store_name
--   - date
--   - daily_sales
--   - rolling_7day_avg (average of current day and preceding 6 days)




-- QNS 24. Find Stores with 3 Consecutive Days of Increasing Revenue
-- Scenario / Objective:
--   Identify stores where daily sales increased for 3 consecutive days in a row (Day 1 < Day 2 < Day 3).
-- Tables to use:
--   - fact_sales (store_key, date_key, total_amount)
--   - dim_date (date_key, date)
--   - dim_store (store_key, store_name)
-- Required columns:
--   - store_name
--   - day_1_date
--   - day_2_date
--   - day_3_date
--   - day_1_sales
--   - day_2_sales
--   - day_3_sales




-- QNS 25. Employees Earning More than Their Direct Manager (Self-Join)
-- Scenario / Objective:
--   From an employee hierarchy table, find all employees whose salary is higher than their direct manager's salary.
-- Table to use:
--   - employees (emp_id, emp_name, department, salary, manager_id)
-- Required columns:
--   - employee_id
--   - employee_name
--   - employee_salary
--   - manager_name
--   - manager_salary
--   - salary_difference (employee_salary - manager_salary)




-- QNS 26. First and Most Recent Product Purchased per Customer
-- Scenario / Objective:
--   For every customer, display the name of the very first product they purchased and the name of the
--   most recent product they purchased without writing correlated subqueries.
-- Tables to use:
--   - dim_customer (customer_key, first_name, last_name)
--   - fact_sales (customer_key, product_key, date_key)
--   - dim_product (product_key, product_name)
--   - dim_date (date_key, date)
-- Required columns:
--   - customer_key
--   - customer_name
--   - first_product_bought
--   - first_purchase_date
--   - latest_product_bought
--   - latest_purchase_date




-- QNS 27. Web Sessionization with 30-Minute Inactivity Window
-- Scenario / Objective:
--   Group user web browsing clicks into sessions. A new session starts if more than 30 minutes
--   have elapsed since the user's previous click.
-- Table to use:
--   - user_web_clicks (event_id, user_id, click_timestamp, page_url)
-- Required columns:
--   - user_id
--   - event_id
--   - click_timestamp
--   - page_url
--   - session_id (incremental session number: 1, 2, 3... per user)




-- QNS 28. Repeat Buyers within 7 Days of First Purchase
-- Scenario / Objective:
--   Find all customers who placed a second order within 7 days of their first ever order.
-- Tables to use:
--   - fact_sales (sales_id, customer_key, date_key)
--   - dim_date (date_key, date)
--   - dim_customer (customer_key, first_name, last_name, email)
-- Required columns:
--   - customer_key
--   - customer_name
--   - first_order_date
--   - second_order_date
--   - days_between_orders (must be <= 7)




-- QNS 29. Deduplicate CDC Changelog Table (Keep Latest Non-Deleted Record)
-- Scenario / Objective:
--   In a streaming CDC table, updates arrive with `op_type` ('INSERT', 'UPDATE', 'DELETE') and `updated_at`.
--   Write a query to fetch the current active state of every record. If the latest operation was 'DELETE',
--   exclude the entity completely.
-- Table to use:
--   - product_cdc_stream (product_id, product_name, price, op_type, updated_at)
-- Required columns:
--   - product_id
--   - product_name
--   - price
--   - last_updated_at




-- QNS 30. Top 3 Selling Products in Each Category with Dense Rank
-- Scenario / Objective:
--   Find the top 3 selling products (by total revenue) in each category. If there is a tie for 3rd place,
--   include all tied products.
-- Tables to use:
--   - dim_product (product_key, product_name, category)
--   - fact_sales (product_key, total_amount)
-- Required columns:
--   - category
--   - product_name
--   - total_revenue
--   - rank_in_category (1, 2, or 3)




-- QNS 31. Churned Customers Analysis (Purchased in 2024 but Zero in 2025)
-- Scenario / Objective:
--   Find all customers who made 3 or more purchases in 2024, but have made ZERO purchases in the entire year 2025.
-- Tables to use:
--   - dim_customer (customer_key, first_name, last_name, email)
--   - fact_sales (customer_key, date_key)
--   - dim_date (date_key, year)
-- Required columns:
--   - customer_key
--   - customer_name
--   - email
--   - total_orders_2024




-- QNS 32. Market Basket Analysis: Top Co-Purchased Product Pairs
-- Scenario / Objective:
--   Find the top 5 most frequently co-purchased pairs of products that were bought together in the same order (`sales_id` or same basket).
-- Tables to use:
--   - fact_sales (sales_id, product_key)
--   - dim_product (product_key, product_name)
-- Required columns:
--   - product_1_name
--   - product_2_name
--   - times_bought_together
-- Conditions:
--   - Ensure product_1_name < product_2_name so pairs are not counted twice in reverse order.




-- QNS 33. Time Gap Between Consecutive Bank Transactions
-- Scenario / Objective:
--   For each bank account, calculate the time difference (in hours and minutes) between the current transaction
--   and the immediate previous transaction. Flag any transaction occurring within 10 minutes of the previous one.
-- Table to use:
--   - bank_transactions (transaction_id, account_id, transaction_date, amount, city)
-- Required columns:
--   - account_id
--   - transaction_id
--   - transaction_date
--   - prev_transaction_date
--   - minutes_since_last_txn
--   - velocity_flag ('RAPID_TRANSACTION' if minutes <= 10, else 'NORMAL')




-- QNS 34. Customer Cohort Retention (Month 0 to Month 1 Retention)
-- Scenario / Objective:
--   Calculate how many new users placed their first order in January 2025, and what percentage of those
--   same users returned to make another purchase in February 2025.
-- Tables to use:
--   - fact_sales (customer_key, date_key)
--   - dim_date (date_key, year, month)
-- Required columns:
--   - jan_new_users_count
--   - feb_returning_users_count
--   - retention_rate_pct




-- QNS 35. Multi-Step Checkout Funnel Drop-off Analysis
-- Scenario / Objective:
--   Calculate the conversion rate and drop-off rate across a 4-step e-commerce funnel:
--     Step 1: 'view_item' -> Step 2: 'add_to_cart' -> Step 3: 'checkout' -> Step 4: 'purchase'
-- Table to use:
--   - funnel_logs (event_id, user_id, session_id, step_name, event_time)
-- Required columns:
--   - step_name
--   - unique_users_count
--   - conversion_pct_from_step1
--   - drop_off_pct_from_prior_step




-- QNS 36. Inventory Depletion & Stockout Date Forecast
-- Scenario / Objective:
--   Given starting stock on Jan 1st and daily outgoing units sold, compute the remaining balance per day
--   and find the exact date each product first ran out of stock (balance <= 0).
-- Tables to use:
--   - product_inventory (product_key, initial_stock_qty)
--   - fact_sales (product_key, date_key, quantity_sold)
--   - dim_date (date_key, date)
-- Required columns:
--   - product_key
--   - stockout_date
--   - final_depleted_balance




-- QNS 37. Unpivot Monthly Wide Columns into Normalized Rows
-- Scenario / Objective:
--   Convert a wide table `store_sales_wide` into a normalized relational format.
--   Source schema: `store_sales_wide (store_id, year, jan_sales, feb_sales, mar_sales, apr_sales)`
-- Required columns:
--   - store_id
--   - year
--   - month_name ('Jan', 'Feb', 'Mar', 'Apr')
--   - sales_amount
-- Conditions:
--   - Use UNION ALL or CROSS JOIN with CASE statements.




-- QNS 38. Overlapping Booking / Subscription Intervals
-- Scenario / Objective:
--   A hotel booking system needs to detect double-booking errors where the same room was booked
--   for overlapping date ranges.
-- Table to use:
--   - hotel_bookings (booking_id, room_id, guest_name, check_in_date, check_out_date)
-- Required columns:
--   - room_id
--   - booking_id_1
--   - guest_1
--   - booking_id_2
--   - guest_2
--   - overlap_start_date
--   - overlap_end_date




-- QNS 39. Median Salary per Department Without Built-in MEDIAN()
-- Scenario / Objective:
--   Calculate the 50th percentile (median) salary for each department in `employees` without using MEDIAN().
-- Table to use:
--   - employees (emp_id, emp_name, department, salary)
-- Required columns:
--   - department
--   - median_salary
-- Conditions:
--   - Use ROW_NUMBER() or PERCENT_RANK() to find the middle salary value.




-- QNS 40. Source vs Target Data Warehouse Reconciliation
-- Scenario / Objective:
--   Compare an operational staging table `stg_orders` with the data warehouse table `dw_fact_orders`
--   to identify missing rows or mismatched amount fields.
-- Tables to use:
--   - stg_orders (order_id, customer_id, order_amount, order_status)
--   - dw_fact_orders (order_id, customer_id, order_amount, order_status)
-- Required columns:
--   - order_id
--   - status ('MISSING_IN_DW', 'MISSING_IN_STAGING', 'AMOUNT_MISMATCH', 'STATUS_MISMATCH')
--   - stg_amount
--   - dw_amount





-- =================================================================================================
-- LEVEL 3: HARD (QNS 41 TO 60)
-- =================================================================================================

-- QNS 41. Longest Consecutive Daily Login Streak (Classic Gaps & Islands)
-- Scenario / Objective:
--   Given daily user login events, calculate the length of the longest consecutive active login streak
--   (in days) for every user.
-- Table to use:
--   - user_logins (user_id, login_date) -- Multiple logins may occur on same day
-- Required columns:
--   - user_id
--   - longest_streak_days
--   - streak_start_date
--   - streak_end_date
-- Conditions:
--   - Must use the Gaps and Islands pattern (e.g. `login_date - ROW_NUMBER()`).




-- QNS 42. Continuous State Duration & Island Merging
-- Scenario / Objective:
--   A server health-check logger pings machines. Merge consecutive contiguous rows with the same status
--   into a single interval showing when the state started, when it ended, and total duration in minutes.
-- Table to use:
--   - server_status_logs (server_id, log_time, status) -- status is 'HEALTHY' or 'DOWN'
-- Required columns:
--   - server_id
--   - status
--   - status_start_time
--   - status_end_time
--   - total_duration_minutes




-- QNS 43. Recursive Organizational Hierarchy & Total Subordinate Salary Budget
-- Scenario / Objective:
--   Using a Recursive CTE, calculate the total cumulative salary budget managed by every manager.
--   This includes the manager's own salary plus all direct reports and all indirect reports down the entire tree.
-- Table to use:
--   - employees (emp_id, emp_name, manager_id, salary)
-- Required columns:
--   - manager_id
--   - manager_name
--   - hierarchy_level
--   - total_team_headcount
--   - total_managed_budget




-- QNS 44. Recursive Bill of Materials (BOM) Parts Explosion
-- Scenario / Objective:
--   In manufacturing, a finished product is composed of sub-assemblies, which in turn require base raw parts.
--   Recursively explode the parts hierarchy to find the total quantity of each base raw part required
--   to manufacture 1 unit of a finished product (`parent_part = 'AUTOMOBILE'`).
-- Table to use:
--   - bom_parts (parent_part, child_part, quantity_per_parent)
-- Required columns:
--   - final_product
--   - base_part
--   - total_units_required




-- QNS 45. Shortest Flight Route between Two Hubs (Graph Traversal with Recursive CTE)
-- Scenario / Objective:
--   Find the shortest flight route (lowest total flight duration in hours) between 'MUMBAI' and 'LONDON'
--   allowing up to 3 intermediate stops. Prevent infinite loops by ensuring no city is visited twice.
-- Table to use:
--   - flight_routes (origin_city, destination_city, flight_duration_hours, ticket_cost)
-- Required columns:
--   - origin_city
--   - destination_city
--   - total_stops
--   - route_path (e.g., 'MUMBAI -> DUBAI -> LONDON')
--   - total_flight_hours
--   - total_cost




-- QNS 46. Slowly Changing Dimension Type 2 (SCD2) Timeline Generation
-- Scenario / Objective:
--   Transform a raw customer address change audit log into a production SCD Type 2 dimension table
--   containing `valid_from`, `valid_to`, and an `is_current` flag.
-- Table to use:
--   - customer_address_history (customer_id, address, city, changed_at)
-- Required columns:
--   - customer_id
--   - address
--   - city
--   - valid_from
--   - valid_to (set to '9999-12-31 23:59:59' for currently active address)
--   - is_current (1 for active, 0 for historical)




-- QNS 47. Complete Calendar Date Scaffolding with 0-Sales Fill
-- Scenario / Objective:
--   Sales data only records days when a purchase occurs. Build a continuous 365-day dataset for 2025
--   for every store, filling missing sales with 0, and compute an accurate 30-day calendar rolling revenue.
-- Tables to use:
--   - dim_store (store_key, store_name)
--   - dim_date (date_key, date, year) -- Contains all 365 dates
--   - fact_sales (store_key, date_key, total_amount)
-- Required columns:
--   - store_name
--   - date
--   - daily_revenue (0 if no sales)
--   - true_30day_rolling_revenue




-- QNS 48. Financial Point-in-Time "As-Of" Join (Trades to Prevailing Quotes)
-- Scenario / Objective:
--   In stock trading, trade executions must be matched with the latest quote (bid/ask) that was
--   effective immediately on or before the trade timestamp.
-- Tables to use:
--   - stock_trades (trade_id, ticker, trade_time, execution_price, volume)
--   - stock_quotes (quote_id, ticker, quote_time, bid_price, ask_price)
-- Required columns:
--   - trade_id
--   - ticker
--   - trade_time
--   - execution_price
--   - prevailing_bid
--   - prevailing_ask
--   - quote_time




-- QNS 49. Forward-Fill (Last Observation Carried Forward - LOCF)
-- Scenario / Objective:
--   In IoT telemetry logs, sensor lag results in NULL temperature readings at some timestamps.
--   Impute each NULL by carrying forward the most recent non-null temperature recorded by that sensor.
-- Table to use:
--   - sensor_readings (sensor_id, reading_time, temperature)
-- Required columns:
--   - sensor_id
--   - reading_time
--   - raw_temperature
--   - forward_filled_temperature




-- QNS 50. Merge Overlapping or Contiguous Outage Time Windows
-- Scenario / Objective:
--   A cloud infrastructure logger records service outage intervals. Multiple overlapping incidents
--   can occur simultaneously. Merge overlapping or contiguous outages into unified periods.
-- Table to use:
--   - service_outages (service_id, outage_start, outage_end)
-- Required columns:
--   - service_id
--   - merged_outage_start
--   - merged_outage_end
--   - total_uninterrupted_downtime_minutes




-- QNS 51. Real-Time Rolling 60-Minute Velocity Window per Card
-- Scenario / Objective:
--   For credit card fraud detection, calculate for EACH transaction the count and total dollar volume
--   of transactions made on that card in the preceding 60 minutes relative to the transaction's exact timestamp.
-- Table to use:
--   - card_transactions (txn_id, card_id, txn_time, txn_amount)
-- Required columns:
--   - txn_id
--   - card_id
--   - txn_time
--   - txn_amount
--   - txns_in_last_60min
--   - total_amount_in_last_60min




-- QNS 52. Hierarchical Category Revenue Rollup across All Depths
-- Scenario / Objective:
--   Given a product taxonomy tree with subcategories nested to arbitrary depths, compute the total rolled-up
--   revenue for EVERY category including all of its child, grandchild, and descendant subcategories.
-- Tables to use:
--   - categories (category_id, category_name, parent_category_id)
--   - fact_sales (product_key, total_amount)
--   - dim_product (product_key, category_id)
-- Required columns:
--   - category_id
--   - category_name
--   - direct_sales
--   - total_rolled_up_subtree_sales




-- QNS 53. Multi-Touch Attribution: First-Touch and Last-Touch Marketing Channels
-- Scenario / Objective:
--   Determine which marketing channel was the 'First-Touch' (earliest interaction) and which was the
--   'Last-Touch' (most recent interaction before purchase) for each customer's first completed order.
-- Tables to use:
--   - marketing_clicks (click_id, customer_id, channel, click_time)
--   - fact_sales (sales_id, customer_key, date_key)
--   - dim_date (date_key, date)
-- Required columns:
--   - customer_id
--   - first_touch_channel
--   - last_touch_channel
--   - days_from_first_touch_to_purchase




-- QNS 54. Anomaly Detection: Flag Spikes Using 30-Day Rolling Z-Score
-- Scenario / Objective:
--   Detect fraudulent or anomalous spending spikes by calculating the 30-day rolling average and
--   rolling standard deviation of transaction amounts for each account. Flag transactions where Z-Score >= 3.0.
-- Table to use:
--   - bank_transactions (transaction_id, account_id, transaction_date, amount)
-- Required columns:
--   - account_id
--   - transaction_id
--   - transaction_date
--   - amount
--   - rolling_30day_avg
--   - rolling_30day_stddev
--   - z_score
--   - is_anomaly_flag (1 if z_score >= 3.0, else 0)




-- QNS 55. Cross-Device Session Stitching (Anonymous to Authenticated ID Resolution)
-- Scenario / Objective:
--   A user browses products on a mobile device anonymously (`anonymous_id`). After 20 minutes, they log in,
--   revealing their `user_id`. Write a query to stitch all pre-login anonymous events to the authenticated `user_id`.
-- Table to use:
--   - clickstream (event_id, anonymous_id, user_id, event_time, page_name)
-- Required columns:
--   - event_id
--   - event_time
--   - page_name
--   - original_anonymous_id
--   - resolved_user_id




-- QNS 56. Social Network Triadic Closure (Mutual Friend Triangles)
-- Scenario / Objective:
--   Find all unique triangles of mutual friends in a social network: User A is friends with User B,
--   User B is friends with User C, and User C is friends with User A.
-- Table to use:
--   - friendships (user_id_1, user_id_2) -- Assume user_id_1 < user_id_2
-- Required columns:
--   - user_a
--   - user_b
--   - user_c
-- Conditions:
--   - Display each triangle only once (user_a < user_b < user_c).




-- QNS 57. CDC Deduplication with Vector Sequence / Log Sequence Numbers (LSN)
-- Scenario / Objective:
--   In a distributed database where clocks drift, records arrive with a Log Sequence Number (`lsn`)
--   and transaction ID (`txn_seq`). Discard stale updates and output the true final state of each record.
-- Table to use:
--   - account_cdc_events (account_id, balance, lsn, txn_seq, event_type, created_at)
-- Required columns:
--   - account_id
--   - current_balance
--   - highest_lsn
--   - latest_txn_seq




-- QNS 58. Maximum Rolling Peak-to-Trough Drawdown
-- Scenario / Objective:
--   In an investment portfolio daily balance log, calculate the Maximum Drawdown (largest percentage drop
--   from an all-time peak achieved prior to or on that date).
-- Table to use:
--   - portfolio_history (portfolio_id, valuation_date, portfolio_value)
-- Required columns:
--   - portfolio_id
--   - valuation_date
--   - portfolio_value
--   - historical_peak_value
--   - current_drawdown_pct
--   - max_drawdown_so_far_pct




-- QNS 59. Customer Lifecycle State Machine & Duration per State
-- Scenario / Objective:
--   A customer transitions between states: 'ACTIVE', 'DORMANT', 'CHURNED', 'REACTIVATED'.
--   Calculate the exact duration (in days) the customer remained in each state before transitioning to the next.
-- Table to use:
--   - customer_status_log (customer_id, status, status_change_date)
-- Required columns:
--   - customer_id
--   - status
--   - state_start_date
--   - state_end_date
--   - days_in_state




-- QNS 60. Parse & Explode Nested JSON Array Elements into Rows
-- Scenario / Objective:
--   An order webhook delivers line items as a JSON array string:
--     `{"order_id": 101, "items": [{"sku": "A1", "qty": 2, "price": 10}, {"sku": "B2", "qty": 1, "price": 50}]}`
--   Write a query to parse and explode each item from the array into its own row with order ID attached.
-- Table to use:
--   - raw_webhooks (webhook_id, payload_json)
-- Required columns:
--   - order_id
--   - item_sku
--   - item_quantity
--   - item_price
--   - line_total (item_quantity * item_price)









-- =================================================================================================
-- END OF QUESTION BANK (QNS 01 TO 60)
-- =================================================================================================
