USE BikeSalesDWSP;

/*
    Query 1: What discount rate is most profitable?
        - Discount rate (%)
        - Loss
        - Net Sales per unit
*/
SELECT
	discount*100 AS 'Discount (%)',
	sum(price*(discount)*quantity) AS Loss,
	sum(price*quantity) AS Revenue,
	sum(quantity) AS Sales,
	sum(price*quantity) -sum(price*(discount)*quantity)  AS 'Net Sales',
	(sum(price*quantity) -sum(price*(discount)*quantity) )/sum(quantity) AS 'Net Sales Per Unit',
	avg(price) 'Average List Price'
FROM [dbo].Sales_Fact
JOIN [Time] t ON sales_Fact.ORDERDate=t.TimeKey
WHERE ORDER_status=4
GROUP BY discount
ORDER BY 'Net Sales Per Unit' DESC

/*
    Query 2: Who is the best performing employee?
        - Year
        - Quarter
        - Store
        - Employee
*/

SELECT

	top 1 with ties  [Year],Quarter,sum(quantity) AS Sales,
    sum(price*(1-discount)) AS Revenue,
    last_name as Last_name,
    first_name as First_name,
    Sales_Fact.storekey as StoreKey,
    store_name as Store_name

FROM Sales_fact
LEFT JOIN Store ON store.StoreKey=Sales_Fact.StoreKey
INNER JOIN staff ON staff.StaffKey=Sales_Fact.StaffKey
LEFT JOIN [Time] ON [Time].TimeKey=Sales_Fact.ORDERDate
GROUP BY Sales_fact.StaffKey,[year],quarter,last_name,first_name,Sales_Fact.StoreKey,store_name
ORDER by (row_number() over (partition by quarter,[year] ORDER by sum(quantity) desc))


/*
    Query 3: What is the impact of seasonality on revenue gain?
        - Year
        - season
        - % change FROM last season
        - % change FROM seasonal average
        - best performing store
*/


SELECT

	year AS 'Year',
    season AS 'Season',
    FORMAT(sum(price*(1-discount)),'C2', 'us-US') AS 'Current_Revenue',
    FORMAT(LAG(sum(price*(1-discount)),4) OVER (
		ORDER BY year, CASE season
			 WHEN 'Spring' THEN 1
             WHEN 'Summer' THEN 2
             WHEN 'Fall' THEN 3
             WHEN 'Winter' THEN 4
			 ELSE 5
END
	),'C2', 'us-US') 'Previous Revenue',
	FORMAT(ROUND((sum(price*(1-discount))-LAG(sum(price*(1-discount)),4) OVER (
		ORDER BY year,
		     CASE season
				 WHEN 'Spring' THEN 1
	             WHEN 'Summer' THEN 2
	             WHEN 'Fall' THEN 3
	             WHEN 'Winter' THEN 4
				 ELSE 5
			 END)  )
     / LAG(sum(price*(1-discount)),4) OVER (
		ORDER BY year,
		     CASE season
				 WHEN 'Spring' THEN 1
	             WHEN 'Summer' THEN 2
	             WHEN 'Fall' THEN 3
	             WHEN 'Winter' THEN 4
				 ELSE 5
			END
	), 3),'P') AS '% Increase FROM Previous Year'

FROM [Time]
JOIN Sales_Fact SF ON Time.TimeKey = SF.ORDERDate
GROUP BY year, season
ORDER by YEAR,
		CASE season
			 WHEN 'Spring' THEN 1
             WHEN 'Summer' THEN 2
             WHEN 'Fall' THEN 3
             WHEN 'Winter' THEN 4
			 ELSE 5
		END



/*
    Query 4: Which state is the most popular and profitable for Trek Bicycle Store Inc. ?
        - Year
        - State
        - Number of Customers
        - Number of sales
        - Total revenue
*/
SELECT

    t.year AS 'Year',
    C.State AS 'US State',
    COUNT(C.CustomerKey) AS 'Customers',
    CAST(SUM(S.Quantity*S.Price*(1-S.Discount)) AS DECIMAL(18,2)) AS 'Revenue($)'

FROM 
    sales_fact S,
	customer C,
    time t
WHERE

    --link FKs
    S.CustomerKey=C.CustomerKey
    AND S.ORDERDate=T.TimeKey
    -- only get completed orders
    AND S.ORDER_status=4

GROUP BY t.year,C.state
ORDER BY t.year DESC, 'Customers' DESC,'Revenue($)' DESC

/*
    Query 5: What are our most popular products and categories?
        - Category
        - Top 3 Product
        - % quantity avail
*/

SELECT

   t.category_name AS 'Category',
   sum(t.total_stock) AS 'Available Stock',
   r.sales AS 'Sales',
   sum(t.total_stock) +r.sales AS 'Total Stock',
   r.sales*100 /(sum(t.total_stock) +r.sales ) AS 'Percent Sold (%)' ,
   pri.AveragePrice AS 'Average Price($)',
   j.revenue AS 'Revenue($)'

FROM
	(SELECT
		DISTINCT product_id,category_name,
		inventory.total_stock
	FROM  inventory
    LEFT JOIN Sales_Fact ON Inventory.InventoryKey=Sales_Fact.inventorykey
    ) t
LEFT JOIN Inventory ON Inventory.product_id=t.product_id
LEFT JOIN (
			SELECT category_name,
					sum(quantity) AS sales
			FROM Sales_Fact
		    LEFT JOIN Inventory ON Sales_Fact.InventoryKey=Inventory.InventoryKey
			GROUP BY category_name
		  ) r
ON r.category_name=t.category_name
LEFT JOIN (
		    SELECT category_name,
					SUM(Quantity*Price*(1-Discount)) AS 'Revenue'
		    FROM Sales_Fact
	        INNER JOIN Inventory ON Inventory.InventoryKey=Sales_Fact.InventoryKey
		    GROUP BY category_name
		  ) j
ON r.category_name=j.category_name
LEFT JOIN (
		    SELECT category_name,
					AVG(Price*(1-Discount)) AS 'AveragePrice'
		    FROM Sales_Fact
	        INNER JOIN Inventory ON Inventory.InventoryKey=Sales_Fact.InventoryKey
		    GROUP BY category_name
		  ) pri
ON j.category_name=pri.category_name

GROUP BY t.category_name,r.sales,j.revenue,pri.AveragePrice
ORDER BY 'Revenue($)' DESC


