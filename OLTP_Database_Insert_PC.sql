-- DECLARE @sysuser NVARCHAR(30)
--
-- SET @sysuser = SYSTEM_USER
--
-- PRINT @sysuser
-- EXEC sp_defaultlanguage @sysuser, 'british'

USE BikeSalesSP;
/*
    Insert into Customers Table
 */
BULK INSERT
        Sales.Customers
    FROM
        'C:/customers.csv'
    WITH
    (fieldterminator=',',
    rowterminator='\n',
    firstrow=2)

/*
    Insert into Store Table
 */
DECLARE @StoreJSON VARCHAR(MAX);

SELECT
        @StoreJSON = BulkColumn FROM OPENROWSET(BULK 'C:/Stores.json', SINGLE_BLOB) JSON

INSERT INTO
    Sales.Stores
SELECT
    *
FROM
    OPENJSON(@StoreJSON, '$') WITH (
        store_id VARCHAR(5) '$.store_id',
        store_name VARCHAR(255) '$.store_name',
        phone VARCHAR(25) '$.phone',
        email VARCHAR(255) '$.email',
        street VARCHAR(255) '$.street',
        city VARCHAR(255) '$.city',
        state VARCHAR(10) '$.state',
        zip_code VARCHAR(5) '$.zip_code'
        )

/*
    Insert into Staff Table
 */
DECLARE @StaffJSON VARCHAR(MAX)

SELECT
        @StaffJSON = BulkColumn FROM OPENROWSET(BULK 'C:/staff.json', SINGLE_BLOB) JSON

INSERT INTO
    Sales.Staffs
SELECT
    staff_id,
    first_name,
    last_name,
    email,
    phone,
    active,
    store_id,
    NULLIF(manager_id, 'NULL')
FROM
    OPENJSON(@StaffJSON, '$') WITH (
        staff_id INT '$.staff_id',
        first_name VARCHAR(50) '$.first_name',
        last_name VARCHAR(50) '$.last_name',
        email VARCHAR(255) '$.email',
        phone VARCHAR(25) '$.phone',
        active INT '$.active',
        store_id VARCHAR(5) '$.store_id',
        manager_id VARCHAR(5) '$.manager_id'
        )

/*
    Insert into Categories Table [JSON FORMAT]
 */
DECLARE @CategoryJSON VARCHAR(MAX)

SELECT
        @CategoryJSON = BulkColumn FROM OPENROWSET(BULK 'C:/Category.json', SINGLE_BLOB) JSON

INSERT INTO
    Production.categories
SELECT
    *
FROM
    OPENJSON(@CategoryJSON, '$') WITH (
        category_id VARCHAR(5) '$.category_id',
        category_name VARCHAR(255) '$.category_name'
        )

/*
    Insert into Brands Table [JSON FORMAT]
*/
DECLARE @BrandsJSON VARCHAR(MAX)

SELECT
        @BrandsJSON = BulkColumn FROM OPENROWSET(BULK 'C:/brands.json', SINGLE_BLOB) JSON

INSERT INTO
    Production.Brands
SELECT
    *
FROM
    OPENJSON(@BrandsJSON, '$') WITH (
        brand_id VARCHAR(5) '$.brand_id',
        brand_name VARCHAR(255) '$.brand_name'
        )

/*
    Insert into Products table
 */
DECLARE @ProductsJSON VARCHAR(MAX)

SELECT
        @ProductsJSON = BulkColumn FROM OPENROWSET(BULK 'C:/products.json', SINGLE_BLOB) JSON

INSERT INTO
    Production.Products
SELECT
    *
FROM
    OPENJSON(@ProductsJSON, '$') WITH (
        product_id VARCHAR(10) '$.product_id',
        product_name VARCHAR(255) '$.product_name',
        brand_id VARCHAR(5) '$.brand_id',
        category_id VARCHAR(5) '$.category_id',
        model_year INT '$.model_year',
        list_price DECIMAL(10, 2) '$.list_price'
        )

/*
    Insert into Stocks tables
 */
BULK INSERT
    Production.Stocks
    FROM
        'C:/Stocks.csv'
    WITH
        (fieldterminator=',',
        rowterminator='0x0d0a',
        firstrow=2)

/*
    Insert into Orders Table
 */
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Staging')
    BEGIN
        EXEC('CREATE SCHEMA Staging;')
    END

CREATE TABLE Staging.Orders(
                               order_id varchar(255),
                               customer_id varchar(255),
                               order_status varchar(255),
                               order_date varchar(255),
                               required_date varchar(255),
                               shipped_date varchar(255),
                               store_id varchar(255),
                               staff_id int
)

BULK INSERT
    Staging.Orders
    FROM
    'C:/Orders.csv'
    WITH
    (fieldterminator=',',
    rowterminator='\n',
    firstrow=2,
    keepnulls);

UPDATE
    Staging.Orders
SET
    Shipped_date = NULL
WHERE
        Shipped_Date = 'NULL'

INSERT INTO
    Sales.Orders
SELECT
    order_id,
    customer_id,
    order_status,
    CONVERT(datetime, order_date, 103),
    CONVERT(datetime, required_date, 103),
    IIF(shipped_date = '', NULL, CONVERT(datetime, shipped_date, 103)),
    store_id,
    staff_id
FROM
    Staging.Orders

/*
    Insert into OrderItems Table
 */
BULK INSERT
    Sales.order_items
    FROM
        'C:/OrderItems.csv'
    WITH
        (fieldterminator=',',
        rowterminator='\n',
        firstrow=2)
