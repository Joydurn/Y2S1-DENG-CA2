EXEC master.dbo.sp_configure 'show advanced options', 1
EXEC master.dbo.sp_configure 'xp_cmdshell', 1
GO
RECONFIGURE
GO


DECLARE @StockSQL VARCHAR(4000);
SET @StockSQL = 'bcp "USE BikeSalesSP;SELECT CAST((SELECT s.product_id, s.store_id, s.quantity, p.product_name, b.brand_name, c.category_name, p.list_price, p.model_year FROM Production.stocks S JOIN Production.products P ON p.product_id = S.product_id JOIN Production.brands B ON b.brand_id = P.brand_id JOIN Production.categories C ON C.category_id = P.category_id WHERE s.quantity > 0 FOR JSON PATH) AS VARCHAR(MAX))" queryout "C:\Temp\Stock.json" -c -T'
EXEC sys.xp_CMDSHELL @StockSQL

