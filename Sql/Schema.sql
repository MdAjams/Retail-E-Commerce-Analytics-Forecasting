create database Ajam;
use Ajam;
-- ============================================================
-- Retail Intelligence & Forecasting Platform - MySQL Schema
-- ============================================================

-- 1. Regions (Countries)
CREATE TABLE Regions (
    region_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL
);

-- 2. Suppliers
CREATE TABLE Suppliers (
    supplier_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(255) NOT NULL,
    region_id INT UNSIGNED,
    FOREIGN KEY (region_id) REFERENCES Regions(region_id)
);

-- 3. Products
CREATE TABLE Products (
    product_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    price DECIMAL(10,2) NOT NULL,
    supplier_id INT UNSIGNED,
    FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id)
);

-- 4. Customers
CREATE TABLE Customers (
    customer_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255) UNIQUE,
    gender VARCHAR(20),
    age INT CHECK (age >= 0),
    region_id INT UNSIGNED,
    FOREIGN KEY (region_id) REFERENCES Regions(region_id)
);

-- 5. Inventory
CREATE TABLE Inventory (
    inventory_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id INT UNSIGNED,
    stock_quantity INT CHECK (stock_quantity >= 0),
    last_restock DATE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- 6. Orders
CREATE TABLE Orders (
    order_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_id INT UNSIGNED,
    order_date DATE NOT NULL,
    total_amount DECIMAL(12,2) DEFAULT 0,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- 7. OrderDetails (Line Items)
CREATE TABLE OrderDetails (
    order_detail_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id INT UNSIGNED,
    product_id INT UNSIGNED,
    quantity INT CHECK (quantity > 0),
    discount DECIMAL(4,2) CHECK (discount >= 0 AND discount <= 1),
    line_amount DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- 8. Payments
CREATE TABLE Payments (
    payment_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id INT UNSIGNED,
    payment_method VARCHAR(50),
    payment_date DATE,
    amount DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

# Fetch all rows individually
SELECT * FROM Regions;
SELECT * FROM Suppliers;
SELECT * FROM Products;
SELECT * FROM Customers;
SELECT * FROM Inventory;
SELECT * FROM Orders;
SELECT * FROM OrderDetails;
SELECT * FROM Payments;
