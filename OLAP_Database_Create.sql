IF NOT EXISTS (SELECT * FROM master.sys.databases WHERE name = 'BikeSalesDWSP')
    BEGIN
        EXEC('CREATE DATABASE BikeSalesDWSP')
    END
GO

USE BikeSalesDWSP;

    CREATE TABLE Customer(
    CustomerKey INT IDENTITY(1, 1) PRIMARY KEY,
    customer_id VARCHAR(10) NOT NULL,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    phone VARCHAR(25),
    email VARCHAR(255) NOT NULL,
    street VARCHAR(255),
    city VARCHAR(50),
    state VARCHAR(25),
    zip_code VARCHAR(5)
)
GO

CREATE TABLE Inventory(
    InventoryKey INT IDENTITY(1, 1) PRIMARY KEY,
    product_id VARCHAR(10) NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    model_year INT NOT NULL,
    list_price DECIMAL(10, 2) NOT NULL,
    category_name VARCHAR(255) NOT NULL,
    brand_name VARCHAR(255),
    total_stock INT,
    last_updated DATE NOT NULL
)
GO

CREATE TABLE Staff(
    StaffKey INT IDENTITY(1, 1) PRIMARY KEY,
    staff_id INT NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(25),
    active INT NOT NULL,
    manager_id INT
)
GO

CREATE TABLE Store(
    StoreKey INT IDENTITY(1, 1) PRIMARY KEY,
    store_id VARCHAR(5) NOT NULL,
    store_name VARCHAR(255),
    phone VARCHAR(25),
    email VARCHAR(255),
    street VARCHAR(255),
    city VARCHAR(255),
    state VARCHAR(10),
    zip_code VARCHAR(5)
)
GO

CREATE TABLE Time(
    TimeKey DATE PRIMARY KEY,
    dayOfWeek INT NOT NULL,
    dayName VARCHAR(12) NOT NULL,
    dayOfMonth INT NOT NULL,
    month INT NOT NULL,
    year INT NOT NULL,
    quarter INT NOT NULL,
    season VARCHAR(12) NOT NULL
)
GO

CREATE TABLE Sales_Fact(
    StaffKey INT NOT NULL,
    CustomerKey INT NOT NULL,
    InventoryKey INT NOT NULL,
    OrderDate DATE NOT NULL,
    StoreKey INT NOT NULL,
    quantity INT NOT NULL,
    discount DECIMAL(4, 2) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    order_status varchar(255) NOT NULL,
    PRIMARY KEY (StaffKey, CustomerKey, InventoryKey, OrderDate, StoreKey),
    FOREIGN KEY (StaffKey) REFERENCES Staff (StaffKey)
        ON UPDATE CASCADE,
    FOREIGN KEY (CustomerKey) REFERENCES Customer (CustomerKey)
       ON UPDATE CASCADE,
    FOREIGN KEY (InventoryKey) REFERENCES Inventory (InventoryKey)
       ON UPDATE CASCADE,
    FOREIGN KEY (OrderDate) REFERENCES Time (TimeKey),
    FOREIGN KEY (StoreKey) REFERENCES Store (StoreKey)
       ON UPDATE CASCADE
)
