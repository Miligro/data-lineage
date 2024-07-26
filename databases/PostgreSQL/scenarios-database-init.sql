CREATE TABLE customers (
  id INT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  address VARCHAR(200) NOT NULL,
  city VARCHAR(50) NOT NULL,
  state VARCHAR(2) NOT NULL,
  zip_code VARCHAR(10) NOT NULL
);

CREATE TABLE orders (
  id INT PRIMARY KEY,
  customer_id INT NOT NULL,
  order_date DATE NOT NULL,
  paid INT DEFAULT 0,
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE customer_logs AS
SELECT id as customer_id, name, CURRENT_TIMESTAMP as log_time FROM customers;

CREATE TABLE products (
    id INT PRIMARY KEY,
    name VARCHAR(255),
    price DECIMAL(10, 2),
    is_active BOOLEAN
);

CREATE TABLE order_products (
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE VIEW expensive_products AS
SELECT
    id,
    name,
    price
FROM
    products
WHERE
    price > 80;

CREATE TABLE expensive_orders_products AS
SELECT
    ep.id as expensive_product_id,
    ep.name,
    ep.price,
    op.order_id,
    op.quantity
FROM expensive_products ep JOIN order_products op on ep.id = op.product_id;

CREATE OR REPLACE PROCEDURE create_expensive_products_view()
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM expensive_products;

    INSERT INTO expensive_products (id, name, price)
    SELECT
        id,
        name,
        price
    FROM
        products
    WHERE
        price > 80;

    CALL create_expensive_orders_products_table();
END;
$$;

CREATE OR REPLACE PROCEDURE create_expensive_orders_products_table()
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM expensive_orders_products;

    INSERT INTO expensive_orders_products (expensive_product_id, name, price, order_id, quantity)
    SELECT
        ep.id as expensive_product_id,
        ep.name,
        ep.price,
        op.order_id,
        op.quantity
    FROM expensive_products ep JOIN order_products op on ep.id = op.product_id;
END;
$$;

CREATE TEMP TABLE order_products_inactive AS
    SELECT op.* FROM order_products op JOIN products p ON op.product_id = p.id
    WHERE p.is_active = FALSE;

CREATE TABLE expensive_order_products_inactive AS
    SELECT opi.*, ep.price
    FROM order_products_inactive opi JOIN expensive_products ep ON opi.product_id = ep.id;
