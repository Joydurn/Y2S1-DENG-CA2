USE BikeSalesDWSP;

/*
    Inserting into Customer Dimension
 */
INSERT INTO
    Customer
SELECT
    *
FROM
    BikeSalesSP.Sales.Customers

/*
    Inserting into Store Dimension
 */
INSERT INTO
    Store
SELECT
    *
FROM
    BikeSalesSP.Sales.Stores

/*
    Inserting into Staff Dimension
 */
INSERT INTO
    Staff
SELECT
    staff_id, first_name, last_name, email, phone, active, manager_id
FROM
    BikeSalesSP.Sales.Staffs

/*
    Inserting into Inventory Dimension
 */
INSERT INTO
    Inventory
SELECT
    p.product_id,
    p.product_name,
    p.model_year,
    p.list_price,
    c.category_name,
    b.brand_name,
    ISNULL(SUM(s.quantity), 0) 'total_stock',
    ISNULL(MAX(OI.order_date), GETDATE()) 'last_updated'
FROM
    BikeSalesSP.Production.Products p
JOIN
    BikeSalesSP.Production.Categories c ON c.category_id = p.category_id
JOIN
    BikeSalesSP.Production.Brands b ON b.brand_id = p.brand_id
LEFT JOIN
    BikeSalesSP.Production.Stocks s ON s.product_id = p.product_id
LEFT JOIN
    (SELECT
         OI.product_id,
         MAX(O.order_date) 'order_date'
    FROM
         BikeSalesSP.Sales.Order_Items OI
    JOIN
         BikeSalesSP.Sales.Orders O ON O.order_id = OI.order_id --AND O.order_status = 4
    GROUP BY
        OI.product_id) AS OI ON OI.product_id = P.product_id
GROUP BY
    p.product_id,
    p.product_name,
    p.model_year,
    p.list_price,
    c.category_name,
    b.brand_name
    
/*
    Inserting into Time Dimension
 */
INSERT INTO
    Time
SELECT DISTINCT
    order_date 'TimeKey',
    DATEPART(dw, order_date) 'dayOfWeek',
    DATENAME(dw, order_date) 'dayName',
    DATEPART(dd, order_date) 'dayOfMonth',
    DATEPART(mm, order_date) 'month',
    DATEPART(yyyy, order_date) 'year',
    DATEPART(quarter, order_date) 'quarter',
    (CASE WHEN MONTH(order_date) IN (12, 1, 2) THEN 'Winter'
          WHEN MONTH(order_date) IN (3, 4, 5) THEN 'Spring'
          WHEN MONTH(order_date) IN (6, 7, 8) THEN 'Summer'
          WHEN MONTH(order_date) IN (9, 10,11) THEN 'Fall'
     END) 'season'
FROM
    BikeSalesSP.Sales.Orders
/*
    Inserting into Sales Fact
 */
INSERT INTO
    Sales_Fact
SELECT
    S.StaffKey,
    C.CustomerKey,
    I.InventoryKey,
    T.TimeKey,
    ST.StoreKey,
    OI.quantity,
    OI.discount,
    OI.list_price,
    O.order_status
FROM
    BikeSalesSP.Sales.Orders O
LEFT JOIN
    BikeSalesSP.Sales.Order_Items OI ON O.order_id = OI.order_id
LEFT JOIN
    Store ST ON ST.store_id = O.store_id
LEFT JOIN
    Staff S ON S.staff_id = O.staff_id
LEFT JOIN
    Inventory I ON I.product_id = OI.product_id
LEFT JOIN
    Customer C ON C.customer_id = O.customer_id
LEFT JOIN
    Time T ON T.TimeKey = O.order_date
