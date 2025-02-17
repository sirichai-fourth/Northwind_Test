with ProductSales as (
	SELECT 
	    YEAR(o.OrderDate) AS OrderY, 
	    concat('Q-',DATEPART(QUARTER, o.OrderDate)) AS OrderQ, 
	    p.ProductName, 
	    sum(od.Quantity * p.Price) AS Sales 
	FROM (select OrderID, OrderDate from Orders) o
	JOIN (select OrderID, Quantity, ProductID from OrderDetails) od ON o.OrderID = od.OrderID
	JOIN (select ProductID, Price,ProductName, CategoryID  from Products) p ON od.ProductID = p.ProductID
	group by YEAR(o.OrderDate), DATEPART(QUARTER, o.OrderDate), p.ProductName
)
,PercentSales as (
	select  *, 
		case
			when PrevSales = 0 then Null
			else ROUND((((Sales - PrevSales)/ Sales) * 100), 2)
		end as PercentSalse  from (
			select *, COALESCE(LAG(Sales) OVER(PARTITION BY ProductName ORDER BY OrderY,OrderQ),0) as PrevSales from ProductSales
	) b
)
select OrderY, OrderQ, ProductName, Sales, PrevSales, PercentSalse from (
	select *, RANK() OVER(partition by OrderY order by PercentSalse desc) as ranks_1 from PercentSales
) b 
where ranks_1 = 1