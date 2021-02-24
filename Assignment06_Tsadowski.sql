--*************************************************************************--
-- Title: Assignment06
-- Author: Tara Sadowski
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2021-02-22,Tara Sadowski, Loaded File
-- 2021-02-22,Tara Sadowski, Created Views 1 thru 8
-- 2021-02-22,Tara Sadowski, Created Views 9 and 10
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_TSadowski')
	 Begin 
	  Alter Database [Assignment06DB_TSadowski] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_TSadowski;
	 End
	Create Database Assignment06DB_TSadowski;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_TSadowski;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
--'NOTES------------------------------------------------------------------------------------ 
-- 1) You can use any name you like for you views, but be descriptive and consistent
-- 2) You can use your working code from assignment 5 for much of this assignment
-- 3) You must use the BASIC views for each table after they are created in Question 1
--------------------------------------------------------------------------------------------'

-- Question 1 (5 pts): How can you create BACIC views to show data from each table in the database.

Create View vCategories
With Schemabinding
 As
  Select CategoryID
  ,CategoryName
 From dbo.Categories;
 Go

Create View vProducts
With Schemabinding
 As
  Select ProductID
  ,ProductName
  ,CategoryID
  ,UnitPrice
 From dbo.Products;
 Go

Create View vEmployees
With Schemabinding
 As
  Select EmployeeID
  ,EmployeeFirstName
  ,EmployeeLastName
  ,ManagerID
 From dbo.Employees;
 Go


Create View vInventories
With Schemabinding
 As
  Select InventoryID
  ,InventoryDate
  ,EmployeeID
  ,ProductID
  ,[Count]
 From dbo.Inventories;
 Go

-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!


-- Question 2 (5 pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

DENY Select On Categories to Public;
Go
DENY Select On Products to Public;
Go
DENY Select On Employees to Public;
Go
DENY Select On Inventories to Public;
Go
GRANT Select on vCategories to Public;
go
GRANT Select on vProducts to Public;
go
GRANT Select on vEmployees to Public;
go
GRANT Select on vInventories to Public;
go

-- Question 3 (10 pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!


Create View vCategoryProductPrice
 With Schemabinding
 As
	Select Top 100000 CategoryName
	,ProductName
	,UnitPrice
	 From dbo.Categories As C
	 Inner Join dbo.Products As P
	 On C.CategoryID = P.CategoryID
	 Order by CategoryName, ProductName;
 Go


-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00


-- Question 4 (10 pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

Create View vProductInventoryCount
 With Schemabinding
 As
	Select Top 100000 ProductName
	,InventoryDate
	,[Count]
	 From dbo.Inventories As I
	 Inner Join dbo.Products As P
	 On I.ProductID = P.ProductID
	 Order by ProductName, InventoryDate, [Count] desc;
 Go

-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83


-- Question 5 (10 pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

Create View vInventoryEmployee
 With Schemabinding
 As
	Select Top 100000 InventoryDate
	,EmployeeName = EmployeeFirstName + ' ' + EmployeeLastName
	 From dbo.Inventories as I
	 Inner Join dbo.Employees as E
	 On I.EmployeeID = E.EmployeeID
	 Group By InventoryDate, EmployeeFirstName, EmployeeLastName
	 Order by InventoryDate;
 Go

-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth


-- Question 6 (10 pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

Create View vCategoryProductInventoryCount
 With Schemabinding
 As
	Select Top 100000 CategoryName
	,ProductName
	,InventoryDate
	,[Count]
	 From dbo.Inventories As I
	 Inner Join dbo.Products As P
	 On I.ProductID = P.ProductID
	 Inner Join dbo.Categories As C
	 On C.CategoryID=P.CategoryID
	 Order by CategoryName, ProductName, InventoryDate, [Count] desc;
 Go


-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54


-- Question 7 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

Create View vCategoryProductInventoryEmployee
 With Schemabinding
 As
	Select Top 100000 CategoryName
	,ProductName
	,InventoryDate
	,[Count]
	,EmployeeName = EmployeeFirstName + ' ' + EmployeeLastName
	 From dbo.Inventories As I
	 Inner Join dbo.Products As P
	 On I.ProductID = P.ProductID
	 Inner Join dbo.Categories As C
	 On C.CategoryID=P.CategoryID
	 Inner Join dbo.Employees as E
	 On E.EmployeeID = I.EmployeeID
	 Order by InventoryDate, CategoryName, ProductName, EmployeeName;
 Go

 
-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan


-- Question 8 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

Create View vChaiChangInventory
 With Schemabinding
 As
	Select Top 100000 CategoryName
	,ProductName
	,InventoryDate
	,[Count]
	,EmployeeName = EmployeeFirstName + ' ' + EmployeeLastName
	 From dbo.Inventories As I
	 Inner Join dbo.Products As P
	 On I.ProductID = P.ProductID
	 Inner Join dbo.Categories As C
	 On C.CategoryID=P.CategoryID
	 Inner Join dbo.Employees as E
	 On E.EmployeeID = I.EmployeeID
	  WHERE P.ProductID IN
		(SELECT (ProductID)
		 FROM dbo.Products
		 WHERE ProductName IN ('Chai', 'Chang'))
	Order By InventoryDate, ProductName;
 Go


-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King


-- Question 9 (10 pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

Create View vEmployeeManagers
 With Schemabinding
 As
	Select Top 100000 (M.EmployeeFirstName + ' ' + M.EmployeeLastName) AS ManagerName
	,(E.EmployeeFirstName + ' ' + E.EmployeeLastName) AS EmployeeName
	 FROM dbo.Employees as M, dbo.Employees as E
	  WHERE M.EmployeeID = E.ManagerID
	  Order by ManagerName, EmployeeName;
Go


-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan



-- Question 10 (10 pts): How can you create one view to show all the data from all four 
-- BASIC Views?

Create View vFullView
 With Schemabinding
 As
	Select Top 100000 VC.CategoryID
	,CategoryName
	,VP.ProductID
	,ProductName
	,UnitPrice
	,InventoryID
	,InventoryDate
	,[Count]
	,VE.EmployeeID
	,(VE.EmployeeFirstName + ' ' + VE.EmployeeLastName) AS EmployeeName
	,(VM.EmployeeFirstName + ' ' + VM.EmployeeLastName) AS ManagerName
	From [dbo].[vCategories] as VC
	Inner Join [dbo].[vProducts] as VP
	On VC.CategoryID = VP.CategoryID
	Inner Join [dbo].[vInventories] as VI
	On VI.ProductID = VP.ProductID
	Inner Join [dbo].[vEmployees] as VE
	On VE.EmployeeID = VI.EmployeeID
	Inner Join [dbo].[vEmployees] as VM
	On VE.ManagerID = VM.EmployeeID
	Order by VC.CategoryID,CategoryName,VP.ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,[Count],VI.EmployeeID,EmployeeName,ManagerName;
Go



-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan

-- Test your Views (NOTE: You must change the names to match yours as needed!)
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vCategoryProductPrice]
Select * From [dbo].[vProductInventoryCount]
Select * From [dbo].[vInventoryEmployee]
Select * From [dbo].[vCategoryProductInventoryCount]
Select * From [dbo].[vCategoryProductInventoryEmployee]
Select * From [dbo].[vChaiChangInventory]
Select * From [dbo].[vEmployeeManagers]
Select * From [dbo].[vFullView]
/***************************************************************************************/