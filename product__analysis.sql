-- Most Popular Products (by Quantity Sold)
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
    p.product_name, p.brand, p.category
ORDER BY
    total_quantity_sold DESC
LIMIT 10; 

-- Least Popular Products (by Quantity Sold)
SELECT
    p.product_name,
    p.brand,
    p.category,
    COALESCE(SUM(s.quantity), 0) AS total_quantity_sold  
FROM
    products AS p
LEFT JOIN
    sales AS s ON p.productkey = s.productkey
GROUP BY
    p.product_name, p.brand, p.category
ORDER BY
    total_quantity_sold ASC
LIMIT 15;  

-- Product Profitability Analysis (Gross Profit and Gross Profit Margin)
SELECT
    p.productkey,
    p.product_name,
    p.brand,
    p.category,
    p.unit_cost_usd,
    p.unit_price_usd,
    -- Calculate Gross Profit Per Unit
    (p.unit_price_usd - p.unit_cost_usd) AS gross_profit_per_unit_usd,
    -- Calculate Gross Profit Margin (%)
    CASE
        WHEN p.unit_price_usd > 0 THEN
            ROUND(((p.unit_price_usd - p.unit_cost_usd) / p.unit_price_usd) * 100, 2)
        ELSE
            0.00 -- Handle cases where unit_price_usd might be zero to avoid division by zero
    END AS gross_profit_margin_percentage
FROM
    products AS p
WHERE
    p.unit_cost_usd IS NOT NULL AND p.unit_price_usd IS NOT NULL -- Exclude products with missing cost/price data
ORDER BY
    gross_profit_margin_percentage DESC, gross_profit_per_unit_usd DESC;
    
-- Total Sales Revenue and Quantity by Product Category
SELECT 
    p.category,
    ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS total_revenue_usd,
    SUM(s.quantity) AS total_quantity_sold,
    COUNT(DISTINCT s.order_number) AS total_orders
FROM
    sales AS s
        JOIN
    products AS p ON s.productkey = p.productkey
GROUP BY p.category
ORDER BY total_revenue_usd DESC;

-- Total Sales Revenue and Quantity by Product Subcategory
SELECT
    p.category,
    p.subcategory,
    ROUND(SUM(s.quantity * p.unit_price_usd), 2) AS total_revenue_usd,
    SUM(s.quantity) AS total_quantity_sold,
    COUNT(DISTINCT s.order_number) AS total_orders
FROM
    sales AS s
JOIN
    products AS p ON s.productkey = p.productkey
GROUP BY
    p.category, p.subcategory
ORDER BY
    p.category, total_revenue_usd DESC;
    
