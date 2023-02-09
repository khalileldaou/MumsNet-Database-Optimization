
----********************************************************************************************
--  Step 1.  This script create a new database called [MUMSNETDB] for the project.
--
----********************************************************************************************


IF NOT EXISTS(SELECT * FROM sys.databases WHERE name = 'MUMSNETDB')
BEGIN
	CREATE DATABASE MUMSNETDB
END

GO 

USE MUMSNETDB

GO


IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'Country' AND xtype='U')
	CREATE TABLE Country
	(CountryID INT IDENTITY(1,1),
	Country nvarchar(255) NOT NULL)

	ALTER TABLE Country
	ADD CONSTRAINT pk_CountryID PRIMARY KEY CLUSTERED (CountryID)
GO

	
IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'Region' AND xtype='U')
	CREATE TABLE Region
	(RegionID INT IDENTITY(1,1),
	Region nvarchar(255) NOT NULL)

	ALTER TABLE Region
	ADD CONSTRAINT pk_RegionID PRIMARY KEY CLUSTERED (RegionID)

GO


IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'County' AND xtype='U')
	CREATE TABLE County
	(CountyID INT IDENTITY(1,1),
	County nvarchar(255) NOT NULL)

	ALTER TABLE County
	ADD CONSTRAINT pk_CountyID PRIMARY KEY CLUSTERED (CountyID)
GO


IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'City' AND xtype='U')
	CREATE TABLE City
	(CityID INT IDENTITY(1,1),
	City nvarchar(255) NOT NULL)

	ALTER TABLE City
	ADD CONSTRAINT pk_CityID PRIMARY KEY CLUSTERED (CityID)

GO


IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'OrderStatus' AND xtype='U')
	CREATE TABLE OrderStatus
	(OrderStatusCode INT IDENTITY(0,1),
	StatusDescription nvarchar(128) NOT NULL)

	ALTER TABLE OrderStatus
	ADD CONSTRAINT pk_OrderStatusCode PRIMARY KEY CLUSTERED (OrderStatusCode)

GO



IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'Customer' AND xtype='U')
BEGIN
	CREATE TABLE Customer
	(CustomerID bigint NOT NULL,
	Gender nvarchar(255),
	FirstName nvarchar(255),
	LastName nvarchar(255),
	DateRegistered datetime,
	CityID int,
	CountyID int,
	RegionID int,
	CountryID int,
	CONSTRAINT pk_CustomerID PRIMARY KEY CLUSTERED (CustomerID))

	ALTER TABLE Customer
	ADD CONSTRAINT fk_city FOREIGN KEY (CityID) REFERENCES City (CityID)

	ALTER TABLE Customer
	ADD CONSTRAINT fk_county FOREIGN KEY (CountyID) REFERENCES County (CountyID)

	ALTER TABLE Customer
	ADD CONSTRAINT fk_region FOREIGN KEY (RegionID) REFERENCES Region (RegionID)

	ALTER TABLE Customer
	ADD CONSTRAINT fk_country FOREIGN KEY (CountryID) REFERENCES Country (CountryID)

END

GO


IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'OrderGroup' AND xtype='U')
BEGIN
	CREATE TABLE OrderGroup
	(OrderNumber nvarchar(50) NOT NULL,
	OrderStatusCode int NOT NULL,
	CustomerID bigint NOT NULL,
	OrderCreateDate datetime,
	BillingCurrency nvarchar(8) NOT NULL,
	TotalLineItems int NOT NULL, -- Need to create a Trigger on Insert/Update/Delete SELECT COUNT(*) FROM OrderItem WHERE OrderItem.OrderNumber = OrderNumber
	SavedTotal money NOT NULL,     -- Need to create a Trigger on Insert/Update/Delete SELECT SUM(OrderItem.LineItemTotal) FROM OrderItem WHERE OrderItem.OrderNumber = OrderNumber
	CONSTRAINT pk_ordergroup PRIMARY KEY CLUSTERED (OrderNumber))

	ALTER TABLE OrderGroup
	ADD CONSTRAINT fk_orderstatus FOREIGN KEY (OrderStatusCode) REFERENCES OrderStatus (OrderStatusCode)

	ALTER TABLE OrderGroup
	ADD CONSTRAINT fk_customerid FOREIGN KEY (CustomerID) REFERENCES Customer (CustomerID)

	ALTER TABLE OrderGroup
	ADD CONSTRAINT df_ordercreatedate DEFAULT (GETDATE()) FOR OrderCreateDate

	ALTER TABLE OrderGroup
	ADD CONSTRAINT df_checkordernumber CHECK (OrderNumber LIKE 'OR\[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\[0-9][0-9]')

--	ALTER TABLE OrderGroup
--	ADD CONSTRAINT df_checkordernumber CHECK (OrderNumber LIKE 'OR-(?:0[1-9]|[12][0-9]|3[01])-(?:0[1-9]|1[012])-(?:19\d{2}|[2-9][0-9]{3})-([0-9][0-9])')
--  TSQL does not support full RegEx like this 'OR-(?:0[1-9]|[12][0-9]|3[01])-(?:0[1-9]|1[012])-(?:19\d{2}|[2-9][0-9]{3})-([0-9][0-9])'

END

GO

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'ProductGroup' AND xtype='U')
BEGIN
	CREATE TABLE ProductGroup
	(ProductGroupID INT IDENTITY(1,1),
	ProductGroupDesp nvarchar(128),
	CONSTRAINT pk_ProductGroupID PRIMARY KEY CLUSTERED (ProductGroupID))

END

GO


IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'Product' AND xtype='U')
BEGIN
	CREATE TABLE Product
	(ProductCode nvarchar(50) NOT NULL,
	Features nvarchar(3600),
	Description nvarchar(3600),
	CONSTRAINT pk_ProductCode PRIMARY KEY CLUSTERED (ProductCode))

END

GO

--Check the relation of price with product below.  For the same product, there are multiple prices according to the productvariants.
--select count(distinct Price) as freq, [ProductCode] from [Product] Group by [Product].[ProductCode] order by freq desc

IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'ProductGroupProduct' AND xtype='U')
BEGIN
	CREATE TABLE ProductGroupProduct
	( MappingID INT IDENTITY(1,1),
	ProductGroupID INT NOT NULL,
	ProductCode nvarchar(50) NOT NULL,
	CONSTRAINT pk_MappingID PRIMARY KEY CLUSTERED (MappingID))

	ALTER TABLE ProductGroupProduct
	ADD CONSTRAINT fk_productgroupid FOREIGN KEY (ProductGroupID) REFERENCES ProductGroup (ProductGroupID)

	ALTER TABLE ProductGroupProduct
	ADD CONSTRAINT fk_productcode2 FOREIGN KEY (ProductCode) REFERENCES Product (ProductCode)

END

GO



IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'ProductVariant' AND xtype='U')
BEGIN
	CREATE TABLE ProductVariant
	(VariantCode nvarchar(50) NOT NULL,
	ProductCode nvarchar(50) NOT NULL,
	Price money,
	Name nvarchar(256) NOT NULL,
	Cup nvarchar(255),
	Size nvarchar(255),
	LegLength nvarchar(255),
	Colour nvarchar(255),
	CONSTRAINT pk_VariantCode PRIMARY KEY CLUSTERED (VariantCode))

	ALTER TABLE ProductVariant
	ADD CONSTRAINT fk_productcode FOREIGN KEY (ProductCode) REFERENCES Product (ProductCode)

END

GO



IF NOT EXISTS(SELECT * FROM sysobjects WHERE name = 'OrderItem' AND xtype='U')
BEGIN
	CREATE TABLE OrderItem
	(OrderItemNumber nvarchar(32) NOT NULL,
	OrderNumber nvarchar(50) NOT NULL,
	VariantCode nvarchar(50) NOT NULL,
	Quantity int NOT NULL,
	UnitPrice money NOT NULL, 
	LineItemTotal AS (UnitPrice*Quantity),
	CONSTRAINT pk_OrderItemNumber PRIMARY KEY CLUSTERED (OrderItemNumber))

	ALTER TABLE OrderItem
	ADD CONSTRAINT fk_ordernumber FOREIGN KEY (OrderNumber) REFERENCES OrderGroup (OrderNumber)

	ALTER TABLE OrderItem
	ADD CONSTRAINT fk_variantcode FOREIGN KEY (VariantCode) REFERENCES ProductVariant (VariantCode)

	
	ALTER TABLE OrderItem
	ADD CONSTRAINT df_checkorderitemnumber CHECK (OrderItemNumber LIKE 'OR\[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\[0-9][0-9]\%')

END

GO


