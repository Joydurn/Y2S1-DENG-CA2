IF NOT EXISTS (SELECT * FROM master.sys.databases WHERE name = 'BikeSalesSP')
    BEGIN
        EXEC('CREATE DATABASE BikeSalesSP')
    END
GO

USE BikeSalesSP;

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Production')
    BEGIN
        EXEC('CREATE SCHEMA Production;')
    END

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Sales')
    BEGIN
        EXEC('CREATE SCHEMA Sales;')
    END

CREATE TABLE Sales.Stores(
    store_id VARCHAR(5) PRIMARY KEY,
    store_name VARCHAR(255) NOT NULL,
    phone VARCHAR(25),
    email VARCHAR(255),
    street VARCHAR(255),
    city VARCHAR(255),
    state VARCHAR(10),
    zip_code VARCHAR(5)
)

CREATE TABLE Sales.Staffs(
    staff_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(25),
    active INT NOT NULL,
    --
    store_id VARCHAR(5) NOT NULL,
    manager_id INT,
    FOREIGN KEY (store_id) REFERENCES Sales.Stores (store_id)
                         ON DELETE CASCADE
                         ON UPDATE CASCADE,
    FOREIGN KEY (manager_id) REFERENCES Sales.Staffs (staff_id)
                         ON DELETE NO ACTION
                         ON UPDATE NO ACTION
)

CREATE TABLE Sales.Customers(
    customer_id VARCHAR(10) PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    phone VARCHAR(25),
    email VARCHAR(255) NOT NULL,
    street VARCHAR(255),
    city VARCHAR(50),
    state VARCHAR(25),
    zip_code VARCHAR(5)
)

CREATE TABLE Sales.Orders(
    order_id VARCHAR(10) PRIMARY KEY,
    customer_id VARCHAR(10),
    order_status INT NOT NULL,
    order_date DATE NOT NULL,
    required_date DATE NOT NULL,
    shipped_date DATE,
    store_id varchar(5) NOT NULL,
    staff_id int NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Sales.Customers (customer_id)
                        ON DELETE CASCADE
                        ON UPDATE CASCADE,
    FOREIGN KEY (store_id) REFERENCES Sales.Stores (store_id)
                        ON DELETE CASCADE
                        ON UPDATE CASCADE,
    FOREIGN KEY (staff_id) REFERENCES Sales.Staffs (staff_id)
                        ON DELETE NO ACTION
                        ON UPDATE NO ACTION
)

CREATE TABLE Production.Categories(
    category_id VARCHAR(5) PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL
)

CREATE TABLE Production.Brands(
    brand_id VARCHAR(5) PRIMARY KEY,
    brand_name VARCHAR(255) NOT NULL
)

CREATE TABLE Production.Products(
    product_id VARCHAR(10) PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    brand_id VARCHAR(5) NOT NULL,
    category_id VARCHAR(5) NOT NULL,
    model_year INT NOT NULL,
    list_price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (category_id) REFERENCES Production.Categories (category_id)
                                ON DELETE CASCADE
                                ON UPDATE CASCADE,
    FOREIGN KEY (brand_id) REFERENCES Production.Brands (brand_id)
                                ON DELETE CASCADE
                                ON UPDATE CASCADE
)

CREATE TABLE Production.Stocks(
    store_id VARCHAR(5),
    product_id VARCHAR(10),
    quantity INT,
    PRIMARY KEY (store_id, product_id),
    FOREIGN KEY (store_id) REFERENCES Sales.Stores (store_id)
                            ON DELETE CASCADE
                            ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Production.Products (product_id)
                            ON DELETE CASCADE
                            ON UPDATE CASCADE
)

CREATE TABLE Sales.Order_Items(
    order_id VARCHAR(10),
    item_id INT,
    product_id VARCHAR(10) NOT NULL,
    quantity INT NOT NULL,
    list_price DECIMAL(10, 2) NOT NULL,
    discount DECIMAL(4, 2) NOT NULL DEFAULT 0,
    PRIMARY KEY (order_id, item_id),
    FOREIGN KEY (order_id) REFERENCES Sales.Orders (order_id)
                            ON DELETE CASCADE
                            ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Production.Products (product_id)
                            ON DELETE CASCADE
                            ON UPDATE CASCADE
)
