SELECT LossGrouped.CustomerCategoryName, 
       LossGrouped.MaxLoss, 
       sub1.CustomerName, 
       sub1.CustomerID 
FROM 
	   (SELECT Cu.CustomerID, 
               Cu.CustomerName, 
               Ca.CustomerCategoryName, 
               Sum(ol.quantity * ol.unitprice) AS TotalValueLostOrders 
		 FROM   sales.orders AS O, 
               sales.orderlines AS ol, 
               sales.customers AS Cu, 
               sales.customercategories AS Ca 
		  WHERE  NOT EXISTS 
		  (SELECT * FROM   
				sales.invoices AS Iv 
           WHERE  Iv.orderid = O.orderid) 
				AND ol.orderid = O.orderid 
                AND Cu.CustomerID = O.CustomerID 
                AND Ca.customercategoryid = Cu.customercategoryid 
			GROUP  BY Cu.CustomerID, Cu.CustomerName, Ca.CustomerCategoryName) 
AS sub1 
JOIN
		(SELECT Loss.CustomerCategoryName, 
               Max(Loss.totalvaluelostorders) AS MaxLoss 
         FROM   
		(SELECT Cu.CustomerID, 
                Cu.CustomerName, 
                Ca.CustomerCategoryName, 
                Sum(ol.Quantity * ol.UnitPrice) AS TotalValueLostOrders
		FROM   Sales.Orders AS O, 
               Sales.OrderLines AS OL, 
               Sales.Customers AS Cu, 
			   Sales.CustomerCategories AS Ca 
        WHERE  NOT EXISTS 
				(SELECT Iv.OrderID 
				 FROM Sales.Invoices AS Iv 
                  WHERE  Iv.orderid = O.orderid) 
                  AND OL.OrderID = O.OrderID 
                  AND Cu.CustomerID = O.CustomerID 
                  AND Ca.customercategoryid = Cu.customercategoryid 
          GROUP  BY Cu.CustomerID, Cu.CustomerName, Ca.CustomerCategoryName) 
AS Loss 
        GROUP  BY CustomerCategoryName) 
AS LossGrouped 
ON  sub1.CustomerCategoryName = LossGrouped.CustomerCategoryName 
       AND sub1.totalvaluelostorders = LossGrouped.MaxLoss
ORDER  BY LossGrouped.MaxLoss DESC