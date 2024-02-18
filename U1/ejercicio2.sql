use nw
go

-- ##################### 1 #####################
-- Para la base de datos NORTHWND cree una nueva tabla, que permita puntuar 
--a los customersID con m�s �rdenes TOP 5, la nueva tabla deber� tener los 
--siguientes campos CustomerID, Name, QuantityOrders. Para realizar la 
--inserci�n en la nueva tabla, deber� utilizar un cursor para contabilizar e 
--insertar en la tabla.
DECLARE @QuantityOrders AS int
DECLARE @CustomerID AS nchar(5)
DECLARE @name AS nvarchar(30)
declare crc cursor 
for 
select COUNT(a.CustomerID) QuantityOrders, a.CustomerID, b.ContactName from Orders a
inner join Customers b
ON a.CustomerID = b.CustomerID
group by a.CustomerID, b.ContactName
order by COUNT(a.CustomerID) desc
OFFSET 0 ROWS FETCH FIRST 5 ROWS ONLY
OPEN crc
delete from dbo.puntuacion
FETCH NEXT FROM crc INTO @QuantityOrders, @CustomerID, @name
WHILE @@fetch_status = 0
BEGIN
	insert into dbo.puntuacion values (@CustomerID, @name, @QuantityOrders)
    FETCH NEXT FROM crc INTO @QuantityOrders, @CustomerID, @name
END
CLOSE crc
DEALLOCATE crc
go

-- ##################### 2 #####################
--Crear un trigger sobre la tabla Customers para que permita encriptar el campo 
--HomePhone para cuando se cree un nuevo registro sobre esta tabla
alter table Customers
add phone varchar(255)
GO

create trigger tep
ON Customers
AFTER insert
AS
Begin
	UPDATE c
    SET c.Phone = CONVERT(VARCHAR(255), ENCRYPTBYPASSPHRASE('clave', (select phone from inserted)))
    FROM Customers c
    INNER JOIN inserted i ON c.CustomerID = i.CustomerID;
end

delete from Customers where CustomerID = '12'
INSERT INTO [dbo].[Customers]
    VALUES
        ('12','12','12','12','12','12','12','12','12','12','12')

select * from Customers where CustomerID = '12'


-- ##################### 3 #####################
--Genere un cursor que permita agregar un descuento en la tabla Order Details
--con base en las siguientes condiciones:
--Categor�a Seafood 5%, categor�a Dairy Products 6%, categor�a Meat/Poultry 
--7%. Despu�s que actualice el campo Discount en la tabla Order Details, 
--deber� imprimir en forma de reporte (use PRINT) los siguientes valores 
--Order ID, ProductName, SubTotal, que ser� igual a UnitPrice * Quantity , 
--Discount, Total (SubTotal � Discount)
declare co cursor
for
select a.OrderID, a.ProductID, b.ProductName, a.UnitPrice, a.Quantity, a.Discount, c.CategoryName from [Order Details] a
inner join Products b 
on a.ProductID = b.ProductID
inner join Categories c
on b.CategoryID = c.CategoryID
where c.CategoryName = 'Seafood' or c.CategoryName = 'Dairy Products' or c.CategoryName = 'Meat/Poultry'
open co
declare @orderID nvarchar(20)
declare @productID nvarchar(20)
declare @product nvarchar(40)
declare @price nvarchar(10)
declare @qua smallint
declare @dis nvarchar(5)
declare @category varchar(15)
declare @total real
fetch next from co into @orderID,@productID, @product, @price, @qua, @dis, @category
while @@FETCH_STATUS = 0 
begin 
	if @category = 'Seafood'
	begin
		set @dis = 0.05
	end
	if @category = 'Dairy Products'
	begin
		set @dis = 0.06
	end
	if @category = 'Meat/Poultry'
	begin
		set @dis = 0.07
	end
	set @total = cast(@price as real)*cast(@qua as real)
	update [Order Details]
	set Discount = @dis
	where OrderID = @orderID and ProductID = @productID 
	print 'Order ID: '+@orderID+', ProductName: '+@product+', Category: '+@category+', SubTotal: '+cast(@total as varchar)+', Discount: '+@dis+', Total: ' + cast((@total*(1.0-@dis)) as varchar)
	
	fetch next from co into @orderID,@productID, @product, @price, @qua, @dis, @category
end
close co
deallocate co
-- ##################### 4 #####################
--Modifique la estructura de la tabla Employees, agregue el campo estado 
--char(1) e inicialice el valor de esta columna en A = �ACTIVO�. Deber� 
--agregar un check constraint para que solo permita los valores A, I.
ALTER TABLE Employees
ADD estado CHAR(1) DEFAULT 'A';

UPDATE Employees
SET estado = 'A';

ALTER TABLE Employees
ADD CONSTRAINT CK_Employees_Estado
CHECK (estado IN ('A', 'I'));

-- ##################### 5 #####################
--Cree una tabla de EliminacionesHistoricas con la siguiente estructura: ID int 
--identity, IDEntity varchar(20) [aqu� guardar� el ID de la entidad que est� 
--eliminando, es decir, si elimino un employee entonces el valor ser� 
--employeID, si es un producto, ser� productID y as� sucesivamente], acci�n
--varchar (100), fecha DATE, usuario
CREATE TABLE EliminacionesHistoricas (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Ide VARCHAR(20),
    Accion VARCHAR(100),
    Fecha DATE,
    Usuario VARCHAR(50)
);
GO

-- ##################### 6 #####################
--Cree un trigger sobre la tabla Employees para que en lugar de hacer una 
--eliminaci�n, cambie el valor del status a I y lo inserte en la tabla 
--EliminacionesHist�ricas que creo en el numeral 5.
-- Crear el trigger en la tabla Employees
CREATE TRIGGER trg_Employees_Delete
ON Employees
INSTEAD OF DELETE
AS
BEGIN
    INSERT INTO EliminacionesHistoricas(Ide, Accion, Fecha, Usuario)
    SELECT 'EmployeeID', 'Eliminar Employee', GETDATE(), SYSTEM_USER
    FROM deleted;
    UPDATE e
    SET e.estado = 'I'
    FROM Employees e
    INNER JOIN deleted d ON e.EmployeeID = d.EmployeeID;

END;

-- ##################### 7 #####################
-- Cree un cursor sobre la tabla que Order Details para que a todas las ordenes 
--que se emitieron en diciembre de 1997, si la cantidad de productos de la 
--categor�a Dairy Products les agregu� un discount de un 3% adicional y 
--recalcule el valor del total, esta informaci�n la deber� mostrar con un print
--OrderID, Product Name, SubTotal (Unit Price*Quantity), Discount, Total
--(SubTotal-Discount).

declare co cursor
for
select  a.OrderID, c.ProductName, a.UnitPrice, a.Quantity, a.Discount
from [Order Details] a
inner join Orders b
on a.OrderID = b.OrderID
inner join Products c
on a.ProductID = c.ProductID
inner join Categories d
on c.CategoryID = d.CategoryID
where b.OrderDate between '1997-12-01 00:00:00' and '1997-12-31 23:59:59'
and d.CategoryName = 'Dairy Products'

open co
declare @orderID nvarchar(20)
declare @product nvarchar(40)
declare @price nvarchar(10)
declare @qua smallint
declare @dis nvarchar(5)
declare @total real
fetch next from co into @orderID, @product, @price, @qua, @dis
while @@FETCH_STATUS = 0
begin 
	set @total = cast(@price as real)*cast(@qua as real)
	set @dis = @dis + 0.03
	print 'Order ID: '+@orderID+', ProductName: '+@product+', SubTotal: '+cast(@total as varchar)+', Discount: '+@dis+', Total: ' + cast((@total*(1.0-@dis)) as varchar)
	fetch next from co into @orderID, @product, @price, @qua, @dis
end
close co
deallocate co