-- Creating products table
DROP TABLE IF EXISTS products;
CREATE TABLE products(
product_id VARCHAR(10) PRIMARY KEY,
product_name VARCHAR(50),
category_id VARCHAR(10),
lauch_date DATE,
price NUMERIC,
CONSTRAINT fk_products_category_id FOREIGN KEY (category_id) REFERENCES category(category_id)
);

-- Creating warranty table.
DROP TABLE IF EXISTS warranty;
CREATE TABLE warranty (
claim_id VARCHAR(10) PRIMARY KEY,
claim_date DATE,
sale_id VARCHAR(20),
repair_status VARCHAR(20)
);


-- Creating category table.
DROP TABLE IF EXISTS category;
CREATE TABLE category (
category_id VARCHAR(10) PRIMARY KEY,
category_name VARCHAR(25)
);

-- Creating store table.
DROP TABLE IF EXISTS stores;
CREATE TABLE stores (
store_id VARCHAR(15) PRIMARY KEY,
store_name VARCHAR(50),
city VARCHAR(25), 
country VARCHAR(30)
);


-- Creating sales table
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


-- Parse the sale_date values as date in sales table.
UPDATE sales
SET sale_date=TO_DATE(sale_date, 'DD-MM-YYYY');

-- Change the data type of sale_date from text to date.
ALTER TABLE sales
ALTER COLUMN sale_date TYPE DATE
USING sale_date::DATE;

