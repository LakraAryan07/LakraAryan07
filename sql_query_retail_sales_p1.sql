---CREATING THE TABLE
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales
(
    transactions_id INT PRIMARY KEY,
    sale_date DATE,	
    sale_time TIME,
    customer_id INT,	
    gender VARCHAR(10),
    age INT,
    category VARCHAR(35),
    quantity INT,
    price_per_unit FLOAT,	
    cogs FLOAT,
    total_sale FLOAT
);



---DATA EXPLORATION AND CLEANING

SELECT COUNT(*) FROM retail_sales;
SELECT * FROM retail_sales
LIMIT 100;

------
SELECT * FROM retail_sales
WHERE transactions_id IS NULL;

SELECT * FROM retail_sales
WHERE sale_date IS NULL;

SELECT * FROM retail_sales
WHERE sale_time IS NULL;

SELECT * FROM retail_sales
WHERE 
	transactions_id IS NULL
	OR
	sale_date IS NULL
	OR
	sale_time IS NULL
	OR
	customer_id IS NULL
	OR
	gender IS NULL
	OR
	category IS NULL
	OR
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL;

-- deleting these null values as they don`t have any information
DELETE FROM retail_sales
WHERE 
	transactions_id IS NULL
	OR
	sale_date IS NULL
	OR
	sale_time IS NULL
	OR
	customer_id IS NULL
	OR
	gender IS NULL
	OR
	category IS NULL
	OR
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL;
SELECT COUNT(*) FROM retail_sales;

--DATA EXPLORATION
--HOW MANY SALES WE HAVE 
SELECT COUNT(*) as total_sale FROM retail_sales;
-- how many UNIQUE customers we have 
SELECT COUNT(DISTINCT(customer_id)) as total_customers FROM retail_sales;

--CATEGORIES WE HAVE
SELECT DISTINCT category from retail_sales;

---DATA ANALYSIS & BUSINESS KEY PROBLEMS

--1)SQL QUERY TO RETRIEVE ALL SALES OF A SPECIFIC DATE LET 2022-11-05

SELECT * FROM retail_sales
WHERE sale_date='2022-11-05';

--2) SQL QUERY TO RETRIEVE ALL TRANSACTIONS WHERE THE CATEGORY IS 'CLOTHING' AND THE QTY SOLD IS MORE THAN OR EQUAL TO 4 IN THE MONTN OF NOV-2022
SELECT * FROM retail_sales
WHERE category ='Clothing'
AND
TO_CHAR(sale_date, 'YYYY-MM')='2022-11'
AND
quantity >=4;

--3) sql query TO CALCULATE THE TOTAL SALES FOR EACH CATEGORY

SELECT category, SUM(total_sale) as net_sales, COUNT(*) as total_orders FROM retail_sales
GROUP BY 1;

--4) SQL QUERY TO FIND THE AVERAGE AGE OF CUSTOMER WHO PURCHASED ITEMS FROM THE BEAUTY CATEGORY
SELECT category, ROUND(AVG(age),2) as AVERAGE_AGE from retail_sales
WHERE category='Beauty'
GROUP BY 1;

--5)TRANSACTIONS WHERE TOTAL SALES IS MORE THAN 1000
SELECT * FROM retail_sales
WHERE total_sale>1000;

--6) total number of transactions made by each gender in each category
SELECT category,gender,COUNT(*) as total_trans
FROM retail_sales
group by 1, 2
ORDER BY 1;

--7) BEST SELLING MONTH FOR EACH YEAR -------------------
SELECT year, month, AVG_sale FROM(           --creating a sub-query
SELECT 
	EXTRACT(YEAR FROM sale_date) as year,
	EXTRACT(MONTH FROM sale_date) as month,
	AVG(total_sale) as AVG_sale,
	RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) AS rank
FROM retail_sales
GROUP BY 1,2) as tb1
WHERE rank =1;

-- 8) top 5 customers based on the total sales 
SELECT customer_id, SUM(total_sale) as total_sales FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

--9)NUMBER OF UNIQUE CUSTOMERS WHO PURCHASED ITEMS FROM EACH CATEGORY 

SELECT category, COUNT(DISTINCT(customer_id)) AS unique_cust FROM retail_sales
GROUP BY 1;

--10) write a sql query to create each shift and number of orders (example MORNING <=12, AFTERNOON BETWEEN 12 & 17, EVENING>17)
WITH HOURLY_SALES AS (
		SELECT *,
			CASE 
				WHEN EXTRACT(HOUR FROM sale_time)<12 THEN 'Morning'
				WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'  --using between to include both 12 and 17 as well
				ELSE 'evening'
			END as shift
		FROM retail_sales)
SELECT shift, COUNT(*) as Total_orders FROM HOURLY_SALES
GROUP BY shift;

--11) PROFIT ANALYSYS--
SELECT category,
       SUM(total_sale - cogs) AS profit
FROM retail_sales
GROUP BY category;

--12) repeat vs new customers
SELECT
  CASE
    WHEN COUNT(*) = 1 THEN 'New'
    ELSE 'Repeat'
  END AS customer_type,
  COUNT(*) AS customers
FROM (
    SELECT customer_id, COUNT(*) 
    FROM retail_sales
    GROUP BY customer_id
) t
GROUP BY customer_type;


--13)peak hours by order
SELECT EXTRACT(HOUR FROM sale_time) AS hour,
       COUNT(*) AS orders
FROM retail_sales
GROUP BY hour
ORDER BY orders DESC;


---END OF PROJECT---

