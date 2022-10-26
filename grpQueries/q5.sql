use BikeSalesDWSP
--What are our most popular products and categories?
SELECT 
    I.category_name as 'Category',
    I.product_id as 'ProductID',
    I.product_name as 'Name',
    SUM(S.Quantity) as 'quantity',
    MAX(I.total_stock) as 'totalstock MAX',
    AVG(I.total_stock) as 'totalstock AVG',
    MAX(I.total_stock)-AVG(I.total_stock) as 'max and avg difference',
    CAST(SUM(S.Quantity)*100.0/((
    SELECT 
        (SELECT
            I.product_id as 'productid',
            I.total_stock as 'stock',
            S.OrderDate as 'date',
            ROW_NUMBER() OVER (Partition by I.product_id ORDER BY S.OrderDate) as 'RowNum'
        FROM Sales_Fact S, inventory I,Time T 
        WHERE RowNum=1)
    WHERE
        S.InventoryKey=I.InventoryKey
        AND S.OrderDate=T.TimeKey
    GROUP BY 
        I.product_id,I.total_stock,S.OrderDate
    HAVING 
        S.OrderDate=MAX(T.TimeKey)
    ) +SUM(S.Quantity)) AS DECIMAL(6, 2)) as '% Stocks Sold',
    --get most recent total stock value
    -- (AVG(I.total_stock)
    
    CAST(SUM(S.Quantity*S.Price*(1-S.Discount)) as DECIMAL(18,2)) as 'Revenue($)',
    MAX(I.total_stock) as 'Total Stock'
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
-- ORDER BY '% Stocks Sold' DESC, 'Revenue($)' DESC