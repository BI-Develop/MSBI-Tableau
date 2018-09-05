create database DWNorthwind;
use DWNorthwind;
go
CREATE TABLE [dbo].[DimProducts](
	[ProductID] [int]  PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[ProductName] [nvarchar](40) NOT NULL,
	[SupplierID] [int] NULL,
	[CategoryID] [int] NULL,
	[QuantityPerUnit] [nvarchar](20) NULL,
	[UnitPrice] [money] NULL,
	[UnitsInStock] [smallint] NULL,
	[UnitsOnOrder] [smallint] NULL,
	[ReorderLevel] [smallint] NULL,
	[Discontinued] [bit] NOT NULL,
)

GO
CREATE TABLE [dbo].[DimCategories](
	[CategoryID] [int]  PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[CategoryName] [nvarchar](15) NOT NULL,
	[Description] [ntext] NULL,
	[Picture] [image] NULL
 )

GO
CREATE TABLE [dbo].[DimEmployees](
	[EmployeeID] [int] PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[LastName] [nvarchar](20) NOT NULL,
	[FirstName] [nvarchar](10) NOT NULL,
	[Title] [nvarchar](30) NULL,
	[TitleOfCourtesy] [nvarchar](25) NULL,
	[BirthDate] [datetime] NULL,
	[HireDate] [datetime] NULL,
	[Address] [nvarchar](60) NULL,
	[City] [nvarchar](15) NULL,
	[Region] [nvarchar](15) NULL,
	[PostalCode] [nvarchar](10) NULL,
	[Country] [nvarchar](15) NULL,
	[HomePhone] [nvarchar](24) NULL,
	[Extension] [nvarchar](4) NULL,
	[Photo] [image] NULL,
	[Notes] [ntext] NULL,
	[ReportsTo] [int] NULL,
	[PhotoPath] [nvarchar](255) NULL,
 )

GO
use DWNorthwind;
CREATE TABLE [dbo].[DimCustomers](
	[CustomerID] [nchar](5) NOT NULL PRIMARY KEY,
	[CompanyName] [nvarchar](40) NOT NULL,
	[ContactName] [nvarchar](30) NULL,
	[ContactTitle] [nvarchar](30) NULL,
	[Address] [nvarchar](60) NULL,
	[City] [nvarchar](15) NULL,
	[Region] [nvarchar](15) NULL,
	[PostalCode] [nvarchar](10) NULL,
	[Country] [nvarchar](15) NULL,
	[Phone] [nvarchar](24) NULL,
	[Fax] [nvarchar](24) NULL,
 ) 

GO

CREATE TABLE [dbo].[DimDates](
	[DateKey] [int] PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[Date] [datetime] NOT NULL,
	[Day] [int] NOT NULL,
	[Month] [int] NOT NULL,
	[Year] [int] NOT NULL,
	[DateName] [varchar](10) NULL,
	[MonthName] [varchar](10) NULL,
	[Quarter] [int] NULL,
	[QuarterName] [varchar](10) NULL,
	[YearName] [varchar](10) NULL,
)
GO
CREATE TABLE [dbo].[FactOrders](
	[OrderID] [int] NULL,
	[CustomerID] [nchar](5) NULL,
	[EmployeeID] [int] NULL,
	[IdOrderDate] [int] NULL,
	[IdRequiredDate] [int] NULL,
	[IdShippedDate] [int] NULL,
	[ShipVia] [int] NULL,
	[Freight] [money] NULL,
	[ShipName] [nvarchar](40) NULL,
	[ShipAddress] [nvarchar](60) NULL,
	[ShipCity] [nvarchar](15) NULL,
	[ShipRegion] [nvarchar](15) NULL,
	[ShipPostalCode] [nvarchar](10) NULL,
	[ShipCountry] [nvarchar](15) NULL,
	[ProductID] [int] NOT NULL,
	[UnitPrice] [money] NOT NULL,
	[Quantity] [smallint] NOT NULL,
	[Discount] [real] NOT NULL,
	[CategoryID] [int] NULL,
	[OrderDate] [datetime] NULL,
	[RequiredDate] [datetime] NULL,
	[ShippedDate] [datetime] NULL
	FOREIGN KEY (ProductID) REFERENCES DimProducts(ProductID),
	FOREIGN KEY (CustomerID) REFERENCES DimCustomers(CustomerID),
	FOREIGN KEY (CategoryID) REFERENCES DimCategories(CategoryID),
	FOREIGN KEY (EmployeeID) REFERENCES DimEmployees(EmployeeID),
	FOREIGN KEY (IdOrderDate) REFERENCES DimDates(DateKey),
	FOREIGN KEY (IdRequiredDate) REFERENCES DimDates(DateKey),
	FOREIGN KEY (IdShippedDate) REFERENCES DimDates(DateKey)
)
use northwind;
insert into DWNorthwind.dbo.DimProducts(ProductName,SupplierID,CategoryID,QuantityPerUnit,UnitPrice,UnitsInStock,UnitsOnOrder,ReorderLevel,Discontinued) 
select ProductName,SupplierID,CategoryID,QuantityPerUnit,UnitPrice,UnitsInStock,UnitsOnOrder,ReorderLevel,Discontinued from Products;

insert into DWNorthwind.dbo.DimEmployees(LastName,FirstName,Title,TitleOfCourtesy,BirthDate,HireDate,Address,City,Region,PostalCode,Country,HomePhone,Extension,Photo,Notes,ReportsTo,PhotoPath) 
select LastName,FirstName,Title,TitleOfCourtesy,BirthDate,HireDate,Address,City,Region,PostalCode,Country,HomePhone,Extension,Photo,Notes,ReportsTo,PhotoPath from Employees;

insert into DWNorthwind.dbo.DimCustomers
select * from Customers;

insert into DWNorthwind.dbo.DimCategories(CategoryName,Description,Picture) 
select CategoryName,Description,Picture from Categories;

insert into DWNorthwind.dbo.FactOrders(OrderID,ProductID,UnitPrice,Quantity,Discount) 
select OrderID,ProductID,UnitPrice,Quantity,Discount from [Order Details];

use northwind;
insert into DWNorthwind.dbo.FactOrders(OrderID,CustomerID,EmployeeID,ShipVia,Freight,ShipName,ShipAddress,ShipCity,ShipRegion,ShipPostalCode,ShipCountry,ProductID,UnitPrice,Quantity,Discount,CategoryID,OrderDate,RequiredDate,ShippedDate)
select o.OrderID,ot.CustomerID,ot.EmployeeID,ot.ShipVia,ot.Freight,ot.ShipName,ot.ShipAddress,ot.ShipCity,ot.ShipRegion,ot.ShipPostalCode,
ot.ShipCountry,o.ProductID,o.UnitPrice,o.Quantity,o.Discount,p.CategoryID,ot.OrderDate,ot.RequiredDate,ot.ShippedDate from [Order Details] o,Products p,Orders ot
where o.ProductID=p.ProductID and o.OrderID=ot.OrderID

use DWNorthwind;
insert into DimDates(Date,DateName,Day,Month,MonthName,Quarter,QuarterName,Year,YearName)
SELECT distinct orderdate  [Date]-- [Date] 
  , DateName( weekday, orderdate )  as [DateName] 
, Day(orderdate) as [Day]  
  , Month( orderdate ) as [Month]   
  , DateName( month, orderdate ) as [MonthName]
  , DateName( quarter, orderdate )  as [Quarter]
  , 'Q' + DateName( quarter, orderdate ) + ' - ' + Cast( Year(orderdate) as nVarchar(50) ) as [QuarterName] 
  , Year( orderdate ) as Year
  , Cast( Year(orderdate ) as nVarchar(50) ) as [YearName] 
  from FactOrders
   where orderdate is not null;

insert into DimDates(Date,DateName,Day,Month,MonthName,Quarter,QuarterName,Year,YearName)
SELECT distinct requireddate  [Date]-- [Date] 
  , DateName( weekday, requireddate )  as [DateName] 
, Day(requireddate) as [Day]  
  , Month( requireddate ) as [Month]   
  , DateName( month, requireddate ) as [MonthName]
  , DateName( quarter, requireddate )  as [Quarter]
  , 'Q' + DateName( quarter, requireddate ) + ' - ' + Cast( Year(requireddate) as nVarchar(50) ) as [QuarterName] 
  , Year( requireddate ) as Year
  , Cast( Year(requireddate ) as nVarchar(50) ) as [YearName] 
  from FactOrders
   where requireddate is not null;

insert into DimDates(Date,DateName,Day,Month,MonthName,Quarter,QuarterName,Year,YearName)
SELECT distinct ShippedDate  [Date]-- [Date] 
  , DateName( weekday, ShippedDate )  as [DateName] 
, Day(ShippedDate) as [Day]  
  , Month( ShippedDate ) as [Month]   
  , DateName( month, ShippedDate ) as [MonthName]
  , DateName( quarter, ShippedDate )  as [Quarter]
  , 'Q' + DateName( quarter, ShippedDate ) + ' - ' + Cast( Year(ShippedDate) as nVarchar(50) ) as [QuarterName] 
  , Year( ShippedDate ) as Year
  , Cast( Year(ShippedDate ) as nVarchar(50) ) as [YearName] 
  from FactOrders
  where shippeddate is not null;

delete x from (
  select *, rn=row_number() over (partition by date order by date)
  from dimdates 
) x
where rn > 1;

UPDATE FactOrders 
   SET FactOrders.IdOrderDate= DimDates.DateKey 
   FROM FactOrders  INNER JOIN  DimDates ON FactOrders.OrderDate = DimDates.Date

UPDATE FactOrders 
   SET FactOrders.IdRequiredDate= DimDates.DateKey 
   FROM FactOrders  INNER JOIN  DimDates ON FactOrders.requireddate = DimDates.Date

UPDATE FactOrders 
   SET FactOrders.IdshippedDate= DimDates.DateKey 
   FROM FactOrders  INNER JOIN  DimDates ON FactOrders.shippedDate = DimDates.Date