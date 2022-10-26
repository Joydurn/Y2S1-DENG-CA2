use BikeSalesDWSP
--What are our most popular products and categories?
SELECT
    I.category_name as 'Category',
    I.product_id as 'ProductID',
    I.product_name as 'Name',
    SUM(S.Quantity) as 'Sales',
    CAST(SUM(S.Quantity)*100.0/(MIN(I.total_stock)+SUM(S.Quantity)) AS DECIMAL(18, 2)) as '% Stocks Sold',
    CAST(SUM(S.Quantity*S.Price*(1-S.Discount)) as DECIMAL(18,2)) as 'Revenue($)',
    MIN(I.total_stock) as 'Current Stock',
    MIN(I.total_stock)+SUM(S.Quantity) as 'Total Stock'
FROM 
    sales_fact S,
    inventory I, 
    time T
WHERE 
    --link FKs
    S.InventoryKey=I.InventoryKey
    AND S.OrderDate=T.TimeKey
    -- only get completed orders
    AND S.order_status=4
GROUP BY I.category_name, I.product_id,I.product_name
ORDER BY I.category_name,'% Stocks Sold' DESC, 'Revenue($)' DESC