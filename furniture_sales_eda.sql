-- ========================================
-- Phase 1 — Database Setup & Schema
-- ========================================

-- 1.1. Create Database
CREATE DATABASE ecommerce_furniture_db;
USE ecommerce_furniture_db;

-- 1.2. Create Table
CREATE TABLE furniture_sales (
    product_title TEXT,
    original_price DECIMAL(10,2),
    price DECIMAL(10,2),
    sold INT,
    shipping_cost DECIMAL(10,2),
    shipping_type VARCHAR(50),
    discount_percent DECIMAL(5,2),
    total_cost DECIMAL(10,2),
    outlier_flag VARCHAR(10)
);

SET GLOBAL local_infile = 1;

-- 1.3. Load data to MySQL
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/furniture_sales.csv'
INTO TABLE furniture_sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(product_title, original_price, price, sold, shipping_cost, shipping_type, discount_percent, total_cost, outlier_flag);

-- Check if NULLs
SELECT 
    COUNT(*) - COUNT(original_price) AS missing_original_price,
    COUNT(*) - COUNT(price) AS missing_price
FROM furniture_sales;

SELECT * 
FROM furniture_sales
LIMIT 10;

-- ========================
-- Data Validation Queries
-- ========================
-- 1. Logical Check
SELECT *
FROM furniture_sales
WHERE original_price < price;

-- 2. Outlier Check
SELECT *
FROM furniture_sales
WHERE outlier_flag = 'Outlier';

-- 3. Discount Distribution
SELECT 
    MIN(discount_percent),
    MAX(discount_percent),
    AVG(discount_percent)
FROM furniture_sales;

-- Create Index for Performance Optimization
CREATE INDEX idx_price ON furniture_sales(price);
CREATE INDEX idx_sold ON furniture_sales(sold);
CREATE INDEX idx_shipping ON furniture_sales(shipping_cost);

-- ================================
-- Phase 2 — Data Understanding
-- ================================
-- 2.1 — Basic Dataset Overview
SELECT COUNT(*) As total_count
FROM furniture_sales;

-- 2.2 — Column-Level Null Check
SELECT 
    COUNT(*) - COUNT(product_title) AS missing_title,
    COUNT(*) - COUNT(original_price) AS missing_original_price,
    COUNT(*) - COUNT(price) AS missing_price,
    COUNT(*) - COUNT(sold) AS missing_sold,
    COUNT(*) - COUNT(shipping_cost) AS missing_shipping_cost
FROM furniture_sales;

-- 2.3 — Data Types Verification
DESCRIBE furniture_sales;

-- 2.4 — Summary Statistics (Core Step)
SELECT 
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    AVG(price) AS avg_price,
    
    MIN(sold) AS min_sold,
    MAX(sold) AS max_sold,
    AVG(sold) AS avg_sold,
    
    MIN(discount_percent) AS min_discount,
    MAX(discount_percent) AS max_discount,
    AVG(discount_percent) AS avg_discount
FROM furniture_sales;

-- 2.5 — Distribution of Shipping Types
SELECT 
    shipping_type,
    COUNT(*) AS count_products
FROM furniture_sales
GROUP BY shipping_type;

-- 2.6 — Check Outliers Presence
SELECT 
    outlier_flag,
    COUNT(*) AS count
FROM furniture_sales
GROUP BY outlier_flag;

-- 2.7 — Top & Bottom Price Products
-- Highest priced
SELECT 
	product_title, 
    price
FROM furniture_sales
ORDER BY price DESC
LIMIT 5;

-- Lowest priced
SELECT 
	product_title, 
	price
FROM furniture_sales
ORDER BY price ASC
LIMIT 5;

-- 2.8 — Sales Distribution Insight
SELECT 
    CASE 
        WHEN sold = 0 THEN 'No Sales'
        WHEN sold BETWEEN 1 AND 50 THEN 'Low Sales'
        WHEN sold BETWEEN 51 AND 200 THEN 'Medium Sales'
        ELSE 'High Sales'
    END AS sales_category,
    COUNT(*) AS product_count
FROM furniture_sales
GROUP BY sales_category;

-- ===========================================
-- Phase 3 — Feature Engineering
-- ===========================================
-- 3.1. Add New Columns
ALTER TABLE furniture_sales
ADD COLUMN discount_amount DECIMAL(10,2),
ADD COLUMN is_discounted TINYINT,
ADD COLUMN price_bucket VARCHAR(20),
ADD COLUMN sales_bucket VARCHAR(20),
ADD COLUMN shipping_bucket VARCHAR(20);

-- 3.2 — Populate discount_amount
UPDATE furniture_sales
SET discount_amount = original_price - price;

-- 3.3 — Create is_discounted Flag
UPDATE furniture_sales
SET is_discounted = 
    CASE 
        WHEN original_price > price THEN 1
        ELSE 0
    END;

-- 3.4 — Create Price Buckets
UPDATE furniture_sales
SET price_bucket =
    CASE 
        WHEN price < 50 THEN 'Low'
        WHEN price BETWEEN 50 AND 200 THEN 'Medium'
        ELSE 'High'
    END;

-- 3.5 — Create Sales Buckets
UPDATE furniture_sales
SET sales_bucket =
    CASE 
        WHEN sold = 0 THEN 'No Sales'
        WHEN sold BETWEEN 1 AND 50 THEN 'Low Sales'
        WHEN sold BETWEEN 51 AND 200 THEN 'Medium Sales'
        ELSE 'High Sales'
    END;

-- 3.6 — Create Shipping Buckets
UPDATE furniture_sales
SET shipping_bucket =
    CASE 
        WHEN shipping_cost = 0 THEN 'Free'
        WHEN shipping_cost BETWEEN 1 AND 50 THEN 'Low Shipping'
        WHEN shipping_cost BETWEEN 51 AND 200 THEN 'Medium Shipping'
        ELSE 'High Shipping'
    END;

-- 3.7 — Discount Category
ALTER TABLE furniture_sales
ADD COLUMN discount_bucket VARCHAR(20);

UPDATE furniture_sales
SET discount_bucket =
    CASE 
        WHEN discount_percent < 0.2 THEN 'Low Discount'
        WHEN discount_percent BETWEEN 0.2 AND 0.5 THEN 'Medium Discount'
        ELSE 'High Discount'
    END;

-- 3.8 — Verify Engineered Features
SELECT 
    product_title,
    price,
    original_price,
    discount_amount,
    is_discounted,
    price_bucket,
    sales_bucket,
    shipping_bucket
FROM furniture_sales
LIMIT 10;

-- Add product_id colum
ALTER TABLE furniture_sales
ADD COLUMN product_id VARCHAR(10);

SET @row_number = 0;

UPDATE furniture_sales
SET product_id = 
    CONCAT('P', LPAD(@row_number := @row_number + 1, 4, '0'));

ALTER TABLE furniture_sales
ADD PRIMARY KEY (product_id);

-- Verify
SELECT product_id, product_title
FROM furniture_sales
LIMIT 10;

-- ===============================
-- Phase 4 — Univariate Analysis
-- ===============================
-- 4.1 — Price Distribution
SELECT 
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    AVG(price) AS avg_price,
    ROUND(STDDEV(price),2) AS std_price
FROM furniture_sales;

-- Price Bucket Distribution
SELECT 
    price_bucket,
    COUNT(*) AS product_count
FROM furniture_sales
GROUP BY price_bucket
ORDER BY product_count DESC;

-- 4.2 — Sales (sold) Distribution
SELECT 
    MIN(sold) AS min_sold,
    MAX(sold) AS max_sold,
    AVG(sold) AS avg_sold,
    ROUND(STDDEV(sold),2) AS std_sold
FROM furniture_sales;

-- Sales Bucket Analysis
SELECT 
    sales_bucket,
    COUNT(*) AS product_count
FROM furniture_sales
GROUP BY sales_bucket
ORDER BY product_count DESC;

-- 4.3 — Discount Distribution
SELECT 
    MIN(discount_percent) AS min_discount,
    MAX(discount_percent) AS max_discount,
    AVG(discount_percent) AS avg_discount,
    ROUND(STDDEV(discount_percent),3) AS std_discount
FROM furniture_sales;

-- Discount Bucket
SELECT 
    discount_bucket,
    COUNT(*) AS product_count
FROM furniture_sales
GROUP BY discount_bucket;

-- 4.4 — Shipping Cost Distribution
SELECT 
    MIN(shipping_cost) AS min_shipping,
    MAX(shipping_cost) AS max_shipping,
    AVG(shipping_cost) AS avg_shipping,
    ROUND(STDDEV(shipping_cost),2) AS std_shipping
FROM furniture_sales;

-- Shipping Bucket Distribution
SELECT 
    shipping_bucket,
    COUNT(*) AS product_count
FROM furniture_sales
GROUP BY shipping_bucket;

-- 4.5 — Shipping Type Distribution
SELECT 
    shipping_type,
    COUNT(*) AS count_products
FROM furniture_sales
GROUP BY shipping_type;

-- 4.6 — Outlier Analysis
SELECT 
    outlier_flag,
    COUNT(*) AS count
FROM furniture_sales
GROUP BY outlier_flag;

-- 4.7 — Discounted vs Non-Discounted
SELECT 
    is_discounted,
    COUNT(*) AS product_count
FROM furniture_sales
GROUP BY is_discounted;

-- ================================
-- Phase 5 — Bivariate Analysis
-- ================================
-- 5.1 — Price vs Sales
SELECT 
    price_bucket,
    ROUND(AVG(sold),2) AS avg_sales,
    COUNT(*) AS product_count
FROM furniture_sales
GROUP BY price_bucket
ORDER BY avg_sales DESC;

-- 5.2 — Discount vs Sales
SELECT 
    discount_bucket,
    ROUND(AVG(sold),2) AS avg_sales,
    COUNT(*) AS product_count
FROM furniture_sales
GROUP BY discount_bucket
ORDER BY avg_sales DESC;

-- 5.3 — Shipping Cost vs Sales
SELECT 
    shipping_bucket,
    ROUND(AVG(sold),2) AS avg_sales,
    COUNT(*) AS product_count
FROM furniture_sales
GROUP BY shipping_bucket
ORDER BY avg_sales DESC;

-- 5.4 — Shipping Type vs Sales
SELECT 
    shipping_type,
    ROUND(AVG(sold),2) AS avg_sales,
    COUNT(*) AS product_count
FROM furniture_sales
GROUP BY shipping_type
ORDER BY avg_sales DESC;

-- 5.5 — Total Cost vs Sales (Critical Insight)
SELECT 
    CASE 
        WHEN total_cost < 50 THEN 'Low Total Cost'
        WHEN total_cost BETWEEN 50 AND 200 THEN 'Medium Total Cost'
        ELSE 'High Total Cost'
    END AS total_cost_bucket,
    ROUND(AVG(sold),2) AS avg_sales,
    COUNT(*) AS product_count
FROM furniture_sales
GROUP BY total_cost_bucket
ORDER BY avg_sales DESC;

-- 5.6 — Discount vs Price Bucket
SELECT 
    price_bucket,
    ROUND(AVG(discount_percent),3) AS avg_discount
FROM furniture_sales
GROUP BY price_bucket;

-- 5.7 — Shipping Cost vs Price
SELECT 
    price_bucket,
    ROUND(AVG(shipping_cost),2) AS avg_shipping
FROM furniture_sales
GROUP BY price_bucket;

-- 5.8 — Outliers Impact on Sales
SELECT 
    outlier_flag,
    ROUND(AVG(sold),2) AS avg_sales
FROM furniture_sales
GROUP BY outlier_flag;

-- 5.9 — Discounted vs Non-Discounted Sales
SELECT 
    is_discounted,
    ROUND(AVG(sold),2) AS avg_sales,
    COUNT(*) AS product_count
FROM furniture_sales
GROUP BY is_discounted;

-- 5.10 — Correlation Approximation
SELECT 
    ROUND(
        (AVG(price * sold) - AVG(price) * AVG(sold)) /
        (STDDEV(price) * STDDEV(sold)),
    3) AS price_sales_correlation
FROM furniture_sales;

-- ======================================================
-- Phase 6 — Performance Analytics & Strategic Insights
-- ======================================================
-- 6.1 — Top 10 Best-Selling Products
SELECT 
	product_id,
    product_title,
    sold,
    price,
    total_cost
FROM furniture_sales
ORDER BY sold DESC
LIMIT 10;

-- 6.2 — Top Revenue Generating Products
SELECT 
	product_id,
    product_title,
    sold,
    price,
    (price * sold) AS revenue
FROM furniture_sales
ORDER BY revenue DESC
LIMIT 10;

-- 6.3 — High Discount but Low Sales
SELECT 
	product_id,
    product_title,
    discount_percent,
    sold
FROM furniture_sales
WHERE discount_percent > 0.5
AND sold < 20
ORDER BY discount_percent DESC;

 -- 6.4 — Low Discount but High Sales
SELECT 
	product_id,
    product_title,
    discount_percent,
    sold
FROM furniture_sales
WHERE discount_percent < 0.2
AND sold > 100
ORDER BY sold DESC;

-- 6.5 — High Shipping Cost but Still Selling Well
SELECT 
	product_id,
    product_title,
    shipping_cost,
    sold
FROM furniture_sales
WHERE shipping_cost > 100
AND sold > 50
ORDER BY sold DESC;

-- 6.6 — Free Shipping Advantage
SELECT 
    shipping_type,
    ROUND(AVG(sold),2) AS avg_sales
FROM furniture_sales
GROUP BY shipping_type;

-- 6.7 — Most Profitable Price Segment
SELECT 
    price_bucket,
    SUM(price * sold) AS total_revenue
FROM furniture_sales
GROUP BY price_bucket
ORDER BY total_revenue DESC;

-- 6.8 — Products with High Total Cost but Low Sales (Risk Zone)
SELECT 
	product_id,
    product_title,
    total_cost,
    sold
FROM furniture_sales
WHERE total_cost > 200
AND sold < 20
ORDER BY total_cost DESC;

-- 6.9 — Discount Efficiency (Advanced)
SELECT 
    discount_bucket,
    ROUND(AVG(sold),2) AS avg_sales,
    ROUND(AVG(discount_amount),2) AS avg_discount_value
FROM furniture_sales
GROUP BY discount_bucket;

-- 6.10 — Top Performers by Shipping Strategy
SELECT 
    shipping_type,
    SUM(price * sold) AS total_revenue,
    ROUND(AVG(sold),2) AS avg_sales
FROM furniture_sales
GROUP BY shipping_type
ORDER BY total_revenue DESC;

-- ============================================================
-- Phase 7 — Export Pipeline
-- ============================================================
-- 7.1. Top Performing Products
SELECT 
	product_id,
    product_title,
    sold,
    price,
    (price * sold) AS revenue
FROM furniture_sales
ORDER BY revenue DESC
LIMIT 50;

-- 7.2. Price Bucket Analysis
SELECT 
    price_bucket,
    COUNT(*) AS product_count,
    AVG(price) AS avg_price,
    AVG(sold) AS avg_sales
FROM furniture_sales
GROUP BY price_bucket;

-- 7.3. Shipping Analysis
SELECT 
    shipping_type,
    COUNT(*) AS total_products,
    AVG(shipping_cost) AS avg_shipping,
    AVG(sold) AS avg_sales
FROM furniture_sales
GROUP BY shipping_type;

-- 7.4. Discount Analysis
SELECT 
    discount_bucket,
    COUNT(*) AS total_products,
    AVG(discount_percent) AS avg_discount,
    AVG(sold) AS avg_sales
FROM furniture_sales
GROUP BY discount_bucket;

-- 7.5. Revenue by Segment
SELECT 
    price_bucket,
    SUM(price * sold) AS total_revenue
FROM furniture_sales
GROUP BY price_bucket;

-- 7.6. Export data
SELECT * 
FROM furniture_sales
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/furniture_export.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';















