with CustomerSpen as 
	(
	select OrderID, CustomerID, CustomerName, Country, sum(Spending) as Spending
	from (select o.OrderID, c.CustomerID, c.CustomerName, c.Country, od.Quantity, p.Price, (od.Quantity * p.Price) as Spending 
	from (select OrderID, CustomerID from Orders) o 
	join (select OrderID, ProductID, Quantity from OrderDetails) od on o.OrderID = od.OrderID 
	join (select CustomerID, CustomerName, Country from Customers) c on o.CustomerID = c.CustomerID 
	join (select ProductID, Price from Products) p on od.ProductID = p.ProductID 
	where od.Quantity > 10) b
	group by OrderID, CustomerID, CustomerName, Country
	having sum(Spending) > 1000
    ),
GroupCountry as
 (select CustomerID, CustomerName, Country, sum(Spending) as Spending from CustomerSpen group by CustomerID, CustomerName, Country),
TopSpending as 
	(select *, row_number() over(partition by Country order by Spending desc) as TopSpend from GroupCountry)
select CustomerID, CustomerName, Country, Spending 
from TopSpending 
where TopSpend = 1 
order by Spending desc;