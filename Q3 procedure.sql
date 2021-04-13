CREATE OR ALTER PROCEDURE ReportCustomerTurnover @Choice int = 1, @Year int = 2013  --using 1 and 2013 as default values
AS
BEGIN 

 -----------------------------------------------------------------------------------------------------------------------case 1

IF @Choice = 1
	BEGIN
	SELECT CustomerName,
				--using COALESCE and pivot to form months 
				COALESCE([1], 0) AS "January",
				COALESCE([2], 0) AS "February",
				COALESCE([3], 0) AS "March",
				COALESCE([4], 0) AS "April",
				COALESCE([5], 0) AS "May",
				COALESCE([6], 0) AS "June",
				COALESCE([7], 0) AS "July",
				COALESCE([8], 0) AS "August",
				COALESCE([9], 0) AS "September",
				COALESCE([10],0) AS "October",
				COALESCE([11],0) AS "November",
				COALESCE([12],0) AS "December"
				FROM (SELECT	
				Cu.CustomerName,
				MONTH(C1.InvoiceDate) AS InvoiceMonth, 
				SUM(C1.InvoiceTotal) AS InvoiceTotal
						FROM Sales.Customers AS Cu
				FULL JOIN (
					SELECT I.CustomerID, I.InvoiceID, I.InvoiceDate, SUM(Il.Quantity * Il.UnitPrice) AS InvoiceTotal
					FROM	Sales.Invoices AS I		
							FULL JOIN Sales.InvoiceLines AS Il on I.InvoiceID = Il.InvoiceID	
					WHERE	YEAR(I.InvoiceDate) = @Year
					GROUP BY I.CustomerID, I.InvoiceID, I.InvoiceDate
				--	HAVING SUM(Il.Quantity * Il.UnitPrice) <> 0    thought we should drop people with 0's, but turned out no :)
				) AS C1	on Cu.CustomerID = C1.CustomerID
		GROUP BY Cu.CustomerName, MONTH(C1.InvoiceDate)
		
		) AS MONTHS
		Pivot (
			MAX(InvoiceTotal) FOR InvoiceMonth IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])
		) AS Pivoted
		ORDER BY CustomerName

		END
	
------------------------------------------------------------------------------------------------------------------------------------case 2

	ELSE IF @Choice = 2
		BEGIN
			SELECT 
				CustomerName,
				COALESCE([1],0) AS Q1,
				COALESCE([2],0) AS Q2,
				COALESCE([3],0) AS Q3,
				COALESCE([4],0) AS Q4
		FROM (SELECT	
				Cu.CustomerName,
				DATEPART(quarter, C2.InvoiceDate) AS InvoiceQuarter, 
				SUM(C2.InvoiceTotal) AS InvoiceTotal
			  FROM	Sales.Customers AS Cu
				FULL JOIN (
					SELECT I.CustomerID, I.InvoiceID, I.InvoiceDate, SUM(Il.Quantity * Il.UnitPrice) AS InvoiceTotal
					FROM	Sales.Invoices AS I		
							FULL JOIN Sales.InvoiceLines AS Il on I.InvoiceID = Il.InvoiceID	
					WHERE	YEAR(I.InvoiceDate) = 2015
					GROUP BY I.CustomerID, I.InvoiceID, I.InvoiceDate
				) AS C2	
				ON Cu.CustomerID = C2.CustomerID
		GROUP BY Cu.CustomerName, DATEPART(quarter, C2.InvoiceDate)
		
		) AS Quarters
		Pivot (
			MAX(InvoiceTotal) FOR InvoiceQuarter IN ([1],[2],[3],[4])
		) AS Pivoted
		ORDER BY CustomerName
	END
	
------------------------------------------------------------------------------------------------------------------------------- case 3

	ELSE IF @Choice = 3
		BEGIN
			SELECT 
				CustomerName,
				COALESCE([2013],0) AS [2013],
				COALESCE([2014],0) AS [2014],
				COALESCE([2015],0) AS [2015],
				COALESCE([2016],0) AS [2016]
		FROM (SELECT	
				Cu.CustomerName AS CustomerName,
				SUM(Il.Quantity * Il.UnitPrice) AS InvoiceTotal,
				YEAR(I.InvoiceDate) AS InvoiceYear
			  FROM	Sales.Customers AS Cu,
				Sales.Invoices AS I,
				Sales.InvoiceLines AS Il
			  WHERE	Cu.CustomerID = I.CustomerID
			  AND I.InvoiceID = Il.InvoiceID
			  GROUP BY Cu.CustomerName, YEAR(I.InvoiceDate)) 
		AS YEARSandYEARS
		Pivot (
			MAX(InvoiceTotal) FOR InvoiceYear IN ([2013],[2014],[2015],[2016])
		) AS Pivoted 
		ORDER BY CustomerName
		END
END
GO
 -- test by running following commands:
EXEC ReportCustomerTurnover;
--EXEC ReportCustomerTurnover @choice = 1, @year = 2014
--EXEC ReportCustomerTurnover @choice = 2, @year = 2015
--EXEC ReportCustomerTurnover @choice = 3;