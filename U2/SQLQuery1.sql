use AdventureWorks2019
go

with avghours as (
	select avg(VacationHours) VacationHours from HumanResources.Employee
)
select a.* from HumanResources.Employee a, avghours
where a.VacationHours < avghours.VacationHours

SELECT 
    p.ProductID,
    p.Name,
    p.Color,
    c.Name AS CategoryName,
    sc.Name AS SubCategoryName
FROM 
    Production.Product p
INNER JOIN 
    Production.ProductSubcategory sc ON p.ProductSubcategoryID = sc.ProductSubcategoryID
INNER JOIN 
    Production.ProductCategory c ON sc.ProductCategoryID = c.ProductCategoryID
GO

SELECT SOH.*
FROM Sales.SalesOrderHeader SOH
LEFT JOIN Sales.SalesOrderDetail SOD ON SOH.SalesOrderID = SOD.SalesOrderID
LEFT JOIN Production.Product P ON SOD.ProductID = P.ProductID
LEFT JOIN Production.ProductSubcategory PS ON P.ProductSubcategoryID = PS.ProductSubcategoryID
LEFT JOIN Production.ProductCategory PC ON PS.ProductCategoryID = PC.ProductCategoryID
WHERE SOD.SalesOrderID IS NULL
AND (SOH.OrderDate >= '2012-06-01' AND SOH.OrderDate < '2012-10-01')
AND PC.Name = 'Clothing'
GO

SELECT 
    SP.BusinessEntityID,
    SP.TerritoryID AS Territorio,
    COUNT(SOH.SalesOrderID) AS TotalOrdenesVendidas
FROM 
    Sales.SalesPerson SP
LEFT JOIN 
    Sales.SalesOrderHeader SOH ON SP.BusinessEntityID = SOH.SalesPersonID
GROUP BY 
    SP.BusinessEntityID, SP.TerritoryID
GO

SELECT *
FROM Sales.SalesOrderHeader SOH
WHERE NOT EXISTS (
    SELECT *
    FROM Sales.SalesPerson SP
	inner join Sales.SalesTerritory ST
	ON sp.TerritoryID = st.TerritoryID
    WHERE SOH.SalesPersonID = SP.BusinessEntityID
    AND ST.CountryRegionCode = 'CA'
)
AND SOH.OrderDate >= '2013-12-01'
AND SOH.OrderDate < '2014-01-01'
GO

SELECT 
    P.ProductID,
    P.Name,
    P.ProductNumber,
    PM.Name AS ProductModelName
FROM 
    Production.Product P
INNER JOIN 
    Production.ProductModel PM ON P.ProductModelID = PM.ProductModelID
GO

SELECT 
    P.FirstName,
    P.LastName,
    E.NationalIDNumber
FROM 
    Person.Person P
LEFT JOIN 
    HumanResources.Employee E ON P.BusinessEntityID = E.BusinessEntityID
GO

WITH VentasPorProducto AS (
    SELECT 
        ProductID,
        SUM(OrderQty) AS TotalVentas
    FROM 
        Sales.SalesOrderDetail
    GROUP BY 
        ProductID
)

SELECT 
    VP.ProductID,
    P.Name AS NombreProducto,
    VP.TotalVentas
FROM 
    VentasPorProducto VP
INNER JOIN 
    Production.Product P ON VP.ProductID = P.ProductID;

-- ######################################## GUIA 2
create database BD_Seguros
GO

USE BD_Seguros
GO

create schema maestros
GO

create table maestros.polizas(
 id int primary key,
 ramo varchar(10),
 cuota decimal(12,2),
 cobertura char(1)
)
GO

create table maestros.clientes(
  identidad varchar(20) primary key,
  nombre varchar(20),
  apellido varchar(20),
  fechaNacimiento date,
  correo varchar(100),
  telefono varchar(20),
  genero varchar(10)
)
GO

create table maestros.ventas(
  identidad varchar(10),
  monto decimal(12,2),
  vendedor varchar(10),
  fecha date
)
GO

create clustered index idx1 on maestros.polizas (id desc, cuota asc)

create clustered index idx2 on maestros.clientes (identidad asc, nombre desc)

create nonclustered index idx3 on maestros.clientes (genero)
where genero = 'M'

create nonclustered index idx4 on maestros.polizas (ramo asc)

create nonclustered index idx5 on maestros.clientes (apellido desc)

create unique index idx6 on maestros.clientes (correo)

create nonclustered index idx7 on maestros.ventas (vendedor asc)

-- ######################################## GUIA 3
use nw
go

create view vw1 as
with tpro as (
	select COUNT(ProductID) productos,CategoryID from dbo.Products 
	group by CategoryID
) select a.CategoryID, a.CategoryName, tpro.productos from Categories a
left join tpro
on a.CategoryID = tpro.CategoryID
go

CREATE VIEW vw2 AS
SELECT 
    e.EmployeeID,
    e.LastName,
    e.FirstName,
    COUNT(o.OrderID) AS CantidadOrdenes,
    SUM(o.Freight) AS TotalPorOrdenes
FROM 
    Employees e
INNER JOIN 
    Orders o ON e.EmployeeID = o.EmployeeID
GROUP BY 
    e.EmployeeID, e.LastName, e.FirstName;
go

CREATE PROCEDURE ObtenerTotalProductosPorCategoria
    @CategoriaID INT,
    @TotalProductos INT OUTPUT
AS
BEGIN
    SELECT @TotalProductos = COUNT(*)
    FROM Products
    WHERE CategoryID = @CategoriaID;
END;
GO

CREATE PROCEDURE ObtenerOrdenesPorEmpleado
    @EmployeeID INT
AS
BEGIN
    SELECT *
    FROM Orders
    WHERE EmployeeID = @EmployeeID;
END;
GO

CREATE PROCEDURE ObtenerInformacionProducto
    @ProductName NVARCHAR(100),
    @UnitPrice MONEY OUTPUT,
    @TotalUnidadesVendidas INT OUTPUT
AS
BEGIN
    SELECT @UnitPrice = p.UnitPrice,
           @TotalUnidadesVendidas = SUM(od.Quantity)
    FROM dbo.Products p
    INNER JOIN dbo.[Order Details] od ON p.ProductID = od.ProductID
    INNER JOIN dbo.Orders o ON od.OrderID = o.OrderID
    WHERE p.ProductName = @ProductName
    GROUP BY p.UnitPrice;
END;
