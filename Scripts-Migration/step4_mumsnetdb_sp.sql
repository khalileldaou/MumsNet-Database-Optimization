----********************************************************************************************
--  Step 4.  This script will two stored procedures to create OrderGroup and OrderItem.
--  Some error checking and handling procedures were added.
----********************************************************************************************


USE [MUMSNETDB]

GO

IF OBJECT_ID ( 'dbo.prCreateOrderGroup', 'P' ) IS NOT NULL  
    DROP PROCEDURE prCreateOrderGroup;  
GO


----------prCreateOrderGroup-----------------------
CREATE PROCEDURE prCreateOrderGroup 
@OrderNumber nvarchar(50), 
@OrderCreateDate datetime, 
@CustomerID int, 
@BillingCurrency nvarchar(8), 
@TotalLineItems int, 
@SavedTotal int, 
@result nvarchar(128) OUTPUT
AS
	DECLARE @OrderStatusCode int
	DECLARE @retcode int
	SET @result = 'SUCCESS: 1 row inserted.'
	SET @retcode = 0
	SET  @OrderStatusCode = 0 -- Default is 0 for newly added order

	IF (@OrderNumber IS NULL OR @OrderCreateDate IS NULL OR @CustomerID IS NULL OR @BillingCurrency IS NULL OR @TotalLineItems IS NULL OR @SavedTotal IS NULL)
		BEGIN
			SET @result = 'ERROR: NULL values were found in input parameters. 0 row inserted.'
			RETURN @retcode;
		END

	IF NOT EXISTS(SELECT OrderNumber FROM OrderGroup WHERE OrderNumber = @OrderNumber) --Check the existence of ordernumber in OrderGroup table
		BEGIN
			IF EXISTS(SELECT * FROM Customer WHERE CustomerID = @CustomerID) --Check the existence of CustomerCityID in Customer table
				BEGIN
					IF (@OrderNumber LIKE 'OR\[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\[0-9][0-9]')
						BEGIN
								IF (ISDATE(@OrderCreateDate) = 1)
									BEGIN 
										INSERT INTO OrderGroup VALUES (@OrderNumber, @OrderStatusCode, @CustomerID, @OrderCreateDate, @BillingCurrency, @TotalLineItems, @SavedTotal)
										SET @retcode = 1
									END
								ELSE
									SET @result = 'ERROR: Order Create Date ' + @OrderCreateDate + ' is invalid. 0 row inserted.'
						END
					ELSE
						SET @result = 'ERROR: Order Number ' + @OrderNumber + ' is invalid format. 0 row inserted.'

				END
			ELSE
				SET @result = 'ERROR: CustomerCityID ' + @CustomerID + ' does not exist in table Customer. 0 row inserted.'
		END
	ELSE
		SET @result = 'ERROR: OrderNumber ' + @OrderNumber + ' already exists in table OrderGroup. 0 row inserted.'

	RETURN @retcode;

GO

-----Trial code to execute the  -----------------
--DECLARE @sp_result nvarchar(128)
--DECLARE @ret int

--EXEC @ret = prCreateOrderGroup 
--@OrderNumber='OR\05052022\02', 
--@OrderCreateDate= '2022-11-02', 
--@CustomerID=1, 
--@BillingCurrency='GBP', 
--@TotalLineItems=2, 
--@SavedTotal=3, 
--@result=@sp_result OUTPUT

--SELECT @sp_result 
--SELECT @ret 


--------prCreateOrderItem------------------------------------
IF OBJECT_ID ( 'dbo.prCreateOrderItem', 'P' ) IS NOT NULL  
    DROP PROCEDURE prCreateOrderItem;  
GO


CREATE PROCEDURE prCreateOrderItem 
@OrderItemNumber nvarchar(32), 
@OrderNumber nvarchar(32), 
@VariantCode nvarchar(255), 
--@ProductCode nvarchar(255), 
--@ProductGroup nvarchar(128), 
@Quantity int, 
@UnitPrice money, 
@result nvarchar(128) OUTPUT
AS
	DECLARE @retcode int
	SET @result = 'SUCCESS: 1 row inserted.'
	SET @retcode = 0

	IF (@OrderNumber IS NULL OR @OrderItemNumber IS NULL OR  @VariantCode IS NULL OR @Quantity IS NULL OR @UnitPrice IS NULL)
		BEGIN
			SET @result = 'ERROR: NULL values were found in input parameters. 0 row inserted.'
			RETURN @retcode;
		END

	IF NOT EXISTS(SELECT OrderItemNumber FROM OrderItem WHERE OrderItemNumber = @OrderItemNumber) --Check the existence of orderitemnumber in OrderItem table. Only proceed if not exist
		BEGIN
			IF EXISTS(SELECT OrderNumber FROM OrderGroup WHERE OrderNumber = @OrderNumber) --Check the existence of ordernumber in OrderGroup table.  Only insert if exists
				BEGIN
					IF EXISTS(SELECT VariantCode FROM ProductVariant WHERE VariantCode = @VariantCode) --Check the existence of VariantCode in ProductVariant table.  Only insert if exists
						BEGIN
							INSERT INTO OrderItem VALUES (@OrderItemNumber,
															@OrderNumber,
															@VariantCode,
															@Quantity,
															@UnitPrice)
							SET @retcode = 1
						END
					ELSE
						SET @result = 'ERROR: VariantCode ' + @VariantCode + ' does not exist in table Product. 0 row inserted.'


				END
			ELSE
				SET @result = 'ERROR: OrderNumber ' + @OrderNumber + ' does not exist in table OrderGroup. 0 row inserted.'
		END
	ELSE
		SET @result = 'ERROR: OrderItemNumber ' + @OrderItemNumber + ' already exists in table OrderItem. 0 row inserted.'

	RETURN @retcode;

GO


-----Trial to execute the stored procedures-----------------
--DECLARE @sp_result nvarchar(128)
--DECLARE @ret int

--EXEC @ret = prCreateOrderItem 
--@OrderItemNumber='OR\05052022\02\02', 
--@OrderNumber='OR\05052022\02', 
--@VariantCode='00122200', 
--@Quantity=8, 
--@UnitPrice=11, 
--@result=@sp_result OUTPUT

--SELECT @sp_result 
--SELECT @ret 



