SELECT * FROM customers;
SELECT * FROM exchange_rates;
SELECT * FROM products;
SELECT * FROM stores;
SELECT * FROM sales;

-- Query 1:  Male count & Female customer count - continent and country wise
SELECT
    continent,
    country,
    gender,
    COUNT(*) AS customer_count
FROM
    customers
WHERE
    gender IN ('Male', 'Female')  -- Ensures only valid gender values are included
GROUP BY
    continent,
    country,
    gender
ORDER BY
    continent,
    country,
    gender;


-- Query 2: Age analysis with AOV
SELECT
  age_range,
  COUNT(DISTINCT customerkey) AS customer_count,
  ROUND(SUM(quantity * unit_price_usd / exchange) / COUNT(DISTINCT order_number), 2) AS AOV_USD
FROM (
  SELECT
    s.order_number,
    s.quantity,
    p.unit_price_usd,
    c.birthday,
    s.order_date,
    s.currency_code,
    c.customerkey,
    ex.exchange,
    CASE
      WHEN TIMESTAMPDIFF(YEAR, c.birthday, CURDATE()) < 18 THEN '<18'
      WHEN TIMESTAMPDIFF(YEAR, c.birthday, CURDATE()) BETWEEN 18 AND 25 THEN '18-25'
      WHEN TIMESTAMPDIFF(YEAR, c.birthday, CURDATE()) BETWEEN 26 AND 35 THEN '26-35'
      WHEN TIMESTAMPDIFF(YEAR, c.birthday, CURDATE()) BETWEEN 36 AND 45 THEN '36-45'
      WHEN TIMESTAMPDIFF(YEAR, c.birthday, CURDATE()) BETWEEN 46 AND 60 THEN '46-60'
      ELSE '>60'
    END AS age_range
  FROM sales s
  JOIN customers c ON s.customerkey = c.customerkey
  JOIN products p ON s.productkey = p.productkey
  JOIN exchange_rates ex 
    ON s.order_date = ex.date AND s.currency_code = ex.currency
) AS order_data
GROUP BY age_range
ORDER BY FIELD(age_range, '<18', '18-25', '26-35', '36-45', '46-60', '>60');

-- Query 4: Geographic analysis    
SELECT
    Continent,
    COUNT(CustomerKey) AS CustomerCount  
FROM
    customers
GROUP BY
    Continent
ORDER BY
    CustomerCount DESC;
    
SELECT
    Country,
    COUNT(CustomerKey) AS CustomerCount
FROM
    customers
GROUP BY
    Country
ORDER BY
    CustomerCount DESC;

-- Query 4: AOV,purchase frequency, preferred products analysis
-- AOV -- Trend Yearwise

SELECT
    DATE_FORMAT(s.order_date, '%Y') AS OrderYear,  
    SUM(s.quantity * p.unit_price_usd) / COUNT(DISTINCT s.order_number) AS Yearly_AOV
FROM
    sales s
JOIN
    products p ON s.productkey = p.productkey
GROUP BY
    OrderYear
ORDER BY
    OrderYear;

-- purchase frequency

SELECT
    s.customerkey,
    c.Name, -- Optional: Join to customers table to get name
    COUNT(DISTINCT s.order_number) AS Customer_Order_Count -- Total orders for this customer
FROM
    sales s
LEFT JOIN
    customers c ON s.customerkey = c.customerkey -- Assuming you want customer name
GROUP BY
    s.customerkey, c.Name -- Group by customer to count their specific orders
ORDER BY
    Customer_Order_Count DESC;
    
-- Preferred products
-- By Quantity
SELECT
    p.product_name,
    p.brand,
    p.category,         
    p.subcategory,      
    SUM(s.quantity) AS TotalQuantitySold
FROM
    sales s
JOIN
    products p ON s.productkey = p.productkey
GROUP BY
    p.productkey, p.product_name, p.brand, p.category, p.subcategory
ORDER BY
    TotalQuantitySold DESC
LIMIT 10;  

-- By price_value

SELECT
    p.product_name,
    p.brand,
    p.category,
    p.subcategory,
    SUM(s.quantity * p.unit_price_usd) AS TotalRevenueGenerated
FROM
    sales s
JOIN
    products p ON s.productkey = p.productkey
GROUP BY
    p.productkey, p.product_name, p.brand, p.category, p.subcategory
ORDER BY
    TotalRevenueGenerated DESC
LIMIT 10;

-- Demographic Segmentation - Customers by Gender and Country
SELECT
    c.gender,
    c.country,
    COUNT(DISTINCT c.customerkey) AS number_of_customers
FROM
    customers AS c
GROUP BY
    c.gender,
    c.country
ORDER BY
    c.country, c.gender;

-- Behavioral Segmentation - Top Product Categories by Customer Demographics (Gender and Country)
SELECT
    c.gender,
    c.country,
    p.category,
    SUM(s.quantity) AS total_quantity_purchased,
    COUNT(DISTINCT c.customerkey) AS number_of_unique_customers
FROM
    customers AS c
JOIN
    sales AS s ON c.customerkey = s.customerkey
JOIN
    products AS p ON s.productkey = p.productkey
GROUP BY
    c.gender,
    c.country,
    p.category
ORDER BY
    total_quantity_purchased DESC;