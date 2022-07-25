use Wind


-- Nuber Of Orders And Order Average By Year/Month.
SELECT
	CONVERT(nvarchar ,YEAR(OrderDate)) + '/' + CONVERT(nvarchar ,MONTH(OrderDate)) AS [Date], 
	COUNT(distinct OrderID) as[NumberOfOrders], 
	ROUND(SUM(UnitPrice*Quantity)/COUNT(distinct OrderID),0) AS [OrderAverage]
FROM
	Orders
GROUP BY
	YEAR(OrderDate), MONTH(OrderDate)
ORDER BY
	YEAR(OrderDate), MONTH(OrderDate);




--Nuber Of Orders By Number Of Pordacts By Year.
SELECT
	YEAR, NumberOfProducts ,COUNT(NumberOfProducts) AS [NumberOfOrders]
FROM
				(SELECT
					YEAR(OrderDate) AS [Year] ,COUNT(OrderID) AS [NumberOfProducts], OrderID
				FROM
					Orders
				GROUP BY
					YEAR(OrderDate), OrderID) AS [NumberOfOprodactsByOrderID]
GROUP BY
	YEAR, NumberOfProducts
ORDER BY
	YEAR, NumberOfProducts




-- Number Of Customers By Seniority(The First Order) By Case Of Time.
SELECT
	Seniority, COUNT(CustomerID) AS [NumberOfCustomers]
FROM
				(SELECT
					CASE
						WHEN DATEDIFF(month, MIN(OrderDate), GETDATE()) <= 6 THEN '0 - 0.5 Years'
						WHEN DATEDIFF(month, MIN(OrderDate), GETDATE()) between  7 AND  12 THEN '0.6 - 1 Years'
						WHEN DATEDIFF(month, MIN(OrderDate), GETDATE()) between 13 AND  18 THEN '1.1 - 1.5 Years'
						WHEN DATEDIFF(month, MIN(OrderDate), GETDATE()) >= 19 THEN '1.6 - More Years'
						END as [Seniority], CustomerID
					FROM 
						Orders
					GROUP BY
						CustomerID) as [Seniority]
GROUP BY
	Seniority;



-- Percetage Of Unit Price By Category Name.
select
	P.CategoryName,  CONVERT(nvarchar,ROUND((SUM(UnitPrice) * 100 )/SUM(SUM(UnitPrice)) OVER (),2))+'%' as 'Percentage of Total Price'
from
	Orders O INNER JOIN Products P
	ON O.ProductID = P.ProductID
GROUP BY
	P.CategoryName
ORDER BY
	P.CategoryName




-- The First And The Last Order By Customer ID.
SELECT
	CustomerID, OrderDate, ROUND(UnitPrice* Quantity,0) AS [OrderPrice]
from 
	(SELECT v.*,
             row_number() over (partition by CustomerID order by OrderDate asc) AS seqnum_asc,
             row_number() over (partition by CustomerID order by OrderDate desc) AS seqnum_desc
      FROM Orders v
     ) v
WHERE 
	seqnum_asc = 1 or seqnum_desc = 1
ORDER BY
	CustomerID, OrderDate;



-- The Time Difference Between First And Lasr Order By Case Of Time.
SELECT
	FirstToLastOrder, COUNT(CustomerID) AS [NumberOfOrders]
FROM
				(SELECT 
				CustomerID, OrderDate, 
				ABS(DATEDIFF(month,OrderDate,LAG (OrderDate) OVER(PARTITION BY CustomerID ORDER BY (CustomerID)))) AS [DifferenceBetweenDates],
				case
					WHEN ABS(DATEDIFF(month,OrderDate,LAG (OrderDate) OVER(PARTITION BY CustomerID ORDER BY (CustomerID)))) <= 6 THEN '0 - 0.5 Year'
					WHEN ABS(DATEDIFF(month,OrderDate,LAG (OrderDate) OVER(PARTITION BY CustomerID ORDER BY (CustomerID)))) between 7 AND 12 THEN '0.6 - 1 Year'
					WHEN ABS(DATEDIFF(month,OrderDate,LAG (OrderDate) OVER(PARTITION BY CustomerID ORDER BY (CustomerID)))) >= 13 THEN '1.1 - More Years'
					END as [FirstToLastOrder]
			FROM 
				(select v.*,
						 row_number() over (partition by CustomerID order by OrderDate asc) as seqnum_asc,
						 row_number() over (partition by CustomerID order by OrderDate desc) as seqnum_desc
				  from Orders v
				 ) v
			WHERE 
				seqnum_asc = 1 or seqnum_desc = 1) AS [FirstAndLasrOrder]
WHERE
	FirstToLastOrder IS NOT NULL
GROUP BY
	FirstToLastOrder;




-- Creating Page With 10 Rows Of OrderID Row Number And Option To Search By Row Number (With Window Functions: ROW_NUMBER)
CREATE PROCEDURE dbo.OrderPage
(
	@start as int,
	@step as int = 10
) AS
BEGIN
	SELECT 
		OrderID, CustomerID, EmployeeID, OrderDate, ShipCity, ShipCountry, ProductID, UnitPrice, Quantity, Shipping, RowNumber
	FROM
			(SELECT 
				OrderID, CustomerID, EmployeeID, OrderDate, ShipCity, ShipCountry, ProductID, UnitPrice, Quantity, Shipping, 
				ROW_NUMBER() OVER (ORDER BY OrderID ASC) AS RowNumber
			FROM
				Orders) as [orderID]
	WHERE
		RowNumber > @start and RowNumber <= @step
END
GO


--Search By Row Number.
EXEC dbo.OrderPage 0;
go




-- Total Sales And Number Of Orders By Country.
SELECT
	ShipCountry AS [Country], ROUND(SUM(UnitPrice * Quantity),0) AS [Total], COUNT(DISTINCT OrderID) AS [NumberOfOrders]
FROM
	Orders
GROUP BY
	ShipCountry
ORDER BY
	ROUND(SUM(UnitPrice * Quantity),0) DESC;




-- Totsl Per Month in 2020.
SELECT	MONTH(OrderDate), SUM(UnitPrice * Quantity)
FROM	
	ORDERS
WHERE
	YEAR(OrderDate) = 2020
GROUP BY
	MONTH(OrderDate)
ORDER BY
	MONTH(OrderDate) ASC


