CREATE TABLE warehouses (
    warehouse_id VARCHAR(10) PRIMARY KEY,
    name VARCHAR(100)
);


CREATE TABLE inventories (
    inventory_id VARCHAR(10) PRIMARY KEY,
    warehouse_id VARCHAR(10),
    name         VARCHAR(100),
    city         VARCHAR(100),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id)
);


CREATE TABLE employees (
    warehouse_id VARCHAR(10),
    employee_id VARCHAR(10) PRIMARY KEY,
    first_name   VARCHAR(50),
    last_name    VARCHAR(50),
    phone        VARCHAR(15),
    dob          DATE,
    role         VARCHAR(30),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id)
);


CREATE TABLE suppliers (
    supplier_id VARCHAR(10) PRIMARY KEY,
    name VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    country VARCHAR(50)
);

CREATE TABLE products (
    supplier_id     VARCHAR(10) NOT NULL,
    product_id      VARCHAR(10) PRIMARY KEY,
    category        VARCHAR(50),
    name            VARCHAR(150),
    description     VARCHAR(MAX),
    shelf_life      INT,
    is_cold         BIT,
    cost_price      INT,
    selling_price   INT,
    boxes_quantity  INT,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

CREATE TABLE restock_requests (
    restock_id      VARCHAR(10) PRIMARY KEY,
    warehouse_id    VARCHAR(10),
    supplier_id     VARCHAR(10),
    purchase_price  INT,
    status          VARCHAR(20) CHECK (status IN ('approved', 'rejected', 'pending')),
    requested_date  DATE,
    estimated_date  DATE,
    actual_date     DATE,
    delay           INT,
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

CREATE TABLE stock_level (
    batch_id        VARCHAR(10) PRIMARY KEY,
    restock_id      VARCHAR(10) NOT NULL,
    product_id      VARCHAR(10) NOT NULL,
    stored_in       VARCHAR(20), 
    purchase_cost   INT,
    quantity        INT,
    sold            INT,
    remaining       AS (quantity - sold) PERSISTED,
    is_expired      BIT,
    expiry_date     DATE,
    FOREIGN KEY (restock_id) REFERENCES restock_requests(restock_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE inventory_stock (
    inventory_id VARCHAR(10) NOT NULL,
    product_id   VARCHAR(10) NOT NULL,
    revenue      INT,
    quantity     INT NOT NULL,
    sold         INT NOT NULL DEFAULT 0,
    expired      INT NOT NULL DEFAULT 0,
    remaining    AS (quantity - sold - expired) PERSISTED,
    PRIMARY KEY (inventory_id, product_id),
    FOREIGN KEY (inventory_id) REFERENCES inventories(inventory_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE warehouse_stock (
    warehouse_id         VARCHAR(10) NOT NULL,
    product_id           VARCHAR(10) NOT NULL,
    total_received       INT NOT NULL,
    in_warehouse         INT NOT NULL,
    transferred          INT NOT NULL,
    total_sold           INT NOT NULL,
    sold_revenue         INT,
    sold_cost            INT,
    sold_profit          INT,
    Loss_from_Expired    INT,
    expired_in_warehouse INT NOT NULL,
    total_expired        INT NOT NULL,
    remaining            AS (total_received - total_sold - total_expired) PERSISTED,
    PRIMARY KEY (warehouse_id, product_id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE customers (
    customer_id VARCHAR(10) NOT NULL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    type VARCHAR(50) NOT NULL,
    phone VARCHAR(15),
    email VARCHAR(100),
    city VARCHAR(100)
);

CREATE TABLE vehicles (
    vehicle_id VARCHAR(10) PRIMARY KEY,
    has_cold_chain BIT NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('Available', 'Under Maintenance'))
);

CREATE TABLE orders (
    order_id                VARCHAR(10) PRIMARY KEY,
    emp_id                  VARCHAR(10) NOT NULL,
    inventory_id            VARCHAR(10) NOT NULL,
    customer_id             VARCHAR(10) NOT NULL,
    status                  VARCHAR(20) NOT NULL,
    order_date              DATE NOT NULL,
    total_price             INT,
    payment_methods         VARCHAR(50),
    expected_delivery_date  DATE,
    actual_delivery_date    DATE,
    delay                   INT,
    is_cold_chain           BIT,
    vehicle_id              VARCHAR(10),
    FOREIGN KEY (emp_id) REFERENCES employees(employee_id),
    FOREIGN KEY (inventory_id) REFERENCES inventories(inventory_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id)
);

CREATE TABLE order_contains (
    order_id   VARCHAR(10) NOT NULL,
    product_id VARCHAR(10) NOT NULL,
    price      INT,
    amount     INT NOT NULL,
    is_cold    BIT NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE incidents (
    incident_id    VARCHAR(10) PRIMARY KEY,
    order_id       VARCHAR(10) NOT NULL,
    incident_date  DATE NOT NULL,
    incident_type  VARCHAR(50),
    reason         VARCHAR(255),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
