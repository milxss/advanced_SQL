SELECT 
		temp1.CustomerID,
		temp3.CustomerName,
		temp1.OrderTotalNB,
		temp2.TotalOrderValue,
		temp3.InvoicesTotalValue,
		temp3.NBTotalInvoices,
		Abs(temp2.TotalOrderValue - temp3.InvoicesTotalValue) AS AbsoluteValueDifference
FROM 
		(SELECT 
			CustomerID,
			COUNT (*) AS OrderTotalNB
		FROM Sales.Orders as o
		--WHERE PickingCompletedWhen IS NOT NULL
		Group by CustomerID) 
	AS temp1
JOIN
		(SELECT 
			cu.CustomerID,
			Sum(PickedQuantity * UnitPrice) As TotalOrderValue
		FROM Sales.OrderLines as ol,
		Sales.Orders as o,
		sales.Customers as cu
		WHERE o.OrderID = ol.OrderID
		AND o.CustomerID = cu.CustomerID
		Group by cu.CustomerID) 
	AS temp2
	ON temp1.customerid = temp2.customerid
JOIN
			(SELECT i.customerid,
			 customername,
			 			 Count(DISTINCT i.invoiceid) AS NBTotalInvoices,
						 SUM(Quantity * UnitPrice) AS InvoicesTotalValue
			 FROM Sales.InvoiceLines as il,
			 Sales.Invoices as i,
			 sales.Customers as cu,
			 sales.Orders as o
			 WHERE il.InvoiceID = i.InvoiceID
			 AND cu.CustomerID = i.CustomerID
			 and i.InvoiceID = il.InvoiceID
			 AND i.OrderID = o.OrderID
			 group by i.CustomerID, customername
			) 
	AS temp3
	ON temp1.CustomerID = temp3.CustomerID
	AND temp2.CustomerID = temp3.CustomerID

ORDER  BY absolutevaluedifference DESC, 
          OrderTotalNB ASC, 
          temp3.customername ASC
