use test1
go

create database test1
go

create login prueba with password = '12345'
go
create user prueba for login prueba
go

grant select, insert on SCHEMA::dbo to prueba
go

create table dbo.users (
	userid int NOT NULL IDENTITY PRIMARY KEY,
    LastName varchar(255),
    FirstName varchar(255),
	email varchar(255),
	pass varbinary(255)
)
go

insert into dbo.users values ('cesar', 'flores', 'cofloresf@unah.hn', ENCRYPTBYPASSPHRASE('key','1234'))
go