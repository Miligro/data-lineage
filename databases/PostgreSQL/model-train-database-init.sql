CREATE TABLE users (
    user_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    password VARCHAR(255),
    registration_date DATE
);

CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    name VARCHAR(50)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    description TEXT,
    price DECIMAL(10, 2),
    category_id INT,
    added_date DATE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    user_id INT,
    order_date DATE,
    status VARCHAR(50),
    amount DECIMAL(10, 2),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE order_details (
    order_detail_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    price DECIMAL(10, 2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    order_id INT,
    amount DECIMAL(10, 2),
    payment_date DATE,
    payment_method VARCHAR(50),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE addresses (
    address_id INT PRIMARY KEY,
    user_id INT,
    street VARCHAR(100),
    city VARCHAR(50),
    postal_code VARCHAR(10),
    country VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE reviews (
    review_id INT PRIMARY KEY,
    product_id INT,
    user_id INT,
    rating INT,
    comment TEXT,
    review_date DATE,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE carts (
    cart_id INT PRIMARY KEY,
    user_id INT,
    creation_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE cart_products (
    cart_product_id INT PRIMARY KEY,
    cart_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (cart_id) REFERENCES carts(cart_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY,
    name VARCHAR(100),
    contact VARCHAR(100),
    email VARCHAR(100) UNIQUE
);

CREATE TABLE supplier_products (
    supplier_product_id INT PRIMARY KEY,
    supplier_id INT,
    product_id INT,
    purchase_price DECIMAL(10, 2),
    delivery_date DATE,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE order_history (
    order_history_id INT PRIMARY KEY,
    order_id INT,
    status VARCHAR(50),
    status_change_date DATE,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE payment_history (
    payment_history_id INT PRIMARY KEY,
    payment_id INT,
    amount DECIMAL(10, 2),
    payment_date DATE,
    payment_method VARCHAR(50),
    FOREIGN KEY (payment_id) REFERENCES payments(payment_id)
);

CREATE TABLE review_history (
    review_history_id INT PRIMARY KEY,
    review_id INT,
    rating INT,
    comment TEXT,
    change_date DATE,
    FOREIGN KEY (review_id) REFERENCES reviews(review_id)
);

CREATE TABLE promotions (
    promotion_id INT PRIMARY KEY,
    name VARCHAR(100),
    description TEXT,
    start_date DATE,
    end_date DATE
);

CREATE TABLE discount_codes (
    discount_code_id INT PRIMARY KEY,
    code VARCHAR(50),
    description TEXT,
    discount_value DECIMAL(5, 2),
    expiration_date DATE
);

CREATE TABLE payment_types (
    payment_type_id INT PRIMARY KEY,
    name VARCHAR(50)
);

CREATE TABLE delivery_types (
    delivery_type_id INT PRIMARY KEY,
    name VARCHAR(50),
    price DECIMAL(10, 2)
);

CREATE TABLE returns (
    return_id INT PRIMARY KEY,
    order_id INT,
    return_date DATE,
    status VARCHAR(50),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE complaints (
    complaint_id INT PRIMARY KEY,
    product_id INT,
    user_id INT,
    complaint_date DATE,
    status VARCHAR(50),
    description TEXT,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE related_products (
    product_id INT,
    related_product_id INT,
    PRIMARY KEY (product_id, related_product_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (related_product_id) REFERENCES products(product_id)
);

CREATE TABLE warehouses (
    warehouse_id INT PRIMARY KEY,
    name VARCHAR(100),
    address VARCHAR(255)
);

CREATE TABLE warehouse_products (
    warehouse_product_id INT PRIMARY KEY,
    product_id INT,
    warehouse_id INT,
    quantity INT,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id)
);

CREATE TABLE employee_roles (
    role_id INT PRIMARY KEY,
    name VARCHAR(50)
);

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    password VARCHAR(255),
    role_id INT,
    FOREIGN KEY (role_id) REFERENCES employee_roles(role_id)
);

CREATE TABLE action_logs (
    log_id INT PRIMARY KEY,
    employee_id INT,
    description TEXT,
    log_date DATE,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE newsletters (
    newsletter_id INT PRIMARY KEY,
    email VARCHAR(100) UNIQUE,
    subscription_date DATE
);

CREATE TABLE shipment_types (
    shipment_type_id INT PRIMARY KEY,
    name VARCHAR(50),
    price DECIMAL(10, 2)
);

CREATE TABLE shipments (
    shipment_id INT PRIMARY KEY,
    order_id INT,
    shipment_type_id INT,
    shipment_date DATE,
    status VARCHAR(50),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (shipment_type_id) REFERENCES shipment_types(shipment_type_id)
);

CREATE TABLE shipment_products (
    shipment_product_id INT PRIMARY KEY,
    shipment_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (shipment_id) REFERENCES shipments(shipment_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE conversations (
    conversation_id INT PRIMARY KEY,
    user_id INT,
    start_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE messages (
    message_id INT PRIMARY KEY,
    conversation_id INT,
    user_id INT,
    content TEXT,
    sent_date DATE,
    FOREIGN KEY (conversation_id) REFERENCES conversations(conversation_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE promotion_products (
    promotion_product_id INT PRIMARY KEY,
    product_id INT,
    promotion_id INT,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (promotion_id) REFERENCES promotions(promotion_id)
);

CREATE TABLE vip_clients (
    vip_client_id INT PRIMARY KEY,
    user_id INT,
    status_granted_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE login_history (
    login_history_id INT PRIMARY KEY,
    user_id INT,
    login_date DATE,
    ip_address VARCHAR(45),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE favorite_products (
    favorite_product_id INT PRIMARY KEY,
    user_id INT,
    product_id INT,
    added_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE product_types (
    product_type_id INT PRIMARY KEY,
    name VARCHAR(50)
);

CREATE TABLE reports (
    report_id INT PRIMARY KEY,
    name VARCHAR(100),
    description TEXT,
    creation_date DATE
);

CREATE TABLE promotion_calendar (
    promotion_calendar_id INT PRIMARY KEY,
    promotion_id INT,
    start_date DATE,
    end_date DATE,
    FOREIGN KEY (promotion_id) REFERENCES promotions(promotion_id)
);

CREATE TABLE notifications (
    notification_id INT PRIMARY KEY,
    user_id INT,
    content TEXT,
    sent_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE cart_history (
    cart_history_id INT PRIMARY KEY,
    cart_id INT,
    modification_date DATE,
    FOREIGN KEY (cart_id) REFERENCES carts(cart_id)
);

CREATE TABLE sales_statistics (
    sales_statistics_id INT PRIMARY KEY,
    product_id INT,
    quantity_sold INT,
    sale_date DATE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE VIEW user_orders_view AS
SELECT
    o.order_id,
    o.order_date,
    o.status,
    o.amount,
    u.first_name,
    u.last_name,
    u.email
FROM
    orders o
JOIN
    users u ON o.user_id = u.user_id;

CREATE VIEW order_details_view AS
SELECT
    od.order_id,
    od.product_id,
    p.name,
    od.quantity,
    od.price
FROM
    order_details od
JOIN
    products p ON od.product_id = p.product_id;

CREATE VIEW product_reviews_view AS
SELECT
    r.product_id,
    p.name,
    r.user_id,
    u.first_name,
    u.last_name,
    r.rating,
    r.comment,
    r.review_date
FROM
    reviews r
JOIN
    products p ON r.product_id = p.product_id
JOIN
    users u ON r.user_id = u.user_id;

CREATE VIEW user_cart_view AS
SELECT
    c.user_id,
    cp.product_id,
    p.name,
    cp.quantity
FROM
    carts c
JOIN
    cart_products cp ON c.cart_id = cp.cart_id
JOIN
    products p ON cp.product_id = p.product_id;

CREATE VIEW supplier_products_view AS
SELECT
    sp.supplier_id,
    s.name AS supplier,
    sp.product_id,
    p.name AS product,
    sp.purchase_price,
    sp.delivery_date
FROM
    supplier_products sp
JOIN
    suppliers s ON sp.supplier_id = s.supplier_id
JOIN
    products p ON sp.product_id = p.product_id;

CREATE VIEW order_history_view AS
SELECT
    oh.order_id,
    o.order_date,
    oh.status,
    oh.status_change_date
FROM
    order_history oh
JOIN
    orders o ON oh.order_id = o.order_id;

CREATE VIEW payment_history_view AS
SELECT
    ph.payment_id,
    p.payment_date,
    ph.amount,
    ph.payment_method
FROM
    payment_history ph
JOIN
    payments p ON ph.payment_id = p.payment_id;

CREATE VIEW user_returns_view AS
SELECT
    r.return_id,
    r.order_id,
    r.return_date,
    r.status,
    u.first_name,
    u.last_name,
    u.email
FROM
    returns r
JOIN
    orders o ON r.order_id = o.order_id
JOIN
    users u ON o.user_id = u.user_id;

CREATE VIEW product_complaints_view AS
SELECT
    c.complaint_id,
    c.product_id,
    p.name,
    c.user_id,
    u.first_name,
    u.last_name,
    c.complaint_date,
    c.status,
    c.description
FROM
    complaints c
JOIN
    products p ON c.product_id = p.product_id
JOIN
    users u ON c.user_id = u.user_id;

CREATE VIEW promotional_products_view AS
SELECT
    p.product_id,
    p.name,
    p.price,
    pr.name AS promotion,
    pr.start_date,
    pr.end_date
FROM
    products p
JOIN
    promotions pr ON p.product_id = pr.promotion_id;

CREATE VIEW user_discount_codes_view AS
SELECT
    dc.discount_code_id,
    dc.code,
    dc.description,
    dc.discount_value,
    dc.expiration_date,
    u.first_name,
    u.last_name,
    u.email
FROM
    discount_codes dc
JOIN
    users u ON dc.discount_code_id = u.user_id;

CREATE VIEW warehouse_products_view AS
SELECT
    wp.warehouse_id,
    w.name AS warehouse,
    wp.product_id,
    p.name AS product,
    wp.quantity
FROM
    warehouse_products wp
JOIN
    warehouses w ON wp.warehouse_id = w.warehouse_id
JOIN
    products p ON wp.product_id = p.product_id;

CREATE VIEW employees_and_roles_view AS
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.email,
    r.name AS role
FROM
    employees e
JOIN
    employee_roles r ON e.role_id = r.role_id;

CREATE VIEW employee_action_logs_view AS
SELECT
    al.log_id,
    al.description,
    al.log_date,
    e.first_name,
    e.last_name,
    r.name AS role
FROM
    action_logs al
JOIN
    employees e ON al.employee_id = e.employee_id
JOIN
    employee_roles r ON e.role_id = r.role_id;

CREATE VIEW newsletter_subscribers_view AS
SELECT
    n.newsletter_id,
    n.email,
    n.subscription_date
FROM
    newsletters n;

CREATE VIEW vip_clients_view AS
SELECT
    vc.user_id,
    u.first_name,
    u.last_name,
    u.email,
    vc.status_granted_date
FROM
    vip_clients vc
JOIN
    users u ON vc.user_id = u.user_id;

CREATE VIEW favorite_products_view AS
SELECT
    u.user_id,
    p.product_id,
    p.name,
    p.price,
    fp.added_date
FROM
    favorite_products fp
JOIN
    users u ON fp.user_id = u.user_id
JOIN
    products p ON fp.product_id = p.product_id;

CREATE VIEW cart_history_view AS
SELECT
    ch.cart_id,
    c.user_id,
    u.first_name,
    u.last_name,
    ch.modification_date
FROM
    cart_history ch
JOIN
    carts c ON ch.cart_id = c.cart_id
JOIN
    users u ON c.user_id = u.user_id;

CREATE VIEW sales_statistics_view AS
SELECT
    ss.product_id,
    p.name,
    SUM(ss.quantity_sold) AS quantity_sold,
    ss.sale_date
FROM
    sales_statistics ss
JOIN
    products p ON ss.product_id = p.product_id
GROUP BY
    ss.product_id, p.name, ss.sale_date;


CREATE OR REPLACE FUNCTION get_promotional_products_with_suppliers()
RETURNS TABLE (
    product_id INT,
    product_name VARCHAR,
    promotion_name VARCHAR,
    promotion_start_date DATE,
    promotion_end_date DATE,
    supplier_name VARCHAR,
    supplier_contact VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.product_id,
        p.name AS product_name,
        pr.name AS promotion_name,
        pr.start_date AS promotion_start_date,
        pr.end_date AS promotion_end_date,
        s.name AS supplier_name,
        s.contact AS supplier_contact
    FROM
        products p
    JOIN
        promotion_products pp ON p.product_id = pp.product_id
    JOIN
        promotions pr ON pp.promotion_id = pr.promotion_id
    JOIN
        supplier_products sp ON p.product_id = sp.product_id
    JOIN
        suppliers s ON sp.supplier_id = s.supplier_id
    WHERE
        pr.start_date <= CURRENT_DATE
        AND pr.end_date >= CURRENT_DATE;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION create_cart_for_user(p_user_id INT)
RETURNS INT AS $$
DECLARE
    v_cart_id INT;
BEGIN
    INSERT INTO carts (user_id, creation_date) VALUES (p_user_id, CURRENT_DATE) RETURNING cart_id INTO v_cart_id;

    RETURN v_cart_id;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION add_user_and_cart(
    p_first_name VARCHAR,
    p_last_name VARCHAR,
    p_email VARCHAR,
    p_password VARCHAR
) RETURNS TABLE(new_user_id INT, new_cart_id INT) AS $$
DECLARE
    v_new_user_id INT;
BEGIN
    INSERT INTO users (first_name, last_name, email, password, registration_date)
    VALUES (p_first_name, p_last_name, p_email, p_password, CURRENT_DATE)
    RETURNING user_id INTO v_new_user_id;

    CALL create_cart_for_user(v_new_user_id);
END;
$$ LANGUAGE plpgsql;