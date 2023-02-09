----********************************************************************************************
--  Step 3.  This script will two triggers attached under the table [OrderItem].
--  The triggers will be fired whenever records in the table [OrderItem] are inserted/modified/deleted.
--  The triggers will try to update the columns OrderGroup.TotalLineItems and OrderGroup.SavedTotal 
--  For a given OrderNumber = X, 
--			OrderGroup.TotalLineItems = COUNT(OrderItem.OrderItemNumber) WHERE OrderItem.OrderNumber = X and 
--			OrderGroup.SavedTotal = SUM(OrderItem.LineItemTotal) WHERE OrderItem.OrderNumber = X
----********************************************************************************************

USE MUMSNETDB

GO

IF EXISTS(SELECT * FROM sysobjects WHERE name = 'OrderItem_INSERT' AND xtype='TR')
	DROP TRIGGER [dbo].[OrderItem_INSERT] 

GO

IF EXISTS(SELECT * FROM sysobjects WHERE name = 'OrderItem_UPDATE' AND xtype='TR')
	DROP TRIGGER [dbo].[OrderItem_UPDATE] 

GO

IF EXISTS(SELECT * FROM sysobjects WHERE name = 'OrderItem_DELETE' AND xtype='TR')
	DROP TRIGGER [dbo].[OrderItem_DELETE] 

GO

CREATE TRIGGER [dbo].[OrderItem_INSERT]
       ON [dbo].[OrderItem]
AFTER INSERT
AS
BEGIN
		SET NOCOUNT ON;
 
		DECLARE @i_OrderNumber nvarchar(50);
 
		SELECT @i_OrderNumber = INSERTED.OrderNumber  FROM INSERTED;
 
		MERGE OrderGroup AS Ogp
		USING(SELECT COUNT(OrderItemNumber) as TotalLineItems, 
		SUM(LineItemTotal) as SavedTotal, OrderNumber FROM OrderItem WHERE OrderItem.OrderNumber=@i_OrderNumber GROUP BY OrderNumber) AS OdrAgg   
		ON Ogp.OrderNumber=OdrAgg.OrderNumber 
		WHEN MATCHED THEN
			UPDATE SET Ogp.TotalLineItems=OdrAgg.TotalLineItems , Ogp.SavedTotal = OdrAgg.SavedTotal;

END

GO

CREATE TRIGGER [dbo].[OrderItem_DELETE]
       ON [dbo].[OrderItem]
AFTER DELETE
AS
BEGIN
       SET NOCOUNT ON;
 
       DECLARE @d_OrderNumber nvarchar(50)
 
       SELECT @d_OrderNumber = DELETED.OrderNumber FROM DELETED

	
	   IF EXISTS(SELECT * FROM OrderItem WHERE OrderItem.OrderNumber=@d_OrderNumber)
		   BEGIN
				MERGE OrderGroup AS Ogp
				USING(SELECT COUNT(OrderItemNumber) as TotalLineItems, 
				SUM(LineItemTotal) as SavedTotal, OrderNumber FROM OrderItem WHERE OrderItem.OrderNumber=@d_OrderNumber GROUP BY OrderNumber) AS OdrAgg   
				ON Ogp.OrderNumber=OdrAgg.OrderNumber 
				WHEN MATCHED THEN
					UPDATE SET Ogp.TotalLineItems=OdrAgg.TotalLineItems , Ogp.SavedTotal = OdrAgg.SavedTotal;
		   END
	   ELSE
			UPDATE OrderGroup SET TotalLineItems=0, SavedTotal=0 WHERE OrderGroup.OrderNumber=@d_OrderNumber;
			

END

GO

CREATE TRIGGER [dbo].[OrderItem_UPDATE]
       ON [dbo].[OrderItem]
AFTER UPDATE
AS
BEGIN
       SET NOCOUNT ON;
 
       DECLARE @u_OrderNumber nvarchar(50)
 
       SELECT @u_OrderNumber = INSERTED.OrderNumber  FROM INSERTED

	
	   IF EXISTS(SELECT * FROM OrderItem WHERE OrderItem.OrderNumber=@u_OrderNumber)
		   BEGIN
				MERGE OrderGroup AS Ogp
				USING(SELECT COUNT(OrderItemNumber) as TotalLineItems, 
				SUM(LineItemTotal) as SavedTotal, OrderNumber FROM OrderItem WHERE OrderItem.OrderNumber=@u_OrderNumber GROUP BY OrderNumber) AS OdrAgg   
				ON Ogp.OrderNumber=OdrAgg.OrderNumber 
				WHEN MATCHED THEN
					UPDATE SET Ogp.TotalLineItems=OdrAgg.TotalLineItems , Ogp.SavedTotal = OdrAgg.SavedTotal;
		   END
	   ELSE
			UPDATE OrderGroup SET TotalLineItems=0, SavedTotal=0 WHERE OrderGroup.OrderNumber=@u_OrderNumber;
			
END