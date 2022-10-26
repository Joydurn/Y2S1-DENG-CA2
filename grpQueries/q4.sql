use BikeSalesDWSP
--Which state is the most popular and profitable for Trek Bicycle Store Inc. ?
SELECT 
    t.year as 'Year',
    C.State as 'US State',
    COUNT(C.CustomerKey) as 'Customers',
    CAST(SUM(S.Quantity*S.Price*(1-S.Discount)) as DECIMAL(18,2)) as 'Revenue($)'
FROM 
    sales_fact S,
    customer C,
    time t
WHERE 
    --link FKs
    S.CustomerKey=C.CustomerKey
    AND S.OrderDate=T.TimeKey
    -- only get completed orders
    AND S.order_status=4
GROUP BY t.year,C.state
ORDER BY t.year DESC, 'Customers' DESC,'Revenue($)' DESC