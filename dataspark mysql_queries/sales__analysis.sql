-- Total Sales Over Time (Month-wise)
SELECT
    DATE_FORMAT(s.order_date, '%Y-%m') AS sales_month,
    ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS total_sales_usd  
FROM
    sales AS s
JOIN
    products AS p ON s.productkey = p.productkey
GROUP BY
    DATE_FORMAT(s.order_date, '%Y-%m')
ORDER BY
    sales_month;

--  Top Products by Quantity Sold
SELECT
    p.product_name,
    p.brand,
    p.category,
    SUM(s.quantity) AS total_quantity_sold
FROM
    sales AS s
JOIN
    products AS p ON s.productkey = p.productkey
GROUP BY
    p.product_name,
    p.brand,
    p.category
ORDER BY
    total_quantity_sold DESC
LIMIT 10;  

-- Top Products by Revenue Generated
SELECT
    p.product_name,
    p.brand,
    p.category,
    ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS total_revenue_usd
FROM
    sales AS s
JOIN
    products AS p ON s.productkey = p.productkey
GROUP BY
    p.product_name,
    p.brand,
    p.category
ORDER BY
    total_revenue_usd DESC
LIMIT 10;  

-- Total Sales Revenue by Store
SELECT
    st.storekey,
    st.country AS store_country,
    st.state AS store_state,
    ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS total_store_revenue_usd
FROM
    sales AS s
JOIN
    stores AS st ON s.storekey = st.storekey
JOIN
    products AS p ON s.productkey = p.productkey
GROUP BY
    st.storekey, st.country, st.state
ORDER BY
    total_store_revenue_usd DESC;
    
-- Sales performance by currency
SELECT
    s.currency_code AS original_currency,
    DATE_FORMAT(s.order_date, '%Y-%m') AS sales_month,
    ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS total_sales_in_original_currency, -- Assuming unit_price_usd is in the local currency
    ROUND(SUM(s.quantity * p.unit_price_usd * COALESCE(er.exchange, 1)), 2) AS total_sales_in_usd -- Converted to USD
FROM
    sales AS s
JOIN
    products AS p ON s.productkey = p.productkey
LEFT JOIN
    exchange_rates AS er
    ON s.order_date = er.date AND s.currency_code = er.currency
GROUP BY
    s.currency_code, sales_month
ORDER BY
    sales_month, original_currency;
    
