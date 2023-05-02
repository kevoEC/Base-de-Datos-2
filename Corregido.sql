-- SCRIPT GRUPO BASE DE DATOS MARTES
-- AUTOR: Kevin Rosero, Emilia Morejon, William Pepinos
-- FECHA CREACION: 07 DE ABRIL DE 2023
-- FECHA ULTIMA MODIFICACION: 19 DE ABRIL DE 2023
------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CREACION DE LA BASE DE DATOS, RESERVA EQUIPOS
------------------------------------------------------------------------------------------------------------------------------------------------------------
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
------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CREACION DE TIPOS DE DATOS
------------------------------------------------------------------------------------------------------------------------------------------------------------

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
------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CREACION DE TABLAS
------------------------------------------------------------------------------------------------------------------------------------------------------------
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
  fechaHoraUso DATETIME,
  minutosUso tinyint,
  usuarioRegistro VARCHAR(50) NOT NULL DEFAULT suser_name() ,
  fechaRegistro DATE NOT NULL DEFAULT getdate(),
  CONSTRAINT PK_idUso PRIMARY KEY (idUso),
  CONSTRAINT FK_UsoEquipoCliente FOREIGN KEY (idCliente) REFERENCES Cliente(idCliente),
  CONSTRAINT FK_UsoEquipoEquipos FOREIGN KEY (idEquipo) REFERENCES Equipo(idEquipo),
  CONSTRAINT CH_fechas CHECK(fechaHoraUso BETWEEN fechaReserva AND DATEADD(minute, 15, fechaReserva))
);
GO

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CREACION DE REGLAS
------------------------------------------------------------------------------------------------------------------------------------------------------------

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

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ENLACE DE LAS REGLAS CREADASS
------------------------------------------------------------------------------------------------------------------------------------------------------------

--ENLACE REGLA DE LA CEDULA-----------
sp_bindrule cedula_regla, 'dbo.Cliente.cedula'
GO
--ENLACE REGLA DEL CORREO-----------
sp_bindrule correo_regla, 'dbo.Cliente.correo'
GO
------------------------------------------------------------------------------------------------------------------------------------------------------------
-- iNGRESO DE LOS DATOS DE CLIENTE
------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES ('1004177455', 'Kevin', 'Rosero', 'kevin.rosero@udla.edu.ec','0993884541', '1997-12-16', 89.5)
INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES ('1750578963', 'Emilia', 'Morejon', 'emilia.morejon.cardenas@udla.edu.ec','0998980115', '2002-03-15', 75)
INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES ('1724589443', 'William', 'Pepinos', 'william.pepinos@udla.edu.ec','0986807237', '1999-11-09', 82.3)
INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES ('1004177448', 'Aaron', 'Rosero', 'aaron.rosero@udla.edu.ec','0979852861', '2000-04-03', 62)
INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES ('2410235678', 'Jose', 'Ramos', 'joseramos@gmail.com','0999637445', '1995-10-21', 95)
INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES ('0210321330', 'Ernesto', 'Villegas', 'ernesto._@gmail.com','0985558194', '1968-04-03', 92.5)
GO
INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES('0605065622','Andres','Nuñez','andNunez@gmail.com','0992811899','2003-03-23',64.05)
INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES('1601654116','Galo','Estrella','glEstrella@gmail.com','0942213299','2004-01-10', 34.05)
INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES('2235064233','Mateo','Velasquez','mVelasquez@gmail.com','0991814239','2000-02-14',35.0)
INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES('1755365690','Santiago','Arias','sArias@gmail.com','0995911548','2001-04-24',20.05)
INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES('0235663462','Ricardo','Vinueza','vinueza@gmail.com','0992358249','2001-06-05',35.0)
INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES('0125635642','Joaquin','Perez','joaPerez@gmail.com','0994769899','2002-07-23',44)
GO
INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES('1712345678', 'Juan', 'Pérez', 'juan.perez@gmail.com', '0987654321', '1990-01-01', 70.5)
INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES('1823456789', 'María', 'García', 'maria.garcia@gmail.com', '0998765432', '1985-05-10', 65.2)
INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES('1934567890', 'Pedro', 'Ramírez', 'pedro.ramirez@gmail.com', '0987654327', '2000-12-25', 80.0)
INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES('2045678901', 'Ana', 'Gómez', 'ana.gomez@gmail.com', '0998765435', '1978-08-15', 55.0)          
INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES('2156789012', 'José', 'López', 'jose.lopez@gmail.com', '0987654329', '1995-06-30', 75.8)   
INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES('2267890123', 'Laura', 'Herrera', 'laura.herrera@gmail.com', '0998765431', '1982-11-20', 60.7)                     
GO
INSERT INTO Cliente(cedula, nombre, apellido, correo, telefono, fechaNacimiento, peso) VALUES('0912345678', 'Juan', 'Pérez', 'juan.perez@gmail.com', '0987654300', '1990-01-01', 70.5)
INSERT INTO Cliente(cedula, nombre, apellido, correo, telefono, fechaNacimiento, peso) VALUES('0923456789', 'María', 'García', 'maria.garcia@gmail.com', '0998765400', '1985-05-10', 65.2)
INSERT INTO Cliente(cedula, nombre, apellido, correo, telefono, fechaNacimiento, peso) VALUES('0934567890', 'Pedro', 'Ramírez', 'pedro.ramirez@gmail.com', '0987654344', '2000-12-25', 80.0)
INSERT INTO Cliente(cedula, nombre, apellido, correo, telefono, fechaNacimiento, peso) VALUES('0945678901', 'Ana', 'Gómez', 'ana.gomez@gmail.com', '0998765399', '1978-08-15', 55.0)
INSERT INTO Cliente(cedula, nombre, apellido, correo, telefono, fechaNacimiento, peso) VALUES('0956789012', 'José', 'López', 'jose.lopez@gmail.com', '0987654377', '1995-06-30', 75.8)
GO
INSERT INTO Cliente(cedula, nombre, apellido, correo, telefono, fechaNacimiento, peso) VALUES('2067890123', 'Carlos', 'González', 'carlos.gonzalez@gmail.com', '0998765401', '1999-03-22', 68.5)
INSERT INTO Cliente(cedula, nombre, apellido, correo, telefono, fechaNacimiento, peso) VALUES('2178901234', 'Fernanda', 'Martínez', 'fernanda.martinez@gmail.com', '0987654378', '1988-11-18', 63.7)
INSERT INTO Cliente(cedula, nombre, apellido, correo, telefono, fechaNacimiento, peso) VALUES('2289012345', 'Sofía', 'Sánchez', 'sofia.sanchez@gmail.com', '0998765398', '1977-07-05', 59.2)
INSERT INTO Cliente(cedula, nombre, apellido, correo, telefono, fechaNacimiento, peso) VALUES('2390123456', 'Alejandro', 'Jiménez', 'alejandro.jimenez@gmail.com', '0987654343', '1992-12-15', 72.3)
INSERT INTO Cliente(cedula, nombre, apellido, correo, telefono, fechaNacimiento, peso) VALUES('2401234567', 'Martha', 'Álvarez', 'martha.alvarez@gmail.com', '0998765402', '1980-05-30', 57.8)
GO
INSERT INTO Cliente(cedula, nombre, apellido, correo, telefono, fechaNacimiento, peso) VALUES('0100000001', 'María', 'García', 'maria.garcia@gmail.com', '0000000001', '1990-01-15', 65.2);
INSERT INTO Cliente(cedula, nombre, apellido, correo, telefono, fechaNacimiento, peso) VALUES('0200000002', 'Juan', 'Ramírez', 'juan.ramirez@gmail.com', '0000000002', '1985-03-22', 78.3);
INSERT INTO Cliente(cedula, nombre, apellido, correo, telefono, fechaNacimiento, peso) VALUES('0300000003', 'Lucía', 'Fernández', 'lucia.fernandez@gmail.com', '0000000003', '1992-11-07', 61.1);
INSERT INTO Cliente(cedula, nombre, apellido, correo, telefono, fechaNacimiento, peso) VALUES('0400000004', 'Diego', 'Torres', 'diego.torres@gmail.com', '0000000004', '1994-07-18', 71.5);
INSERT INTO Cliente(cedula, nombre, apellido, correo, telefono, fechaNacimiento, peso) VALUES('0500000005', 'José', 'López', 'jose.lopez@gmail.com', '0000000005', '1995-06-30', 75.8);
INSERT INTO Cliente(cedula, nombre, apellido, correo, telefono, fechaNacimiento, peso) VALUES('0600000006', 'Paulina', 'Gómez', 'paulina.gomez@gmail.com', '0000000006', '1989-02-14', 62.9);
INSERT INTO Cliente(cedula, nombre, apellido, correo, telefono, fechaNacimiento, peso) VALUES('0700000007', 'Andrés', 'Pérez', 'andres.perez@gmail.com', '0000000007', '1987-04-23', 84.2);
INSERT INTO Cliente(cedula, nombre, apellido, correo, telefono, fechaNacimiento, peso) VALUES('0800000008', 'Gabriela', 'Herrera', 'gabriela.herrera@gmail.com', '0000000009', '1993-09-12', 56.4);
INSERT INTO Cliente(cedula, nombre, apellido, correo, telefono, fechaNacimiento, peso) VALUES('0900000009', 'Pedro', 'Sánchez', 'pedro.sanchez@gmail.com', '0000000010', '1984-08-01', 90.5);
INSERT INTO Cliente(cedula, nombre, apellido, correo, telefono, fechaNacimiento, peso) VALUES('1000000010', 'Carla', 'Álvarez', 'carla.alvarez@gmail.com', '0000000011', '1991-05-20', 67.3);
INSERT INTO Cliente(cedula, nombre, apellido, correo, telefono, fechaNacimiento, peso) VALUES('1100000011', 'Héctor', 'Guzmán', 'hector.guzman@gmail.com', '0000000012', '1986-12-17', 76.1);
GO

INSERT INTO Cliente(cedula, nombre, apellido, correo, telefono, fechaNacimiento, peso) VALUES('1100000012', 'María', 'García', 'maria.garcia@gmail.com', '0000000013', '1990-03-15', 65.2)
INSERT INTO Cliente(cedula, nombre, apellido, correo, telefono, fechaNacimiento, peso) VALUES('1100000013', 'Juan', 'Pérez', 'juan.perez@gmail.com', '0000000014', '1985-08-20', 78.5)
INSERT INTO Cliente(cedula, nombre, apellido, correo, telefono, fechaNacimiento, peso) VALUES('1100000014', 'Carlos', 'Ruiz', 'carlos.ruiz@gmail.com', '0000000015', '1998-12-10', 70.3)
INSERT INTO Cliente(cedula, nombre, apellido, correo, telefono, fechaNacimiento, peso) VALUES('1100000015', 'Ana', 'Gómez', 'ana.gomez@gmail.com', '0000000016', '1992-05-22', 57.1)
INSERT INTO Cliente(cedula, nombre, apellido, correo, telefono, fechaNacimiento, peso) VALUES('1100000016', 'Pedro', 'Herrera', 'pedro.herrera@gmail.com', '0000000017', '1988-10-05', 80.2)
INSERT INTO Cliente(cedula, nombre, apellido, correo, telefono, fechaNacimiento, peso) VALUES('1100000017', 'Sofía', 'Lara', 'sofia.lara@gmail.com', '0000000018', '1991-09-25', 62.9)
INSERT INTO Cliente(cedula, nombre, apellido, correo, telefono, fechaNacimiento, peso) VALUES('1100000018', 'Jorge', 'Chávez', 'jorge.chavez@gmail.com', '0000000019', '1997-02-14', 75.0)
INSERT INTO Cliente(cedula, nombre, apellido, correo, telefono, fechaNacimiento, peso) VALUES('1100000019', 'Laura', 'Alvarado', 'laura.alvarado@gmail.com', '0000000020', '1993-11-07', 58.7)
INSERT INTO Cliente(cedula, nombre, apellido, correo, telefono, fechaNacimiento, peso) VALUES('1100000020', 'Diego', 'Moreno', 'diego.moreno@gmail.com', '0000000021', '1989-07-12', 81.3)
INSERT INTO Cliente(cedula, nombre, apellido, correo, telefono, fechaNacimiento, peso) VALUES('1100000021', 'Mónica', 'Sánchez', 'monica.sanchez@gmail.com', '0000000022', '1994-04-01', 63.4)
INSERT INTO Cliente(cedula, nombre, apellido, correo, telefono, fechaNacimiento, peso) VALUES('1100000022', 'Andrés', 'Fernández', 'andres.fernandez@gmail.com', '0000000023', '1996-01-18', 72.6)
GO


------------------------------------------------------------------------------------------------------------------------------------------------------------
-- iNGRESO DE LOS DATOS DE EQUIPO
------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO Equipo(nombre, edadMInima, edadMaxima, pesoMaximo, tiempoMaximo, estado) VALUES ('Cinta de correr', 14, 70, 200.00, 60, 1)
INSERT INTO Equipo(nombre, edadMInima, edadMaxima, pesoMaximo, tiempoMaximo, estado) VALUES ('Bicicleta Vertical', 15, 50, 200.00, 60, 1)
INSERT INTO Equipo(nombre, edadMInima, edadMaxima, pesoMaximo, tiempoMaximo, estado) VALUES ('Remo', 15, 50, 200.00, 45 , 1)
INSERT INTO Equipo(nombre, edadMInima, edadMaxima, pesoMaximo, tiempoMaximo, estado) VALUES ('Maquina de Poleas', 14, 60, 200.00, 45 , 1)
INSERT INTO Equipo(nombre, edadMInima, edadMaxima, pesoMaximo, tiempoMaximo, estado) VALUES ('Prensa de Piernas', 14, 60, 200.00, 45 , 1)
INSERT INTO Equipo(nombre, edadMInima, edadMaxima, pesoMaximo, tiempoMaximo, estado) VALUES ('Banco Olimpico', 14, 60, 200.00, 45 , 0)

INSERT INTO Equipo(nombre, edadMInima, edadMaxima, pesoMaximo, tiempoMaximo, estado) VALUES ('Máquina de escalada', 14, 70, 200.00, 60, 1)
INSERT INTO Equipo(nombre, edadMInima, edadMaxima, pesoMaximo, tiempoMaximo, estado) VALUES ('Elíptica', 15, 50, 200.00, 60, 1)
INSERT INTO Equipo(nombre, edadMInima, edadMaxima, pesoMaximo, tiempoMaximo, estado) VALUES ('Stepper', 14, 60, 200.00, 45 , 1)
INSERT INTO Equipo(nombre, edadMInima, edadMaxima, pesoMaximo, tiempoMaximo, estado) VALUES ('Máquina abdominal', 15, 50, 200.00, 45 , 1)
INSERT INTO Equipo(nombre, edadMInima, edadMaxima, pesoMaximo, tiempoMaximo, estado) VALUES ('Máquina de press', 15, 54, 200.00, 45 , 1)
INSERT INTO Equipo(nombre, edadMInima, edadMaxima, pesoMaximo, tiempoMaximo, estado) VALUES ('Prensa inclinada', 14, 60, 200.00, 45 , 1)

INSERT INTO Equipo(nombre, edadMInima, edadMaxima, pesoMaximo, tiempoMaximo, estado) VALUES ('Curl de bíceps', 14, 70, 200.00, 60, 1)
INSERT INTO Equipo(nombre, edadMInima, edadMaxima, pesoMaximo, tiempoMaximo, estado) VALUES ('Máquina de tríceps', 14, 60, 200.00, 60, 1)
INSERT INTO Equipo(nombre, edadMInima, edadMaxima, pesoMaximo, tiempoMaximo, estado) VALUES ('Extensión de piernas', 14, 60, 200.00, 45 , 1)
INSERT INTO Equipo(nombre, edadMInima, edadMaxima, pesoMaximo, tiempoMaximo, estado) VALUES ('Máquina de piernas', 15, 55, 200.00, 45 , 1)
INSERT INTO Equipo(nombre, edadMInima, edadMaxima, pesoMaximo, tiempoMaximo, estado) VALUES ('Máquina de pull-down', 14, 60, 200.00, 45 , 1)
INSERT INTO Equipo(nombre, edadMInima, edadMaxima, pesoMaximo, tiempoMaximo, estado) VALUES ('Máquina de hombros', 14, 60, 200.00, 45 , 0)
INSERT INTO Equipo(nombre, edadMInima, edadMaxima, pesoMaximo, tiempoMaximo, estado) VALUES ('Maquina de prueba prestamo', 14, 60, 150.00, 45 , 0)
GO


------------------------------------------------------------------------------------------------------------------------------------------------------------
-- iNGRESO DE LOS DATOS DE USO DE EQUIPOS
------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (1, 1, '2022-06-15 08:00:00', '2022-06-15 08:05:00', 13)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (1, 2, '2022-06-15 08:00:00', '2022-06-15 08:05:00', 14)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (1, 9, '2023-04-09 11:30:00', '2023-04-09 11:35:00', 10)
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
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (9, 16, '2023-04-18 15:00:00', '2023-04-18 15:14:00', 13)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva) VALUES (9, 16, '2023-04-18 15:00:00')
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva) VALUES (9, 19, '2023-05-01 15:30:00')

INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (19, 7, '2022-06-15 08:00:00', '2022-06-15 08:05:00', 13)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (19, 11, '2022-06-15 08:00:00', '2022-06-15 08:05:00', 14)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (19, 13, '2023-04-09 11:30:00', '2023-04-09 11:35:00', 10)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (20, 14, '2023-04-10 14:00:00', '2023-04-10 14:15:00', 11)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (20, 1, '2023-04-11 16:30:00', '2023-04-11 16:45:00', 14)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (20, 2, '2023-04-12 07:00:00', '2023-04-12 07:05:00', 13)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (20, 3, '2023-04-13 10:00:00', '2023-04-13 10:10:00', 10)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (21, 4, '2023-04-14 12:00:00', '2023-04-14 12:10:00', 15)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (21, 5, '2023-04-15 14:00:00', '2023-04-15 14:05:00', 11)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (21, 6, '2022-06-15 08:00:00', '2022-06-15 08:07:00', 12)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (22, 17, '2023-04-09 11:30:00', '2023-04-09 11:33:00', 12)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (22, 12, '2023-04-10 14:00:00', '2023-04-10 14:10:00', 14)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (22, 13, '2023-04-11 16:00:00', '2023-04-11 16:05:00', 15)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (23, 17, '2023-04-12 07:00:00', '2023-04-12 07:08:00', 14)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (23, 15, '2023-04-13 10:00:00', '2023-04-13 10:05:00', 11)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (23, 9, '2023-04-14 12:00:00', '2023-04-14 12:11:00', 10)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (24, 9, '2023-04-15 14:00:00', '2023-04-15 14:02:00', 10)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (24, 4, '2023-04-15 16:00:00', '2023-04-15 16:00:00', 11)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (24, 5, '2023-04-18 14:00:00', '2023-04-18 14:01:00', 12)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (24, 10, '2023-04-18 15:00:00', '2023-04-18 15:13:00', 14)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (24, 11, '2023-04-18 15:00:00', '2023-04-18 15:14:00', 13)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (24, 15, '2023-04-18 15:00:00', '2023-04-18 15:14:00', 13)
GO

INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (25, 5, '2022-06-15 08:00:00', '2022-06-15 08:05:00', 13)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (25, 8, '2022-06-15 08:00:00', '2022-06-15 08:05:00', 14)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (25, 15, '2023-04-09 11:30:00', '2023-04-09 11:35:00', 10)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (26, 17, '2023-04-10 14:00:00', '2023-04-10 14:15:00', 11)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (26, 16, '2023-04-11 16:30:00', '2023-04-11 16:45:00', 14)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (26, 15, '2023-04-12 07:00:00', '2023-04-12 07:05:00', 13)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (26, 1, '2023-04-13 10:00:00', '2023-04-13 10:10:00', 10)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (27, 5, '2023-04-14 12:00:00', '2023-04-14 12:10:00', 15)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (27, 7, '2023-04-15 14:00:00', '2023-04-15 14:05:00', 11)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (27, 10, '2022-06-15 08:00:00', '2022-06-15 08:07:00', 12)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (28, 11, '2023-04-09 11:30:00', '2023-04-09 11:33:00', 12)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (28, 12, '2023-04-10 14:00:00', '2023-04-10 14:10:00', 14)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (28, 9, '2023-04-11 16:00:00', '2023-04-11 16:05:00', 15)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (29, 12, '2023-04-12 07:00:00', '2023-04-12 07:08:00', 14)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (29, 1, '2023-04-13 10:00:00', '2023-04-13 10:05:00', 11)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (29, 3, '2023-04-14 12:00:00', '2023-04-14 12:11:00', 10)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (30, 5, '2023-04-15 14:00:00', '2023-04-15 14:02:00', 10)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (30, 16, '2023-04-15 16:00:00', '2023-04-15 16:00:00', 11)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (30, 15, '2023-04-18 14:00:00', '2023-04-18 14:01:00', 12)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (31, 12, '2023-04-18 15:00:00', '2023-04-18 15:13:00', 14)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (31, 8, '2023-04-18 15:00:00', '2023-04-18 15:14:00', 13)
GO

INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (32, 10, '2022-06-15 08:00:00', '2022-06-15 08:05:00', 13)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (32, 12, '2022-06-15 08:00:00', '2022-06-15 08:05:00', 14)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (32, 17, '2023-04-09 11:30:00', '2023-04-09 11:35:00', 10)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (33, 13, '2023-04-10 14:00:00', '2023-04-10 14:15:00', 11)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (33, 11, '2023-04-11 16:30:00', '2023-04-11 16:45:00', 14)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (33, 12, '2023-04-12 07:00:00', '2023-04-12 07:05:00', 13)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (34, 7, '2023-04-13 10:00:00', '2023-04-13 10:10:00', 10)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (34, 10, '2023-04-14 12:00:00', '2023-04-14 12:10:00', 15)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (34, 15, '2023-04-15 14:00:00', '2023-04-15 14:05:00', 11)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (35, 16, '2022-06-15 08:00:00', '2022-06-15 08:07:00', 12)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (35, 17, '2023-04-09 11:30:00', '2023-04-09 11:33:00', 12)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (35, 13, '2023-04-10 14:00:00', '2023-04-10 14:10:00', 14)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (36, 11, '2023-04-11 16:00:00', '2023-04-11 16:05:00', 15)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (36, 8, '2023-04-12 07:00:00', '2023-04-12 07:08:00', 14)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (36, 9, '2023-04-13 10:00:00', '2023-04-13 10:05:00', 11)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (37, 9, '2023-04-14 12:00:00', '2023-04-14 12:11:00', 10)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (37, 10, '2023-04-15 14:00:00', '2023-04-15 14:02:00', 10)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (37, 7, '2023-04-15 16:00:00', '2023-04-15 16:00:00', 11)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (38, 8, '2023-04-18 14:00:00', '2023-04-18 14:01:00', 12)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (38, 3, '2023-04-18 15:00:00', '2023-04-18 15:13:00', 14)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (38, 10, '2023-04-18 15:00:00', '2023-04-18 15:14:00', 13)
GO

INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (39, 10, '2021-06-15 08:00:00', '2021-06-15 08:05:00', 13)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (39, 8, '2021-06-15 08:00:00', '2021-06-15 08:05:00', 14)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (40, 8, '2021-04-09 11:30:00', '2021-04-09 11:35:00', 10)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (40, 5, '2021-04-10 14:00:00', '2021-04-10 14:11:00', 11)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (41, 11, '2021-04-11 16:30:00', '2021-04-11 16:35:00', 14)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (41, 17, '2021-04-12 07:00:00', '2021-04-12 07:03:00', 13)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (42, 12, '2021-04-13 10:00:00', '2021-04-13 10:07:00', 10)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (42, 14, '2021-04-14 12:00:00', '2021-04-14 12:05:00', 15)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (43, 15, '2021-04-15 14:00:00', '2021-04-15 14:08:00', 11)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (43, 16, '2021-06-15 08:00:00', '2021-06-15 08:05:00', 12)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (44, 7, '2022-04-09 11:30:00', '2022-04-09 11:33:00', 12)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (44, 2, '2022-04-10 14:00:00', '2022-04-10 14:05:00', 14)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (45, 3, '2022-04-11 16:00:00', '2022-04-11 16:09:00', 15)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (45, 7, '2022-04-12 07:00:00', '2022-04-12 07:05:00', 14)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (46, 5, '2022-04-13 10:00:00', '2022-04-13 10:08:00', 11)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (47, 10, '2022-04-14 12:00:00', '2022-04-14 12:05:00', 10)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (48, 14, '2022-04-15 14:00:00', '2022-04-15 14:07:00', 10)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (49, 14, '2022-04-11 16:00:00', '2022-04-11 16:05:00', 11)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (49, 15, '2023-05-13 14:00:00', '2023-05-13 14:05:00', 12)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (49, 2, '2023-05-12 15:00:00', '2023-05-12 15:05:00', 14)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (50, 1, '2023-05-10 15:00:00', '2023-05-10 15:10:00', 13)
INSERT INTO UsoEquipo(idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso) VALUES (50, 5, '2023-05-15 15:00:00', '2023-05-15 15:12:00', 13)
GO
------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MUESTRA DE LOS TABLAS DE CLIENTE, EQUIPO Y USO EQUIPO
------------------------------------------------------------------------------------------------------------------------------------------------------------
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
------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONTROLES DE ERRORES CON STORED PROCEDURE
------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE insertar_cliente
    @cedula cedula,
    @nombre varchar(40),
    @apellido varchar(40),
    @correo correo,
    @telefono varchar(10),
    @fechaNacimiento date,
    @peso decimal(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @nombre NOT LIKE '[A-Z][a-z]%' OR @nombre LIKE '%[^a-zA-Z]%'
        BEGIN
            THROW 51000, 'El nombre debe empezar por una mayúscula y solo contener letras', 1;
        END

        IF @apellido NOT LIKE '[A-Z][a-z]%' OR @apellido LIKE '%[^a-zA-Z]%'
        BEGIN
            THROW 51000, 'El apellido debe empezar por una mayúscula y solo contener letras', 1;
        END

        IF TRY_CONVERT(date, @fechaNacimiento) IS NULL
        BEGIN
            THROW 51000, 'Fecha de nacimiento inválida', 1;
        END

        IF @peso <= 0 OR @peso > 1000
        BEGIN
            THROW 51000, 'Peso debe estar entre 0 y 1000', 1;
        END

        INSERT INTO Cliente (cedula, nombre, apellido, correo, telefono, fechaNacimiento, peso)
        VALUES (@cedula, @nombre, @apellido, @correo, @telefono, @fechaNacimiento, @peso);
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 2627
        BEGIN
            THROW 51000, 'Ya existe un cliente con esta cedula o telefono', 1;
        END
        ELSE
        BEGIN
            THROW;
        END
    END CATCH
END
GO

CREATE PROCEDURE insertar_equipo
    @nombre varchar(40),
    @edadMinima tinyint,
    @edadMaxima tinyint,
    @pesoMaximo decimal(10,2),
    @tiempoMaximo tinyint
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @nombre NOT LIKE '%[a-zA-Z0-9]%'
        BEGIN
            THROW 51000, 'El nombre del equipo debe contener al menos una letra o número', 1;
        END

        IF @edadMaxima <= @edadMinima OR @edadMaxima > 119 OR @edadMinima <= 0 OR @edadMinima > 119
        BEGIN
            THROW 51000, 'La edad mínima debe ser mayor que 0, la edad máxima debe ser mayor que la edad mínima y ambas deben estar en el rango de 1 a 119 años', 1;
        END

        IF @pesoMaximo <= 0
        BEGIN
            THROW 51000, 'El peso máximo debe ser mayor que 0', 1;
        END

        IF @tiempoMaximo <= 0 OR @tiempoMaximo > 60
        BEGIN
            THROW 51000, 'El tiempo máximo debe ser mayor que 0 y menor o igual a 60 minutos', 1;
        END

        INSERT INTO Equipo (nombre, edadMinima, edadMaxima, pesoMaximo, tiempoMaximo)
        VALUES (@nombre, @edadMinima, @edadMaxima, @pesoMaximo, @tiempoMaximo);
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 2627
        BEGIN
            THROW 51000, 'Ya existe un equipo con este nombre', 1;
        END
        ELSE
        BEGIN
            THROW;
        END
    END CATCH
END
GO


CREATE PROCEDURE insertar_uso_equipo 
  @idCliente tinyint,
  @idEquipo tinyint,
  @fechaReserva DATETIME,
  @fechaHoraUso DATETIME,
  @minutosUso tinyint
AS
BEGIN
  SET NOCOUNT ON;

  BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @idUso tinyint;

    -- Insertar registro en la tabla UsoEquipo
    INSERT INTO UsoEquipo (idCliente, idEquipo, fechaReserva, fechaHoraUso, minutosUso)
    VALUES (@idCliente, @idEquipo, @fechaReserva, @fechaHoraUso, @minutosUso);

    -- Obtener el idUso del registro recién insertado
    SET @idUso = SCOPE_IDENTITY();

    COMMIT;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;

    DECLARE @errorMessage VARCHAR(2000) = ERROR_MESSAGE();
    DECLARE @errorNumber INT = ERROR_NUMBER();
    DECLARE @errorSeverity INT = ERROR_SEVERITY();
    DECLARE @errorState INT = ERROR_STATE();

    -- Control de errores para la constraint FK_UsoEquipoCliente
    IF @errorNumber = 547 AND @errorState = 0
    BEGIN
      RAISERROR('El idCliente especificado no existe en la tabla Cliente.', 16, 1);
    END
    -- Control de errores para la constraint FK_UsoEquipoEquipos
    ELSE IF @errorNumber = 547 AND @errorState = 1
    BEGIN
      RAISERROR('El idEquipo especificado no existe en la tabla Equipo.', 16, 1);
    END
    -- Control de errores para la constraint CH_fechas
    ELSE IF @errorNumber = 547 AND @errorState = 2
    BEGIN
      RAISERROR('La fechaHoraUso debe estar dentro de los 15 minutos siguientes a la fechaReserva.', 16, 1);
    END
    -- Control de errores para otros errores no controlados
    ELSE
    BEGIN
      RAISERROR(@errorMessage, @errorSeverity, @errorState);
    END;
  END CATCH;
END;
GO


------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SCRPIPTS DEBER
-- Número de préstamos por equipo de aquellos que se pueden usar entre 15 y 55 años de edad.  
-- La consulta deberá devolver tres columnas: "Nombre del equipo", "Rango de edad mínima y máxima" y "Número de Préstamos" 
------------------------------------------------------------------------------------------------------------------------------------------------------------
	SELECT E.nombre AS 'Nombre del equipo',
		   CONCAT(E.edadMInima, ' - ', E.edadMaxima) AS 'Rango de edad mínima y máxima',
		   COUNT(U.idUso) AS 'Número de Préstamos'
	FROM Equipo E
	INNER JOIN UsoEquipo U ON E.idEquipo = U.idEquipo
	WHERE E.edadMinima >=15 AND E.edadMaxima <= 55
	GROUP BY E.nombre, E.edadMinima, E.edadMaxima;
------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SCRPIPTS DEBER
-- Nombre y apellido de los clientes (en una sola columna con título "Clientes") que han realizado préstamos de los 3 equipos más comúnmente utilizados.
------------------------------------------------------------------------------------------------------------------------------------------------------------

	SELECT CONCAT(C.nombre, ' ', C.apellido) AS 'Clientes', E.nombre AS 'Equipos mas utilizados'
	FROM Cliente C
	INNER JOIN (
		SELECT TOP 3 idEquipo, COUNT(*) AS num_usos
		FROM UsoEquipo
		GROUP BY idEquipo
		ORDER BY num_usos DESC
	) AS U ON U.idEquipo = U.idEquipo
	INNER JOIN Equipo E ON U.idEquipo = E.idEquipo
	INNER JOIN UsoEquipo UE ON UE.idCliente = C.idCliente AND UE.idEquipo = E.idEquipo
	ORDER BY E.nombre, CONCAT(C.nombre, ' ', C.apellido);

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SCRPIPTS DEBER
-- Listado de equipos con su estado. Deberá presentarse en el resultado de la consulta las columnas: "Equipo", "Peso", "Estado"
-- (cuando esté Disponible deberá presentarse la frase "Disponible para préstamo", cuando esté Prestado, deberá presentarse la frase "Prestado a cliente")  
------------------------------------------------------------------------------------------------------------------------------------------------------------
	SELECT E.nombre AS 'Equipo',
		   E.pesoMaximo AS 'Peso',
		   CASE
			   WHEN U.idUso IS NULL THEN 'Disponible para préstamo'
			   ELSE 'Prestado a cliente'
		   END AS 'Estado'
	FROM Equipo E
	LEFT JOIN (
		SELECT idEquipo, MAX(idUso) AS idUso
		FROM UsoEquipo
		GROUP BY idEquipo
	) AS U ON E.idEquipo = U.idEquipo;

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SCRPIPTS DEBER
-- Listado de equipos de aquellos que han sido reservados pero no han sido utilizados durante el presente mes.
------------------------------------------------------------------------------------------------------------------------------------------------------------

	SELECT E.nombre AS 'Equipo que no fue usado', U.fechaReserva AS 'Fecha Reserva', CONCAT(C.nombre, ' ', C.apellido) AS 'Cliente'
	FROM Equipo E
	LEFT OUTER JOIN UsoEquipo U ON E.idEquipo = U.idEquipo
	LEFT OUTER JOIN Cliente C ON U.idCliente = C.idCliente
	WHERE MONTH(ISNULL(U.fechaReserva, '1900-01-01')) = MONTH(GETDATE())
	AND YEAR(ISNULL(U.fechaReserva, '1900-01-01')) = YEAR(GETDATE())
	AND U.fechaHoraUso IS NULL
	ORDER BY E.nombre;
------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SCRPIPTS DEBER
-- Modificación de datos:  Cree una tabla llamada "Entrenadores" basada en los registros de Clientes, 
-- que incluya los 5 primeros clientes ordenados de manera descendente por la edad que están registrados en la tabla.  
-- Asígneles a los Entrenadores un correo compuesto por primera letra de nombre seguido de apellido@gimnasio.ec   
-- Crear la tabla Entrenadores solo después de que se hayan insertado los primeros 5 clientes
------------------------------------------------------------------------------------------------------------------------------------------------------------

IF (SELECT COUNT(*) FROM Cliente) >= 5
BEGIN
	IF OBJECT_ID('Entrenadores') IS NOT NULL
	DROP TABLE Entrenadores
	BEGIN

  -- Crear la tabla Entrenadores
  CREATE TABLE Entrenadores (
    idEntrenador tinyint IDENTITY (1,1) NOT NULL,
    nombre varchar(40) NOT NULL,
    apellido varchar(40) NOT NULL,
    correoEntrenador correo,
    edad tinyint NOT NULL,
    CONSTRAINT PK_idEntrenador PRIMARY KEY (idEntrenador),
    CONSTRAINT CH_nombreFormatoEntrenador CHECK (nombre LIKE '[A-Z][a-z]%' AND nombre NOT LIKE '%[^a-zA-Z]%'),
    CONSTRAINT CH_apellidoFormatoEntrenador CHECK (apellido LIKE '[A-Z][a-z]%' AND apellido NOT LIKE '%[^a-zA-Z]%'),
    CONSTRAINT CH_correoEntrenadorFormato CHECK (correoEntrenador LIKE '%@gimnasio.ec'),
    CONSTRAINT CH_edadEntrenador CHECK (edad >= 18 AND edad <= 100)
  );
  --Altera la tabla cliente para agregar el campo y el constraint para la relacion Cliente-Entrenador
  	ALTER TABLE Entrenadores
	ADD idCliente tinyint
	ALTER TABLE Cliente
	ADD CONSTRAINT FK_Entrenador_Cliente
	FOREIGN KEY (idCliente)
	REFERENCES Cliente (idCliente);

  -- Insertar datos en la tabla Entrenadores
  INSERT INTO Entrenadores (nombre, apellido, correoEntrenador, edad, idCliente)
  SELECT TOP 5 nombre, apellido, LOWER(apellido) + '@gimnasio.ec', FLOOR(DATEDIFF(DAY, fechaNacimiento, GETDATE()) / 365.25) AS Edad, idCliente
  FROM Cliente
  END
 END
  -- Muestra los 5 entrenadores ordenados con la edad en forma descendente
 Select nombre, apellido, correoEntrenador as 'Correo Institucional', edad from Entrenadores
 ORDER BY edad DESC
	
------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SCRPIPTS DEBER
-- Genere el script que devuelva el nombre y apellido (en una sola columna) y el tipo de usuario Cliente 
-- o Entrenador de las personas registradas en la base de datos. En el caso que sean Cliente y Entrenador deberá tener esa especificación.  
------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT 
	c.nombre + ' '+ c.apellido as 'Nombre y Apellido',
    CASE 
        WHEN e.idEntrenador IS NOT NULL THEN 'Es cliente y Entrenador'
        ELSE 'Es cliente'
    END AS Tipo
FROM Cliente c
LEFT JOIN Entrenadores e ON c.idCliente = e.idCliente
ORDER BY c.nombre, c.apellido;

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CODIGO DE PRUEBAS
------------------------------------------------------------------------------------------------------------------------------------------------------------

--Select * from Entrenadores


--VER REGLAS
--SELECT * FROM SYS.sysobjects
--where xtype='R'

----PRUEBA CON ERRORES
--INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES ('4004177455', 'Kevin', 'Rosero', 'kevin.rosero@udla.edu.ec','0993884542', '1997-12-16', 89.5)
--INSERT INTO Cliente(cedula, nombre, apellido,correo, telefono, fechaNacimiento, peso) VALUES ('2004177455', 'Kevin', 'Rosero', 'kevin.roseroudla.edu.ec','0993884542', '1997-12-16', 89.5)

