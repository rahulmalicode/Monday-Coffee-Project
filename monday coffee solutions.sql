-- MONDAY COFFEE -- DATA ANALYSIS 

SELECT * FROM city;
SELECT * FROM products;
SELECT * FROM customers;
SELECT * FROM sales;

-- Reports and Data Analysis 
-- Q1 Coffee Consumers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?

SELECT 
city_name,
ROUND((population*0.25)/1000000,2) as coffee_people_in_millions,
city_rank
 FROM city 
ORDER BY population DESC;

-- Q2
-- Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in last qtr of 2023

select COUNT(*) from sales;

 select 
 SUM(total) as total_revenue 
 FROM sales
 WHERE 
 EXTRACT(YEAR FROM sale_date) = 2023
 AND 
 EXTRACT(quarter FROM sale_date) = 4;
 
 select 
 ci.city_name,
 SUM(s.total) as total_revenue 
 FROM sales as s
 JOIN customers as c
 on s.customer_id = c.customer_id
 JOIN city as ci
 on ci.city_id = c.city_id
 WHERE 
 EXTRACT(YEAR FROM sale_date) = 2023
 AND 
 EXTRACT(quarter FROM sale_date) = 4
 GROUP BY city_name
ORDER by total_revenue DESC ;
 
-- Q3 Sales Count Each Product
-- How many units of each coffee product have been sold?

select 
 p.product_name,
 count(s.sale_id) as total_orders
from products as p
LEFT JOIN 
sales as s
ON s.product_id = p.product_id
GROUP BY product_name
ORDER BY total_orders DESC; 

-- Q4
-- Average Sales Amount per city
-- What is the average sales amount per customer in each city?

select * from city ;
select * from customers;
select * from sales; 

SELECT ci.city_name,
 SUM(s.total) as total_revenue ,
 COUNT(DISTINCT s.customer_id) as total_cx,
 ROUND( SUM(s.total) /COUNT(DISTINCT s.customer_id),2) as avg_sale_pr_cx
FROM sales as s
JOIN customers as c
ON s.customer_id=c.customer_id
JOIN city as ci
on ci.city_id = c.city_id 
GROUP BY city_name
ORDER BY total_revenue DESC;

-- Q5
-- City Population and Coffee Consumers (25%)
-- Provide a list of cities along with their polulations and estimated coffee consumers.
-- return city_name , total current cx , estimated coffee consumers(25%)

select * from city;
select * from customers;
select * from sales;

WITH city_table as(
select city_name ,
ROUND((population*0.25/1000000),2) as coffee_consumers_in_millions
from city
),
customers_table
AS(
select ci.city_name,
COUNT(DISTINCT c.customer_id) as unique_cx
FROM sales as s
JOIN customers as c
ON c.customer_id = s.customer_id
JOIN city as ci
on ci.city_id=c.city_id
GROUP BY city_name
)
 
 SELECT 
  customers_table.city_name,
  city_table.coffee_consumers_in_millions,
  customers_table.unique_cx
  FROM city_table
  JOIN customers_table
  on city_table.city_name=customers_table.city_name
  
  -- Q6 
  -- Top Selling Products by City
  -- What are the top 3 selling products in each city based on sale volume?
  

 select 
 ci.city_name ,
 p.product_name,
 COUNT(s.sale_id) as total_orders,
 DENSE_RANK() OVER(PARTITION BY ci.city_name ORDER BY COUNT(s.sale_id) DESC)  
 from sales as s
 JOIN products as p
 on s.product_id = p.product_id 
JOIN customers as c
on c.customer_id = s.customer_id
JOIN city as ci
on ci.city_id = c.city_id
 GROUP BY city_name , product_name
 -- ORDER BY city_name , total_order DESC ;
 
 
-- Q7
-- Customer segmentation by city
-- How many unique customers are there in each city who have purchased coffee products?
 
 SELECT ci.city_name ,
 COUNT(DISTINCT c.customer_id) as unique_cx 
  FROM city as ci
  JOIN customers as c
  ON ci.city_id = c.city_id
  JOIN sales as s 
  ON c.customer_id = s.customer_id
  where s.product_id in (1,2,3,4,5,6,7,8,9,10,11,12,13,14)
  group by city_name;  
 
 -- Q8
 -- Average Sale vs Rent
 -- Find each city and their average sale per customer and avg rent per customer 

 select * from customers;
 select * from city;
 select * from sales ;
 select * from products;
 
WITH city_table AS (
    SELECT
        ci.city_name,
        SUM(s.total) AS total_revenue,
        COUNT(DISTINCT s.customer_id) AS total_cx,
        ROUND(
            SUM(s.total) /
            COUNT(DISTINCT s.customer_id), 2
        ) AS avg_sale_pr_cx
    FROM sales s
    JOIN customers c
        ON s.customer_id = c.customer_id
    JOIN city ci
        ON ci.city_id = c.city_id
    GROUP BY ci.city_name
),

city_rent AS (
    SELECT
        city_name,
        estimated_rent
    FROM city
)

SELECT
    cr.city_name,
    cr.estimated_rent,
    ct.total_cx,
    ct.avg_sale_pr_cx,
    ROUND(cr.estimated_rent / ct.total_cx, 2) AS avg_rent_per_cx
FROM city_rent cr
JOIN city_table ct
    ON cr.city_name = ct.city_name;
 
             
             
 -- Q9 
 -- Monthly Sales Growth
 -- Sales growth rate: Calculate the % growth (or decline) in sales over the different time period (monthly)
 -- in each city
 
 WITH 
   monthly_sales
   as(
 SELECT
    ci.city_name,
    EXTRACT(MONTH FROM s.sale_date) AS month,
    EXTRACT(YEAR FROM s.sale_date) AS year,
    SUM(s.total) AS total_sale
FROM sales s
JOIN customers c
    ON s.customer_id = c.customer_id
JOIN city ci
    ON ci.city_id = c.city_id
GROUP BY ci.city_name,
         EXTRACT(YEAR FROM s.sale_date),
         EXTRACT(MONTH FROM s.sale_date)
ORDER BY ci.city_name, year, month
),
 growth_ratio
 AS (
  SELECT  
	city_name,
    month,
    year,
    total_sale as cr_month_sale , 
    LAG (total_sale) OVER (PARTITION BY city_name ORDER BY year , month) as last_month_sale
    FROM monthly_sales
    )
    SELECT
     city_name,
     month,
     year,
     cr_month_sale,
     last_month_sale,
     ROUND ( 
     (cr_month_sale - last_month_sale)/last_month_sale * 100 , 2) as growth_ratio
 from growth_ratio
 where last_month_sale is not null;
 
 
-- Q.10
-- Market Potential Analysis
-- Identify top 3 city based on highest sales , return city name, total sale ,total rent, total customers, estimated coffee consumer 

WITH city_table AS (
    SELECT
        ci.city_name,
        SUM(s.total) AS total_revenue,
        COUNT(DISTINCT s.customer_id) AS total_cx,
        ROUND(
            SUM(s.total) /
            COUNT(DISTINCT s.customer_id), 2
        ) AS avg_sale_pr_cx
    FROM sales s
    JOIN customers c
        ON s.customer_id = c.customer_id
    JOIN city ci
        ON ci.city_id = c.city_id
    GROUP BY ci.city_name
),

city_rent AS (
    SELECT
        city_name,
        estimated_rent,
       ROUND( (population *0.25)/1000000 ,2) as estimated_coffee_consumer_in_millions
    FROM city
)

SELECT
    cr.city_name,
    total_revenue,
    cr.estimated_rent as total_rent ,
    ct.total_cx,
    estimated_coffee_consumer_in_millions,
    ct.avg_sale_pr_cx,
    ROUND(cr.estimated_rent / ct.total_cx, 2) AS avg_rent_per_cx
FROM city_rent cr
JOIN city_table ct
    ON cr.city_name = ct.city_name
    ORDER BY total_revenue DESC;
 /*
 -- Recommendation
 City 1: Pune
	1. Avg rent per cx is very less
	2. highest total revenue
	3. avg sale per cx is also high
 
 City 2: Delhi
	 1. Highest estimated coffee consumer is 7.7M
	 2. Highest total cx which is 68
     3. avg rent per cx 300 (under 500)
     
City 3: Jaipur
	1. Highest cx no which is 69
    2. avg rent is very less 156
    3. avg sale per cx is better which is 11.6k
 