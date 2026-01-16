DROP TABLE IF EXISTS products;
CREATE TABLE products(
product_id VARCHAR(10) PRIMARY KEY,
product_name VARCHAR(50),
category_id VARCHAR(10),
lauch_date DATE,
price NUMERIC,
CONSTRAINT fk_products_category_id FOREIGN KEY (category_id) REFERENCES category(category_id)
);

DROP TABLE IF EXISTS warranty;
CREATE TABLE warranty (
claim_id VARCHAR(10) PRIMARY KEY,
claim_date DATE,
sale_id VARCHAR(20),
repair_status VARCHAR(20)
);

DROP TABLE IF EXISTS category;
CREATE TABLE category (
category_id VARCHAR(10) PRIMARY KEY,
category_name VARCHAR(25)
);

DROP TABLE IF EXISTS stores;
CREATE TABLE stores (
store_id VARCHAR(15) PRIMARY KEY,
store_name VARCHAR(50),
city VARCHAR(25), 
country VARCHAR(30)
);

DROP TABLE IF EXISTS sales;
CREATE TABLE sales (
sale_id VARCHAR(20) PRIMARY KEY,
sale_date TEXT,
store_id VARCHAR(10),
product_id VARCHAR(10),
quantity INT,
CONSTRAINT fk_sales_store_id FOREIGN KEY (store_id) REFERENCES stores(store_id),
CONSTRAINT fk_sales_product_id FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Parse the sale_date values as date.
UPDATE sales
SET sale_date=TO_DATE(sale_date, 'DD-MM-YYYY');

-- Change the data type of sale_date to date.
ALTER TABLE sales
ALTER COLUMN sale_date TYPE DATE
USING sale_date::DATE;


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
WITH store_ranking AS (SELECT s.store_name, TO_CHAR(sal.sale_date, 'FMDay') AS day, 
			sum(sal.quantity) AS total_qty_sold, 
         	DENSE_RANK() OVER (PARTITION BY s.store_name ORDER BY sum(sal.quantity) DESC) AS ranking
			FROM sales AS sal
			JOIN stores AS s ON s.store_id=sal.store_id
			GROUP BY 1, 2)
SELECT * 
FROM store_ranking
WHERE ranking=1;



/* Q.11 Identify the least selling product in each country for each year based on total units sold.
*/






/* Q.12 Calculate how many warranty claims were filed within 180 days of a product sale.
*/





/* Q.13 Determine how many warranty claims were filed for products launched in the last two years.
*/




/* Q.14 List the months in the last three years where sales exceeded 5,000 units in the USA.
*/
/* Q.15 Identify the product category with the most warranty claims filed in the last two years
*/
/* Q.16 Determine the percentage chance of receiving warranty claims after each purchase for each country.
*/

/* Q.17 Analyze the year-by-year growth ratio for each store.
*/
/* Q.18 Calculate the correlation between product price and warranty claims for products sold in the last five years, segmented by price range.
*/
/* Q.19 Write a query to calculate the monthly running total of sales for each store over the past four years and compare trends during this period
*/

/* Q.20 Analyze product sales trends over time, segmented into key periods: from launch to 6 months, 6-12 months, 12-18 months, and beyond 18 months.
*/