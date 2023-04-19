-- SCRIPT GRUPO BASE DE DATOS MARTES
-- AUTOR: Kevin Rosero, Emilia Morejon, William Pepinos
-- FECHA CREACION: 07 DE ABRIL DE 2023
-- FECHA ULTIMA MODIFICACION: 09 DE ABRIL DE 2023
---------------------------------
--CREACION DE LA BASE DE DATOS
USE MASTER
GO
IF(DB_ID('RESERVA_EQUIPOS_COMPLETO')IS NOT NULL)
BEGIN
	DROP DATABASE RESERVA_EQUIPOS_COMPLETO
END
GO
CREATE DATABASE RESERVA_EQUIPOS_COMPLETO
GO

USE RESERVA_EQUIPOS_COMPLETO
GO
---------------------------------
--/--CREACION TIPOS DE DATOS/

--CREACION DEL TIPO DE DATO CEDULA
--AUTOR: Kevin Rosero, Emilia Morejon, William Pepinos
--CREACION
--FECHA DE CREACION: 08 DE ABRIL DE 2023
--FECHA DE ULTIMA ACTUALIZACION: 08 DE ABRIL DE 2023
CREATE TYPE cedula 
FROM char(10) NOT NULL
GO
--CREACION DEL TIPO DE DATO CORREO
--AUTOR: Kevin Rosero, Emilia Morejon, William Pepinos
--CREACION
--FECHA DE CREACION: 08 DE ABRIL DE 2023
--FECHA DE ULTIMA ACTUALIZACION: 08 DE ABRIL DE 2023
CREATE TYPE correo 
FROM varchar(100) NULL
GO
---------------------------------
--/--CREACION TABLAS/
----CREACION TABLA CLIENTE---------------
IF OBJECT_ID('Cliente') IS NOT NULL
	DROP TABLE Cliente
GO
CREATE TABLE Cliente (
  idCliente tinyint IDENTITY (1,1) NOT NULL,
  cedula cedula,
  nombre varchar(40) NOT NULL,
  apellido varchar(40) NOT NULL,
  correo correo,
  telefono varchar(10) NOT NULL,
  fechaNacimiento date NOT NULL,
  peso decimal(10,2) NOT NULL,
  usuarioRegistro varchar(50) NOT NULL DEFAULT suser_name() ,
  fechaRegistro date NOT NULL DEFAULT getdate()
  CONSTRAINT PK_idcliente PRIMARY KEY (idCliente),
  CONSTRAINT CH_nombreFormato CHECK (nombre LIKE '[A-Z][a-z]%' AND nombre NOT LIKE '%[^a-zA-Z]%'),
  CONSTRAINT CH_apellidoFormato CHECK (apellido LIKE '[A-Z][a-z]%' AND apellido NOT LIKE '%[^a-zA-Z]%'),
  CONSTRAINT CH_longitudTelefono CHECK(telefono LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
  CONSTRAINT CH_fechaNacimiento CHECK (fechaNacimiento <= CONVERT(date, GETDATE())),
  CONSTRAINT CH_peso CHECK (peso > 0 AND peso <= 1000),
  CONSTRAINT UQ_cedula UNIQUE(cedula),
  CONSTRAINT UQ_telefono UNIQUE(telefono)
);
GO

----CREACION TABLA EQUIPO---------------
IF OBJECT_ID('Equipo') IS NOT NULL
	DROP TABLE Equipo
GO
CREATE TABLE Equipo(
    idEquipo tinyint IDENTITY (1,1) NOT NULL,
    nombre varchar (40) NOT NULL,
    edadMInima tinyint  NOT NULL,
    edadMaxima tinyint NOT NULL,
    pesoMaximo decimal(10,2) NOT NULL,
    tiempoMaximo tinyint NOT NULL,
    estado BIT NOT NULL,
    usuarioRegistro varchar(50) NOT NULL DEFAULT suser_name() ,
    fechaRegistro date NOT NULL DEFAULT getdate(),
    CONSTRAINT PK_idEquipo PRIMARY KEY (idEquipo),
	CONSTRAINT CH_nombreFormatoEquipo CHECK (nombre LIKE '%[a-zA-Z0-9]%'),
	CONSTRAINT CH_Edad CHECK (edadMaxima > edadMInima AND edadMaxima>0 AND edadMinima >0 AND edadMaxima<120 AND edadMinima<120),
	CONSTRAINT CH_pesoEquipo CHECK (pesoMaximo > 0),
	CONSTRAINT CH_tiempoMax CHECK (tiempoMaximo > 0 AND tiempoMaximo <= 60),
	CONSTRAINT CH_estadoFormato CHECK (estado IN (0, 1)), --1 para Activo y 0 para dañado
	CONSTRAINT UN_EquipoUnique UNIQUE (nombre)
);
GO

----CREACION TABLA USO EQUIPO---------------
IF OBJECT_ID('UsoEquipo') IS NOT NULL
	DROP TABLE UsoEquipo
GO
CREATE TABLE UsoEquipo (
  idUso tinyint IDENTITY (1,1) NOT NULL,
  idCliente tinyint NOT NULL,
  idEquipo tinyint NOT NULL,
  fechaReserva DATETIME NOT NULL,
  fechaHoraUso DATETIME NOT NULL,
  minutosUso INT NOT NULL,
  usuarioRegistro VARCHAR(50) NOT NULL DEFAULT suser_name() ,
  fechaRegistro DATE NOT NULL DEFAULT getdate(),
  CONSTRAINT PK_idUso PRIMARY KEY (idUso),
  CONSTRAINT FK_UsoEquipoCliente FOREIGN KEY (idCliente) REFERENCES Cliente(idCliente),
  CONSTRAINT FK_UsoEquipoEquipos FOREIGN KEY (idEquipo) REFERENCES Equipo(idEquipo),
  CONSTRAINT CH_fechas CHECK(fechaHoraUso BETWEEN fechaReserva AND DATEADD(minute, 15, fechaReserva))
);
GO

---------------------------------
----CREACION REGLAS

--REGLA DE LA CEDULA-----------
CREATE RULE cedula_regla
AS @value LIKE '[0][1-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' -- del 01 al 09 
OR @value LIKE '1[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' -- del 10 al 19 
OR @value LIKE '2[0-4][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' -- del 20 al 24 
OR @value LIKE '30[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' -- el 30 
GO
--REGLA DEL CORREO-----------
CREATE RULE correo_regla
AS @value LIKE '%_@__%.__%' AND @value NOT LIKE '%[^a-zA-Z0-9@._]%'
GO

---------------------------------
----ENLACE REGLAS
--ENLACE REGLA DE LA CEDULA-----------
sp_bindrule cedula_regla, 'dbo.Cliente.cedula'
GO
--ENLACE REGLA DEL CORREO-----------
sp_bindrule correo_regla, 'dbo.Cliente.correo'
GO
---------------------------------
----INGRESO DE DATOS
----------INGRESO DE DATOS CLIENTE--------------------
INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES ('1004177455', 'Kevin', 'Rosero', 'kevin.rosero@udla.edu.ec','0993884541', '1997-12-16', 89.5)
INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES ('1750578963', 'Emilia', 'Morejon', 'emilia.morejon.cardenas@udla.edu.ec','0998980115', '2002-03-15', 75)
INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES ('1724589443', 'William', 'Pepinos', 'william.pepinos@udla.edu.ec','0986807237', '1999-11-09', 82.3)
INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES ('1004177448', 'Aaron', 'Rosero', 'aaron.rosero@udla.edu.ec','0979852861', '2000-04-03', 62)
INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES ('2410235678', 'Jose', 'Ramos', 'joseramos@gmail.com','0999637445', '1995-10-21', 95)
INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES ('0210321330', 'Ernesto', 'Villegas', 'ernesto._@gmail.com','0985558194', '1968-04-03', 92.5)

INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES('0605065622','Andres','Nuñez','andNunez@gmail.com','0992811899','2003-03-23',64.05)
INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES('1601654116','Galo','Estrella','glEstrella@gmail.com','0942213299','2004-01-10', 34.05)
INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES('2235064233','Mateo','Velasquez','mVelasquez@gmail.com','0991814239','2000-02-14',35.0)
INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES('1755365690','Santiago','Arias','sArias@gmail.com','0995911548','2001-04-24',20.05)
INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES('0235663462','Ricardo','Vinueza','vinueza@gmail.com','0992358249','2001-06-05',35.0)
INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES('0125635642','Joaquin','Perez','joaPerez@gmail.com','0994769899','2002-07-23',44)

INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES('1712345678', 'Juan', 'Pérez', 'juan.perez@gmail.com', '0987654321', '1990-01-01', 70.5)
INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES('1823456789', 'María', 'García', 'maria.garcia@gmail.com', '0998765432', '1985-05-10', 65.2)
INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES('1934567890', 'Pedro', 'Ramírez', 'pedro.ramirez@gmail.com', '0987654327', '2000-12-25', 80.0)
INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES('2045678901', 'Ana', 'Gómez', 'ana.gomez@gmail.com', '0998765435', '1978-08-15', 55.0)          
INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES('2156789012', 'José', 'López', 'jose.lopez@gmail.com', '0987654329', '1995-06-30', 75.8)   
INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES('2267890123', 'Laura', 'Herrera', 'laura.herrera@gmail.com', '0998765431', '1982-11-20', 60.7)                     
GO

----------INGRESO DE DATOS EQUIPO--------------------
INSERT INTO Equipo(nombre, edadMInima, edadMaxima, pesoMaximo, tiempoMaximo, estado) VALUES ('Cinta de correr', 14, 70, 200.00, 60, 1)
INSERT INTO Equipo(nombre, edadMInima, edadMaxima, pesoMaximo, tiempoMaximo, estado) VALUES ('Bicicleta Vertical', 14, 60, 200.00, 60, 1)
INSERT INTO Equipo(nombre, edadMInima, edadMaxima, pesoMaximo, tiempoMaximo, estado) VALUES ('Remo', 14, 60, 200.00, 45 , 1)
INSERT INTO Equipo(nombre, edadMInima, edadMaxima, pesoMaximo, tiempoMaximo, estado) VALUES ('Maquina de Poleas', 14, 60, 200.00, 45 , 1)
INSERT INTO Equipo(nombre, edadMInima, edadMaxima, pesoMaximo, tiempoMaximo, estado) VALUES ('Prensa de Piernas', 14, 60, 200.00, 45 , 1)
INSERT INTO Equipo(nombre, edadMInima, edadMaxima, pesoMaximo, tiempoMaximo, estado) VALUES ('Banco Olimpico', 14, 60, 200.00, 45 , 0)

INSERT INTO Equipo(nombre, edadMInima, edadMaxima, pesoMaximo, tiempoMaximo, estado) VALUES ('Máquina de escalada', 14, 70, 200.00, 60, 1)
INSERT INTO Equipo(nombre, edadMInima, edadMaxima, pesoMaximo, tiempoMaximo, estado) VALUES ('Elíptica', 14, 60, 200.00, 60, 1)
INSERT INTO Equipo(nombre, edadMInima, edadMaxima, pesoMaximo, tiempoMaximo, estado) VALUES ('Stepper', 14, 60, 200.00, 45 , 1)
INSERT INTO Equipo(nombre, edadMInima, edadMaxima, pesoMaximo, tiempoMaximo, estado) VALUES ('Máquina abdominal', 14, 60, 200.00, 45 , 1)
INSERT INTO Equipo(nombre, edadMInima, edadMaxima, pesoMaximo, tiempoMaximo, estado) VALUES ('Máquina de press', 14, 60, 200.00, 45 , 1)
INSERT INTO Equipo(nombre, edadMInima, edadMaxima, pesoMaximo, tiempoMaximo, estado) VALUES ('Prensa inclinada', 14, 60, 200.00, 45 , 1)

INSERT INTO Equipo(nombre, edadMInima, edadMaxima, pesoMaximo, tiempoMaximo, estado) VALUES ('Curl de bíceps', 14, 70, 200.00, 60, 1)
INSERT INTO Equipo(nombre, edadMInima, edadMaxima, pesoMaximo, tiempoMaximo, estado) VALUES ('Máquina de tríceps', 14, 60, 200.00, 60, 1)
INSERT INTO Equipo(nombre, edadMInima, edadMaxima, pesoMaximo, tiempoMaximo, estado) VALUES ('Extensión de piernas', 14, 60, 200.00, 45 , 1)
INSERT INTO Equipo(nombre, edadMInima, edadMaxima, pesoMaximo, tiempoMaximo, estado) VALUES ('Máquina de piernas', 14, 60, 200.00, 45 , 1)
INSERT INTO Equipo(nombre, edadMInima, edadMaxima, pesoMaximo, tiempoMaximo, estado) VALUES ('Máquina de pull-down', 14, 60, 200.00, 45 , 1)
INSERT INTO Equipo(nombre, edadMInima, edadMaxima, pesoMaximo, tiempoMaximo, estado) VALUES ('Máquina de hombros', 14, 60, 200.00, 45 , 0)
GO
----------INGRESO DE DATOS USO CLIENTE--------------------
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (1, 1, '2022-06-15 08:00:00', '2022-06-15 08:05:00', 13)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (1, 2, '2022-06-15 08:00:00', '2022-06-15 08:05:00', 14)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (1, 1, '2023-04-09 11:30:00', '2023-04-09 11:35:00', 10)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (2, 3, '2023-04-10 14:00:00', '2023-04-10 14:15:00', 11)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (3, 1, '2023-04-11 16:30:00', '2023-04-11 16:45:00', 14)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (4, 2, '2023-04-12 07:00:00', '2023-04-12 07:05:00', 13)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (4, 3, '2023-04-13 10:00:00', '2023-04-13 10:10:00', 10)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (5, 1, '2023-04-14 12:00:00', '2023-04-14 12:10:00', 15)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (6, 2, '2023-04-15 14:00:00', '2023-04-15 14:05:00', 11)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (1, 4, '2022-06-15 08:00:00', '2022-06-15 08:07:00', 12)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (1, 5, '2023-04-09 11:30:00', '2023-04-09 11:33:00', 12)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (2, 4, '2023-04-10 14:00:00', '2023-04-10 14:10:00', 14)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (3, 5, '2023-04-11 16:00:00', '2023-04-11 16:05:00', 15)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (4, 6, '2023-04-12 07:00:00', '2023-04-12 07:08:00', 14)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (4, 5, '2023-04-13 10:00:00', '2023-04-13 10:05:00', 11)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (5, 4, '2023-04-14 12:00:00', '2023-04-14 12:11:00', 10)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (6, 6, '2023-04-15 14:00:00', '2023-04-15 14:02:00', 10)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (2, 2, '2023-04-15 16:00:00', '2023-04-15 16:00:00', 11)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (3, 3, '2023-04-18 14:00:00', '2023-04-18 14:01:00', 12)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (4, 4, '2023-04-18 15:00:00', '2023-04-18 15:13:00', 14)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (5, 5, '2023-04-18 15:00:00', '2023-04-18 15:14:00', 13)

INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (7, 1, '2022-06-15 08:00:00', '2022-06-15 08:05:00', 13)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (7, 7, '2022-06-15 08:00:00', '2022-06-15 08:05:00', 14)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (7, 10, '2023-04-09 11:30:00', '2023-04-09 11:35:00', 10)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (8, 2, '2023-04-10 14:00:00', '2023-04-10 14:15:00', 11)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (8, 12, '2023-04-11 16:30:00', '2023-04-11 16:45:00', 14)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (8, 18, '2023-04-12 07:00:00', '2023-04-12 07:05:00', 13)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (9, 15, '2023-04-13 10:00:00', '2023-04-13 10:10:00', 10)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (9, 14, '2023-04-14 12:00:00', '2023-04-14 12:10:00', 15)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (9, 2, '2023-04-15 14:00:00', '2023-04-15 14:05:00', 11)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (10, 17, '2022-06-15 08:00:00', '2022-06-15 08:07:00', 12)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (10, 5, '2023-04-09 11:30:00', '2023-04-09 11:33:00', 12)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (10, 9, '2023-04-10 14:00:00', '2023-04-10 14:10:00', 14)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (11, 3, '2023-04-11 16:00:00', '2023-04-11 16:05:00', 15)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (11, 13, '2023-04-12 07:00:00', '2023-04-12 07:08:00', 14)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (11, 16, '2023-04-13 10:00:00', '2023-04-13 10:05:00', 11)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (12, 1, '2023-04-14 12:00:00', '2023-04-14 12:11:00', 10)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (12, 7, '2023-04-15 14:00:00', '2023-04-15 14:02:00', 10)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (12, 10, '2023-04-15 16:00:00', '2023-04-15 16:00:00', 11)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (13, 11, '2023-04-18 14:00:00', '2023-04-18 14:01:00', 12)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (13, 18, '2023-04-18 15:00:00', '2023-04-18 15:13:00', 14)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (13, 3, '2023-04-18 15:00:00', '2023-04-18 15:14:00', 13)

INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (14, 11, '2022-06-15 08:00:00', '2022-06-15 08:05:00', 13)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (14, 10, '2022-06-15 08:00:00', '2022-06-15 08:05:00', 14)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (14, 2, '2023-04-09 11:30:00', '2023-04-09 11:35:00', 10)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (15, 18, '2023-04-10 14:00:00', '2023-04-10 14:15:00', 11)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (15, 5, '2023-04-11 16:30:00', '2023-04-11 16:45:00', 14)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (15, 1, '2023-04-12 07:00:00', '2023-04-12 07:05:00', 13)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (16, 15, '2023-04-13 10:00:00', '2023-04-13 10:10:00', 10)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (16, 12, '2023-04-14 12:00:00', '2023-04-14 12:10:00', 15)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (16, 13, '2023-04-15 14:00:00', '2023-04-15 14:05:00', 11)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (16, 14, '2022-06-15 08:00:00', '2022-06-15 08:07:00', 12)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (17, 8, '2023-04-09 11:30:00', '2023-04-09 11:33:00', 12)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (17, 10, '2023-04-10 14:00:00', '2023-04-10 14:10:00', 14)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (17, 17, '2023-04-11 16:00:00', '2023-04-11 16:05:00', 15)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (18, 11, '2023-04-12 07:00:00', '2023-04-12 07:08:00', 14)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (18, 7, '2023-04-13 10:00:00', '2023-04-13 10:05:00', 11)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (18, 6, '2023-04-14 12:00:00', '2023-04-14 12:11:00', 10)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (12, 9, '2023-04-15 14:00:00', '2023-04-15 14:02:00', 10)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (14, 8, '2023-04-15 16:00:00', '2023-04-15 16:00:00', 11)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (14, 12, '2023-04-18 14:00:00', '2023-04-18 14:01:00', 12)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (11, 13, '2023-04-18 15:00:00', '2023-04-18 15:13:00', 14)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (9, 16, '2023-04-18 15:00:00', '2023-04-18 15:14:00', 13)
GO

---------------------------------
----MUESTRA DE DATOS/
SELECT cedula AS 'Cedula', nombre+' '+apellido AS 'Nombre Completo', correo AS 'Correo Electronico', telefono AS 'Telefono',
fechaNacimiento AS 'Fecha de Nacimiento', CONCAT(peso, ' [kg]') AS 'Peso', usuarioRegistro AS 'Usuario Registro', fechaRegistro AS 'Fecha de Registro'
FROM Cliente
GO

SELECT nombre AS 'Nombre', CONCAT(edadMInima, ' [Años]') AS 'Edad Minima', CONCAT(edadMaxima, ' [Años]') AS 'Edad Maxima', 
CONCAT(pesoMaximo, ' [kg]') AS 'Peso Maximo', CONCAT(tiempoMaximo, ' minutos') AS 'Tiempo Maximo', CASE WHEN estado = 1 THEN 'Activo' ELSE 'Dañado'END AS 'Estado de la Maquina', 
usuarioRegistro AS 'Usuario Registro', fechaRegistro AS 'Fecha de Registro' 
FROM Equipo;
GO

SELECT E.nombre AS 'Nombre equipo reservado', C.nombre+' '+C.apellido AS 'Reservado por', C.cedula AS 'Cedula', C.telefono AS 'Telefono',
CONVERT(varchar(10), UE.fechaReserva, 23) AS 'Fecha de reserva', CONVERT(varchar(8), UE.fechaReserva, 108) AS 'Hora que planea usar' ,CONVERT(varchar(8), UE.fechaHoraUso, 108) AS 'Hora que empezo a usar'
FROM Cliente AS C
INNER JOIN  UsoEquipo AS UE ON C.idCliente=UE.idCliente
INNER JOIN Equipo AS E ON UE.idEquipo = E.idEquipo
GROUP BY E.nombre, C.nombre, C.apellido, C.cedula, C.telefono, UE.fechaReserva	, UE.fechaHoraUso
GO


--VER REGLAS
--SELECT * FROM SYS.sysobjects
--where xtype='R'

----PRUEBA CON ERRORES
--INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES ('4004177455', 'Kevin', 'Rosero', 'kevin.rosero@udla.edu.ec','0993884542', '1997-12-16', 89.5)
--INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES ('2004177455', 'Kevin', 'Rosero', 'kevin.roseroudla.edu.ec','0993884542', '1997-12-16', 89.5)


---------------------------------
--/--SCRPIPTS DEBER/
--Número de préstamos por equipo de aquellos que se pueden usar entre 15 y 55 años de edad.  
--La consulta deberá devolver tres columnas: "Nombre del equipo", "Rango de edad mínima y máxima" y "Número de Préstamos" 



--Nombre y apellido de los clientes (en una sola columna con título "Clientes") que han realizado préstamos de los 3 equipos más comúnmente utilizados.


--Listado de equipos con su estado. Deberá presentarse en el resultado de la consulta las columnas: "Equipo", "Peso", "Estado" 
--(cuando esté Disponible deberá presentarse la frase "Disponible para préstamo", cuando esté Prestado, deberá presentarse la frase "Prestado a cliente")  

--Listado de equipos de aquellos que han sido reservados pero no han sido utilizados durante el presente mes.

--Modificación de datos:  Cree una tabla llamada "Entrenadores" basada en los registros de Clientes, 
--que incluya los 5 primeros clientes ordenados de manera descendente por la edad que están registrados en la tabla.  
--Asígneles a los Entrenadores un correo compuesto por primera letra de nombre seguido de apellido@gimnasio.ec   

-- Crear la tabla Entrenadores solo después de que se hayan insertado los primeros 5 clientes
IF (SELECT COUNT(*) FROM Cliente) >= 5
BEGIN
  -- Crear la tabla Entrenadores
  CREATE TABLE Entrenadores (
    idEntrenador tinyint IDENTITY (1,1) NOT NULL,
    nombre varchar(40) NOT NULL,
    apellido varchar(40) NOT NULL,
    correoEntrenador correo,
    edad tinyint NOT NULL,
	idCliente tinyint,
    CONSTRAINT PK_idEntrenador PRIMARY KEY (idEntrenador),
	CONSTRAINT FK_Cliente_Entrenador FOREIGN KEY (idCliente) REFERENCES Cliente(idCliente),
    CONSTRAINT CH_nombreFormatoEntrenador CHECK (nombre LIKE '[A-Z][a-z]%' AND nombre NOT LIKE '%[^a-zA-Z]%'),
    CONSTRAINT CH_apellidoFormatoEntrenador CHECK (apellido LIKE '[A-Z][a-z]%' AND apellido NOT LIKE '%[^a-zA-Z]%'),
    CONSTRAINT CH_correoEntrenadorFormato CHECK (correoEntrenador LIKE '%@gimnasio.ec'),
    CONSTRAINT CH_edadEntrenador CHECK (edad >= 18 AND edad <= 100)
  );

  -- Insertar datos en la tabla Entrenadores
  INSERT INTO Entrenadores (nombre, apellido, correoEntrenador, edad)
  SELECT TOP 5 nombre, apellido, LOWER(apellido) + '@gimnasio.ec', FLOOR(DATEDIFF(DAY, fechaNacimiento, GETDATE()) / 365.25) AS Edad
  FROM Cliente
 END

 Select nombre, apellido, correoEntrenador, edad from Entrenadores
 ORDER BY edad DESC


--Genere el script que devuelva el nombre y apellido (en una sola columna) y el tipo de usuario Cliente 
--o Entrenador de las personas registradas en la base de datos. En el caso que sean Cliente y Entrenador deberá tener esa especificación.  
SELECT 
  CASE 
    WHEN c.idCliente IS NOT NULL THEN 'Cliente' 
    WHEN e.idEntrenador IS NOT NULL THEN 'Entrenador' 
  END as Tipo,
  COALESCE(c.nombre, e.nombre)+''+ COALESCE(c.apellido, e.apellido) as 'Nombre y Apellido',
  e.correoEntrenador as correoEntrenador,
  peso
FROM Cliente c
FULL OUTER JOIN Entrenadores e ON c.idCliente = e.idCliente
ORDER BY Tipo, nombre, apellido;


