-- ================================================================
-- 🛒 Retail Intelligence & Forecasting Platform
-- ================================================================

-- 1. List all customers with their region
SELECT c.first_name, c.last_name, r.country_name
FROM Customers c
JOIN Regions r ON c.region_id = r.region_id;
-- Business: Helps identify customer base by geography.

-- 2. Find total number of orders placed
SELECT COUNT(*) AS total_orders
FROM Orders;
-- Business: Quick snapshot of order volume.

-- 3. Calculate total revenue from all orders
SELECT SUM(total_amount) AS total_revenue
FROM Orders;
-- Business: Overall revenue performance.

-- 4. Top 5 customers by total spend
SELECT c.customer_id, c.first_name, c.last_name, SUM(o.total_amount) AS total_spent
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC
LIMIT 5;
-- Business: Identifies VIP/high-value customers.

-- 5. Monthly revenue trend
SELECT DATE_FORMAT(order_date, '%Y-%m') AS month, SUM(total_amount) AS revenue
FROM Orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;
-- Business: Tracks revenue growth month by month.

-- 6. Most popular products by order quantity
SELECT p.product_name, SUM(od.quantity) AS total_sold
FROM OrderDetails od
JOIN Products p ON od.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_sold DESC
LIMIT 10;
-- Business: Helps spot best-sellers.

-- 7. Average order value (AOV)
SELECT AVG(total_amount) AS avg_order_value
FROM Orders;
-- Business: A key retail KPI.

-- 8. Customer order frequency
SELECT c.customer_id,c.first_name, c.last_name, COUNT(o.order_id) AS orders_count
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id
ORDER BY orders_count DESC;
-- Business: Identifies repeat vs one-time buyers.

-- 9. Revenue by product category
SELECT p.category, SUM(od.line_amount) AS category_revenue
FROM OrderDetails od
JOIN Products p ON od.product_id = p.product_id
GROUP BY p.category
ORDER BY category_revenue DESC;
-- Business: Reveals strong & weak categories.

-- 10. Payment method share
SELECT payment_method, COUNT(*) AS transactions, SUM(amount) AS total_paid
FROM Payments
GROUP BY payment_method;
-- Business: Useful for finance/ops optimization.

-- 11. Inventory status (low stock alert)
SELECT p.product_name, i.stock_quantity
FROM Inventory i
JOIN Products p ON i.product_id = p.product_id
WHERE i.stock_quantity < 20;
-- Business: Prevents stockouts.

-- 12. Top suppliers by revenue contribution
SELECT s.supplier_name, SUM(od.line_amount) AS supplier_revenue
FROM Suppliers s
JOIN Products p ON s.supplier_id = p.supplier_id
JOIN OrderDetails od ON p.product_id = od.product_id
GROUP BY s.supplier_name
ORDER BY supplier_revenue DESC
LIMIT 5;
-- Business: Tracks supplier performance.

-- 13. Average customer age by region
SELECT r.country_name, AVG(c.age) AS avg_age
FROM Customers c
JOIN Regions r ON c.region_id = r.region_id
GROUP BY r.country_name;
-- Business: Shows demographic insights.

-- 14. Discount impact on sales
SELECT CASE WHEN od.discount > 0 THEN 'Discounted' ELSE 'Full Price' END AS discount_flag,
       SUM(od.line_amount) AS revenue
FROM OrderDetails od
GROUP BY discount_flag;
-- Business: Measures promo effectiveness.

-- 15. Orders without payments (potential issues)
SELECT o.order_id, o.total_amount
FROM Orders o
LEFT JOIN Payments p ON o.order_id = p.order_id
WHERE p.payment_id IS NULL;
-- Business: Detects unpaid/pending transactions.

-- 16. First-time customers in each month (Cohort Analysis)
WITH first_orders AS (
    SELECT customer_id, MIN(order_date) AS first_order_date
    FROM Orders
    GROUP BY customer_id
)
SELECT DATE_FORMAT(first_order_date, '%Y-%m') AS cohort_month,
       COUNT(customer_id) AS new_customers
FROM first_orders
GROUP BY cohort_month
ORDER BY cohort_month;
-- Business: Customer acquisition trends.

-- 17. Running total of revenue (cumulative sales)
SELECT order_date,
       SUM(total_amount) OVER (ORDER BY order_date) AS cumulative_revenue
FROM Orders
ORDER BY order_date;
-- Business: Tracks growth trajectory.

-- 18. Rank products by revenue within category
SELECT p.category, p.product_name,
       SUM(od.line_amount) AS product_revenue,
       RANK() OVER (PARTITION BY p.category ORDER BY SUM(od.line_amount) DESC) AS category_rank
FROM OrderDetails od
JOIN Products p ON od.product_id = p.product_id
GROUP BY p.category, p.product_name;
-- Business: Category-level product performance.

-- 19. Year-over-Year revenue growth
SELECT YEAR(order_date) AS year, SUM(total_amount) AS revenue
FROM Orders
GROUP BY YEAR(order_date)
ORDER BY year;
-- Business: Long-term growth metric.

-- 20. Customer lifetime value (CLV)
SELECT c.customer_id, c.first_name, c.last_name, SUM(o.total_amount) AS lifetime_value
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY lifetime_value DESC
LIMIT 10;
-- Business: Prioritizes retention strategies.

-- 21. Average delivery (order-to-payment) time
SELECT AVG(DATEDIFF(p.payment_date, o.order_date)) AS avg_days_to_pay
FROM Orders o
JOIN Payments p ON o.order_id = p.order_id;
-- Business: Cash flow efficiency.

-- 22. Region-wise revenue distribution
SELECT r.country_name, SUM(o.total_amount) AS region_revenue
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Regions r ON c.region_id = r.region_id
GROUP BY r.country_name
ORDER BY region_revenue DESC;
-- Business: Market segmentation by geography.

-- 23. Find inactive customers (no orders in last 6 months)
SELECT c.customer_id, c.first_name, c.last_name
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
WHERE c.customer_id NOT IN (
    SELECT customer_id FROM Orders WHERE order_date >= CURDATE() - INTERVAL 6 MONTH
);
-- Business: Helps target re-engagement campaigns.

-- 24. Profit estimation (Revenue - Discount)
SELECT SUM(od.line_amount - (od.discount * od.quantity)) AS estimated_profit
FROM OrderDetails od;
-- Business: Rough profit calculation.

-- 25. Customers who bought from multiple categories
SELECT c.customer_id, c.first_name, c.last_name, COUNT(DISTINCT p.category) AS categories_bought
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN OrderDetails od ON o.order_id = od.order_id
JOIN Products p ON od.product_id = p.product_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(DISTINCT p.category) > 1;
-- Business: Identifies diverse shoppers.
