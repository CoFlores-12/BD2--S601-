CREATE DATABASE BD_CARS_FIX
GO

use BD_CARS_FIX
GO

CREATE SCHEMA taller
GO

CREATE LOGIN user1 WITH PASSWORD = '1234'

CREATE USER user1 FOR LOGIN user1
GO

GRANT SELECT, DELETE, UPDATE ON SCHEMA::taller TO user1;
GRANT CREATE SCHEMA TO user1;
GRANT ALTER ON SCHEMA::taller TO user1;
GO

CREATE TABLE taller.autos (
    Matricula VARCHAR(8) PRIMARY KEY,
    Marca varchar(15),
    Modelo varchar(15),
    AnioFabricacion DECIMAL(4,0)
)

CREATE TABLE taller.mecanicos (
    DNI VARCHAR(14) PRIMARY KEY,
    Nombre VARCHAR(20),
    Puesto VARCHAR(20)
)

CREATE TABLE taller.trabajos (
    Matricula VARCHAR(8) FOREIGN KEY REFERENCES taller.autos(Matricula),
    DNI VARCHAR(14) FOREIGN KEY REFERENCES taller.mecanicos(DNI), 
    HORAS NUMERIC,
    fehca_reparacion DATE,
    primary key(Matricula,DNI),
    CONSTRAINT HORAS CHECK (HORAS>1)
)

CREATE LOGIN user2 WITH PASSWORD = '1234'

CREATE USER user2 FOR LOGIN user2
GO

GRANT SELECT, DELETE, UPDATE ON SCHEMA::taller TO user2;
GRANT CREATE SCHEMA TO user2;
GRANT ALTER ON SCHEMA::taller TO user2;
GO

REVOKE SELECT, DELETE, UPDATE ON SCHEMA::taller TO user1
REVOKE ALTER ON SCHEMA::taller TO user1;
REVOKE CREATE SCHEMA TO user1;
GO
