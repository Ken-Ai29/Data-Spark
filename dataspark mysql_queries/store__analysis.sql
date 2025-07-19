-- Store Performance Overview
SELECT
    st.storekey,
    st.country,
    st.state,
    st.square_meters,
    st.open_date,
    ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS total_revenue_usd,
    COUNT(DISTINCT s.order_number) AS total_transactions,
    CASE
        WHEN st.square_meters > 0 THEN ROUND(SUM(s.quantity * p.unit_price_usd) / st.square_meters, 2)
        ELSE 0
    END AS revenue_per_sq_meter,
    -- Calculate years since opening
    (YEAR(CURRENT_DATE) - YEAR(st.open_date)) AS years_since_open
FROM
    sales AS s
JOIN
    products AS p ON s.productkey = p.productkey
JOIN
    stores AS st ON s.storekey = st.storekey
GROUP BY
    st.storekey, st.country, st.state, st.square_meters, st.open_date
ORDER BY
    total_revenue_usd DESC;
    
-- Monthly Sales Trend by Store
SELECT
    DATE_FORMAT(s.order_date, '%Y-%m') AS sales_month,
    st.storekey,
    st.country,
    st.state,
    ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS monthly_revenue_usd
FROM
    sales AS s
JOIN
    products AS p ON s.productkey = p.productkey
JOIN
    stores AS st ON s.storekey = st.storekey
GROUP BY
    sales_month, st.storekey, st.country, st.state
ORDER BY
    st.storekey, sales_month;
    
-- Sales Performance by Country    
SELECT
    st.country,
    ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS total_revenue_usd,
    SUM(s.quantity) AS total_quantity_sold,
    COUNT(DISTINCT s.order_number) AS total_transactions,
    COUNT(DISTINCT st.storekey) AS number_of_stores
FROM
    sales AS s
JOIN
    products AS p ON s.productkey = p.productkey
JOIN
    stores AS st ON s.storekey = st.storekey
GROUP BY
    st.country
ORDER BY
    total_revenue_usd DESC;
    
-- Sales Performance by State within Each Country
SELECT
    st.country,
    st.state,
    ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS total_revenue_usd,
    SUM(s.quantity) AS total_quantity_sold,
    COUNT(DISTINCT s.order_number) AS total_transactions,
    COUNT(DISTINCT st.storekey) AS number_of_stores
FROM
    sales AS s
JOIN
    products AS p ON s.productkey = p.productkey
JOIN
    stores AS st ON s.storekey = st.storekey
GROUP BY
    st.country, st.state
ORDER BY
    st.country, total_revenue_usd DESC;
    
-- Sales Performance by Store per Square Meter in Each State 
SELECT
    st.country,
    st.state,
    ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS total_revenue_usd,
    SUM(st.square_meters) AS total_square_meters,
    CASE
        WHEN SUM(st.square_meters) > 0 THEN ROUND(SUM(s.quantity * p.unit_price_usd) / SUM(st.square_meters), 2)
        ELSE 0
    END AS regional_revenue_per_sq_meter
FROM
    sales AS s
JOIN
    products AS p ON s.productkey = p.productkey
JOIN
    stores AS st ON s.storekey = st.storekey
GROUP BY
    st.country, st.state
ORDER BY
    regional_revenue_per_sq_meter DESC;