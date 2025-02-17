CREATE PROCEDURE dbo.reportSalesQByCategory
	-- create parameter @Year
	@Year NVARCHAR(4)
AS
BEGIN
	-- create variable @sql
	DECLARE @sql NVARCHAR(MAX);

	-- Start transaction
	BEGIN TRANSACTION;
		-- Start Try
		BEGIN TRY
			-- Set query to @sql
			SET @sql = '
				SELECT CategoryName, OrderY,[1] AS Q1, [2] AS Q2, [3] AS Q3, [4] AS Q4
                FROM (
                    SELECT 
                        DATEPART(YEAR, o.OrderDate) AS OrderY, 
                        DATEPART(QUARTER, o.OrderDate) AS OrderQ, 
                        c.CategoryName, 
                        (od.Quantity * p.Price) AS Spending 
                    FROM (select OrderID, OrderDate from Orders) o
                    JOIN (select OrderID, Quantity, ProductID from OrderDetails) od ON o.OrderID = od.OrderID
                    JOIN (select ProductID, Price, CategoryID  from Products) p ON od.ProductID = p.ProductID
                    JOIN (select CategoryID, CategoryName from Categories) c ON p.CategoryID = c.CategoryID
                    WHERE YEAR(o.OrderDate) = '+ QUOTENAME(@Year, '''') +'
				) AS SourceTable
				PIVOT (
				    SUM(Spending)
				    FOR OrderQ IN ([1], [2], [3], [4])
				) AS pvt;'
			
			-- execute sql
			EXEC sp_executesql @sql;
			-- Commit Transaction
			COMMIT TRANSACTION;
			PRINT 'Transaction Committed Successfully';
		END TRY
		-- Start CATCH
		BEGIN CATCH
			-- Rollback the transaction
        	ROLLBACK TRANSACTION;
        	PRINT 'Transaction Committed Error';
		END CATCH
END
