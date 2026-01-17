
-- Bussiness Questions
/* Q.1 Find the number of stores in each country.
*/
SELECT count(*)
FROM stores;

/* Q.2 Calculate the total number of units sold by each store.
*/
SELECT sal.store_id, count(p.product_id), sum(sal.quantity*p.price) AS total_sales
FROM sales AS sal
JOIN products AS p ON sal.product_id=p.product_id
GROUP BY 1
ORDER BY total_sales DESC;


/* Q.3 Identify how many sales occurred in december 2023.
*/
SELECT sum(sal.quantity*p.price) AS sales_dec2023
FROM sales AS sal
JOIN products AS p ON p.product_id=sal.product_id
WHERE TO_CHAR(sale_date, 'YYYY-MM')='2023-12';
--or
SELECT sum(sal.quantity*p.price) AS sales_dec2023
FROM sales AS sal
JOIN products AS p ON p.product_id=sal.product_id
WHERE EXTRACT(YEAR FROM sale_date)=2023 AND EXTRACT(MONTH FROM sale_date)=12;

/* Q.4 Determine how many stores have never had a warranty claim filed
*/
SELECT DISTINCT sal.store_id
FROM sales As sal
RIGHT JOIN stores As s ON sal.store_id=s.store_id
WHERE sal.sale_id NOT IN (SELECT sal.sale_id FROM warranty);

--or
SELECT * FROM stores
WHERE store_id NOT IN (
	SELECT DISTINCT store_id FROM sales AS s
	RIGHT JOIN warranty AS w ON s.sale_id=w.sale_id);



/* Q.5 Calculate the percentage of warranty claims marked as 'Completed'.
*/
SELECT 100*(count(repair_status) FILTER (WHERE repair_status='Completed'))/count(claim_id) AS percent_complete_claims
FROM warranty;

--or
SELECT 100*(sum(CASE WHEN repair_status='Completed' THEN 1 ELSE 0 END))/count(*) AS percent_complete_claims
FROM warranty;

--or
SELECT 100*count(*)/(SELECT count(*) FROM warranty) AS percent_complete_claims
FROM warranty
WHERE repair_status='Completed';


/* Q.6 Identify which store had the highest total units sold in the last year (e.g 2023).
*/
SELECT sal.store_id, s.store_name, sum(sal.quantity) AS total_qty_sold
FROM sales AS sal
JOIN stores AS s ON sal.store_id=s.store_id
WHERE EXTRACT(YEAR FROM sale_date)=2023
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 1;


/* Q.7 Count the number of unique products sold in the last year (e.g 2023).
*/
SELECT count(DISTINCT sal.product_id) AS products_sold2023
FROM sales AS sal
JOIN products AS p on p.product_id=sal.product_id
WHERE TO_CHAR(sal.sale_date, 'YYYY')='2023';


/* Q.8 Find the average price of products in each category.
*/
SELECT c.category_id, ROUND(avg(p.price),2) AS avg_price
FROM products AS p
JOIN category AS c ON c.category_id=p.category_id
GROUP BY 1
ORDER BY 2 DESC;


/* Q.9 How many warranty claims were filed in each month 2024?
*/
SELECT TO_CHAR(claim_date, 'FMMonth') AS month, count(claim_id) AS total_claims
FROM warranty 
WHERE EXTRACT(YEAR FROM claim_date)=2024
GROUP BY 1
ORDER BY 2 DESC; 


/* Q.10 For each store, identify the best-selling day based on highest quantity sold.
*/
WITH store_ranking AS (SELECT s.store_id, s.store_name, TO_CHAR(sal.sale_date, 'FMDay') AS day, 
			sum(sal.quantity) AS total_qty_sold, 
         	DENSE_RANK() OVER (PARTITION BY s.store_name ORDER BY sum(sal.quantity) DESC) AS ranking
			FROM sales AS sal
			JOIN stores AS s ON s.store_id=sal.store_id
			GROUP BY 1, 2, 3)
SELECT * 
FROM store_ranking
WHERE ranking=1;


/* Q.11 Identify the least selling product in each country for each year based on total units sold.
*/
WITH sales_ranking AS (SELECT s.country, EXTRACT(YEAR FROM sal.sale_date) As year, p.product_name,
		sum(sal.quantity) AS total_quantity,
		DENSE_RANK() OVER(PARTITION BY s.country, EXTRACT(YEAR FROM sal.sale_date) ORDER BY sum(sal.quantity))
		AS sale_ranking
FROM sales AS sal
JOIN products AS p ON p.product_id=sal.product_id
JOIN stores AS s ON s.store_id=sal.store_id
GROUP BY 1, 2, 3)
SELECT *
FROM sales_ranking
WHERE sale_ranking=1;

--or



/* Q.12 Calculate how many warranty claims were filed within 180 days of a product sale.
*/
SELECT count(DISTINCT w.claim_id) AS total_claims
FROM warranty AS w
JOIN sales AS sal ON w.sale_id=sal.sale_id
WHERE w.claim_date <= sal.sale_date+ INTERVAL '180 DAYS';


/* Q.13 Determine how many warranty claims were filed for products launched in the last two years.
*/
SELECT count(DISTINCT w.claim_id) AS total_claims 
FROM warranty AS w
JOIN sales AS sal ON w.sale_id=sal.sale_id
JOIN products AS p ON sal.product_id=p.product_id
WHERE lauch_date > CURRENT_DATE - INTERVAL '2 YEARS';


/* Q.14 List the months in the last three years where sales exceeded 5,000 units in the United States.
*/
SELECT DATE_TRUNC('MONTH', sal.sale_date)::DATE AS year_month,  sum(sal.quantity) AS quantity
FROM sales AS sal
JOIN stores AS s ON s.store_id=sal.store_id
WHERE 
	sal.sale_date > CURRENT_DATE - INTERVAL '3 YEAR' 
	AND s.country='United States'
GROUP BY DATE_TRUNC('MONTH', sal.sale_date)::DATE
HAVING sum(sal.quantity) > 5000
ORDER BY 1 DESC;


/* Q.15 Identify the product category with the most warranty claims filed in the last two years
*/
SELECT p.category_id, c.category_name, count(w.claim_id) AS total_claims
FROM sales AS sal
JOIN warranty AS w ON sal.sale_id=w.sale_id
JOIN products AS p ON p.product_id=p.product_id
JOIN category AS c ON c.category_id=p.category_id
WHERE w.claim_date > CURRENT_DATE - INTERVAL '2 YEAR'
GROUP BY 1, 2
ORDER BY total_claims DESC
LIMIT 5;



/* Q.16 Analyze the year-by-year growth ratio for each store.
*/
WITH sales_by_years AS (SELECT s.store_id, s.store_name,
		sum(CASE WHEN EXTRACT(YEAR FROM sal.sale_date)=2020 THEN sal.quantity*p.price ELSE 0 END) AS sales_2020,
		sum(CASE WHEN EXTRACT(YEAR FROM sal.sale_date)=2021 THEN sal.quantity*p.price ELSE 0 END) AS sales_2021,
		sum(CASE WHEN EXTRACT(YEAR FROM sal.sale_date)=2022 THEN sal.quantity*p.price ELSE 0 END) AS sales_2022,
		sum(CASE WHEN EXTRACT(YEAR FROM sal.sale_date)=2023 THEN sal.quantity*p.price ELSE 0 END) AS sales_2023,
		sum(CASE WHEN EXTRACT(YEAR FROM sal.sale_date)=2024 THEN sal.quantity*p.price ELSE 0 END) AS sales_2024
FROM stores AS s
JOIN sales AS sal ON sal.store_id=s.store_id
JOIN products AS p ON sal.product_id=p.product_id
GROUP BY 1, 2)
SELECT store_name, ROUND(100*(sales_2021-sales_2020)/sales_2020, 2) AS GR_20_21,
					ROUND(100*(sales_2022-sales_2021)/sales_2021, 2) AS GR_21_22,
					ROUND(100*(sales_2023-sales_2022)/sales_2022, 2) AS GR_22_23,
					ROUND(100*(sales_2024-sales_2023)/sales_2023, 2) AS GR_23_24
FROM sales_by_years;



/* Q.17 Calculate the correlation between product price and warranty claims for products sold in the last 
five years, segmented by price range.
*/
WITH price_segmentation AS (SELECT  w.claim_id, 
	CASE WHEN p.price < 500 THEN 'Cheap Product'
		WHEN p.price < 1000 THEN 'Mid Rang Product'
		ELSE 'Expensive' END AS price_category
FROM products AS p
JOIN sales AS sal ON p.product_id=sal.product_id
JOIN warranty AS w ON sal.sale_id=w.sale_id
WHERE sal.sale_date < CURRENT_DATE -INTERVAL '5 YEARS') 
SELECT price_category, count(claim_id) AS total_claims
FROM price_segmentation
GROUP BY price_category; 


/* Q.18 Write a query to calculate the monthly running total of sales for each store over the 
past four years and compare trends during this period
*/
WITH stores_sales4y AS (SELECT s.store_id, EXTRACT(YEAR FROM sal.sale_date) AS year, 
				TO_CHAR(sal.sale_date, 'FMMonth') AS month,
				sum(p.price*sal.quantity) AS total_sales 
FROM stores AS s
JOIN sales AS sal ON s.store_id=sal.store_id
JOIN products AS p ON sal.product_id=p.product_id
WHERE sal.sale_date < CURRENT_DATE -INTERVAL '4 YEARS'
GROUP BY 1, 2, 3)
SELECT store_id, year, month, total_sales, 
	SUM(total_sales) OVER(PARTITION BY store_id ORDER BY year, EXTRACT(MONTH FROM TO_DATE(month, 'FMMonth'))) 
	AS running_sales
FROM stores_sales4y;


/* Q.19 Analyze product sales trends over time, segmented into key periods: from launch to 6 months, 6-12 months, 12-18 months, and beyond 18 months.
*/
SELECT p.product_id, p.product_name,
	CASE WHEN sal.sale_date BETWEEN p.lauch_date AND p.lauch_date + INTERVAL '6 MONTHS' THEN '0-6 months'
		WHEN sal.sale_date BETWEEN p.lauch_date AND p.lauch_date + INTERVAL '6 MONTHS' THEN '6-12 months'
		WHEN sal.sale_date BETWEEN p.lauch_date AND p.lauch_date + INTERVAL '6 MONTHS' THEN '12-18 months'
		ELSE '18+ months' END AS lauch_sale_period,
		sum(sal.quantity) AS total_quantity
FROM sales AS sal
LEFT JOIN products AS p ON sal.product_id=p.product_id
GROUP BY 1, 2, 3;
