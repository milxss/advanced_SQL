UPDATE [Sales].[InvoiceLines]
SET    [Sales].[InvoiceLines].Unitprice = [Sales].[InvoiceLines].Unitprice + 20 
WHERE  [Sales].[InvoiceLines].InvoicelineID = (SELECT TOP (1) IL.InvoiceLineID 
FROM	[Sales].[Customers] AS CU, 
	[Sales].[Invoices] AS I, 	
	[Sales].[InvoiceLines] AS IL 
WHERE  I.invoiceid = IL.invoiceid 
AND I.CustomerID = CU.CustomerID 
AND I.CustomerID = 1060 
ORDER  BY IL.InvoiceLineID ASC) 