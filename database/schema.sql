-- T-Shirts Order Management System - MySQL Database Schema
-- Created: 2025-12-15 21:20:00 UTC
-- Database schema for managing customers, products, orders, inventory, and invoices

-- Drop existing tables if they exist (for clean installation)
DROP TABLE IF EXISTS `invoices`;
DROP TABLE IF EXISTS `order_items`;
DROP TABLE IF EXISTS `orders`;
DROP TABLE IF EXISTS `inventory`;
DROP TABLE IF EXISTS `products`;
DROP TABLE IF EXISTS `customers`;
DROP TABLE IF EXISTS `admin_passwords`;

-- ====================================================
-- CUSTOMERS TABLE
-- ====================================================
CREATE TABLE `customers` (
    `customer_id` INT PRIMARY KEY AUTO_INCREMENT,
    `first_name` VARCHAR(100) NOT NULL,
    `last_name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(150) NOT NULL UNIQUE,
    `phone` VARCHAR(20),
    `address` TEXT,
    `city` VARCHAR(100),
    `state` VARCHAR(50),
    `postal_code` VARCHAR(20),
    `country` VARCHAR(100),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `is_active` BOOLEAN DEFAULT TRUE,
    INDEX `idx_email` (`email`),
    INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================
-- PRODUCTS TABLE
-- ====================================================
CREATE TABLE `products` (
    `product_id` INT PRIMARY KEY AUTO_INCREMENT,
    `product_name` VARCHAR(255) NOT NULL,
    `description` TEXT,
    `category` VARCHAR(100),
    `color` VARCHAR(50),
    `size` VARCHAR(20),
    `material` VARCHAR(100),
    `price` DECIMAL(10, 2) NOT NULL,
    `cost` DECIMAL(10, 2),
    `sku` VARCHAR(50) NOT NULL UNIQUE,
    `image_url` VARCHAR(500),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `is_active` BOOLEAN DEFAULT TRUE,
    INDEX `idx_sku` (`sku`),
    INDEX `idx_category` (`category`),
    INDEX `idx_color_size` (`color`, `size`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================
-- INVENTORY TABLE
-- ====================================================
CREATE TABLE `inventory` (
    `inventory_id` INT PRIMARY KEY AUTO_INCREMENT,
    `product_id` INT NOT NULL,
    `quantity_in_stock` INT NOT NULL DEFAULT 0,
    `quantity_reserved` INT NOT NULL DEFAULT 0,
    `reorder_level` INT DEFAULT 50,
    `reorder_quantity` INT DEFAULT 100,
    `warehouse_location` VARCHAR(255),
    `last_stock_check` TIMESTAMP,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY `uk_product_id` (`product_id`),
    FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX `idx_quantity_low` (`quantity_in_stock`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================
-- ORDERS TABLE
-- ====================================================
CREATE TABLE `orders` (
    `order_id` INT PRIMARY KEY AUTO_INCREMENT,
    `customer_id` INT NOT NULL,
    `order_number` VARCHAR(50) NOT NULL UNIQUE,
    `order_date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `total_amount` DECIMAL(12, 2) NOT NULL,
    `subtotal` DECIMAL(12, 2) NOT NULL,
    `tax_amount` DECIMAL(10, 2) DEFAULT 0.00,
    `shipping_cost` DECIMAL(10, 2) DEFAULT 0.00,
    `discount_amount` DECIMAL(10, 2) DEFAULT 0.00,
    `status` ENUM('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled', 'returned') DEFAULT 'pending',
    `payment_status` ENUM('unpaid', 'partial', 'paid', 'refunded') DEFAULT 'unpaid',
    `payment_method` VARCHAR(50),
    `shipping_address` TEXT,
    `shipping_city` VARCHAR(100),
    `shipping_state` VARCHAR(50),
    `shipping_postal_code` VARCHAR(20),
    `shipping_country` VARCHAR(100),
    `billing_address` TEXT,
    `tracking_number` VARCHAR(100),
    `notes` TEXT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX `idx_order_number` (`order_number`),
    INDEX `idx_customer_id` (`customer_id`),
    INDEX `idx_order_date` (`order_date`),
    INDEX `idx_status` (`status`),
    INDEX `idx_payment_status` (`payment_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================
-- ORDER_ITEMS TABLE
-- ====================================================
CREATE TABLE `order_items` (
    `order_item_id` INT PRIMARY KEY AUTO_INCREMENT,
    `order_id` INT NOT NULL,
    `product_id` INT NOT NULL,
    `quantity` INT NOT NULL,
    `unit_price` DECIMAL(10, 2) NOT NULL,
    `line_total` DECIMAL(12, 2) NOT NULL,
    `discount_applied` DECIMAL(10, 2) DEFAULT 0.00,
    `final_price` DECIMAL(12, 2) NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX `idx_order_id` (`order_id`),
    INDEX `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================
-- ADMIN_PASSWORDS TABLE
-- ====================================================
CREATE TABLE `admin_passwords` (
    `admin_id` INT PRIMARY KEY AUTO_INCREMENT,
    `username` VARCHAR(100) NOT NULL UNIQUE,
    `email` VARCHAR(150) NOT NULL UNIQUE,
    `password_hash` VARCHAR(255) NOT NULL,
    `password_salt` VARCHAR(255),
    `role` ENUM('super_admin', 'admin', 'manager', 'staff') DEFAULT 'staff',
    `is_active` BOOLEAN DEFAULT TRUE,
    `last_login` TIMESTAMP NULL,
    `login_attempts` INT DEFAULT 0,
    `locked_until` TIMESTAMP NULL,
    `password_changed_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_username` (`username`),
    INDEX `idx_email` (`email`),
    INDEX `idx_role` (`role`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================
-- INVOICES TABLE
-- ====================================================
CREATE TABLE `invoices` (
    `invoice_id` INT PRIMARY KEY AUTO_INCREMENT,
    `order_id` INT NOT NULL,
    `invoice_number` VARCHAR(50) NOT NULL UNIQUE,
    `invoice_date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `due_date` DATE,
    `subtotal` DECIMAL(12, 2) NOT NULL,
    `tax_amount` DECIMAL(10, 2) DEFAULT 0.00,
    `shipping_cost` DECIMAL(10, 2) DEFAULT 0.00,
    `discount_amount` DECIMAL(10, 2) DEFAULT 0.00,
    `total_amount` DECIMAL(12, 2) NOT NULL,
    `amount_paid` DECIMAL(12, 2) DEFAULT 0.00,
    `balance_due` DECIMAL(12, 2) NOT NULL,
    `payment_status` ENUM('unpaid', 'partial', 'paid', 'overdue', 'cancelled') DEFAULT 'unpaid',
    `invoice_status` ENUM('draft', 'issued', 'sent', 'viewed', 'paid', 'cancelled') DEFAULT 'draft',
    `payment_terms` VARCHAR(100),
    `notes` TEXT,
    `pdf_path` VARCHAR(500),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE KEY `uk_order_invoice` (`order_id`),
    INDEX `idx_invoice_number` (`invoice_number`),
    INDEX `idx_invoice_date` (`invoice_date`),
    INDEX `idx_payment_status` (`payment_status`),
    INDEX `idx_invoice_status` (`invoice_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================
-- INSERT SAMPLE DATA (Optional - for testing)
-- ====================================================

-- Sample customer
INSERT INTO `customers` 
(`first_name`, `last_name`, `email`, `phone`, `address`, `city`, `state`, `postal_code`, `country`) 
VALUES 
('John', 'Doe', 'john.doe@example.com', '+1-555-0101', '123 Main St', 'New York', 'NY', '10001', 'USA');

-- Sample products
INSERT INTO `products` 
(`product_name`, `description`, `category`, `color`, `size`, `material`, `price`, `cost`, `sku`) 
VALUES 
('Classic Cotton T-Shirt', 'High-quality 100% cotton t-shirt', 'Basic', 'Black', 'M', 'Cotton', 19.99, 8.50, 'TSHIRT-001-BLACK-M'),
('Premium Polo Shirt', 'Comfortable polo shirt with embroidery', 'Polo', 'Blue', 'L', 'Cotton Blend', 29.99, 12.00, 'TSHIRT-002-BLUE-L'),
('Sports Performance Tee', 'Moisture-wicking sports t-shirt', 'Sports', 'Red', 'S', 'Polyester', 24.99, 10.00, 'TSHIRT-003-RED-S');

-- Sample inventory
INSERT INTO `inventory` 
(`product_id`, `quantity_in_stock`, `reorder_level`, `reorder_quantity`, `warehouse_location`) 
VALUES 
(1, 150, 50, 100, 'Shelf A-1'),
(2, 200, 50, 100, 'Shelf B-2'),
(3, 85, 50, 100, 'Shelf C-1');

-- Sample admin user (password: admin123 - hashed with bcrypt: $2y$10$N9qo8uLOickgx2ZMRZoXyeS0Lfx0qSsHaFP1aFHH9XcH7V0Vx9Rz2)
INSERT INTO `admin_passwords` 
(`username`, `email`, `password_hash`, `role`) 
VALUES 
('admin', 'admin@example.com', '$2y$10$N9qo8uLOickgx2ZMRZoXyeS0Lfx0qSsHaFP1aFHH9XcH7V0Vx9Rz2', 'super_admin');

-- ====================================================
-- CREATE VIEWS (Optional - for common queries)
-- ====================================================

-- View: Order Summary with Customer Details
CREATE OR REPLACE VIEW `order_summary_view` AS
SELECT 
    o.order_id,
    o.order_number,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    c.phone,
    o.order_date,
    o.total_amount,
    o.status,
    o.payment_status,
    COUNT(oi.order_item_id) AS item_count
FROM `orders` o
JOIN `customers` c ON o.customer_id = c.customer_id
LEFT JOIN `order_items` oi ON o.order_id = oi.order_id
GROUP BY o.order_id;

-- View: Product Stock Status
CREATE OR REPLACE VIEW `product_stock_status_view` AS
SELECT 
    p.product_id,
    p.sku,
    p.product_name,
    p.color,
    p.size,
    p.price,
    i.quantity_in_stock,
    i.quantity_reserved,
    (i.quantity_in_stock - i.quantity_reserved) AS available_quantity,
    i.reorder_level,
    CASE 
        WHEN (i.quantity_in_stock - i.quantity_reserved) <= i.reorder_level THEN 'LOW'
        WHEN (i.quantity_in_stock - i.quantity_reserved) <= (i.reorder_level * 1.5) THEN 'MEDIUM'
        ELSE 'HIGH'
    END AS stock_status
FROM `products` p
LEFT JOIN `inventory` i ON p.product_id = i.product_id
WHERE p.is_active = TRUE;

-- ====================================================
-- CREATE STORED PROCEDURES (Optional - for complex operations)
-- ====================================================

DELIMITER $$

-- Procedure: Get Order Details
CREATE PROCEDURE `sp_get_order_details`(IN p_order_id INT)
BEGIN
    SELECT 
        o.order_id,
        o.order_number,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        c.email,
        c.phone,
        o.order_date,
        o.total_amount,
        o.status,
        o.payment_status
    FROM `orders` o
    JOIN `customers` c ON o.customer_id = c.customer_id
    WHERE o.order_id = p_order_id;
    
    SELECT 
        oi.order_item_id,
        p.product_name,
        p.sku,
        oi.quantity,
        oi.unit_price,
        oi.final_price
    FROM `order_items` oi
    JOIN `products` p ON oi.product_id = p.product_id
    WHERE oi.order_id = p_order_id;
END $$

-- Procedure: Create New Order
CREATE PROCEDURE `sp_create_order`(
    IN p_customer_id INT,
    IN p_total_amount DECIMAL(12,2),
    IN p_payment_method VARCHAR(50),
    OUT p_order_id INT
)
BEGIN
    DECLARE v_order_number VARCHAR(50);
    
    SET v_order_number = CONCAT('ORD-', DATE_FORMAT(NOW(), '%Y%m%d'), '-', LPAD(FLOOR(RAND() * 10000), 5, '0'));
    
    INSERT INTO `orders` 
    (`customer_id`, `order_number`, `total_amount`, `subtotal`, `payment_method`) 
    VALUES 
    (p_customer_id, v_order_number, p_total_amount, p_total_amount, p_payment_method);
    
    SET p_order_id = LAST_INSERT_ID();
END $$

DELIMITER ;

-- ====================================================
-- CREATE INDEXES FOR PERFORMANCE
-- ====================================================

-- Additional composite indexes for common queries
ALTER TABLE `orders` ADD INDEX `idx_customer_date` (`customer_id`, `order_date`);
ALTER TABLE `order_items` ADD INDEX `idx_order_product` (`order_id`, `product_id`);
ALTER TABLE `products` ADD INDEX `idx_price_category` (`price`, `category`);

-- ====================================================
-- DATABASE NOTES
-- ====================================================
/*
Database: T-Shirts Order Management System

Tables Overview:
1. customers - Store customer information and contact details
2. products - Store product catalog with specifications
3. inventory - Track stock levels and warehouse locations
4. orders - Store order transactions and status
5. order_items - Store individual items within orders
6. admin_passwords - Store admin user credentials and access control
7. invoices - Store billing and invoice records

Key Features:
- UTF8MB4 character set for international support
- Timestamp tracking for audit trail
- Foreign key constraints for data integrity
- Comprehensive indexing for query performance
- ENUM types for status management
- Sample data for testing
- Views for common queries
- Stored procedures for complex operations

Security Considerations:
- Passwords should be hashed using bcrypt or argon2
- Use prepared statements to prevent SQL injection
- Implement proper access control in application
- Regular backups recommended
- Monitor failed login attempts

*/
