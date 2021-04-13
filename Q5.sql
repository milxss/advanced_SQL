SELECT * 
FROM   [dbo].[Customer] AS CU 
WHERE  NOT EXISTS (SELECT * 
	FROM   [dbo].[Product] AS P 
		WHERE  NOT EXISTS (SELECT * 
				   FROM [dbo].[Purchase] AS PU 
				   WHERE  PU.productid = P.productid 
				   AND CU.customerid = PU.customerid)) 
	AND (SELECT Sum(PU.Qty) 
	     FROM [dbo].[Purchase] AS PU 
	     WHERE  PU.customerid = CU.customerid) >= 50 