----********************************************************************************************
--  Step 2.  This script will move the data in old database [AssignmentPart1] 
--  to the new database [MUMSNETDB].  Three new tables with names started    
--  with [OldCustomerCity], [OldOrderItem] and [OldProduct] will be created in 
--  the new database to store the old data.  They can be removed after the migration
--  completes. 
----********************************************************************************************


USE MUMSNETDB

-------Move the old data to the new database----------------------------------
select * into MUMSNETDB.dbo.OldCustomerCity from 
AssignmentPart1.dbo.CustomerCity 

select * into MUMSNETDB.dbo.OldOrderItem from 
AssignmentPart1.dbo.OrderItem  

select * into MUMSNETDB.dbo.OldProduct from 
AssignmentPart1.dbo.Product 

-------Convert the old table column collation to the new database collation---------------
ALTER TABLE MUMSNETDB.dbo.OldCustomerCity
  ALTER COLUMN [Gender] [nvarchar](255)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL

ALTER TABLE MUMSNETDB.dbo.OldCustomerCity
  ALTER COLUMN [FirstName] [nvarchar](255)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL
 
ALTER TABLE MUMSNETDB.dbo.OldCustomerCity
  ALTER COLUMN [LastName] [nvarchar](255)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL

ALTER TABLE MUMSNETDB.dbo.OldCustomerCity
  ALTER COLUMN [City] [nvarchar](255)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL

ALTER TABLE MUMSNETDB.dbo.OldCustomerCity
  ALTER COLUMN [County] [nvarchar](255)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL
	
ALTER TABLE MUMSNETDB.dbo.OldCustomerCity
  ALTER COLUMN [Region] [nvarchar](255)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL	
	
ALTER TABLE MUMSNETDB.dbo.OldCustomerCity
  ALTER COLUMN [Country] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL	

ALTER TABLE MUMSNETDB.dbo.OldOrderItem
  ALTER COLUMN [OrderNumber] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL	
  
ALTER TABLE MUMSNETDB.dbo.OldOrderItem
  ALTER COLUMN [OrderItemNumber] [nvarchar](32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL	
  
ALTER TABLE MUMSNETDB.dbo.OldOrderItem
  ALTER COLUMN [BillingCurrency] [nvarchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL	

ALTER TABLE MUMSNETDB.dbo.OldOrderItem
  ALTER COLUMN [ProductGroup] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL	

ALTER TABLE MUMSNETDB.dbo.OldOrderItem
  ALTER COLUMN [ProductCode] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL	
  
ALTER TABLE MUMSNETDB.dbo.OldOrderItem
  ALTER COLUMN [VariantCode] [nvarchar](50)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL	

 ALTER TABLE MUMSNETDB.dbo.OldProduct
  ALTER COLUMN [ProductGroup] [nvarchar](128)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL	

 ALTER TABLE MUMSNETDB.dbo.OldProduct
  ALTER COLUMN [ProductCode] [nvarchar](50)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL

 ALTER TABLE MUMSNETDB.dbo.OldProduct
  ALTER COLUMN [VariantCode] [nvarchar](50)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL	

 ALTER TABLE MUMSNETDB.dbo.OldProduct
  ALTER COLUMN [Name] [nvarchar](256)   COLLATE SQL_Latin1_General_CP1_CI_AS  NULL

 ALTER TABLE MUMSNETDB.dbo.OldProduct
  ALTER COLUMN [Cup] [nvarchar](256)  COLLATE SQL_Latin1_General_CP1_CI_AS  NULL	

 ALTER TABLE MUMSNETDB.dbo.OldProduct
  ALTER COLUMN [Size] [nvarchar](256)  COLLATE SQL_Latin1_General_CP1_CI_AS  NULL

ALTER TABLE MUMSNETDB.dbo.OldProduct
  ALTER COLUMN [LegLength] [nvarchar](256)  COLLATE SQL_Latin1_General_CP1_CI_AS  NULL

ALTER TABLE MUMSNETDB.dbo.OldProduct
  ALTER COLUMN [Colour] [nvarchar](256)  COLLATE SQL_Latin1_General_CP1_CI_AS  NULL

ALTER TABLE MUMSNETDB.dbo.OldProduct
  ALTER COLUMN [Features] [nvarchar](3600) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL

ALTER TABLE MUMSNETDB.dbo.OldProduct
  ALTER COLUMN [Description] [nvarchar](3600) COLLATE SQL_Latin1_General_CP1_CI_AS  NULL

-------- Migrate City, County, Region, Country---------------------------------------
INSERT INTO MUMSNETDB.dbo.City(City) SELECT DISTINCT(MUMSNETDB.dbo.OldCustomerCity.City) FROM MUMSNETDB.dbo.OldCustomerCity ORDER BY MUMSNETDB.dbo.OldCustomerCity.City ASC

INSERT INTO MUMSNETDB.dbo.County(County) SELECT DISTINCT(MUMSNETDB.dbo.OldCustomerCity.County) FROM MUMSNETDB.dbo.OldCustomerCity ORDER BY MUMSNETDB.dbo.OldCustomerCity.County ASC

INSERT INTO MUMSNETDB.dbo.Region(Region) SELECT DISTINCT(MUMSNETDB.dbo.OldCustomerCity.Region) FROM MUMSNETDB.dbo.OldCustomerCity ORDER BY MUMSNETDB.dbo.OldCustomerCity.Region ASC

INSERT INTO MUMSNETDB.dbo.Country(Country) SELECT DISTINCT(MUMSNETDB.dbo.OldCustomerCity.Country) FROM MUMSNETDB.dbo.OldCustomerCity ORDER BY MUMSNETDB.dbo.OldCustomerCity.Country ASC

--------- Migrate OldCustomerCity table to Customer table---------------------------------
INSERT INTO Customer(CustomerID, Gender, FirstName, LastName, DateRegistered, CityID, CountyID, RegionID, CountryID) 
SELECT o.Id as CustomerID, o.Gender, o.FirstName, o.LastName, o.DateRegistered, 
c.CityID, ct.CountyID, r.RegionID, ctry.CountryID 
from OldCustomerCity o 
JOIN City c on o.City=c.City
JOIN County ct on o.County = ct.County 
JOIN Region r on o.Region = r.Region
JOIN Country ctry on o.Country = ctry.Country

----------- Migrate OldProduct.ProductGroup to ProductGroup table--------------------------
INSERT INTO ProductGroup(ProductGroupDesp) SELECT DISTINCT(OldProduct.ProductGroup) FROM OldProduct ORDER BY OldProduct.ProductGroup ASC

-------------- Migrate OldProduct.ProductCode and related fields to Product table -----------------
INSERT INTO Product(ProductCode, Features, Description) SELECT DISTINCT(OldProduct.ProductCode), 
OldProduct.Features, OldProduct.Description FROM OldProduct ORDER BY OldProduct.ProductCode ASC

-------------- Migrate OldProduct.VariantCode and related fields to ProductVariant table -----------------
INSERT INTO ProductVariant(VariantCode, ProductCode, Price, Name, Cup, Size, LegLength, Colour) SELECT DISTINCT(OldProduct.VariantCode), OldProduct.ProductCode, OldProduct.Price, OldProduct.Name, OldProduct.Cup,
OldProduct.Size, OldProduct.LegLength, OldProduct.Colour FROM  OldProduct ORDER BY OldProduct.VariantCode ASC


-------------- Migrate OldProduct.ProductGroup OldProduct.ProductCode mapping to ProductGroupProdcut table -----------------
INSERT INTO ProductGroupProduct(ProductGroupID, ProductCode) SELECT DISTINCT p.ProductGroupID, o.ProductCode FROM OldProduct o JOIN ProductGroup p ON o.ProductGroup=p.ProductGroupDesp ORDER BY 
o.ProductCode ASC

-------------- Populate OrderStatus table --------------------------------------------------------
INSERT INTO OrderStatus VALUES ('This is a new order')
INSERT INTO OrderStatus VALUES ('This an abandoned order')
INSERT INTO OrderStatus VALUES ('This is an unfulfilled order due to out of stock item(s)')
INSERT INTO OrderStatus VALUES ('This is an order that have been cancelled by the customer')
INSERT INTO OrderStatus VALUES ('This is a fulfilled order; the goods have been shipped to the customer')

--------------- Migrate OldOrderItem.OrderNumber and related fields to OrderGroup table-----------
-- ***Note: the field TotalLineItems and SavedTotal will be tweaked later****
INSERT INTO OrderGroup(OrderNumber, OrderStatusCode, CustomerID, OrderCreateDate,
 BillingCurrency, TotalLineItems, SavedTotal) SELECT DISTINCT(OldOrderItem.OrderNumber), OldOrderItem.OrderStatusCode, OldOrderItem.CustomerCityId as CustomerID, 
OldOrderItem.OrderCreateDate, OldOrderItem.BillingCurrency, -99, -99 FROM OldOrderItem

------------- A consistency check to ensure the OldOrderItem.VariantCode exists in ProductVariant.VariantCode.  
-- Empty result set implies all OldOrderItem.VariantCode exists in ProductVariant.VariantCode
-- SELECT DISTINCT(OldOrderItem.VariantCode) FROM OldOrderItem WHERE OldOrderItem.VariantCode NOT IN (SELECT DISTINCT(ProductVariant.VariantCode) FROM ProductVariant)


--------------- Migrate OldOrderItem.OrderItemNumber and related fields to OrderItem table-----------
INSERT INTO OrderItem(OrderItemNumber, OrderNumber, VariantCode, Quantity, UnitPrice) SELECT DISTINCT(OldOrderItem.OrderItemNumber), OldOrderItem.OrderNumber, OldOrderItem.VariantCode, 
OldOrderItem.Quantity, OldOrderItem.UnitPrice FROM OldOrderItem


--------------- Tweak OrderGroup.TotalLineItems and  SavedTotal ------------------------------
-------***Note: Performance consideration here, need to add additional indexes to the  OrderGroup.TotalLineItems and  SavedTotal
MERGE OrderGroup AS Ogp
USING(SELECT COUNT(OrderItemNumber) as TotalLineItems, SUM(LineItemTotal) as SavedTotal, OrderNumber FROM OrderItem GROUP BY OrderNumber) AS OdrAgg   
ON Ogp.OrderNumber=OdrAgg.OrderNumber 
WHEN MATCHED THEN
UPDATE SET 
Ogp.TotalLineItems=OdrAgg.TotalLineItems ,
Ogp.SavedTotal = OdrAgg.SavedTotal;


----Test only---------------
--SELECT * FROM OrderGroup WHERE OrderNumber='OR\01012006\03'
--SELECT COUNT(OrderItemNumber) as TotalLineItems, SUM(LineItemTotal) as SavedTotal, OrderNumber FROM OrderItem  WHERE OrderNumber='OR\01012006\03' GROUP BY OrderNumber
 

