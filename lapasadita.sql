-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 11-08-2025 a las 19:39:50
-- Versión del servidor: 10.4.28-MariaDB
-- Versión de PHP: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `lapasadita`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizarStock` (`codigo` VARCHAR(50), `stockActual` FLOAT, `stockNuevo` FLOAT)   begin
declare sumaStocks float;
set sumaStocks =  (stockActual + stockNuevo);
update tbl_productos set cantidad_existente = sumaStocks where codigo_barras = codigo;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `aperturaCajaUsuario` (`usuario` BIGINT(20), `monto` DECIMAL(20))   begin 
DECLARE fondoActivo decimal;
DECLARE fondoInactivo decimal;
SET fondoActivo = (SELECT monto_Caja FROM tbl_Cajas WHERE id_Usuario = usuario AND confirmacion_Caja = 1 AND estado_Caja = 1);

IF fondoActivo is null THEN 

SET fondoInactivo = (SELECT monto_Caja FROM tbl_Cajas WHERE id_Usuario = usuario AND confirmacion_Caja = 0 AND estado_Caja = 1);

IF fondoInactivo is null THEN

INSERT INTO tbl_Cajas 
VALUES (default, usuario, monto, 0,1, 0, sysdate());
SELECT 
"1" AS IDENTIFICADOR;

ELSE 

SELECT 
"3" AS IDENTIFICADOR;

END IF;

ELSE 

SELECT 
"2" AS IDENTIFICADOR;

END IF;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `bajaStockVenta` (`codigo_BarrasBS` VARCHAR(50), `stockExistente` FLOAT, `stockBaja` FLOAT)   begin 

declare stockActualizado float;

set stockActualizado = (stockExistente - stockBaja);

update tbl_productos set cantidad_existente = stockActualizado where codigo_barras = codigo_BarrasBS;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `borrarSucursal` (`nombre` VARCHAR(100))   begin 
if nombre is null or nombre = "" or nombre = " " THEN 
 SELECT 
 '1' AS IDENTIFICADOR;
 
 ELSE
 set SQL_SAFE_UPDATES=0;
 delete from tbl_Sucursales WHERE nombre_Sucursal = nombre;
 SELECT 
 '2' AS IDENTIFICADOR;
 
END IF;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `borrarUsuario` (`nombre` VARCHAR(100))   begin 
if nombre is null or nombre = "" or nombre = " " THEN 
 SELECT 
 '1' AS IDENTIFICADOR;
 
 ELSE
 set SQL_SAFE_UPDATES=0;
 delete from tbl_usuarios WHERE nombre_Usuario = nombre;
 SELECT 
 '2' AS IDENTIFICADOR;
 
END IF;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `cambioPeso` (`idBasculaPesoCambio` MEDIUMINT, `pesoPesoCambio` VARCHAR(100))   begin
update tbl_bascula set peso_Bascula = pesoPesoCambio where id_Bascula = idBasculaPesoCambio;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `cerrarCajaUsuario` (`idCaja` BIGINT(20))   begin 

UPDATE tbl_Cajas SET estado_Caja = 2 WHERE id_Caja = idCaja;


SELECT tu.nombre_Usuario AS USUARIO, 
       tc.monto_Caja AS MONTOINICIAL, 
       COALESCE(tc.monto_Final_Caja , 0)  AS MONTOVENTAS, 
       (tc.monto_Caja + tc.monto_Final_Caja) AS TOTAL 
 FROM tbl_Cajas tc
INNER JOIN tbl_Usuarios tu ON tu.id_Usuario = tc.id_Usuario
WHERE tc.id_Caja = idCaja;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `consultarProductos` (`nombreProducto` VARCHAR(100))   begin
if exists(select codigo_barras from tbl_productos where nombre_producto like nombreProducto)
then
select * from tbl_productos where nombre_producto like nombreProducto;
else 
select * from tbl_productos where codigo_barras = 'S/N';
end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `consultaUsuarioXNombre` (`nombre` VARCHAR(100), `sucursal` BIGINT(20))   begin 
DECLARE usuarioExistente bigint(20);

SET usuarioExistente = (SELECT id_Usuario FROM tbl_usuarios WHERE nombre_Usuario = nombre AND id_Sucursal = sucursal);

IF usuarioExistente is null or usuarioExistente = '' THEN 

SELECT '1' AS IDENTIFICADOR;

ELSE 

SELECT id_Usuario AS 'ID', nombre_Usuario AS 'NOMBREUSUARIO', password AS 'PS', IFNULL(permiso , 0) AS 'PERMISO' FROM tbl_usuarios WHERE id_Usuario = usuarioExistente AND id_Sucursal = sucursal;

END IF;


end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `crearExcel` ()   BEGIN 

 SELECT codigo_barras AS 'CODIGO DE BARRAS', nombre_producto AS 'PRODUCTO', cantidad_existente AS 'CANTIDAD EXISTENTE', precio_compra AS 'COSTO COMPRA', precio_venta AS 'COSTO VENTA', (precio_venta - precio_compra) AS 'GANANCIA' FROM tbl_productos WHERE nombre_producto != 'S/N';

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `editarUsuarioAgregado` (`usuarioId` BIGINT(20), `sucursalId` BIGINT(20), `nombre` VARCHAR(100), `clave` VARCHAR(45), `claveConfirmar` VARCHAR(45), `codigo` INT)   BEGIN 
DECLARE usuarioExiste VARCHAR(100);
DECLARE claveExiste VARCHAR(45);
DECLARE Ppermiso int;

SET usuarioExiste = (SELECT nombre_Usuario FROM tbl_usuarios WHERE id_Usuario = usuarioId AND id_Sucursal = sucursalId);
SET claveExiste = (SELECT password FROM tbl_usuarios WHERE id_Usuario = usuarioId AND id_Sucursal = sucursalId);
SET Ppermiso = (SELECT permiso FROM tbl_usuarios WHERE id_Usuario = usuarioId AND id_Sucursal = sucursalId);

IF usuarioExiste is null THEN

   SELECT '1' AS IDENTIFICADOR;

ELSE

    IF nombre = usuarioExiste and clave = claveExiste and codigo =Ppermiso  THEN

  SELECT '4' AS IDENTIFICADOR;

     ELSE 

        IF clave = claveConfirmar THEN

           UPDATE tbl_usuarios
           SET nombre_Usuario = nombre, password = claveConfirmar , permiso= codigo
           WHERE id_Usuario = usuarioId AND id_Sucursal = sucursalId;

           SELECT '3' AS IDENTIFICADOR;

     ELSE 

            SELECT '2' AS IDENTIFICADOR;

          END IF;

      END IF;

END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `empleadosxEmpresa` (`empresa` BIGINT(20))   begin 
SELECT nombre_Usuario AS USUARIOS FROM tbl_Usuarios WHERE id_Sucursal = empresa;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `empresaIp` (`ip` TEXT)   BEGIN 
DECLARE clave TEXT;
DECLARE p1 varchar(1);
DECLARE p2 varchar(10);
DECLARE p3 varchar(10);
DECLARE p4 varchar(2);
DECLARE newPass varchar(10);
DECLARE idIp int;

SET clave = (SELECT pass_Ip FROM tbl_ips WHERE ip_Descripcion = ip);

IF clave is null THEN 

SET p1 = 'L';
SET p2 = (SELECT CONCAT(floor(rand()*(10-5+1) +5), floor(rand()*(10-5+1) +5)));
SET p3 = (SELECT floor(rand()*(10-5+1) +5));
SET P4 = 'T';
SET newPass = (SELECT CONCAT(p1,p2,p3,p4));

SET idIp = (SELECT count(id_IP)+1 FROM tbl_ips) ;

INSERT INTO tbl_ips VALUES (idIp, ip, newPass);

SELECT 
newPass AS PASS;

ELSE 

SELECT 
clave AS PASS;

END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `estadoConfirmacionCaja` (`monto` BIGINT(20), `estadoMontoUsuario` INT)   begin 

UPDATE tbl_Cajas SET confirmacion_Caja = estadoMontoUsuario WHERE id_Caja = monto;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `excelStoreBajo` ()   BEGIN 

SELECT nombre_producto AS 'PRODUCTO', stock_min AS 'STOCK MINIMO', COALESCE(cantidad_Existente,0) AS 'CANTIDAD EN EXISTENCIA' FROM tbl_productos WHERE nombre_producto != 'S/N'ORDER BY cantidad_Existente asc;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertarPesobascula` (`idBascula` MEDIUMINT, `pesoBascula` VARCHAR(100), `marcaBascula` VARCHAR(100), `modeloBascula` VARCHAR(100))   begin 

insert into tbl_bascula values (idBascula,pesoBascula,marcaBascula,modeloBascula);

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertarProductosTickets` (`folioTickets` MEDIUMINT, `codigo_Producto` VARCHAR(50), `producto` VARCHAR(45), `descrip` VARCHAR(100), `cant` FLOAT8, `precio` FLOAT8, `total` FLOAT8)   begin 
insert into tbl_tickets values (folioTickets, codigo_Producto , producto , descrip, cant, precio, total);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertarTicketVentas` (`id_Venta` MEDIUMINT, `fecha` DATE, `id_UsuarioTV` INT, `monto_TotalTV` FLOAT8, `id_SucursalTV` INT, `tipo_Pago` INT)   begin
insert into tbl_ventas values(id_Venta, id_Venta, fecha, id_UsuarioTV, monto_TotalTV, id_SucursalTV, tipo_Pago);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `obtenerCodigoBarrasProductos` (`nombre_productoO` VARCHAR(45), `descripcion_productoO` VARCHAR(100))   begin 
declare cBarrasP varchar(100);

set cBarrasP = (select codigo_barras from tbl_productos where nombre_producto = nombre_productoO and descripcion = descripcion_productoO);

select cBarrasP;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `obtenerFolio` ()   begin 
declare folio int default 0;
set folio = (select count(*) from  tbl_ventas);

select folio;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `obtenerPesoxBascula` (`id` MEDIUMINT)   begin 
declare pesoDado varchar(100);
set pesoDado = (select peso_Bascula from tbl_bascula where id_Bascula = id);

if(pesoDado = "") then 
set pesoDado = "10";
end if;
  
select pesoDado;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `obtenerUsuarioEmpresaId` (`nombre` VARCHAR(100))   begin 
declare uid bigint(20);
set uid = (SELECT id_Sucursales FROM tbl_Sucursales WHERE nombre_Sucursal = nombre);

SELECT 
uid as IDENTIFICADOR;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `obtenerUsuarioId` (`nombre` VARCHAR(100))   begin 
declare uid bigint(20);
set uid = (SELECT id_Usuario FROM tbl_Usuarios WHERE nombre_Usuario = nombre);

SELECT 
uid as IDENTIFICADOR;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registrarNuevaSucursal` (`nombreSucursal` VARCHAR(100), `direccionSucursal` VARCHAR(255), `claveSucursal` VARCHAR(20), `claveValidar` VARCHAR(20))   begin 
declare uid bigint(20);
set uid = (SELECT id_Sucursales FROM tbl_Sucursales WHERE nombre_Sucursal = nombreSucursal);

IF uid is null THEN
IF claveSucursal = claveValidar THEN 
IF direccionSucursal is null or direccionSucursal = "" or direccionSucursal = " " THEN

INSERT INTO tbl_Sucursales VALUES (default, nombreSucursal, 'S/D', claveSucursal);
SELECT
'3' as IDENTIFICADOR;


ELSE 

INSERT INTO tbl_Sucursales VALUES (default, nombreSucursal, direccionSucursal, claveSucursal);
SELECT
'3' as IDENTIFICADOR;

END IF;
ELSE 
SELECT 
'2' as IDENTIFICADOR;
END IF;
ELSE 
SELECT 
'1' as IDENTIFICADOR;
END IF;


end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registrarNuevoEmpleado` (`nombre` VARCHAR(100), `clave` VARCHAR(20), `clave_validar` VARCHAR(20), `empresa` BIGINT(20), `codigo` INT)   begin 
declare uid bigint(20);
set uid = (SELECT id_Usuario FROM tbl_Usuarios WHERE nombre_usuario = nombre);

IF uid is null THEN
IF clave = clave_validar THEN 
INSERT INTO tbl_Usuarios VALUES (default, empresa, nombre, clave,codigo);
SELECT
'3' as IDENTIFICADOR;
ELSE 
SELECT 
'2' as IDENTIFICADOR;
END IF;
ELSE 
SELECT 
'1' as IDENTIFICADOR;
END IF;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `stockActualProducto` (`codigo_BarrasPS` VARCHAR(50))   begin

declare stockActual float;

set stockActual = (select cantidad_existente from tbl_productos where codigo_barras = codigo_BarrasPS);

select stockActual;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sucursalesXLeadTo` ()   begin 
DECLARE idAdmin bigint(20);

SET idAdmin = (SELECT id_Sucursales FROM tbl_Sucursales WHERE nombre_Sucursal = 'LeadTo');

IF idAdmin is null or idAdmin = 0 THEN 

SELECT 
'1' AS IDENTIFICADOR;


ELSE 

IF EXISTS (SELECT * FROM tbl_Sucursales WHERE id_Sucursales != idAdmin) THEN 

SELECT nombre_Sucursal AS IDENTIFICADOR FROM tbl_Sucursales WHERE id_Sucursales != idAdmin;

ELSE

SELECT 
'2' AS IDENTIFICADOR;

END IF;

END IF;
  

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `usuarioCaja` (`usuario` BIGINT(20))   begin 
DECLARE fondo decimal;
DECLARE fondoFinal DECIMAL;
DECLARE fondoActivado DECIMAL;
DECLARE fondoActivoFinal DECIMAL;
DECLARE idMonto bigint(20);
DECLARE idMontoActivado bigint(20);

SET fondoActivado = (select monto_Caja from tbl_Cajas where id_Usuario = usuario AND confirmacion_caja = 1 AND estado_Caja = 1);
SET fondoActivoFinal = (select monto_Final_Caja from tbl_Cajas where id_Usuario = usuario AND confirmacion_caja = 1 AND estado_Caja = 1);
SET idMontoActivado = (select id_Caja from tbl_Cajas where id_Usuario = usuario AND confirmacion_caja = 1 AND estado_Caja = 1);

IF fondoActivado is not null  THEN 

IF fondoActivoFinal is null THEN
SELECT 
"3" AS IDENTIFICADOR,
fondoActivado AS FONDOMONTO,
idMontoActivado AS ID;

ELSE 

SELECT 
"3" AS IDENTIFICADOR,
fondoActivado + fondoActivoFinal AS FONDOMONTO,
idMontoActivado AS ID;


END IF;

ELSE

SET fondo = (select monto_Caja from tbl_Cajas where id_Usuario = usuario AND confirmacion_caja = 0 AND estado_Caja = 1);
SET fondoFinal = (select monto_Final_Caja from tbl_Cajas where id_Usuario = usuario AND confirmacion_caja = 0 AND estado_Caja = 1);
SET idMonto = (select id_Caja from tbl_Cajas where id_Usuario = usuario AND confirmacion_caja = 0 AND estado_Caja = 1);
IF fondoFinal is null and fondo is null THEN 

SELECT 
"1" AS IDENTIFICADOR;

ELSE 
 

SELECT 
"2" AS IDENTIFICADOR,
(fondo + fondoFinal) AS FONDOMONTO,
idMonto AS ID;


END IF;
END IF;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `usuarioEmpresa` (`nombre` VARCHAR(100), `pw` VARCHAR(50))   begin 
declare pwRegistrado varchar(50);
set pwRegistrado = (SELECT clave_Sucursal FROM tbl_Sucursales WHERE nombre_Sucursal = nombre);

if pwRegistrado is null THEN 
SELECT '1' as CLAVE;
else

IF pw = pwRegistrado THEN
IF nombre = 'LeadTo' THEN 
SELECT 
'4' AS CLAVE;
ELSE
SELECT
'3' as CLAVE;
END IF;
ELSE 
SELECT '2' AS CLAVE;
END if;
END IF;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `usuarioExistente` (`nombre` VARCHAR(100), `pw` VARCHAR(50))   begin 
declare pwRegistrado varchar(50);
set pwRegistrado = (SELECT password FROM tbl_usuarios WHERE nombre_Usuario = nombre);

if pwRegistrado is null THEN 
SELECT '1' as CLAVE;
else

IF pw = pwRegistrado THEN
SELECT
'3' as CLAVE;
ELSE 
SELECT '2' AS CLAVE;
end if;
END IF;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ventaSumarAMonto` (`id_Caja_Venta` BIGINT(20), `monto_Venta` DECIMAL)   BEGIN 
DECLARE montoVentas DECIMAL;

SET montoVentas = (SELECT COALESCE(monto_Final_Caja, 0) FROM tbl_Cajas WHERE id_Caja = id_Caja_Venta);


SET monto_Venta = monto_Venta + montoVentas;

UPDATE tbl_Cajas SET monto_Final_Caja = monto_Venta WHERE id_Caja = id_Caja_Venta;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `verificadorBasculas` (`idBasculaPeso` MEDIUMINT)   begin
 
 if not exists(select id_Bascula from tbl_Bascula where id_Bascula = idBasculaPeso)
 then
 call insertarPesoBascula(idBasculaPeso, '0','Basic','Basic');
 end if;

end$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_bascula`
--

CREATE TABLE `tbl_bascula` (
  `id_Bascula` mediumint(9) NOT NULL,
  `peso_Bascula` varchar(100) DEFAULT NULL,
  `marca_Bascula` varchar(100) DEFAULT NULL,
  `modelo_Bascula` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tbl_bascula`
--

INSERT INTO `tbl_bascula` (`id_Bascula`, `peso_Bascula`, `marca_Bascula`, `modelo_Bascula`) VALUES
(1, '32', '1', '1'),
(6, '', 'Basic', 'Basic'),
(10, '100', 'Basic', 'Basic'),
(100, '0', 'Basic', 'Basic');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_cajas`
--

CREATE TABLE `tbl_cajas` (
  `id_Caja` bigint(20) NOT NULL,
  `id_Usuario` bigint(20) NOT NULL,
  `monto_Caja` decimal(10,0) DEFAULT NULL,
  `monto_Final_Caja` decimal(10,0) DEFAULT NULL,
  `estado_Caja` int(11) DEFAULT NULL,
  `confirmacion_Caja` int(11) DEFAULT NULL,
  `fecha_Caja` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tbl_cajas`
--

INSERT INTO `tbl_cajas` (`id_Caja`, `id_Usuario`, `monto_Caja`, `monto_Final_Caja`, `estado_Caja`, `confirmacion_Caja`, `fecha_Caja`) VALUES
(9, 2, 100, 0, 1, 0, '2021-04-09 15:12:08'),
(10, 1, 500, 100, 2, 1, '2021-04-09 15:41:54'),
(11, 1, 600, 120, 2, 1, '2021-04-09 17:41:40'),
(12, 1, 700, 60, 2, 1, '2021-04-09 17:44:17'),
(13, 1, 500, 0, 1, 1, '2021-04-09 18:03:31'),
(14, 15, 500, 0, 1, 1, '2021-04-22 18:30:03');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_ips`
--

CREATE TABLE `tbl_ips` (
  `id_IP` int(11) DEFAULT NULL,
  `ip_Descripcion` text DEFAULT NULL,
  `pass_IP` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tbl_ips`
--

INSERT INTO `tbl_ips` (`id_IP`, `ip_Descripcion`, `pass_IP`) VALUES
(1, '192.168.0.1', 'G799'),
(2, '192.168.0.2', 'O722'),
(3, '192.168.0.3', 'H205'),
(4, '192.168.0.4', 'L435'),
(5, '192.168.0.5', 'D691'),
(6, '192.168.0.6', 'I212'),
(7, '192.168.0.7', '>394'),
(8, '192.168.0.8', 'F550'),
(9, '192.168.0.9', 'G462'),
(10, '192.168.0.10', 'C545'),
(11, '192.168.0.11', '=709'),
(12, '192.168.0.12', 'J463'),
(13, '192.168.0.13', 'A465'),
(14, '192.168.0.14', 'D335'),
(15, '192.168.0.15', 'N475'),
(16, '192.168.0.16', 'J407'),
(17, '192.168.0.17', 'P162'),
(18, '192.168.0.18', 'M273'),
(19, '192.168.0.19', 'G729'),
(20, '192.168.0.20', '@277'),
(21, '192.168.0.21', 'B800'),
(22, '192.168.0.22', '@755'),
(23, '192.168.0.23', '=519'),
(24, '192.168.0.24', 'J192'),
(25, '192.168.0.25', '<211'),
(26, '192.168.0.26', 'F327'),
(27, '192.168.0.27', 'E515'),
(28, '192.168.0.28', 'A410'),
(29, '192.168.0.29', 'M672'),
(30, '192.168.0.30', 'G440'),
(31, '192.168.0.31', 'K480'),
(32, '192.168.0.32', '>529'),
(33, '192.168.0.33', 'E367'),
(34, '192.168.0.34', 'N168'),
(35, '192.168.0.35', 'B328'),
(36, '192.168.0.36', 'C796'),
(37, '192.168.0.37', 'B305'),
(38, '192.168.0.38', 'E167'),
(39, '192.168.0.39', '@386'),
(40, '192.168.0.40', '?169'),
(41, '192.168.0.41', 'M104'),
(42, '192.168.0.42', '<410'),
(43, '192.168.0.43', 'D572'),
(44, '192.168.0.44', 'A385'),
(45, '192.168.0.45', 'G335'),
(46, '192.168.0.46', '@392'),
(47, '192.168.0.47', 'H609'),
(48, '192.168.0.48', '<103'),
(49, '192.168.0.49', '<738'),
(50, '192.168.0.50', 'A460'),
(51, '192.168.0.51', 'N442'),
(52, '192.168.0.52', 'I242'),
(53, '192.168.0.53', '<429'),
(54, '192.168.0.54', 'B396'),
(55, '192.168.0.55', 'C338'),
(56, '192.168.0.56', 'G747'),
(57, '192.168.0.57', 'L423'),
(58, '192.168.0.58', 'A210'),
(59, '192.168.0.59', 'A237'),
(60, '192.168.0.60', 'H791'),
(61, '192.168.0.61', '<263'),
(62, '192.168.0.62', 'A338'),
(63, '192.168.0.63', '@673'),
(64, '192.168.0.64', 'A496'),
(65, '192.168.0.65', 'E506'),
(66, '192.168.0.66', 'P531'),
(67, '192.168.0.67', '<524'),
(68, '192.168.0.68', 'E539'),
(69, '192.168.0.69', 'F353'),
(70, '192.168.0.70', 'B552'),
(71, '192.168.0.71', 'P543'),
(72, '192.168.0.72', '>737'),
(73, '192.168.0.73', '@504'),
(74, '192.168.0.74', '>146'),
(75, '192.168.0.75', '<523'),
(76, '192.168.0.76', '>778'),
(77, '192.168.0.77', '?546'),
(78, '192.168.0.78', 'D358'),
(79, '192.168.0.79', 'J751'),
(80, '192.168.0.80', 'N316'),
(81, '192.168.0.81', 'G674'),
(82, '192.168.0.82', '>211'),
(83, '192.168.0.83', '=428'),
(84, '192.168.0.84', 'O567'),
(85, '192.168.0.85', '@650'),
(86, '192.168.0.86', 'O134'),
(87, '192.168.0.87', '>454'),
(88, '192.168.0.88', 'G169'),
(89, '192.168.0.89', 'A479'),
(90, '192.168.0.90', '>587'),
(91, '192.168.0.91', 'A681'),
(92, '192.168.0.92', 'F182'),
(93, '192.168.0.93', 'F710'),
(94, '192.168.0.94', 'H569'),
(95, '192.168.0.95', '>492'),
(96, '192.168.0.96', '@310'),
(97, '192.168.0.97', 'O147'),
(98, '192.168.0.98', 'G376'),
(99, '192.168.0.99', 'B360'),
(100, '192.168.0.100', 'E702'),
(101, '192.168.0.101', '?565'),
(102, '192.168.0.102', 'A166'),
(103, '192.168.0.103', 'H347'),
(104, '192.168.0.104', 'L775'),
(105, '192.168.0.105', 'K764'),
(106, '192.168.0.106', 'E497'),
(107, '192.168.0.107', 'P578'),
(108, '192.168.0.108', 'F644'),
(109, '192.168.0.109', 'P286'),
(110, '192.168.0.110', 'H560'),
(111, '192.168.0.111', 'E715'),
(112, '192.168.0.112', '<129'),
(113, '192.168.0.113', 'C382'),
(114, '192.168.0.114', 'G606'),
(115, '192.168.0.115', 'B502'),
(116, '192.168.0.116', '?203'),
(117, '192.168.0.117', 'I130'),
(118, '192.168.0.118', 'F464'),
(119, '192.168.0.119', '<326'),
(120, '192.168.0.120', 'A248'),
(121, '192.168.0.121', 'O397'),
(122, '192.168.0.122', 'P758'),
(123, '192.168.0.123', 'K119'),
(124, '192.168.0.124', 'D324'),
(125, '192.168.0.125', 'C235'),
(126, '192.168.0.126', 'P626'),
(127, '192.168.0.127', '@333'),
(128, '192.168.0.128', 'L377'),
(129, '192.168.0.129', 'M700'),
(130, '192.168.0.130', 'P294'),
(131, '192.168.0.131', 'K166'),
(132, '192.168.0.132', 'N306'),
(133, '192.168.0.133', 'G111'),
(134, '192.168.0.134', '<570'),
(135, '192.168.0.135', 'B307'),
(136, '192.168.0.136', 'N661'),
(137, '192.168.0.137', 'I166'),
(138, '192.168.0.138', 'L526'),
(139, '192.168.0.139', 'J782'),
(140, '192.168.0.140', 'C425'),
(141, '192.168.0.141', 'O527'),
(142, '192.168.0.142', '?119'),
(143, '192.168.0.143', '>775'),
(144, '192.168.0.144', '=303'),
(145, '192.168.0.145', 'M570'),
(146, '192.168.0.146', 'A216'),
(147, '192.168.0.147', 'C407'),
(148, '192.168.0.148', 'I138'),
(149, '192.168.0.149', 'I300'),
(150, '192.168.0.150', 'O631'),
(151, '192.168.0.151', '?330'),
(152, '192.168.0.152', 'L468'),
(153, '192.168.0.153', 'F464'),
(154, '192.168.0.154', '>556'),
(155, '192.168.0.155', 'K522'),
(156, '192.168.0.156', '?549'),
(157, '192.168.0.157', 'N365'),
(158, '192.168.0.158', 'B567'),
(159, '192.168.0.159', 'N417'),
(160, '192.168.0.160', '?515'),
(161, '192.168.0.161', 'A592'),
(162, '192.168.0.162', 'J203'),
(163, '192.168.0.163', 'M592'),
(164, '192.168.0.164', 'L679'),
(165, '192.168.0.165', 'E132'),
(166, '192.168.0.166', 'J634'),
(167, '192.168.0.167', 'G308'),
(168, '192.168.0.168', 'E558'),
(169, '192.168.0.169', 'C559'),
(170, '192.168.0.170', 'L181'),
(171, '192.168.0.171', 'C780'),
(172, '192.168.0.172', '@389'),
(173, '192.168.0.173', 'A146'),
(174, '192.168.0.174', '@786'),
(175, '192.168.0.175', 'B437'),
(176, '192.168.0.176', 'C205'),
(177, '192.168.0.177', '@436'),
(178, '192.168.0.178', 'H146'),
(179, '192.168.0.179', '?625'),
(180, '192.168.0.180', '@239'),
(181, '192.168.0.181', 'J159'),
(182, '192.168.0.182', 'D419'),
(183, '192.168.0.183', '<546'),
(184, '192.168.0.184', '@685'),
(185, '192.168.0.185', '?685'),
(186, '192.168.0.186', 'F103'),
(187, '192.168.0.187', 'K496'),
(188, '192.168.0.188', 'I442'),
(189, '192.168.0.189', 'L360'),
(190, '192.168.0.190', '@525'),
(191, '192.168.0.191', 'B704'),
(192, '192.168.0.192', 'C169'),
(193, '192.168.0.193', 'I213'),
(194, '192.168.0.194', 'D274'),
(195, '192.168.0.195', '@355'),
(196, '192.168.0.196', 'C782'),
(197, '192.168.0.197', 'C693'),
(198, '192.168.0.198', '?161'),
(199, '192.168.0.199', '=374'),
(200, '192.168.0.200', 'K130'),
(201, '192.168.0.201', '>236'),
(202, '192.168.0.202', 'H551'),
(203, '192.168.0.203', '@573'),
(204, '192.168.0.204', 'P293'),
(205, '192.168.0.205', 'K588'),
(206, '192.168.0.206', '>178'),
(207, '192.168.0.207', 'M404'),
(208, '192.168.0.208', 'O403'),
(209, '192.168.0.209', 'F476'),
(210, '192.168.0.210', 'C433'),
(211, '192.168.0.211', 'F650'),
(212, '192.168.0.212', 'B773'),
(213, '192.168.0.213', 'N764'),
(214, '192.168.0.214', 'P251'),
(215, '192.168.0.215', 'F330'),
(216, '192.168.0.216', 'F784'),
(217, '192.168.0.217', 'F368'),
(218, '192.168.0.218', 'D742'),
(219, '192.168.0.219', 'F269'),
(220, '192.168.0.220', 'O611'),
(221, '192.168.0.221', 'L200'),
(222, '192.168.0.222', '=759'),
(223, '192.168.0.223', 'E186'),
(224, '192.168.0.224', '?229'),
(225, '192.168.0.225', 'B788'),
(226, '192.168.0.226', 'E420'),
(227, '192.168.0.227', 'A341'),
(228, '192.168.0.228', 'O600'),
(229, '192.168.0.229', '@242'),
(230, '192.168.0.230', 'L663'),
(231, '192.168.0.231', 'F397'),
(232, '192.168.0.232', 'N313'),
(233, '192.168.0.233', '@143'),
(234, '192.168.0.234', 'M317'),
(235, '192.168.0.235', '@352'),
(236, '192.168.0.236', 'P711'),
(237, '192.168.0.237', 'D502'),
(238, '192.168.0.238', '>188'),
(239, '192.168.0.239', '=540'),
(240, '192.168.0.240', 'B125'),
(241, '192.168.0.241', 'N778'),
(242, '192.168.0.242', 'N276'),
(243, '192.168.0.243', 'O736'),
(244, '192.168.0.244', 'P291'),
(245, '192.168.0.245', 'P479'),
(246, '192.168.0.246', 'G285'),
(247, '192.168.0.247', '@647'),
(248, '192.168.0.248', '<349'),
(249, '192.168.0.249', 'A495'),
(250, '192.168.0.250', '=791'),
(251, '192.168.1.3', 'L7109T');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_productos`
--

CREATE TABLE `tbl_productos` (
  `codigo_barras` varchar(50) NOT NULL,
  `nombre_producto` varchar(45) NOT NULL,
  `Proveedor` varchar(45) DEFAULT NULL,
  `descripcion` varchar(100) NOT NULL,
  `precio_compra` float NOT NULL,
  `precio_venta` float NOT NULL,
  `stock_min` int(11) NOT NULL,
  `stock_max` int(11) NOT NULL,
  `caducidad` varchar(11) NOT NULL,
  `cantidad_existente` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tbl_productos`
--

INSERT INTO `tbl_productos` (`codigo_barras`, `nombre_producto`, `Proveedor`, `descripcion`, `precio_compra`, `precio_venta`, `stock_min`, `stock_max`, `caducidad`, `cantidad_existente`) VALUES
(' 7501011118119', 'SABRITAS', 'SP', 'CREMA Y ESPECIAS', 10, 13, 1, 10, '17022050', 10),
('006910021265', 'CHAROLA 007', 'SP', '50 IEZAS', 26, 28, 1, 100, '23032050', 100),
('006910021289', 'CHAROLA 835', 'SP', '50 PIEZAS', 18, 20, 1, 100, '23032050', 100),
('010900000406', 'ALUMINIO REYNOLDS WRAP', 'SP', '1 ROLLO 7.6MTS', 25, 27.5, 5, 24, '02092026', 98),
('011848455570', 'ACHIOTE LA ANITA', 'SP', '110G', 11, 14, 5, 30, '26122025', 95),
('014800515312', 'CLAMATO', 'SP', '296ML', 16, 19, 20, 10, '24062021', 10),
('014800515329', 'CLAMATO', 'SP', '473ML', 20, 25, 5, 24, '04062030', 100),
('014800515336', 'CLAMATO', 'PEÑAFIEL', '946ML', 35, 38, 5, 24, '27032050', 99),
('017479831011', 'YAVAROS', 'SP', 'SARDINAS', 34, 35, 1, 100, '16032050', 1000),
('021136010541', 'TOPO CHICO', 'COCA COLA', 'AGUA MINERAL', 14, 15, 1, 10, '18022050', 10),
('024474393529', 'COSECHA PURA', 'PEPSI', 'PIÑA 1LT', 16, 17, 5, 24, '21032017', 145),
('032239052000', 'DEL VALLE ', 'COCA COLA', 'MANGO 413 ML', 9, 14, 5, 24, '10062060', 100),
('032239052017', 'DEL VALLE', 'COCA COLA', 'DURAZNO 413ML', 9, 14, 5, 24, '21042050', 100),
('032239052147', 'DEL VALLE', 'COCACOLA', 'MANZANA 413M', 9, 10, 5, 12, '25042017', 100),
('034587020021', 'LA FINA', 'SP', 'SAL NATURAL EN BOTE 1KG', 10, 19, 5, 12, '19062025', 100),
('034587030013', 'LA FINA', 'SP', 'SAL NATURAL 1KG', 10, 15, 5, 30, '26082024', 98),
('036731106018', 'GATORADE', 'PEPSI', 'NARANJA 600 ML', 20, 22, 1, 10, '04032050', 10000),
('036731106032', 'GATORADE', 'PEPSI', 'LIMA-LIMON 600ML', 20, 22, 1, 100, '04032050', 10000),
('036731106063', 'GATORADE', 'PEPSI', 'PONCHE DE FRUTAS 600ML', 22, 22, 1, 1000, '04032050', 10000),
('036731135919', 'GATORADE', 'PEPSI', 'BLUE THUNDER', 18, 18, 1, 100, '04032021', 10000),
('036731136916', 'GATORADE', 'PEPSI', 'BLUE THUNDER 600ML', 22, 22, 21, 110, '04032050', 10000),
('036731323002', 'GATORADE ', 'PEPSI', 'LIMA LIMON 1L', 25, 28, 1, 10, '04032050', 10000),
('036731324009', 'GATORADE', 'PEPSI', 'UVA 1L', 25, 28, 1, 10, '04032050', 10000),
('036731326003', 'GATORADE', 'PEPSI', 'PONCHE DE FRUTAS 1L', 25, 28, 10, 1000, '04052050', 9999),
('036731504005', 'GATORADE', 'PEPSI', 'UVA  500ML', 17, 18, 1, 1001, '04032050', 9999),
('038000148019', 'NUT BAR', 'KELLOGGS', '33G BARRA DE CACAHUATE', 6, 8, 1, 101, '02032050', 50),
('038000148040', 'NUT BAR', 'KELLOGGS', 'SOBOR CHOCOLATE OSCURO Y ALMENDRAS', 6, 8, 1, 10, '02032050', 50),
('038000159596', 'PRINGLES', 'KELLOGS', 'EXTRA HOT 40G', 15, 16, 1, 100, '16032050', 100),
('038000184932', 'PRINGLES', 'KELLOGS', 'ORIGINAL 124G', 30, 32, 1, 100, '16032050', 1000),
('038000184949', 'PRINGLES', 'KELLOGS', 'CREMA Y CEBOLLA 124G', 30, 32, 1, 100, '16032050', 1000),
('038000184956', 'PRINGLES', 'KELLOGS', 'QUESO 124G', 30, 32, 1, 100, '16032050', 1000),
('038000185212', 'PRINGLES', 'KELLOGS', 'EXTRA HOT 124G', 30, 32, 1, 100, '16032060', 1000),
('038000846731', 'PRINGLES', 'KELLOGS', 'ORGINAL 40G', 15, 16, 1, 100, '16032050', 100),
('038000846748', 'PRINGLES', 'KELLOGS', 'CREMA Y CEBOLLA 40G', 15, 16, 1, 100, '16032050', 100),
('038000846755', 'PRINGLES', 'KELLOGS', 'QUESO 40G', 15, 16, 1, 1000, '16032050', 100),
('038000847615', 'PRINGLES', 'KELLOGS', 'CHILE Y LIMON 40G', 15, 16, 1, 100, '16032050', 100),
('038287086042', 'GARCI CRESPO', 'SP', 'MANZANA ROJA', 10, 12, 1, 100, '02032050', 555),
('038287086059', 'GARCI CRESPO', 'SP', 'MANDARINA', 11, 12, 11, 101, '02032050', 555),
('038287086066', 'GARCI CRESPO', 'CORONA', 'TORONJA 600ML', 8, 12, 10, 100, '28042030', 100),
('038287086097', 'GARCI CRESPO', 'CORONA', 'CEREZA 600ML', 8, 10, 5, 50, '28042030', 100),
('041594206232', 'VASO TERMICO', 'DART', '12 OZ', 12, 13, 100, 10, '28022023', 40),
('041594206249', 'DART', 'SP', '14J16 20PZAS', 12, 13, 10, 50, '26082026', 100),
('041594206256', 'DART', 'SP', '16J16 20PZAS', 14, 15, 5, 40, '26082026', 100),
('041594206270', 'DART', 'SP', 'NO 32J32 15PZAS', 15, 19, 5, 30, '26082026', 100),
('041594206331', 'ENVASES TÉRMICOS 16OZ', 'DART', '25 PIEZAS ', 18, 19, 100, 10, '31122022', 30),
('041594206607', 'DART', 'SP', '#10 25PZAS', 10, 11, 5, 50, '26082026', 100),
('041594215289', 'TAPAS PLÁSTICAS CON PERFORACIÓN ', 'DART', '100 TAPAS', 68, 68, 100, 100, '31012023', 4),
('041594231173', 'VASO TERMICOS', 'DART', '8 OZ', 9, 10, 100, 8, '30072022', 10),
('041594517963', 'DART TAPAS', 'SP', 'NO 10SL 100PZ', 23, 25.5, 3, 12, '27082026', 100),
('041789001864', 'MARUCHAN', 'SP', 'LIMON Y HABANERO', 6, 11.5, 5, 40, '06052050', 100),
('041789001918', 'MARUCHAN', 'SP', 'POLLO', 5, 11.5, 10, 40, '31052050', 100),
('041789001925', 'MARUCHAN', 'SP', 'CARNE DE RES', 6, 11.5, 10, 40, '11052050', 100),
('041789001956', 'MARUCHAN', 'SP', 'CAMARON', 6, 11.5, 5, 50, '05102050', 100),
('041789001987', 'MARUCHAN', 'SP', 'CHILE PIQUIN', 6, 11.5, 5, 40, '22052050', 100),
('064144030323', 'PAM', 'SP', 'ORIGINAL', 43, 44, 1, 100, '12032050', 1000),
('074323083620', 'CAJETA CORONADO', 'RICOLINO', 'ENVINADA 370G', 39, 46, 2, 5, '14032025', 100),
('07432354', 'BUBU LUBU', 'RICOLINO', 'MALVAVISCO RELLENO', 7, 8, 1, 100, '15032050', 100),
('089826001415', 'TECATE', 'CORONA', 'ORIGINAL', 18, 20, 1, 10, '02032050', 555),
('097339000030', 'VALENTINA', 'SP', 'ETIQUETA AMARILLA 1LT', 22, 24, 4, 12, '26062021', 100),
('097339000047', 'VALENTINA', 'SP', 'ETIQUETA NEGRA 1LT', 20, 24, 5, 12, '26082021', 100),
('097339000054', 'VALENTINA', 'SP', 'ETIQUETA AMARILLA 370ML', 7, 8.5, 5, 24, '26082021', 100),
('097339000061', 'VALENTINA', 'SP', 'ETIQUETA NEGRA 370ML', 10, 13, 5, 24, '26072050', 100),
('121', 'JITOMATE ', 'SP', 'SALADETTE', 9, 16, 10, 60, '27082016', 100),
('123', 'AGUACATE', 'SP', 'HASS', 35, 60, 10, 20, '20082016', 5),
('12345', 'HUEVO', 'SP', 'BLANCO', 35, 42, 10, 500, '11032025', 40),
('1235', 'PLATANO', 'BANABRAVA', 'TABASCO', 15, 23, 100, 20, '17032021', 30),
('12389', 'GUAYABA', 'SP', '1 KILO', 19, 20, 100, 1, '18032021', 100),
('124', 'ALFALFA', 'COMION DE LA ALFALFA ', 'MANOJO', 2.5, 3, 10, 150, '27082016', 99),
('125', 'PETALO', 'SP', 'ULTRA RESISTENTE 1PZS', 3, 4, 10, 50, '27082026', 100),
('126', 'PETALO', 'SP', 'JUMBO', 6, 7.5, 10, 50, '27082026', 100),
('1265', 'JITOMATE', 'SP', 'SALADET', 15, 15, 50, 20, '18032050', 30),
('127', 'CISNE', 'SP', 'PAPEL HIGIENICO 1PZ', 2, 3, 10, 50, '27082026', 100),
('12702905', 'SERVILLETAS TENDER', 'MAXIMA', '500 SERVILLETAS', 37, 39, 1000, 10, '29102022', 100),
('128', 'POPOTE PRIMO', 'SP', '80G', 8, 10, 2, 15, '02092026', 100),
('1290', 'NARANJA', 'SP', '1 KILO', 9, 10, 100, 1, '18032021', 100),
('130', 'POPOTE VARIOS COLORES', 'SP', 'POPOTE EMBOLSADO', 9, 10, 2, 15, '02092026', 100),
('1345', 'CEBOLLA', 'SP', '1 KILO', 20, 20.5, 80, 10, '29102022', 30),
('220130', 'ORBIT', 'ORBIT', 'FRESA', 1, 2, 1, 100, '22032050', 100),
('4033100076428', 'WINSTON', 'JTI', 'WILD MINT', 50, 52, 1, 10, '26022050', 100),
('4033100094316', 'WINSTON', 'JTI', 'CLASSIC', 57, 57, 1, 10, '26022050', 100),
('4058075217621', 'OSRAM', 'SP', 'FOCO LED', 40, 42, 1, 100, '17032050', 1000),
('5410228141266', 'STELLA ARTOIS', 'ANNO 1366', 'BELGIUM 330ML', 23, 25, 1, 100, '020320501', 50),
('613008738785', 'ARIZONA', 'SP', 'TE NEGRO', 9, 11, 5, 24, '09062018', 100),
('613008738808', 'ARIZONA', 'SP', 'MANGO 680ML', 13, 14, 5, 24, '17062050', 100),
('613008738822', 'ARIZONA', 'SP', 'KIWI CON FRESA 680ML', 9, 14, 5, 24, '14062050', 100),
('613008738846', 'ARIZONA', 'SP', 'SANDIA 680ML', 13, 14, 5, 24, '31052050', 100),
('613008738860', 'ARIZONA', 'SP', 'PONCHE DE FRUTAS', 13, 14, 1, 100, '16032050', 100),
('633148100013', 'TAJIN', 'SP', 'CLASICO 142G', 27, 30, 5, 15, '01052025', 100),
('633148100556', 'TAJIN', 'SP', 'CLASICO 400G', 49, 52, 4, 12, '26062025', 100),
('643131505268', 'PLATO TERMICO NO.9-3D', 'ORION', '3 DIVISIONES', 13, 13.5, 1, 100, '23032050', 100),
('650240033537', 'VANART', 'SP', 'SHAMPOO 22ML', 2, 3, 1, 100, '05032050', 100),
('658480001262', 'SANISSIMO TOSTADAS', 'SP', 'HORNEADAS', 20, 26, 1, 10, '14022050', 10),
('706460000658', 'WHISKAS', 'WHISKAS', 'FILETE DE POLLO', 10, 12, 1, 100, '1032050', 1000),
('706460249231', 'PEDIGREE', 'PEDIGREE', 'POLLO ADULTO', 10, 12, 1, 100, '12032050', 1000),
('706460249279', 'PEDIGREE', 'PEDIGREE', 'RES ADULTO', 10, 12, 1, 100, '12032050', 1000),
('706460249361', 'PEDIGREE', 'PEDIGREE', 'POLLO CACHORRO', 10, 12, 1, 10010, '12032050', 1000),
('709859000000', 'CHAROLA 855', 'SP', '100PZAS', 35, 39, 4, 12, '26082022', 100),
('7098594000202', 'CHAROLA 835', 'SP', 'CHAROLA PLATANERA 50PZAS', 15, 17, 5, 12, '26082026', 100),
('723707921705', 'CUCHARAS PASTELERA', 'JUMA', '50 CUCHARAS ', 8, 10, 100, 10, '30062022', 39),
('724865025274', 'CHOCO TIPS', 'KELLOGS', 'GALLETAS', 10, 12, 1, 100, '16032050', 100),
('724865036331', 'POLVORONES', 'SP', 'SABOR NARANJA', 10, 12, 1, 100, '10032050', 1000),
('724865038410', 'ROSCAS', 'KELLOGS', 'SABOR CANELA', 10, 12, 1, 100, '16032050', 100),
('724865052263', 'CHOCO NIEVE', 'KELLOGS', 'CHOCOLATE', 10, 12, 2, 100, '16032050', 1000),
('724865053260', 'FRESA NIEVE', 'KELLOGS', '100G', 10, 12, 1, 100, '16032050', 1000),
('724865054427', 'CONQUISTADOR', 'KELLOGS', 'CHOCOLATE', 10, 12, 20, 1000, '16032050', 100),
('735257000014', 'D\'GARI', 'SP', 'AGUA ANIS 140G', 7.5, 8.5, 5, 24, '30032017', 100),
('735257000021', 'D\'GARI', 'SP', 'LECHE CHOCOLATE 140G', 7.5, 8.5, 5, 24, '09042017', 100),
('735257000052', 'D\'GARI', 'SP', 'AGUA FRESA 140G', 7, 8.5, 5, 24, '15112017', 100),
('735257000069', 'D\'GARI', 'SP', 'LECHE FRESA 140G', 7, 8.5, 5, 24, '22042017', 100),
('735257000076', 'D\'GARI', 'SP', 'AGUA DROSELLA 140G', 7, 8.5, 5, 24, '22082017', 100),
('735257000106', 'D\'GARI', 'SP', 'AGUA LIMON 140G', 7, 8.5, 5, 24, '04082017', 100),
('735257000175', 'D\'GARI', 'SP', 'LECHE NUEZ 140G', 7, 8.5, 5, 24, '03052017', 100),
('735257000205', 'D\'GARI', 'SP', 'LECHE ROMPOPE 140G', 7.5, 8.5, 5, 24, '30032017', 100),
('735257000229', 'D\'GARI', 'SP', 'AGUA UVA 140G', 7.5, 8.5, 5, 24, '14112017', 100),
('735257000236', 'D\'GARI', 'SP', 'LECHE VAINILLA 140G', 7.5, 8.5, 5, 24, '13032017', 100),
('735257002452', 'GELATINA DGARI', 'DGARI', 'UVA AGUA', 10, 13, 1, 100, '12022050', 100),
('735257002469', 'GELATINA DGARI', 'DGARI', 'PIÑA AGUA', 10, 13, 1, 100, '12032040', 100),
('735257002476', 'GELATINA DGARI', 'DGARI', 'NARANJA AGUA', 12, 13, 10, 100, '12032040', 100),
('735257002506', 'GELATINA DGARI', 'DGARI', 'JERZ AGUA', 10, 13, 1, 100, '12032040', 100),
('735257002513', 'GELATINA DGARI', 'DGARI', 'FRESA AGUA', 10, 13, 1, 100, '12032050', 100),
('735257002520', 'GELATINA DGARI', 'DGARI', 'FRAMBUESA AGUA', 10, 13, 1, 100, '12032050', 100),
('735257002568', 'GELATINA DGARI', 'DGARI', 'MANZANA ROJA AGUA', 10, 13, 1, 100, '12032050', 100),
('735257002582', 'GELATINA DGARI', 'GDGARI', 'MANGO AGUA', 10, 13, 1, 1000, '12032050', 100),
('735257002599', 'GELATINA DGARI', 'DGARI', 'MORA SILVESTRE AGUA', 10, 13, 1, 100, '12032050', 100),
('735257002605', 'GELATINA DGARI', 'DGARI', 'ARANDANO AGUA', 10, 13, 1, 100, '12032050', 100),
('735257002629', 'GELATINA DGARI', 'DGARI', 'ROMPOPE LECHE', 10, 13, 1, 100, '12032040', 100),
('735257002636', 'GELATINA DGARI', 'DGARI', 'VAINILLA LECHE', 10, 13, 1, 100, '12032050', 100),
('735257002643', 'GELATINA DGARI', 'DGARI', 'FRESA LECHE', 12, 13, 1, 100, '12032050', 100),
('735257002674', 'GELATINA DGARI', 'DGARI', 'COCO LECHE', 10, 13, 1, 1001, '12032050', 100),
('735257002681', 'GELATINA DGARI', 'DGARI', 'PSITACHE LECHE', 10, 13, 1, 100, '12032050', 100),
('738545010016', 'LA BOTANERA', 'SP', 'SALSA CLASICA 1KG', 11, 12.5, 5, 24, '02062017', 100),
('738545010559', 'LA BOTANERA', 'SP', 'CLASICA 1.5 KG', 25, 29.5, 5, 24, '02042050', 100),
('738545010726', 'LA BOTANERA', 'SP', 'SALSA CLASICA 4.1KG', 54, 54, 4, 12, '30062050', 100),
('738545020015', 'CHAMOY MEGA', 'SP', 'ORIGINAL 500G', 9, 10, 5, 24, '04062017', 100),
('738545020046', 'CHAMOY MEGA', 'SP', 'ORIGINAL 1KG', 15, 19, 5, 24, '19052050', 100),
('738545020206', 'CHAMOY MEGA', 'SP', 'ORIGINAL 4.1KG', 55, 56, 4, 12, '05042050', 100),
('7411000314210', 'MORDISKO', 'HOLANDA', 'CHOCO POP', 18, 20, 1, 100, '17032050', 100),
('7411204801813', 'COSECHA PURA', 'PEPSI', 'MANZANA 1LT', 16, 17, 4, 12, '22032017', 100),
('7441057213372', 'SABA', 'SP', 'INVISIBLE CON ALAS 12PZS', 18, 19.5, 5, 24, '27082026', 100),
('744607588805', 'NEW MIX', 'CORONA', 'VAMPIRO', 16, 17, 1, 100, '10032050', 998),
('744607840804', 'NEW MIX', 'EL JIMADOR', 'PALOMA ', 17, 18, 1, 10, '02032050', 50),
('744886298822', 'JARRITOS', 'JARRITOS', 'MANDARINA 600ML', 6, 7, 20, 200, '21012030', 100),
('744886348824', 'JARRITOS', 'JARRITOS', 'TORONJA 600ML', 6, 7, 5, 50, '28042030', 100),
('744886375059', 'JARRITOS', 'JARRITOS', '2LT MANDARINA', 17, 18, 10, 101, '22022050', 101),
('75000608', 'CLORALEX', 'SP', '500 ML', 4, 7.5, 10, 15, '06082025', 100),
('75000615', 'CLORALEX', 'SP', '950ML', 8, 14.5, 5, 15, '06082050', 100),
('75001162', 'FABULOSO ', 'SP', 'FRESCA LAVANDA 500 ML', 8, 14, 5, 10, '06082050', 100),
('75001186', 'FABULOSO', 'SP', 'MAR FRESCO', 13, 14, 10, 50, '05032050', 1000),
('75001322', 'MARLBORO', 'MARLBORO', '20´S', 65, 66, 1, 101, '26022050', 97),
('75001339', 'MARLBORO', 'MARLBORO', '14´S CIGARROS', 47, 49, 1, 41, '26022050', 140),
('75001476', 'DELICADOS', 'MARLBORO', 'OVALADOS', 17, 53, 1, 10, '26022050', 1010),
('75001759', 'BOING!', 'SP', 'MANGO 250ML', 5, 6, 5, 24, '26032017', 100),
('75001773', 'BOING', 'BOING', 'GUAYABA 250ML', 5, 6, 1, 100, '11032050', 1000),
('75001797', 'BOING!', 'SP', 'MANZANA 250ML', 5, 6, 5, 24, '26022017', 100),
('75001940', 'FRUTSI', 'COCACOLA', 'NARANJA 250ML', 3.5, 4, 5, 24, '25082030', 100),
('75001957', 'FRUTSI', 'SP', 'UVA 250ML', 3.5, 4, 5, 24, '07082030', 100),
('75002084', 'ALPURA', 'SP', 'FRESA 250ML', 6, 8, 5, 24, '05012017', 100),
('75002091', 'ALPURA', 'SP', 'VAINILLA 250ML', 6, 8, 5, 24, '04102016', 100),
('75002107', 'ALPURA', 'SP', 'CHOCOLATE 250ML', 6, 8, 5, 30, '24122016', 100),
('75002275', 'CHOCO ROLES', 'SP', 'PIÑA', 12, 16, 10, 10, '15022050', 1),
('75002343', 'ACEITE 1 2 3', 'SP', '1LT', 30, 33, 5, 20, '01072050', 100),
('75003104', 'BOING', 'BOING', 'MANGO 500ML', 9, 10, 1, 1000, '11032050', 1000),
('75003135', 'BOING!', 'SP', 'GUAYABA 500ML', 9, 10, 5, 24, '12012017', 100),
('75003159', 'BOING!', 'SP', 'MANZANA 500ML', 9, 10, 5, 24, '23022017', 100),
('7500326103322', 'SANGRIA SEÑORAL', 'SANGRIA SEÑORAL', '1LT', 13, 15, 5, 50, '26082030', 100),
('7500326103346', 'SANGRIA SEÑORIAL', 'PEPSI', '2.6L', 33, 33, 1, 10, '04032050', 10000),
('7500326103360', 'SANGRIA SEÑORAL', 'SANGRIA SEÑORAL', '600ML', 9, 10, 5, 50, '06042030', 100),
('75003371', 'GERBER', 'SP', 'DURAZNO', 10, 13, 5, 24, '26052050', 100),
('75003388', 'GERBER', 'SP', 'MANZANA 113G', 9, 13, 6, 24, '26052050', 100),
('75003401', 'GERBER', 'SP', 'PERA 113G', 9, 10, 10, 24, '26042018', 100),
('75003425', 'GERBER', 'SP', 'CIRUELA PASA 113G', 10, 15, 4, 24, '26042050', 100),
('75003456', 'GERBER', 'SP', 'FRUTAS TROPICALES 113G', 10, 13, 5, 24, '26062050', 100),
('75003463', 'GERBER', 'SP', 'FRUTAS MIXTAS 113G', 9, 10, 5, 24, '26032018', 100),
('75003487', 'GERBER', 'SP', 'MANGO 133G', 10, 13, 5, 24, '26072050', 100),
('7500435000123', 'NATURELLA', 'SP', 'CON MANZANILLA', 18, 19, 1, 100, '17032050', 1100),
('7500435018791', 'ACE', 'SP', '900G', 37, 39, 1, 100, '05032050', 1000),
('7500435120852', 'ARIEL', 'SP', '850G', 40, 42, 1, 100, '05032050', 1000),
('7500435125987', 'DOWNY', 'SP', 'PERFUME COLLECTION', 24, 25, 10, 50, '05032050', 100),
('7500435155496', 'ORAL B', 'SP', '50ML', 16, 17, 1, 100, '17032050', 1000),
('7500459000321', 'PERSIL', 'SP', 'GEL UNIVERSAL', 17, 18, 1, 210, '05032080', 1000),
('7500459000598', '1>2>3', 'SP', 'MULTIUSOS', 22, 23, 1, 100, '05032050', 1000),
('7500478005833', 'BOMBITOS', 'GAMESA', 'GAMESA', 10, 12, 12, 100, '12032050', 10001),
('7500478007967', 'RUFFLES', 'SABRITAS', 'SALSA ROJA', 10, 13, 1, 100, '15032050', 100),
('7500478007974', 'RUFFLES', 'SABRITAS', 'JALAPEÑO', 10, 13, 1, 100, '15032050', 100),
('7500478013944', 'PAKETON CHOKIS', 'GAMESA', 'CLASICA', 22, 23, 1, 100, '12032050', 1000),
('7500478014569', 'CHOKIS', 'GAMESA', 'CLASICA', 12, 13, 1, 100, '120320550', 1000),
('7500478015085', 'PAKETON EMPERADOR', 'GAMESA', 'COMBINADO', 22, 23, 1, 100, '12032050', 1000),
('7500478015108', 'PAKETON EMPERADOR', 'GAMESA', 'PIRUETAS', 22, 23, 1, 100, '12032050', 1000),
('7500478015238', 'PAKETON EMPERADOR', 'GAMESA', 'CHOCOLATE', 22, 23, 1, 100, '12032050', 1000),
('7500478015740', 'CRACKETS', 'GAMESA', '89G', 10, 11, 1, 100, '12032050', 1000),
('7500478015870', 'CRACKETS', 'GAMESA', '139G', 14, 15, 1, 100, '12032050', 1000),
('7500478020508', 'GAMESA CLASICAS', 'GAMESA', 'DELICIAS', 12, 13, 1, 1001, '12032050', 10001),
('7500478021086', 'GAMESA CLASICAS', 'GAMESA', 'BARRAS DE COCO', 12, 13, 1, 100, '12032050', 10001),
('7500478021574', 'EMPERADOR', 'GAMESA', 'NOCTURNO', 12, 13, 1, 100, '12032050', 1000),
('7500478021581', 'EMPERADOR', 'GAMESA', 'COMBIANDO', 12, 13, 1, 101, '12032050', 1000),
('7500478021895', 'MINI MARIAS', 'GAMESA', 'GAMESA', 7, 8, 1, 100, '12032050', 10001),
('7500478022410', 'MINI GAMESA CLASICAS', 'GAMESA', 'MARAVILLAS', 9, 10, 1, 100, '12032050', 10001),
('7500478022496', 'EMPERADOR', 'GAMESA', 'SABOR CHOCOLATE', 12, 13, 1, 100, '12032050', 1000),
('7500478022502', 'EMPERADOR', 'GAMESA', 'PIRUETAS', 12, 13, 1, 1001, '12052050', 1000),
('7500478022519', 'EMPERADOR', 'GAMESA', 'VAINILLA', 12, 13, 1, 100, '12032050', 1000),
('7500478022540', 'EMPERADOR', 'GAMESA', 'SABOR NUEZ', 10, 13, 1, 100, '12032050', 1000),
('7500478022748', 'KACANG CACAHUATES', 'SABRITAS', 'FLAMIN HOT', 10, 11, 1, 100, '12032050', 1000),
('7500478023608', 'GAMESA CLASICAS', 'GAMESA', 'MARAVILLAS', 12, 13, 1, 101, '12032050', 1000),
('75005443', 'ACEITE 1 2 3', 'SP', '500ML', 17, 18, 5, 20, '27122050', 100),
('75009076', 'DANY', 'DANONE', 'GELATINA DE FRESA', 5, 6, 1, 100, '18032050', 1100),
('75009083', 'DANY', 'DANONE', 'GELATINA DE PIÑA', 5, 6, 100, 1000, '18032050', 100),
('75009090', 'DANY', 'DANONE', 'GELATINA DE LIMON', 5, 6, 1, 100, '18032055', 100),
('7501000101238', 'SUPER BOLLOS', 'BIMBO', '8 PIEZAS', 34, 41, 1, 110, '10032050', 1000),
('7501000103034', 'DALMATA', 'WONDER', 'PASTELITO ', 10, 10, 1, 10, '15032050', 1100),
('7501000103065', 'CHOCOTORRO', 'WONDER', 'PASTELITO', 10, 10, 1, 100, '15032050', 1100),
('7501000106936', 'TOSTADAS', 'SP', 'PLANAS', 13, 17, 10, 10, '14022050', 10),
('7501000111091', 'PAN', 'SP', 'BLANCO CHICO', 21, 27, 10, 10, '14022050', 10000),
('7501000111251', 'TORTILLINAS', 'SP', '10 PIEZAS', 11, 14, 10, 10, '14022050', 10),
('7501000111299', 'TORTILLINAS', 'SP', '20 PIEZAS', 19, 24, 10, 10, '14022050', 10),
('7501000111466', 'PAN INTEGRAL', 'SP', 'GRANDE', 31, 38, 10, 10, '14022050', 10),
('7501000111503', 'MEDIAS NOCHES', 'BIMBO', '8 PZ', 24.9, 30, 10, 10, '14022050', 1000),
('7501000111602', 'BIMBOLLOS', 'BIMBO', '8 PIEZAS', 29, 35, 1, 100, '10032050', 1000),
('7501000111800', 'PAN TOSTADO', 'SP', 'CLASICO', 19, 25, 10, 10, '14022050', 1000),
('7501000111855', 'PAN MOLIDO', 'SP', 'CLASICO', 13, 18, 10, 10, '14022050', 1000),
('7501000112203', 'COLCHONES', 'SP', 'SABOR NARANJA', 8, 10, 10, 10, '14022050', 1010),
('7501000112302', 'PANQUE ', 'SP', 'PASAS', 24, 32, 10, 10, '15022050', 1000),
('7501000112326', 'PANQUE', 'SP', 'NUEZ', 24, 32, 10, 10, '15022050', 10000),
('7501000112333', 'PAN TOSTADO', 'SP', 'DOBLEFIBRA', 21, 27, 1, 20, '14022050', 1000),
('7501000112784', 'NITO', 'SP', 'PAN DULCE', 8, 11, 1, 10, '14022050', 1009),
('7501000112845', 'REBANADAS ', 'SP', 'PAN DULCE', 4, 5, 10, 10, '14022050', 1010),
('7501000116430', 'BRAN FRUT', 'SP', 'PIÑA', 6, 8, 10, 10, '14022050', 1),
('7501000116447', 'BRAN FRUT', 'FRUT', 'FRESA', 6, 8, 10, 10, '14022050', 1),
('7501000122332', 'PAN BLANCO BIMBO', 'SP', 'GRANDE', 28, 35, 0, 10, '14022050', 7),
('7501000127344', 'LORS', 'MARINELA', 'GALLETA SANDWICH', 10, 12, 1, 1001, '10032050', 1000),
('7501000128167', 'PRINCIPE', 'MARINELA', 'CHOCOLATE', 11, 14, 1, 100, '10032050', 1000),
('7501000131440', 'BIMBO', 'BIMBO', 'MULTIGRANO', 33, 40, 1, 100, '10032050', 1000),
('7501000132300', 'PRINCIPE', 'MARINELA', 'CHOCOLATE BLANCO', 11, 14, 1, 1000, '1022060', 1000),
('7501000132706', 'CONCHAS', 'SP', 'VAINILLA', 10, 12, 10, 10, '15022060', 1000),
('7501000133338', 'PASTISETAS', 'SUANDAY', 'ORIGINALES', 12, 15, 1, 100, '10032050', 1000),
('7501000134465', 'MAGNAS', 'LARA', 'GALLETAS', 12, 15, 1, 100, '10032050', 1000),
('7501000135301', 'MARIAS', 'LARA', 'LARA', 9, 11, 1, 10, '10032050', 1000),
('7501000138944', 'SPONCH', 'MARINELA', 'GALLETA CON MALVAVISCO', 15, 15, 1, 100, '10032050', 999),
('7501000140473', 'POP', 'BARCEL', 'KARAMELADAS', 7, 8, 1, 100, '15032050', 1000),
('7501000140855', 'TRIKI TRAKES', 'MARINELA', 'MARINELA', 10, 12, 0, 1000, '10032050', 1000),
('7501000149100', 'EMPANIZADOR ', 'BIMBO', 'CRUJIENTE', 14, 18, 1, 100, '10032050', 10000),
('7501000153107', 'GANSITO', 'SP', 'PASTELITO', 10, 12, 10, 10, '15022060', 1),
('7501000153282', 'SUBMARINOS', 'S´P', 'VAINILLA', 11, 14, 10, 10, '15022050', 0),
('7501000153374', 'SUBMARINOS', 'SP', 'FRESA', 11, 14, 10, 10, '15022050', 1),
('7501000153459', 'ROLLO', 'MARINELA', 'CON FRESA', 10, 13, 1, 1000, '10032050', 1000),
('7501000153718', 'BOMOBONETES', 'SP', 'GALLETAS', 6, 8, 10, 10, '15022050', 1),
('7501000153763', 'ROCKO', 'SP', 'GALLETA SANDWICH', 5, 6, 10, 10, '15022060', 1),
('7501000153800', 'PINGUINOS', 'SP', 'PASTELITO', 12, 16, 1, 10, '15022050', 0),
('7501000156214', 'SUBMARINOS', 'WS', 'SABOR CHOCOLATE', 1, 14, 0, 1, '15022060', 1),
('7501000157075', 'TOSTADAS ONDULADAS', 'SP', 'MILPAREAL', 19, 24, 10, 101, '14022050', 10),
('7501000264773', 'CHIPS', 'BARCEL', 'JALAPEÑO', 14, 15, 1, 100, '15032050', 1000),
('7501000266203', 'CHIPS', 'BARCEL', 'SAL 170G', 36, 37, 1, 100, '15032050', 100),
('7501000266234', 'CHIPS', 'BARCEL', 'JALAPEÑO', 36, 37, 1, 100, '15032050', 100),
('7501000278404', 'PALETA PAYASO', 'RICOLINO', 'GALLETA DE MALVAVISCO', 10, 12, 1, 1001, '15032050', 100),
('7501000300730', 'BIMBO', 'BIMBO', 'LINAZA', 33, 40, 1, 100, '10032060', 1000),
('7501000309726', 'ROLES', 'SP', 'CON CANELA', 24, 32, 10, 10, '15022060', 10000),
('7501000310647', 'PANQUE', 'SP', 'MARMOL', 24, 30, 10, 10, '15022060', 10),
('7501000336319', 'BIMBO INTEGRAL', 'SP', 'CHICO', 23, 28, 2, 20, '14022050', 10),
('7501000339198', 'MULTIGRANO', 'BIMBO', 'LINAZA', 7, 8, 1, 100, '15032050', 1100),
('7501000383320', 'YOPI', 'SP', 'CAJETA QUEMADA 250G', 25, 26, 5, 24, '31082050', 100),
('7501000392490', 'CANELITAS', 'MARINELA', 'MINI', 5, 5, 1, 100, '10032050', 1000),
('7501000601738', 'GAMESA CLASICAS', 'GAMESA', 'FLORENTINAS FRESA', 12, 13, 1, 100, '12032050', 1000),
('7501000601745', 'GAMESA CLASICAS', 'GAMESA', 'FLORENTINAS CAJETA', 12, 13, 1, 101, '12032050', 1000),
('7501000601776', 'EMPERADOR', 'GAMESA', 'SENZO', 12, 13, 1, 100, '12032050', 1000),
('7501000604685', 'CHOKIS', 'GAMESA', 'RELLENA', 12, 13, 1, 100, '12032050', 1000),
('7501000606566', 'CREMAX', 'GAMESA', 'CHOCOLATE', 12, 13, 1, 1000, '12032060', 1000),
('7501000606573', 'CREMAX', 'GAMESA', 'VAINILLA', 12, 13, 1, 100, '120320501', 1000),
('7501000606580', 'CREMAX', 'GAMESA', 'FRESA', 12, 13, 1, 101, '12032050', 1000),
('7501000612130', 'PAKETON CREMAX ', 'GAMESA', 'CHOCOLATE', 23, 23, 1, 100, '12032050', 1000),
('7501000612147', 'PAKETON CREMAX', 'GAMESA', 'FRESA', 22, 23, 1, 100, '12032050', 1000),
('7501000612161', 'PAKETON CREMAX', 'GAMESA', 'VAINILLA', 22, 23, 1, 100, '12032050', 1000),
('7501000624683', 'GAMESA CLASICAS', 'GAMESA', 'FLOR DE NARANJO ', 12, 13, 1, 100, '12032050', 10001),
('7501000628360', 'GAMESA CLASICAS', 'GAMESA', 'RICALINAS', 12, 13, 1, 100, '12032050', 1000),
('7501000630363', 'MINI MAMUT', 'GAMESA', '12G', 2, 2, 1, 100, '12032050', 10001),
('7501000633890', 'HARINA PARA HOTCAKES', 'GAMESA', 'GAMESA TRADICIONALES 950G', 24, 26.5, 2, 12, '16102016', 100),
('7501000635726', 'ARCOIRIS', 'GAMESA', 'GALLETAS', 12, 13, 1, 100, '12032050', 1000),
('7501000640362', 'GIRO', 'GAMESA', 'GALLETA TIPO SANDWICH', 12, 13, 1, 100, '12032050', 1000),
('7501000651375', 'MAMUT', 'GAMESA', '44G', 6, 7, 1, 100, '12032050', 10001),
('7501000657797', 'CHOKIS', 'GAMESA', 'CHOCOLATE', 12, 13, 1, 100, '12032050', 1000),
('7501000658220', 'CHOCOLATINES', 'GAMESA', 'GAMESA', 7, 8, 1, 100, '12032080', 10001),
('7501000658329', 'MARIAS', 'GAMESA', 'GAMESA AZUCARADAS', 12, 13, 1, 100, '1222050', 1000),
('7501000658923', 'MARIAS', 'GAMESA', 'GAMESA', 11, 12, 1, 100, '12032050', 1000),
('7501000664221', 'SALADITAS ', 'GAMESA', 'GAMESA', 13, 15, 1, 100, '12032050', 1000),
('7501000664382', 'MARIAS DORADAS', 'GAMESA', 'GAMESA', 22, 23, 1, 100, '12032050', 10001),
('7501000904228', 'GERBER', 'SP', 'COMIDITA CASERA', 10, 13, 1, 100, '12032040', 1000),
('7501000904242', 'GERBER', 'SP', 'VERDURAS CON CARNE Y ARROZ 113G', 10, 13, 4, 24, '26022050', 100),
('7501000904259', 'GERBER', 'SP', 'VERDURAS CON JAMON 113G', 9, 10, 6, 24, '26032018', 100),
('7501000904754', 'GERBER', 'SP', 'ZANAHORIA 113G', 9, 10, 5, 24, '26042018', 100),
('7501000910533', 'GERBER', 'SP', 'POSTRE GUAYABA 100G', 9, 10, 4, 24, '26112017', 100),
('7501000911783', 'NESCAFE', 'NESTLE', 'CLASICO 14G', 9, 10, 5, 30, '31052017', 99),
('7501000911943', 'MAGGI', 'SP', 'SABOR MAGICO 8G', 1.5, 2, 5, 24, '25082080', 100),
('7501000912612', 'NESCAFE', 'SP', 'CLASICO 28G', 14, 16, 5, 30, '31012050', 100),
('7501000913282', 'COFFE-MATE', 'NESTLE', 'EL ORIGINAL 34G', 4, 6, 10, 40, '27122017', 100),
('7501001030117', 'ROYAL', 'SP', 'POLVO PARA HORNEAR', 15, 18, 100, 110, '12032050', 1000),
('7501001106690', 'BOLD 3', 'SP', 'FLORES 500G', 15, 16.5, 5, 24, '25082018', 100),
('7501001109172', 'DOWNY', 'SP', 'COLLECTIONS NEGRO', 15, 17, 5, 10, '31122018', NULL),
('7501001130657', 'SALVO', 'SP', 'LIMON 500G', 11, 18, 5, 24, '25082050', 100),
('7501001130664', 'SALVO', 'SP', '250G', 6, 7.5, 10, 50, '05082020', 100),
('7501001155841', 'DOWNY', 'SP', 'AROMA FLORAL 800ML', 24, 25, 5, 10, '31122050', 100),
('7501001157296', 'NATURELLA', 'SP', 'DERMA CREAM CON ALAS 10PZS', 17, 19, 4, 12, '27082026', 100),
('7501001158439', 'NATURELLA', 'SP', 'DERMA CREAM SIN ALAS 10PZS', 17, 18, 4, 12, '27082026', 100),
('7501001405335', 'NATURELLA', 'SP', 'CUIDADO NOCTURNO', 20, 21.5, 5, 12, '27082026', 100),
('7501001600426', 'MEDIA CREMA', 'NESTLE', '225G', 14, 15, 5, 24, '31052050', 100),
('7501001604103', 'JUGO MAGGI', 'SP', 'SASONADOR 100ML', 35, 36, 5, 12, '30062050', 100),
('7501001604318', 'CROSSE & BLACKWELL', 'SP', 'SALSA TIPO INGLESA 145ML', 37, 39, 4, 12, '30122050', 100),
('7501001604554', 'PURE DE PAPA MAGGI', 'SP', '125G', 14, 16, 3, 12, '31122016', 100),
('7501003123213', 'HERDEZ', 'SP', 'CHAMPIÑONES REBANADOS 186G', 13, 14.5, 5, 24, '26042018', 100),
('7501003123237', 'HERDEZ', 'SP', 'CHAMPIÑONES REBANADOS 380G', 26, 39.5, 5, 24, '26122050', 100),
('7501003124135', 'HERDEZ', 'HERDEZ', 'CHICHAROS 215G', 10, 10, 10, 100, '01052050', 1000),
('7501003124142', 'HERDEZ', 'SP', 'CHICHAROS 400G', 9, 10.5, 5, 24, '26122017', 100),
('7501003124166', 'HERDEZ', 'SP', 'CHICHAROS CON ZANAHORIA 225G', 6, 7, 5, 24, '26112018', 100),
('7501003124180', 'HERDEZ', 'HERDEZ', 'CHICCHAROS CON ZANAHORIA ', 17, 18, 10, 101, '01032050', 999),
('7501003124234', 'HERDEZ', 'SP', 'GRANOS DE ELOTE 220G', 7, 10, 5, 24, '26052050', 100),
('7501003124241', 'HERDEZ', 'SP', 'GRANOS DE ELOTE 400G', 13, 18, 5, 24, '26082040', 97),
('7501003124333', 'HERDEZ', 'SP', 'ENSALADA DE LEGUMBRES 220G', 6, 8, 5, 24, '26052050', 95),
('7501003124340', 'HERDEZ', 'HERDEZ', 'ENSALADA DE LEGUMBRES 400G', 15, 17, 1, 10, '01032050', 1000),
('7501003127600', 'HERDEZ', 'HERDEZ', 'SALSA VERDE', 17, 18, 10, 1011, '12032050', 1000),
('7501003150233', 'DOÑA MARIA', 'SP', 'MOLE 235G', 37, 39, 4, 12, '26122050', 1000),
('7501003300461', 'MCCORMICK MAYONESA', 'MCCORMICK', 'CON JUGO DE LIMONES', 20, 23, 1, 101, '01032050', 100),
('7501003300652', 'MCCORMICK', 'MCCORMICK', '105G', 10, 12, 1, 110, '12032050', 1000),
('7501003300676', 'MOSTAZA', 'MCCORMICK', '115G', 10, 12, 1, 100, '12032050', 1000),
('7501003311450', 'SAL CON AJO', 'MCCORMICK', '125G', 17, 19, 1, 100, '12032050', 999),
('7501003313898', 'MCCORMICK', 'MCCORMICK', 'CALDO DE POLLO', 42, 43, 1, 100, '12032050', 1000),
('7501003335029', 'MOSTAZA MCCORMICK', 'SP', 'ORIGINAL 210G', 10, 11.5, 5, 24, '26082017', 100),
('7501003336125', 'MCCORMICK', 'SP', 'MERMELADA DE FRESA 270G', 20, 24, 5, 30, '27072025', 100),
('7501003337825', 'SAL CON AJO MCCORMICK', 'SP', 'CONDIMENTO 157G', 17, 18, 4, 12, '26022019', 100),
('7501003340122', 'MAYONESA MCORMICK', 'SP', '190G', 12, 14, 5, 30, '05042017', 100),
('7501003340139', 'MAYONESA MCCORMICK', 'SP', '390G', 31, 35, 8, 24, '26042025', 99),
('7501003393081', 'BUFALO', 'SP', 'SALSA CLASICA 990G', 35, 37, 4, 12, '26052017', 100),
('7501005102667', 'ADES', 'SP', 'NARANJA 946ML', 19, 21, 4, 24, '22032017', 100),
('7501005102674', 'ADES', 'SP', 'MANZANA 946ML', 19, 21, 4, 12, '10012017', 100),
('7501005102681', 'ADES', 'SP', 'MANGO 1LT', 17, 19.5, 5, 24, '28022017', 100),
('7501005102698', 'ADES', 'SP', 'DURAZNO 946ML', 19, 21, 5, 24, '24032017', 100),
('7501005102728', 'ADES', 'SP', 'NATURAL 1LT', 27, 29, 5, 25, '26082050', 1000),
('7501005110242', 'MAIZENA', 'SP', 'NATURAL 95G', 10, 12, 5, 24, '27112050', 100),
('7501005110389', 'MAIZENA', 'SP', 'ORIGINAL 160G', 20, 22, 1, 100, '16032050', 1000),
('7501005129923', 'KNORK', 'SP', 'SOPA FIDEO', 7, 8, 4, 20, '25082017', 100),
('7501005129947', 'KNORK', 'SP', 'SOPA ESTRELLA 95G', 7, 8, 4, 20, '25082017', 100),
('7501005129954', 'KNORK', 'SP', 'SOPA DE LETRAS 95G', 7, 8, 4, 12, '25082017', 100),
('7501005134712', 'S CODITOS', 'SP', 'KNORR 95G', 7, 8.5, 5, 30, '05082017', NULL),
('7501005151955', 'MAYONESA HELLMANNS', 'SP', 'CLASICA 190G', 13, 14, 5, 24, '26072030', 100),
('7501005180306', 'KNORK', 'SP', '1 CUBO DE CALDO DE POLLO 11G', 1.8, 2, 8, 50, '25082019', 100),
('7501005180504', 'KNORK', 'SP', 'TOMATE 11G', 2, 2.5, 8, 50, '25082017', 100),
('7501006505689', 'HUNTS', 'HUNTS', 'HUNT WINGS', 43, 44, 1, 1001, '12032050', 1000),
('7501006510379', 'DEL MONTE', 'SP', 'SALSA VERDE TOREADA 220G', 11, 13.5, 4, 12, '26042018', 100),
('7501006513783', 'PURE DE TOMATE DEL MONTE', 'SP', 'NATURAL 1LT', 18, 19, 5, 12, '26062017', 100),
('7501006523959', 'SALSAS HUNTS', 'HUNTS', 'TRADICIONAL ', 17, 18, 1, 100, '12032050', 1000),
('7501006523973', 'SALSAS HUNTS', 'HUNTS', 'CUTRO QUESOS ', 20, 22, 1, 100, '12032050', 1000),
('7501006532746', 'DEL MONTE', 'DEL MONTE', 'ENSALADA DE VERDURAS', 8, 8, 1, 10, '01032050', 994),
('7501006582949', 'SALSAS HUNTS', 'HUNTS', 'ESTILO BOLOGNESA', 20, 22, 1, 100, '12032040', 1000),
('7501006584028', 'SALSA BBQ HUNTS', 'SP', 'ORIGINAL 620G', 43, 44, 4, 12, '26102050', 1001),
('7501006584035', 'HUNTS', 'HNTS', 'BBQ ORIGINAL', 24, 25, 1, 100, '12032050', 1000),
('7501006585100', 'SALSAS HUNTS', 'HUNTS', 'ESTILO BOLOGNESA', 25, 26, 1, 100, '12032050', 1000),
('7501006585216', 'CATSUP DEL MONTE', 'DEL MONTE', 'DE TOMATE 900G', 26, 39.5, 1, 5, '07032025', 99),
('7501006705942', 'ACE', 'SP', '250G', 7, 8.5, 5, 30, '05082023', 100),
('7501006713206', 'ZEST', 'SP', 'AQUA 180', 11, 13, 5, 10, '06082018', 100),
('7501006713343', 'ESCUDO', 'SP', 'ANTIBACTERIAL 180G', 11.5, 13.5, 10, 15, '06082016', 100),
('7501006713381', 'CAMAY', 'SP', 'CLASICO 180G', 10, 12, 5, 15, '06082018', 100),
('7501007445557', 'ACE', 'SP', '500G', 15, 22, 5, 24, '26082050', 100),
('7501007452876', 'SALVO', 'SP', 'LIMON 900G', 21, 22.5, 5, 24, '25082018', 100),
('7501007455730', 'ARIEL', 'SP', 'AROMA ORIGINAL 500G', 15, 29, 5, 25, '05082040', 100),
('7501007455761', 'ARIEL', 'SP', 'AROMA ORIGINAL 1KG', 32, 34, 5, 20, '05082021', 100),
('7501007701509', 'PETALO', 'SP', 'JUMBO 4PZS', 22, 24, 5, 24, '27082026', 100),
('7501007704302', 'PETALO', 'SP', 'SERVILLETA 100PZ', 10, 11, 5, 30, '01082026', 100),
('7501007809403', 'CALMEX', 'SP', 'ATUN ALETA AMARILLA EN ACEITE 140G', 9, 10, 5, 30, '26022020', 100),
('7501007829500', 'CALMEX', 'SP', 'SARDINA EN SALSA DE TOMATE 425G', 24, 25, 5, 24, '26052019', 100),
('7501008001387', 'ALL-BRAN', 'KELLOGGS', 'PASAS 285G', 40, 42, 2, 10, '020120501', 100),
('7501008004647', 'CHOCO KRISPIS', 'KELLOGG\'S', 'POPS 90G', 16, 18, 2, 12, '16022017', 100),
('7501008004661', 'FROOT LOOPS', 'KELLOGG\'S', '90G', 16, 18, 2, 12, '16012017', 100),
('7501008004715', 'CORN POPS', 'KELLOGG\'S', '100G', 16, 18, 2, 12, '22122016', 100),
('7501008004753', 'SPECIAL K', 'KELLOGG\'S', 'ORIGINAL 320G', 16, 18, 2, 12, '14022017', 100),
('7501008004777', 'ALL-BRAN', 'KELLOGG\'S', 'FLAKES 110G', 16, 18, 2, 10, '01042017', 100),
('7501008004791', 'ZUCARITAS', 'KELLOGG\'S', 'POWER BALLS 90G', 16, 18, 2, 12, '23092016', 100),
('7501008005064', 'FRUTELA', 'KELLOGGS', 'MANZANA 37G', 5, 8, 2, 12, '10012050', 100),
('7501008005071', 'FRUTELA', 'KELLOGGS', 'FRESA 37G', 5, 10, 5, 20, '21012050', 100),
('7501008005231', 'MEGA RICE KRISPIES TREATS', 'KELLOGGS', 'ARROZ INFLADO 37G', 7, 8, 5, 50, '27012050', 100),
('7501008005552', 'FRUTELA', 'KELLOGGS', 'MORA AZUL 37G', 5, 8, 2, 12, '27012050', 100),
('7501008005583', 'FRUTELA', 'KELLOGG\'S', 'PIÑA 37G', 5, 6, 5, 20, '27012017', 100),
('7501008005606', 'CLASICA', 'KELLOGG\'S', 'FRESA 39G', 5, 6, 2, 12, '11122016', 100),
('7501008005989', 'KRUNCHY GRANOLA', 'KELLOGG\'S', 'AVENA Y CHOCOLATE 35G', 5, 6, 5, 20, '21012017', 100),
('7501008006290', 'ALL-BRAN', 'KELLOGGS', 'FLAKES 300G', 40, 42, 2, 10, '02102050', 100),
('7501008006696', 'KRUNCHY GRANOLA', 'KELLOGG\'S', '35G', 5, 6, 5, 12, '15022017', 100),
('7501008006788', 'ZUCARITAS', 'KELLOGGS', '125G', 16, 18, 2, 12, '03022050', 100),
('7501008007365', 'FROOT FLOOPS', 'KELLOGGS', 'BARRA 18G', 5, 8, 2, 12, '27012050', 100),
('7501008010259', 'CORN POPS', 'KELLOGGS', '30G', 3, 6, 2, 12, '15022050', 100),
('7501008015261', 'CORN POPS', 'KELLOGGS', '210G', 30, 35, 2, 10, '16052050', 100),
('7501008015339', 'FROOT LOOPS', 'KELLOGGS', '180G', 35, 38, 2, 10, '13122050', 100),
('7501008015391', 'ALL-BRAN', 'KELLOGG´S', 'LECHE SABOR CHOCOLATE', 10, 13, 1, 10, '26022050', 1000),
('7501008015438', 'CHOCO KRISPIS', 'KELLOGG\'S', '310G', 36, 38, 2, 10, '10102017', 100),
('7501008015544', 'AMARANTO SABOR CHOCOLATE KELLOGG\'S', 'KELLOGG\'S', ' 27G', 7, 8.5, 5, 24, '17012017', 100),
('7501008018125', 'CHOCO KRISPIS', 'KELLOGS', '290G', 33, 35, 1, 100, '17032050', 1000),
('7501008019283', 'CHOCO KRISPÍS', 'KELLOGS', '135 G', 18, 18, 1, 100, '16032050', 1000),
('7501008019436', 'CHOCO KRIPSIS', 'KELLOGS', '450G', 55, 56, 1, 100, '17032050', 1000),
('7501008019443', 'CHOCO KRISPIS', 'KELLOGS', 'GRANOS DE ARROZ', 5, 6, 1, 100, '16032050', 100),
('7501008021439', 'EXTRA', 'KELLOGS', 'ARANDANO', 19, 20, 1, 100, '16032050', 1000),
('7501008022399', 'MEGA ZUCARITAS', 'KELLOGS', 'BARRA DE CREAL', 8, 8, 1, 100, '16032050', 100),
('7501008022405', 'FROOT LOOPS', 'KELLOGS', 'BARRA CON CEREAL', 8, 8, 1, 100, '16032050', 100),
('7501008027950', 'KELLOGS ', 'KELLOGS', 'MEZCLADITOS', 17, 18, 1, 100, '16032050', 1000),
('7501008028063', 'ZUCARITAS', 'KELLOGS', 'GALLETAS', 9, 10, 1, 100, '16032050', 100),
('7501008028094', 'FROOT LOOPS', 'KELLOGS', 'GALLETAS', 9, 10, 1, 10, '16032050', 100),
('7501008028100', 'CHOCO KRISPIS', 'KELLOGS', 'GALLETAS', 9, 10, 1, 100, '16032050', 100),
('7501008035689', 'KELLOGS', 'KELLOGS', 'EXTRA DELICE', 8, 10, 1, 100, '16032050', 100),
('7501008037744', 'FROOT LOOPS', 'KELLOGGS', '25G', 3, 6, 2, 12, '18112050', 100),
('7501008042236', 'CHOCO ZUCARITAS', 'KELLOGGS', 'MALVAVISCOS', 43, 45, 2, 10, '06112050', 100),
('7501008042793', 'EXTRA', 'KELLOGGS', 'ARANDANOS 310G', 55, 56, 2, 10, '10042050', 100),
('7501008042984', 'ZUCARITAS', 'KELLOGGS', '260G', 30, 32, 2, 10, '07072050', 100),
('7501008044223', 'CHOCO KRISPIS', 'KELLOGG\'S', '30G', 3, 4.5, 2, 12, '16032017', 100),
('7501008051924', 'CHOCO KRISPIS', 'KELLOGG´S', 'LECHE SABOR CHOCOLATE', 10, 13, 1, 10, '26022050', 1000),
('7501008052495', 'KELLOGGS SPECIAL', 'KELLOGGS', 'ORIGINAL 260G', 47, 48, 2, 20, '2842050', 1000),
('7501008052617', 'ALL-BRAN', 'KELLOGGS', 'PASAS BARRA 40G', 5, 8, 5, 20, '21012050', 100),
('7501008064535', 'ALL-BRAN', 'KELLOGGS', 'MANZANA CANELA 37G', 5, 8, 2, 12, '27112050', 100),
('7501008070833', 'KELLOGGS ESPECIAL COSECHA ROJA', 'KELLOGGS', 'FRESA 24G', 5, 8, 5, 20, '21012052', 100),
('7501008072301', 'ALL-BRAN', 'KELLOGG´S', 'LECHE SABOR VAINILLA', 10, 13, 1, 10, '26022050', 1000),
('7501008072509', 'CHOCO KRISPIS', 'KELLOGGS', '19G', 5, 8, 5, 20, '21012050', 100),
('7501008074718', 'ALL-BRAN', 'KELLOGGS', 'FRESA BARRA 37G', 5, 8, 5, 20, '21012050', 100),
('7501008075074', 'ALL-BRAN', 'KELLOGGS', 'CHOCOLATE BARRA 40G', 5, 8, 5, 20, '21012050', 100),
('7501008076521', 'RICE KRISPIES TREATS', 'KELLOGGS', 'ARROZ INFLADO 22G', 5, 8, 5, 20, '1752050', 100),
('7501008082836', 'ZUCARITAS', 'KELLOGGS', 'BARRA 21G', 5, 8, 2, 12, '27012050', 100),
('7501008087152', 'CORN FLAKES', 'KELLOGS', 'EMPANIZADOR', 19, 20, 1, 100, '16032050', 100),
('7501008094280', 'ZUCARITAS', 'KELLOGGS', '30G', 3, 6, 2, 12, '17102050', 100),
('7501008101049', 'CORN FLAKES', 'KELLOGG\'S', '150G', 14, 16, 2, 10, '01072030', 100),
('7501009222729', 'GILLETE', 'GILLETE', 'PRESTOBARBA 2 ', 20, 20, 1, 10, '05032050', 99),
('7501010504258', 'PLATO PH4', 'SO', 'PLATO TERMOUSO 25 PIEZAA', 10, 12, 1000, 10, '31082022', 109),
('7501010509208', 'PLATO TERMOUSO', 'SP', '20 PZA NO9D', 10, 12.5, 4, 12, '26082020', 100),
('7501011101456', 'SABRITAS', 'SP', 'ORIINAL', 10, 13, 10, 10, '17022050', 10),
('7501011101463', 'SABRITAS', 'SP', 'ADOBADAS', 10, 13, 1, 10, '17022050', 9),
('7501011101678', 'SABRITAS', 'SP', 'LIMON', 10, 13, 1, 10, '17022050', 10),
('7501011102095', 'RUFFLES', 'SO', 'ORIGINAL', 10, 13, 1, 10, '17022050', 10),
('7501011104099', 'RUFFLES', 'SP', 'QUESO', 10, 13, 10, 10, '17022050', 41),
('7501011110335', 'FRITOS', 'SABRITAS', 'LIMON Y SAL', 12, 12, 10, 10, '18022050', 10),
('7501011111028', 'RANCHERITOS', 'SABRITAS', 'BOTANA DE MAIZ', 10, 12, 10, 10, '18022050', 100),
('7501011112254', 'FRITOS', 'SABRITAS', 'CHORIZO Y CHIPOTLE', 10, 12, 10, 10, '18022050', 100),
('7501011112438', 'PAKE TAXO', 'SP', 'BOTANERO', 10, 12, 10, 10, '17022050', 10),
('7501011114623', 'PAKE TAXO', 'SP', 'QUEXO', 10, 12, 10, 10, '17022040', 10),
('7501011116252', 'FRITOS', 'SABRITAS', 'CHILES Y LIMON', 10, 12, 10, 10, '18022050', 10),
('7501011118119', 'SABRITAS', 'SABRITAS', 'CREMA Y ESPECIAS', 12, 13, 1, 100, '15032050', 100),
('7501011123380', 'DORITOS', 'SP', 'PIZZEROLAS', 10, 12, 1, 10, '17022050', 10),
('7501011123588', 'DORITOS', 'SP', 'NACHO', 10, 12, 10, 10, '17022050', 41),
('7501011123595', 'DORITOS', 'SP', 'DIABLO', 10, 12, 1, 10, '17022050', 10),
('7501011123878', 'DORITOS', 'SP', 'INCOGNITA', 10, 12, 10, 10, '17022050', 10),
('7501011127012', 'TOSTITOS', 'SP', 'SALSA VERDE', 10, 10, 1, 8, '17022050', 10),
('7501011130272', 'DORITOS', 'SO', 'XTRA FLAMIN HOT', 10, 12, 10, 10, '17022050', 10),
('7501011130975', 'CHEETOS', 'SABRITAS', 'TORCIDITOS 145G', 24, 26, 10, 10, '18022050', 100),
('7501011131064', 'DORITOS', 'SABRITAS', 'NACHO 146G', 24, 26, 1, 10, '18022050', 100),
('7501011133181', 'CHEETOS', 'SO', 'SHOT', 5, 6, 1, 10, '17022050', 10),
('7501011137431', 'SABRITAS', 'SP', 'HABANERO', 10, 13, 10, 120, '1022050', 10),
('7501011142299', 'CRUJITOS', 'SP', 'QUESO Y CHILE', 1, 11, 10, 10, '17022050', 10),
('7501011143258', 'SABRITAS RECETA CRUJIENTE', 'SP', 'JALAPEÑO 170G', 33, 35, 1, 10, '18022050', 10),
('7501011143586', 'CHETOS', 'SP', 'TORCIDITOS', 8, 10, 1, 11, '17022050', 10),
('7501011143739', 'SABRITAS', 'SP', 'XTRA FLAMIN HOT', 10, 13, 10, 10, '17022050', 10),
('7501011143753', 'CHETOS', 'SP', 'XTRA FLAMIN HOT', 8, 10, 1, 10, '17022050', 10),
('7501011143999', 'CHETOS', 'SP', 'NACHO', 8, 10, 10, 10, '17022050', 10),
('7501011144460', 'PAKE TAXO', 'SP', 'XTRA FLAMIN HOT', 10, 12, 1, 10, '17022040', 10),
('7501011145764', 'CHURRUMAIS', 'SABRITAS', 'FLAMAS', 10, 10, 1, 10, '18022050', 100),
('7501011148963', 'PAKE TAXO', 'SP', 'MEZCLADITO', 10, 12, 1, 10, '17022050', 10),
('7501011149205', 'SABRITONES', 'SP', 'BOTANA', 10, 12, 1, 10, '17022050', 10),
('7501011151079', 'CHICHARRON DE CERDO', 'SP', 'SABRITAS', 11, 12, 1, 10, '17022050', 10),
('7501011151086', 'SABRITONES', 'SP', '160G', 25, 27, 10, 10, '17022050', 10),
('7501011154902', 'PAKE TAXO', 'SABRITAS', 'MEZCLADITO 280G', 37, 39, 1, 10, '18022050', 10),
('7501011155008', 'PAKE TAXO', 'SABRITAS', 'QUEXO 215G', 36, 39, 10, 10, '18022050', 10),
('7501011155022', 'PAKE TAXO', 'SABRITAS', 'FLAMIN HOT 228G', 34, 39, 1, 10, '18022050', 10),
('7501011155343', 'CHETOS', 'SP', 'PALOMITAS', 8, 10, 10, 10, '17022050', 10),
('7501011159242', 'SABRITAS', 'SP', 'RECETA CRUJIENTE FLAMIN HOT', 10, 13, 10, 10, '17022050', 10),
('7501011159266', 'SABRITAS RECETAS CRUJIENTE', 'SABRITAS', 'FLAMIN HOT 170G', 33, 35, 1, 10, '18022050', 10),
('7501011163706', 'DORITOS', 'SP', '3D', 10, 12, 10, 10, '17022050', 10),
('7501011165687', 'SABRITAS', 'SABRITAS', 'ORIGINAL 171G', 33, 35, 1, 10, '18022050', 10),
('7501011165717', 'CHETOS', 'SP', 'COLMILLOS', 8, 10, 1, 10, '17022050', 10),
('7501011167070', 'BE LIGTH', 'PEPSI', 'MANGO 1.5L', 17, 18, 1, 410, '04032050', 10000),
('7501011167650', 'SABRITAS ORIGINAL', 'SABRITAS', '105G ', 24, 26, 1, 10, '18022050', 10),
('7501011181809', 'BE LIGHT', 'SP', 'JAMAICA 1.5L', 15, 16, 1, 100, '17032050', 100),
('7501011312623', 'CAMPBELLZ', 'SP', 'CREMA CHAMPIÑONES 420G', 24, 25.5, 5, 24, '30092017', 100),
('7501013100037', 'JUMEX', 'SP', 'MANGO LATA 500ML', 10, 12, 5, 12, '18012018', 100),
('7501013100051', 'JUMEX', 'SP', 'DURAZNO LATA 500ML', 10, 12, 5, 12, '27012018', 100),
('7501013100198', 'JUMEX', 'SP', 'MANZANA LATA 500ML', 10, 12, 4, 12, '17012018', 100),
('7501013101263', 'JUMEX', 'JUMEX', 'MANZANA 500ML', 12, 12, 1, 1000, '11032050', 10001),
('7501013101294', 'JUMEX', 'JUMEX', 'DURAZNO 500ML', 10, 12, 1, 100, '11032050', 1000),
('7501013122039', 'JUMEX', 'SP', 'MANGO 1LT', 19, 22, 4, 12, '23102050', 100),
('7501013122053', 'JUMEX', 'JUMEX', 'DURAZNO 1LT', 19, 22, 4, 12, '09102050', 100),
('7501013122114', 'JUMEX ', 'JUMEX', 'PIÑA 1LT', 20, 22, 1, 100, '11032050', 1000),
('7501013122145', 'JUMEX ', 'JUMEX', 'UVA 1LT', 20, 22, 1, 100, '11032050', 1000),
('7501013122190', 'JUMEX', 'SP', 'MANZANA 1LT', 19, 22, 4, 12, '15102050', 100),
('7501013132199', 'JUMEX', 'SP', 'MANZANA LATA 1LT', 18, 20, 5, 24, '14112017', 100),
('7501013138184', 'JUMEX', 'SP', 'ARANDANO 1LT', 20, 25, 4, 12, '07022050', 100),
('7501013174144', 'JUMEX', 'JUMEX', 'UVA 450ML', 12, 13, 1, 100, '11032050', 10001),
('7501013174199', 'JUMEX', 'JUMEX', 'MANZANA 450ML', 10, 13, 1, 100, '11032050', 10000),
('7501014300405', 'CHOCOLATE IBARRA', 'SP', 'CAJA 630G', 45, 49, 2, 10, '09092017', 100),
('7501014300733', 'CHOCOLATE IBARRA', 'SP', 'TABLILLA 90G', 8, 10, 10, 60, '17092017', 100),
('7501014301297', 'CHOCOCHOCO', 'SP', 'SABOR CHOCOLATE 350G', 27, 29.5, 5, 24, '22022018', 100),
('7501017003006', 'LA COSTEÑA', 'SP', 'JALAPEÑOS EN ESCABECHE 780G', 30, 33, 5, 24, '07012025', 100),
('7501017003020', 'LA COSTEÑA', 'SP', 'RAJAS 800G', 27, 28, 5, 24, '18022019', 100),
('7501017004003', 'LA COSTEÑA', 'SP', 'JALAPEÑOS 380G', 20, 22, 5, 24, '12082050', 100),
('7501017004027', 'LA COSTEÑA', 'SP', 'RAJAS 380G', 20, 22, 5, 24, '22092050', 100),
('7501017004270', 'LA COSTEÑA ', 'LA COSTEÑA', 'BAYOS REFRITOS', 14, 15, 1, 100, '12032050', 1000),
('7501017004294', 'LA COSTEÑA', 'SP', 'FRIJOLES NEGROS ENTEROS 560G', 11, 12, 5, 24, '28042019', 100),
('7501017004362', 'LA COSTEÑA', 'SP', 'FRIJOLES BAYOS ENTEROS 560G', 11, 13, 4, 24, '28062050', 100),
('7501017004423', 'LA COSTEÑA', 'SP', 'FRIJOLES NEGROS REFRITOS 580G', 13, 15, 5, 24, '14042050', 98),
('7501017005000', 'LA COSTEÑA', 'SP', 'JALAPEÑOS ENTEROS 220G', 10, 12, 4, 24, '08082025', 100),
('7501017005024', 'LA COSTEÑA', 'SP', 'RAJAS 220G', 10, 12, 4, 26, '25092050', 100),
('7501017005031', 'LA COSTEÑA', 'LA COSTEÑA', 'CHIPOTLES ADOBADOS', 19, 20, 1, 100, '12032060', 100),
('7501017005611', 'LA COSTEÑA', 'LA COSTEÑA', 'PURE DE TOMATE 210G', 7, 8, 1, 100, '12032050', 1000),
('7501017006014', 'LA COSTEÑA', 'SP', 'RAJAS 105G', 6, 7, 5, 30, '22072025', 100),
('7501017006021', 'LA COSTEÑA', 'SP', 'CHILES CHIPOTLES 105G', 9, 10, 5, 24, '26052025', 100),
('7501017364596', 'DELSEX MAX', 'SP', '125 SERVILLETAS', 7, 8, 4, 30, '27082026', 100),
('7501017375714', 'CISNE', 'SP', 'PAPEL HIGIENICO 4PZ', 8, 11, 5, 24, '27082026', 1),
('7501017379620', 'KLEENEX', 'SP', '70PAÑUELOS', 16, 18, 3, 12, '02092026', 100),
('7501018310011', 'LA MODERNA', 'LA MODERNA ', 'FIDEO 0 200G', 4, 6.5, 10, 30, '25082050', 100),
('7501018310028', 'LA MODERNA ', 'LA MODERNA ', 'FIDEO 1', 6, 6.5, 1, 10, '26022050', 1000),
('7501018310035', 'LA MODERNA ', 'LA MODERNA ', 'FIDEO 2', 5, 6.5, 1, 10, '26022050', 100),
('7501018310042', 'LA MODERNA ', 'LA MODERNA ', 'TALLARIN 1', 4, 6.5, 1, 10, '26022050', 1000),
('7501018310059', 'LA MODERNA ', 'LA MODERNA ', 'TALLARIN 2', 5, 6.5, 1, 10, '26022050', 1000),
('7501018310097', 'LA MODERNA', 'SP', 'MACARRONES', 4, 6.5, 5, 30, '25082050', 100),
('7501018310103', 'LA MODERNA', 'SP', 'SPAGHETTI', 4, 5, 10, 40, '02042019', 100),
('7501018310233', 'LA MODERNA', 'SP', 'LENGUA', 4, 6.5, 5, 30, '25082050', 100),
('7501018310240', 'LA MODERNA', 'SP', 'OJITO', 4, 6.5, 5, 30, '25082050', 100),
('7501018310257', 'LA MODERNA', 'SP', 'LETRA 200G', 4, 5, 5, 30, '25082019', 100),
('7501018310264', 'LA MODERNA', 'SP', 'MUNICION 200G', 4, 6.5, 5, 30, '25082050', 100),
('7501018310295', 'LA MODERNA', 'SP', 'LENTEJA', 4, 6.5, 5, 30, '25022050', 100),
('7501018310318', 'LA MODERNA', 'SP', 'ESTRELLA 200G', 4, 6.5, 5, 30, '25082025', 100),
('7501018310516', 'LA MODERNA', 'SP', 'CODO 1 200G', 4, 5, 5, 30, '25082019', 100),
('7501018310523', 'LA MODERNA', 'SP', 'CODO 2 200G', 4, 5, 5, 30, '25082019', 100),
('7501018310530', 'LA MODERNA', 'SP', 'CODO 3 200G', 4, 6.5, 5, 30, '25082050', 100),
('7501018310547', ' MODERNA', 'SP', 'CODO 4', 4, 6.5, 10, 30, '01062050', 100),
('7501018310554', 'LA MODERNA', 'SP', 'CARACOL 1 200G', 4, 5, 5, 30, '25082019', 100),
('7501018310561', 'LA MODERNA', 'SP', 'CARACOL 2 200G', 4, 5, 5, 30, '25082017', 100),
('7501018310578', 'LA MODERNA ', 'LA MODERNA ', 'CARACOL 3', 5, 6.5, 1, 10, '26022050', 1000),
('7501018310585', 'LA MODERNA', 'SP', 'ENGRANE 200G', 4, 6.5, 5, 30, '25082050', 100),
('7501018310608', 'LA MODERNA', 'LA MODERNA ', 'PLUMA', 4, 6.5, 10, 40, '04052050', 100),
('7501018310721', 'LA MODERNA', 'SP', 'MOÑO 200G', 4, 5, 5, 30, '25082019', 100),
('7501018310745', 'LA MODERNA ', 'LA MODERNA ', 'ALMEJA', 5, 6.5, 1, 10, '26022050', 1000),
('7501018310752', 'LA MODERNA', 'SP', 'MOÑITO 200G', 4, 6.5, 5, 30, '13052050', 100),
('7501018310776', 'LA MODERNA', 'SP', 'SOMBRERO', 4, 5, 5, 30, '25082019', 100),
('7501018320348', 'LA MODERNA ', 'LA MODERNA ', 'SPAGHETTI', 5, 6.5, 1, 10, '26022050', 100),
('7501018320515', 'LA MODERNA ', 'LA MODERNA ', 'CODO 2', 5, 6.5, 1, 10, '26022050', 100),
('7501019006104', 'SABA', 'SP', 'INTIMA SIN ALAS 10PZS', 13, 15, 5, 12, '27082026', 100),
('7501019006623', 'SABA', 'SP', 'BUENAS NOCHES CON ALAS 8PZS', 22, 24, 4, 12, '27082026', 100),
('7501019007606', 'SABA', 'SP', 'CONFORT MANZANILLA NOCTURNA 8PZS', 17, 18.5, 5, 12, '27082026', 100),
('7501020515343', 'LECHE LALA', 'LALA', 'ENTERA  1LT', 14, 16, 5, 24, '17112016', 100),
('7501020515350', 'LECHE LALA', 'LALA', 'LIGHT 1LT', 15, 17.5, 5, 24, '08012017', 100),
('7501020515398', 'LECHE LALA', 'LALA', 'DESLACTOSADA 1LT', 20, 23, 5, 24, '12012050', 100),
('7501020540666', 'NUTRILECHE', 'SP', '1LT', 12, 16, 5, 24, '18112025', 99),
('7501020544398', 'NUTRI', 'NUTRI', 'DESLACTOSADA', 17, 18, 1, 1000, '11032050', 1000),
('7501020550733', 'LALA', 'LALA', 'ENTERA 1.5L', 28, 29.5, 1, 100, '11032050', 1000),
('7501020553079', 'LALA YOMI', 'LALA', 'LECHE SABOR CHOCOLATE', 9, 10, 1, 10, '26022050', 1000),
('7501020553093', 'LALA ', 'LALA', 'YOMI', 8, 10, 1, 100, '11032050', 1000),
('7501020556001', 'NUTRI', 'NUTRI', '2L', 29, 30, 1, 100, '11052050', 1000),
('7501020560695', 'BOREALPLUS', 'MILECHE', '1L', 14, 15, 1, 100, '11032080', 1000),
('7501021900063', 'SAL ELEFANTE', 'SP', 'GRANO 1KG', 10, 14, 5, 30, '20062026', 100),
('7501022009321', 'PEPSI', 'PEPSI', '1.75L', 17, 18, 10, 1000, '04032050', 10000),
('7501022010761', 'JUMEX NARANJADA', 'PEPSI', 'FRUTZZO', 10, 12, 0, 110, '04032050', 10000),
('7501022010877', 'JUMEX MANDARINADA', 'PEPSI', 'MINERALIZADA', 17, 18, 1, 100, '04032050', 10000),
('7501022011010', '7UP', 'PEPSI', 'LIMONADA MINERALIZADA', 10, 12, 1, 1010, '04032050', 10000),
('7501022012185', 'GARCI CRESPO', 'PEPSI', 'AGUA MINERALIZADA', 10, 12, 1, 101, '04032050', 10000),
('7501022013861', 'PEPSI', 'PEPSI', '355ML', 5, 5, 1, 1000, '04032050', 10000),
('7501022013885', '7UP', 'PEPSI', '400ML', 7, 8, 1, 100, '04032050', 10000),
('7501022014042', 'PEPSI', 'PEPSI', '1.25L RETORNABLE', 14, 15, 1, 100, '04032060', 10000),
('7501022014363', 'LIPTON', 'PEPSI', 'JAMICA 600ML', 12, 13, 1, 100, '04032050', 10000),
('7501022014455', 'MIRINDA', 'PEPSI', '1.75L', 17, 18, 1, 100, '04032050', 10000),
('7501022014479', 'MANZANITA SOL', 'PEPSI', '1.75L', 17, 18, 1, 1000, '04032050', 10000),
('7501022014486', 'SANGRIA CASERA', 'PEPSI', '1.75L', 17, 18, 1, 1000, '04032056', 10000),
('7501022014585', '7UP', 'PEPSI', '600ML', 10, 12, 110, 1000, '04032050', 10000),
('7501022014615', '7UP', 'PEPSI', '1.75L', 17, 18, 1, 1000, '04032050', 10000),
('7501023311058', 'SAN MARCOS', 'SAN MARCOS', 'RAJAS DE JALPEÑOS', 6, 7, 1, 100, '12032050', 100),
('7501023314028', 'SAN MARCOS', 'SP', 'CHILES LARGOS 400G', 18, 26, 5, 24, '26062025', 97),
('7501023318033', 'SAN MARCOS', 'SP', 'CHILES CHIPOTLES 380G', 35, 39, 5, 24, '26082050', 100),
('7501023318040', 'SAN MARCOS', 'SP', 'CHILES CHIPOTLES 215G', 18, 20, 5, 24, '26102025', 100),
('7501023318057', 'SAN MARCOS', 'SP', 'CHILES CHIPOTLES 100G', 9, 11, 10, 30, '11112025', 100),
('7501023318088', 'SAN MARCOS', 'SAN MARCOS', 'CHIPOTLES ADOBADOS', 20, 22, 1, 100, '12032050', 100),
('7501023321026', 'SAN MARCOS', 'SP', 'PIÑA REBANADA EN ALMIBAR 800G', 27, 28.5, 4, 24, '26062018', 100),
('7501023322023', 'SAN MARCOS', 'SP', 'REBANADAS DE MANGO EN ALMIBAR 800G', 32, 33, 4, 12, '01062018', 100),
('7501023348047', 'SAN MARCOS', 'SAN MARCOS', 'SALSA CHIPOTLE', 16, 17, 1, 100, '12032050', 99),
('7501024579280', 'HERSHEY´S', 'SP', 'LECHE SABOR FRESA', 12, 13, 1, 10, '26022050', 1000),
('7501024579327', 'HERSHEY´S', 'KELLOGG´S', 'LECHE SABOR CHOLATE', 10, 13, 10, 10, '26022050', 999),
('7501025403027', 'PINOL', 'SP', '500 ML', 9.5, 14, 10, 15, '06082050', 100),
('7501025403485', 'PINOL', 'SP', '828ML', 16, 24.5, 5, 15, '06082050', 100),
('7501025413002', 'ENSUEÑO MAX ', 'SP', 'FRESCURA PRIMAVERAL', 12.5, 21, 5, 10, '31122050', 1000),
('7501025413187', 'PINOL ', 'SP', 'ROPA 500 ML', 10, 11, 1, 5, '06082018', 100),
('7501025414153', 'ENSUEÑO ', 'SP', 'BEBE CON ALOE 850ML', 12.5, 14.5, 5, 10, '31082018', 100);
INSERT INTO `tbl_productos` (`codigo_barras`, `nombre_producto`, `Proveedor`, `descripcion`, `precio_compra`, `precio_venta`, `stock_min`, `stock_max`, `caducidad`, `cantidad_existente`) VALUES
('7501025414207', ' ENSUEÑO', 'SP', 'MAX FRESCA ARMONIA 850ML', 12.5, 21, 5, 10, '31122050', 1000),
('7501025423889', 'EFICAZ', 'SO', 'LAVATRASTES', 5, 5, 0, 11, '05032050', 1000),
('7501026004605', 'ROMA', 'SP', '1KG', 24, 38, 5, 24, '25082058', 99),
('7501026004612', 'ROMA', 'SP', '500G', 12, 18, 5, 24, '26082050', 100),
('7501026004629', 'ROMA', 'SP', '250G', 5, 9, 10, 40, '05082050', 100),
('7501026005374', 'JABON ZOTE', 'SP', 'BLANCO', 16, 17, 1, 1020, '05032050', 1000),
('7501026005381', 'JABON ZOTE', 'SP', 'BLANCO', 8, 8.5, 1, 100, '05032050', 1000),
('7501026005671', 'JABON ZOTE', 'SP', '400G', 16, 17, 1, 10, '05032050', 100),
('7501026005688', 'JABON ZOTE ', 'SP', 'ROSA', 8, 8.5, 1, 100, '05032050', 1000),
('7501026005985', 'JABON ZOTE', 'SP', 'ROSA', 4, 5, 1, 100, '05032050', 1000),
('7501026026546', 'FOCA', 'SP', '1KG', 27, 29, 5, 24, '25082018', 100),
('7501026026560', 'FOCA', 'SP', '500G', 13, 19, 5, 24, '26082050', 100),
('7501026026577', 'FOCA', 'SP', '250G', 5, 10, 5, 30, '05082050', 100),
('7501026027536', 'BLANCA NIEVES', 'SP', '1KG', 24, 38, 5, 24, '25082050', 100),
('7501026027543', 'BLANCA NIEVES', 'SP', '500G', 11, 18, 5, 30, '05082050', 100),
('7501026027550', 'BLANCA NIEVES', 'SP', '250 G', 4.5, 9, 5, 30, '06082050', 100),
('7501026905490', 'OSRAM', 'SP', '72W', 19, 20, 5, 25, '26082020', 100),
('7501026905834', 'OSRAM', 'SP', 'LAMPARA', 40, 42, 1, 100, '17032050', 1000),
('7501030409854', 'NITO', 'SP', '2 PACK', 14, 15, 10, 10, '14022050', 1009),
('7501030417804', 'BIG DADDY', 'SP', 'GALLETA DE AVENA', 8, 10, 1, 10, '16022050', 10),
('7501030417811', 'AHORRA PACK', 'S´P', 'POLVORENES 3 TUBOS', 18, 20, 10, 20, '16022050', 10),
('7501030417989', 'KRONK', 'SP', 'GALLETA TIPO GAUFRETTE', 5, 6, 10, 10, '16022050', 7),
('7501030418276', 'SNOW BALLS', 'SP', 'MALVAVISCO', 12, 15, 10, 10, '15022050', 1),
('7501030418399', 'DONITAS ', 'SP', 'ESPOLVOREADAS', 10, 14, 10, 10, '14022050', 1010),
('7501030418412', 'LECHE NITO', 'SP', 'CHOCOLATE', 8, 10, 10, 10, '14022060', 0),
('7501030418504', 'MAXITUBO', 'SP', 'PRINCIPE', 19, 23, 10, 10, '16022050', 10),
('7501030418528', 'MAXITUBO', 'SP', 'TRIKITRAKES', 19, 23, 10, 10, '16022050', 10),
('7501030418542', 'CANELITAS', 'MARINELA', 'MAXITUBO', 19, 23, 1, 100, '10032050', 1000),
('7501030418559', 'POLVORONES', 'MARINELA', 'MAXITUBO', 20, 23, 1, 100, '10032050', 1000),
('7501030418689', 'MUFFIN', 'SP', 'PAN DULCE', 10, 12, 1, 10, '16022050', 10),
('7501030418726', 'MINI DOUBLE LAYER', 'SP', 'CON CAJETA', 3, 4, 10, 10, '16022050', 10),
('7501030419020', 'CHOCO ROLES', 'MARINELA', 'MINI', 4, 5, 1, 100, '10032050', 1000),
('7501030419037', 'MINI GANSITO', 'SP', 'PASTELITO', 4, 5, 10, 10, '15022050', 1),
('7501030419464', 'PAPATINAS', 'BARCEL', ' CHILIX', 6, 7, 1, 100, '15032050', 1000),
('7501030420262', 'DONERS', 'SP', 'PAN DULCE', 10, 15, 10, 10, '15022050', 1),
('7501030420859', 'MANTECADAS BIMBO', 'CP', 'CHOCOLATE', 16, 20, 10, 10, '14022050', 10),
('7501030423607', 'MINI BARRITAS', 'SP', 'FRESA', 4, 5, 10, 10, '16022050', 10),
('7501030424345', 'MULTI GRANO', 'SP', 'NUEZ', 6, 8, 10, 100, '16022050', 10),
('7501030425243', 'SEMITAS', 'SP', 'SOBOR PILONCILLO', 12, 16, 10, 10, '16022050', 100),
('7501030426196', 'TIRAS DORADITAS', 'SP', 'SABOR CAJETA', 12, 13, 10, 10, '16022040', 100),
('7501030426387', 'MINI ROCKO', 'SP', 'GALLETA SANDWICH', 1, 2, 10, 10, '15022060', 1),
('7501030426653', 'BIMBO CONTIGO', 'SP', 'PAN BLANCO', 20, 25, 10, 10, '14022050', 1),
('7501030426905', 'MINI PAY', 'SP', 'PIÑA', 13, 17, 10, 20, '15022032', 1),
('7501030426912', 'MINI PAY', 'SP', 'NUEZ', 13, 17, 10, 17, '15022021', 10000),
('7501030427193', 'BARRITAS', 'SP', 'FRESA', 8, 10, 1, 1, '16022050', 10),
('7501030427209', 'BARRITAS', 'MARINELA', 'PIÑA', 8, 10, 1, 100, '10032050', 1000),
('7501030428527', 'TROPICOCOS', 'SP', 'GALLETAS CON COCO', 6, 8, 10, 10, '15022050', 1),
('7501030429272', 'PANQUECITOS', 'SP', 'COBOR CHOCOLATE', 18, 20, 10, 10, '15022060', 10),
('7501030429319', 'TWINKIES', 'SP', 'SABOR VAINILLA', 11, 14, 10, 10, '16022050', 10),
('7501030429340', 'TWINKIES', 'SP', 'CHOCOLATE', 11, 14, 10, 10, '16022050', 10),
('7501030429494', 'DONUTS', 'SP', '1 PIEZA', 4, 8, 10, 10, '14082050', 1),
('7501030430421', 'TORTILLINAS', 'SP', '30 PIEZAS', 24, 30, 10, 10, '14022050', 10),
('7501030431183', 'SUAVI CREMAS', 'MARINELA', 'VAINILLA', 8, 10, 1, 100, '100320550', 1000),
('7501030431190', 'SUAVICREMAS', 'MARINELA', 'FRESA', 8, 10, 1, 100, '10032050', 1000),
('7501030431206', 'SUAVI CREMAS', 'MARINELA', 'CHOCOLATE', 8, 10, 1, 110, '10032050', 1000),
('7501030433453', 'NAPOLITANO', 'SP', 'PASTELITO', 13, 17, 10, 10, '15022050', 1),
('7501030444954', 'ANIMALITOS', 'LARA', 'KARAMELO', 10, 12, 1, 100, '10032050', 1000),
('7501030452553', 'BIMBO', 'BIMBO', 'ARTESANO', 29, 35, 1, 100, '10032050', 1000),
('7501030452577', 'TRIKI-TRAKES', 'SP', 'BITES', 8, 10, 10, 10, '16022050', 101010),
('7501030452805', 'CANELITAS', 'SP', 'BITES', 8, 10, 10, 10, '16022021', 10),
('7501030453147', 'MANTE CHOX', 'BIMBO', '3 PIEZAS', 11, 14, 1, 100, '10032050', 1000),
('7501030455707', 'OREJITAS', 'SP', 'SABOR CASERO', 8, 10, 1, 10, '16022050', 10),
('7501030456124', 'MANTECADAS', 'SP', 'SABOR CHOCOLATE', 16, 17, 10, 10, '16022050', 10),
('7501030456322', 'MANTECADAS ', 'SO', 'SABOR MANTEQUILLA', 13, 17, 10, 10, '16022040', 10),
('7501030456971', 'MOBI', 'S¿', 'GALLETA', 5, 6, 10, 11, '15022050', 1),
('7501030456988', 'GALLETA', 'SP', 'SABOR AVENA', 5, 7, 10, 10, '16022050', 10),
('7501030457008', 'TIRAS DORADITAS', 'SP', 'PAN DULCE', 4, 7, 10, 10, '16022050', 100),
('7501030457183', 'MAXITUBO', 'SP', 'MINI BARRITAS PIÑA', 19, 23, 10, 10, '16022021', 10),
('7501030457190', 'MAXITUBO', 'SP', 'MINI BARRITAS FRESA', 19, 23, 10, 10, '16022050', 1010),
('7501030458814', 'POLVORONCITOS', 'SP|', 'CASEROS', 8, 8, 10, 10, '16022050', 10),
('7501030458883', 'SALADAS CLASICAS', 'SP', 'GALLETAS SALADAS', 10, 13, 10, 10, '16022050', 10),
('7501030459736', 'POP', 'BARCEL', 'KARAMELADAS', 15, 18, 1, 100, '15032050', 100),
('7501030462859', 'PRINCIPE', 'SP', 'AVELLANA TENTACION', 10, 14, 10, 10, '17022050', 10),
('7501030463719', 'DELICIOSAS', 'SP', 'CON CHISPAS', 10, 17, 10, 10, '16022050', 10),
('7501030463726', 'DELICIOSAS', 'SP', 'CHISPAS A SABOR CHOCOLATE', 10, 12, 10, 10, '15022040', 1),
('7501030463733', 'DELICIOSAS', 'SP', 'VAINILLA', 16, 17, 10, 10, '16022050', 10),
('7501030463740', 'DELICIOSAS', 'S', 'SABOR VAINILLA', 10, 12, 10, 10, '15022021', 1),
('7501030466949', 'BIMBO EMPANIZADOR', 'SP', 'HOJUELA DE MAIZ', 16, 19, 10, 10, '14022050', 10),
('7501030467090', 'BIMBO', 'BIMBO', 'CERO CERO', 33, 40, 1, 10, '10032050', 1000),
('7501030469827', 'LITTLE BITES', 'SP', 'CHISPAS DE CHOCOLATE', 8, 10, 10, 10, '14022050', 1010),
('7501030472698', 'BIMBUÑUELOS', 'SP', '6P', 13, 16, 10, 10, '14022050', 1010),
('7501030473824', 'PRINCIPE', 'SP', 'SABOR LIMON', 10, 14, 10, 10, '17022050', 10),
('7501030474227', 'DONAS ', 'S´P', 'AZUCARADAS', 10, 16, 10, 10, '14022050', 1010),
('7501030474357', 'PANCHONCITOS', 'SP', 'SABOR NATA', 13, 16, 10, 10, '16022040', 10),
('7501030474739', 'TOSTADAS ONDULADAS', 'BIMBO', '324G', 19, 24, 1, 100, '10032050', 10000),
('7501030475132', 'LECHE GANSITO', 'SP', '236ML', 10, 10, 10, 10, '15022050', 1000),
('7501030475514', 'MANTECADAS BIMBO', 'SP', 'NUEZ', 16, 20, 10, 10, '14022050', 10),
('7501030475521', 'MANTECADAS BIMBO', 'SP', 'VAINILLA', 16, 20, 10, 10, '14022050', 10),
('7501030475743', 'PINGUINOS', 'MARINELA', '3 PIEZAS', 17, 18, 10, 100, '10032050', 1000),
('7501030477488', 'MADALENAS', 'SP', 'CON MATEQUILLA', 11, 15, 10, 10, '14022050', 1010),
('7501030478386', 'SUPER PAN BLANCO', 'SP', 'CON ANJOJOLI', 30, 40, 10, 10, '16022050', 10),
('7501030478409', 'INTEGRAL 100', 'SP', 'CON ANJONJOLI', 32, 39, 10, 10, '16022055', 10),
('7501030480778', 'TOTOPOS', 'SP', 'PARA CHILAQUILES', 17, 23, 10, 10, '14022050', 1000),
('7501030482055', 'VALENTONES', 'BARCEL', 'CHICHARRON', 36, 37, 1, 100, '15032050', 100),
('7501030486077', 'SPIRRONES', 'BARCEL', 'CHICHARRON DE CERDO', 8, 10, 1, 100, '15032050', 1000),
('7501030486664', 'TORTILLINAS', 'BIMBO', '22 PIEZAS', 20, 26, 1, 1000, '10032050', 4000),
('7501030486985', 'SALADAS', 'LARA', 'CLASICAS', 10, 13, 1, 1000, '10032050', 1000),
('7501030488910', 'GANSITO', 'SP', '2 PIEZAS', 13, 15, 1, 1001, '10032050', 1000),
('7501030490272', 'TORTILLINAS', 'BIMBO', '12 PIEZAS', 12, 16, 1, 1001, '10032050', 4000),
('7501030490388', 'CANAPINAS', 'SP', 'LARA', 10, 12, 10, 10, '16022050', 10),
('7501030490418', 'DELICIOSAS ', 'SP|', 'CHOCOCHISPAS', 8, 8, 10, 10, '15022050', 1000),
('7501030490463', 'DELICIOSAS', 'SP', 'VAINILLA', 6, 8, 10, 10, '15022051', 1),
('7501030490951', 'POLVORONES', 'SP', 'GALLETAS', 11, 14, 1, 10, '17022050', 10),
('7501030491644', 'CANELITAS', 'SP', 'GALLETAS', 11, 14, 1, 10, '17022050', 10),
('7501030491668', 'PAN TOSTADO', 'SP', 'INTEGRAL', 21, 27, 1, 20, '14022050', 999),
('7501031302376', 'LIPTON', 'PEPSI', 'CITRICOS', 12, 13, 1, 100, '04032050', 10000),
('7501031302741', 'PEPSI', 'PEPSI', '400ML', 7, 8, 1, 100, '04032050', 10000),
('7501031302802', 'MANZANITA SOL', 'PEPSI', '400ML', 7, 8, 1, 100, '04032050', 10000),
('7501031302819', 'MIRINDA', 'PEPSI', '400ML', 7, 8, 1, 100, '04032060', 10000),
('7501031303540', 'SANGRIA CASERA', 'PEPSI', '400ML', 7, 8, 1, 1000, '04032050', 10000),
('7501031303885', 'BE LIGTH', 'PEPSI', 'LIMON 1LT', 10, 13, 1, 11, '04032050', 10000),
('7501031303892', 'BE LIGHT', 'PEPSI', 'MANGO', 12, 13, 1, 100, '04032050', 10000),
('7501031307265', 'JUMEX FRES', 'PEPSI', 'UVA 2L', 20, 22, 1, 1000, '04032050', 10000),
('7501031307289', 'JUMEX FRESH', 'PEPSI', 'CONGA 2L', 22, 22, 10, 100, '04032056', 10000),
('7501031310012', 'PEPSI', 'PEPSI', '600ML', 11, 11, 1, 1000, '04032050', 10000),
('7501031310098', 'PEPSI', 'PEPSI', '3L', 31, 31, 1, 100, '17032050', 200),
('7501031311606', 'PEPSI', 'PEPSI', '2L ', 22, 23, 1, 100, '04032060', 10000),
('7501031345052', 'MIRINDA', 'PEPSI', '600ML', 10, 12, 101, 11111, '04032055', 10000),
('7501031360024', 'MANZANITA SOL', 'PEPSI', '600ML', 10, 12, 11, 11000, '04032054', 9999),
('7501032395230', 'DANONE MIX', 'DANONE', 'YOGHURT SABOR MANZANA', 10, 12, 1, 100, '18032050', 100),
('7501032397845', 'DANONINO', 'DANONE', 'LUNCH', 11, 12, 1, 100, '18032050', 1100),
('7501032397869', 'BENEGASTRO', 'DANONE', 'CON ALIV', 10, 12, 1, 100, '18032050', 100),
('7501032397944', 'DANONINO', 'DANONE', '168G', 4, 4.5, 1, 100, '18032050', 1100),
('7501032397951', 'DANONINO', 'DANONE', 'FRESA', 8, 8.5, 1, 100, '18032050', 1100),
('7501032397968', 'DANUP', 'DANONE', 'PIÑA COCO 350G', 12, 14, 1, 100, '18032050', 100),
('7501032398224', 'ACTIVIA', 'DANONE', 'PIÑA, APIO Y NOPAL 225G', 10, 12, 100, 4, '28022021', 5),
('7501032398255', 'ACTIVIA', 'DANONE', 'FRUTAS', 10, 12, 1, 100, '18032050', 100),
('7501032398491', 'DANONE', 'DANONE', 'MANZANA', 10, 10, 1, 100, '18032050', 100),
('7501032398576', 'DANONE ', 'DANONE', 'FRESA', 10, 10, 1, 1100, '18032050', 100),
('7501032398583', 'DANUP', 'DANONE', 'FRESA 220G', 10, 12, 1, 100, '18032050', 100),
('7501032398606', 'DANUP', 'DANONE', 'PIÑA COCO 220G', 10, 12, 1, 100, '18032050', 100),
('7501032398637', 'DANUP', 'DANONE', 'COOKIES 2205G', 10, 12, 1, 100, '18032050', 100),
('7501032485016', 'CARIBE COOLER', 'SP', 'DURAZNO', 23, 24, 1, 100, '02032050', 555),
('7501032485030', 'CARIBE COOLER', 'SP', 'MANGO PIÑA', 23, 24, 1, 10, '02032050', 555),
('7501032485047', 'CARIBE COOLER', 'SP', 'FRESA', 23, 24, 1, 10, '02032050', 555),
('7501032601744', 'VITA LECHE', 'BONAFINA', '1LT', 12, 13, 5, 24, '12102016', 100),
('7501032900168', 'RAID', 'SP', 'RAIDOLITOS', 18, 19, 1, 100, '17032050', 1000),
('7501032903596', 'RAID MAX', 'SP', 'MATA CUCARACHAS 400ML', 65, 69, 5, 12, '26082026', 100),
('7501032908157', 'MR MUSCULO', 'WINDEX', 'WINDEX', 37, 39, 1, 100, '05032050', 100),
('7501032920401', 'RAID', 'SP', 'CASA Y JARDIN', 57, 58, 1, 100, '17032050', 1000),
('7501032925956', 'RAID', 'SP', 'CASA Y JARDIN 400ML', 47, 49.5, 5, 12, '26082026', 100),
('7501035046252', 'BOOST', 'SP', 'BEBIDA CARBONATADA', 30, 33, 10, 100, '02032050', 50),
('7501035904071', 'VEL ROSITA', 'SP', '1LT', 50, 53, 1, 5, '06082050', 100),
('7501035910034', 'FABULOSO', 'SP', 'FRESCA LAVANDA', 14, 25, 5, 10, '06082050', 999),
('7501035910041', 'FABULOSO', 'SP', 'MAR FRESCO', 24, 25, 1, 100, '05032050', 1000),
('7501035910072', 'AJAX', 'SP', 'BICLORO 388G ', 13, 18, 5, 20, '06082050', 100),
('7501035910096', 'FABULOSO', 'SP', 'FRESCO AMANECER 1L', 14, 16, 5, 10, '06082018', 100),
('7501035911031', 'COLGATE', 'SP', 'CON CALCIO 100ML', 19, 21, 5, 12, '26022019', 100),
('7501035911567', 'COLGATE', 'SP', 'CON CALCIO 50 ML', 17, 18.5, 5, 12, '26082050', 100),
('7501039120149', 'ACEITE NUTRIOLI', 'SP', '946ML', 23, 25.5, 5, 20, '01082017', 100),
('7501039121993', 'NUTRIOLI', 'SP', 'ACEITE COMESTIBLE', 16, 17, 1, 100, '16032050', 1000),
('7501039122846', 'NUTRIOLI', 'SP', 'ACEITE COMESTIBLE', 29, 30, 1, 100, '16032050', 1000),
('7501039400432', 'BOING!', 'SP', 'GUAYABA 1LT', 14, 15, 5, 24, '18012017', 100),
('7501039400449', 'BOING!', 'SP', 'MANGO 1LT', 14, 15, 5, 24, '17012017', 100),
('7501039400456', 'BOING!', 'SP', 'MANZANA 1LT', 14, 15, 5, 24, '16012017', 100),
('7501039400807', 'BOING', 'BOING', 'MANGO 1LT', 16, 17, 1, 100, '11032050', 1000),
('7501039400814', 'BOING', 'BOING', 'GUAYABA 1LT', 16, 17, 1, 100, '11032050', 1000),
('7501039400838', 'BOING', 'BOING', 'MANZANA 1LT', 16, 17, 1, 1000, '11032051', 1000),
('7501040005831', 'FUD ', 'FUD', 'JAMON DE PAVO ', 54, 55, 1, 10, '18032050', 100),
('7501040009754', 'FUD', 'FUD', 'SALCHICHAS TIPO VIENA', 20, 22, 1, 100, '18032050', 1000),
('7501040009761', 'FUD', 'FUD', 'SALCHICHAS CON PAVO', 22, 22, 1, 100, '18032050', 1000),
('7501040027284', 'FUD ', 'FUD', 'VIRGINIA DE POLLO', 54, 55, 1, 100, '18032050', 100),
('7501040070129', 'CAFE OLE', 'FUD', 'IRLANDES', 24, 25, 1, 100, '18032050', 1000),
('7501040070525', 'CAFE OLE', 'FUD', 'PASTEL DE CUMPLEAÑOS', 24, 25, 1, 100, '18032050', 1000),
('7501040070532', 'CAFE OLE', 'FUD', 'PASTEL DE CHOCOLATE', 24, 25, 1, 100, '18032060', 1000),
('7501040080340', 'NOCHE BUENA', 'FUD', 'QUESO MANCHEGO', 89, 90, 1, 100, '18032050', 100),
('7501040081477', 'LA VILLITA', 'FUD', 'AMERICANO', 27, 28, 1, 100, '18032050', 100),
('7501040081897', 'QUESO PANELA', 'FUD', 'LA VILLITA DE 200G', 20, 24, 6, 5, '18032021', 3),
('7501040082146', 'OLA VILLITA', 'FUD', 'MARGARINA PASTEURIZADA', 10, 11, 1, 100, '18032060', 100),
('7501040082252', 'LA VILLITA', 'FUD', '190G', 20, 21, 1, 100, '18032050', 100),
('7501040083716', 'QUESO PANELA', 'FUD', 'FUD 200G', 25, 29, 8, 2, '18032021', 5),
('7501040083815', 'FUD', 'FUD', 'QUESO MANCHEGO', 29, 29.5, 1, 100, '18032050', 100),
('7501040090011', 'YOPLAIT', 'FUD', 'YOGHURT NATURAL', 6, 6.5, 1, 100, '18032050', 1000),
('7501040090028', 'YOPLAIT', 'FUD', 'NATURAL 1KG', 37, 37.5, 1, 100, '18032050', 100),
('7501040090042', 'YOPLAIT', 'FUD', 'DURAZNO', 6, 6.5, 1, 100, '18032050', 1000),
('7501040090097', 'YOPLAIT', 'FUD', 'DURAZNO 1KG', 37, 37.5, 1, 100, '18032050', 100),
('7501040090141', 'YOPLAIT', 'FUD', 'FRUTAS Y CEREALES', 6, 6.5, 10, 50, '18032050', 1000),
('7501040090165', 'YOPLAIT', 'FUD', 'FRUTAS Y CEREALES 1KG', 37, 37.5, 1, 100, '18032050', 100),
('7501040090349', 'YOPLAIT ', 'FUD', 'CEREALES, FRESAS Y ALMENDRAS 1KG', 37, 37.5, 1, 100, '18032050', 100),
('7501040090691', 'YOPALIT', 'FUD', 'FRUTAS Y CEREALES', 18, 18.5, 1, 100, '18032050', 1000),
('7501040090769', 'YOPLAIT', 'FUD', 'MANZANA NATURAL', 6, 6.5, 1, 100, '18032050', 1000),
('7501040090851', 'YOPLAIT', 'FUD', 'GRANOLA NATURAL', 6, 6.5, 1, 100, '18032050', 100),
('7501040090875', 'YOPLAIT', 'FUD', 'FRESAS NATURALES', 6, 6.5, 1, 50, '18032050', 1000),
('7501040090950', 'YOPLAIT', 'FUD', 'FRESAS NATURALES442G', 18, 18.5, 1, 100, '18032050', 1000),
('7501040090967', 'YOPLAIT', 'FUD', 'YOGHURT NATURAL', 18, 18.5, 1, 100, '18032050', 1000),
('7501040091124', 'YOPLAIT', 'FUD', 'FRESAS NATURALES', 13, 13.5, 1, 100, '18032050', 1000),
('7501040091223', 'YOPLAIT', 'FUD', 'DURAZNO', 11, 12, 1, 100, '18032050', 1000),
('7501040091872', 'YOPLAIT', 'FUD', 'YOGHURT NATURAL', 11, 12, 1, 1000, '18032050', 1000),
('7501040092541', 'YOPLAIT DISFRUTA', 'FUD', 'FRESA', 8, 10, 1, 100, '18032050', 100),
('7501040092565', 'YOPLAIT PLACER', 'FUD', 'COCO', 12, 12, 10, 1000, '18032050', 100),
('7501040092589', 'YOPLAIT PALCER', 'FUD', 'PAY DE FRESA', 11, 12, 1, 100, '18032050', 100),
('7501040092596', 'YOPLAIT MINI', 'FUD', 'FRESA', 3, 3.5, 1, 100, '18032050', 1000),
('7501040092787', 'YOPLAIT DISFRUTA', 'FUD', 'FRESA 442G', 22.5, 22.5, 1, 100, '18032050', 1000),
('7501040092794', 'YOPLAIT MINI', 'FUD', 'DURAZNO', 3, 3.5, 1, 100, '18032050', 1000),
('7501040092848', 'YOPLAIT ', 'FUD', 'GRIEGO MORAS', 10, 10, 1, 100, '18032050', 100),
('7501040092862', 'YOPLAIT GRIEGO', 'FUD', 'NATURAL', 10, 10, 1, 110, '18032050', 100),
('7501040092879', 'YOPLAIT GRIEGO', 'FUD', 'MORAS', 11, 12, 1, 100, '18032050', 1000),
('7501040092886', 'YOPLAIT GRIEGO', 'FUD', 'FRESA', 11, 12, 1, 100, '18032050', 1000),
('7501040092992', 'YOPLAIT MINI', 'FUD', 'UVA', 3, 3.5, 1, 100, '18032040', 1000),
('7501040094118', 'YOPLAIT', 'FUD', 'YOGHURT NATURAL', 18, 19.5, 1, 100, '18032050', 1000),
('7501040094156', 'YOPLAIT MINI', 'FUD', 'COOKIES AND CREAM', 3, 3.5, 1, 100, '18032050', 1000),
('7501040094224', 'YOPLAIT', 'FUD', 'LICUADO CON GRANOLA', 15, 19.5, 1, 100, '18032050', 100),
('7501040094422', 'DISFRUTA', 'FUD', 'FRESA', 16, 16, 1, 100, '18032050', 100),
('7501040094439', 'DISFRUTA', 'FUD', 'MANGO', 15, 16, 1, 100, '18032050', 100),
('7501040094446', 'DISFRUTA', 'FUD', 'MORA AZUL', 15, 16, 1, 100, '18032050', 100),
('7501040094453', 'YOPLAIT GRIEGO', 'FUD', 'YOGHURT PARA BEBER', 11, 12, 1, 100, '18032050', 1000),
('7501040094460', 'YOPLAIT PLACER', 'FUD', 'VAINILLA CRUNCH', 12, 13, 1, 100, '18032050', 100),
('7501040095504', 'DISFRUTA', 'FUD', 'DURAZNO', 15, 16, 1, 100, '18032050', 100),
('7501040095511', 'DISFRUTA', 'FUD', 'GUAYABA', 15, 16, 1, 100, '18032050', 100),
('7501040096082', 'YOPLAIT MINI', 'FUD', 'FRESA', 4, 4.5, 1, 10, '18032050', 1000),
('7501040097577', 'YOPLAIT', 'FUD', 'YOGHURT CON FRESAS', 14, 19.5, 1, 100, '18032050', 100),
('7501045401195', 'EL DORADO', 'SP', 'ATUN ACEITE 140G', 9, 10, 2, 12, '01042020', 10),
('7501045401423', 'ATUN DOLORES', 'SP', 'ACEITE 140G', 12, 13, 8, 30, '26022020', 100),
('7501045401430', 'ATUN DOLORES', 'SP', 'AGUA 140G', 12, 13, 5, 30, '26062020', 100),
('7501045403281', 'SARDINA DOLORES', 'SP', 'EN SALSA DE TOMATE', 34, 35, 1, 10, '01032050', 101),
('7501045403908', 'ATUN DOLORES', 'SP', 'ACEITE', 17, 18.5, 10, 101, '01032050', 96),
('7501045403915', 'ATUN DOLORES', 'SP', 'AGUA', 17, 18.5, 1, 10, '01032050', 88),
('7501048100163', 'ACEITE CRISTAL', 'SP', '1LT', 22, 23.5, 5, 30, '27022018', 100),
('7501048100200', 'ACEITE CRISTAL', 'SP', '500ML', 15, 17, 5, 24, '27072050', 100),
('7501048100248', 'ACEITE CRISTAL', 'SP', '1.5LT', 30, 34, 5, 24, '27072018', 100),
('7501049401016', 'MOLDES CUP', 'BOSCO', '50 MOLDES', 15, 16, 100, 1, '30042022', 4),
('7501049967062', 'SOL MEZCLAS', 'SOL', 'MEZCLAS CLAMATO', 18, 25, 1, 10, '02032050', 50),
('7501052411316', 'LEGAL', 'SP', 'CAFE DE GRANO 200G', 45, 46, 5, 24, '27082050', 100),
('7501052411323', 'LEGAL', 'SP', 'CAFE DE GRANO 400G', 54, 56, 5, 24, '14032017', 100),
('7501052420165', 'LA SIERRA', 'LA SIERRA', 'FRIJOLES NEGROS REFRITOS', 14, 15, 1, 100, '12032050', 1000),
('7501052420424', 'LA SIERRA', 'SP', 'FRIJOLES NEGROS REFRITOS 580G', 13, 15, 5, 24, '04042050', 100),
('7501052420431', 'LA SIERRA', 'SP', 'FRIJOLES BAYOS REFRITOS 580G', 13, 15, 5, 24, '07042050', 100),
('7501052424613', 'LA SIERRA', 'SP', 'FRIJOLES BAYOS ENTEROS 560G', 11, 12, 5, 24, '13042018', 100),
('7501052470061', 'CLEMENTE JACQUES', 'CLEMENTE JACQUES', 'ADEREZO MIL ISLAS', 24, 25, 1, 100, '12032050', 1000),
('7501052470085', 'ADEREZO PARA ENSALADAS', 'CLEMENTE JACQUES', 'RANCH', 25, 25, 1, 100, '12032050', 1000),
('7501052470092', 'CLEMENTE JACQUES', 'CLEMENTE JACQUES', 'ADEREZO RANCH', 66, 68, 1, 100, '12032050', 1000),
('7501052473505', 'CLEMENTE JACQUES', 'CLEMENTE JACQUES', 'SALSA VERDE', 17, 18, 1, 100, '12032050', 1000),
('7501052473529', 'CLEMENTE JACQUES', 'CLEMENTE JACQUES', 'SALSA TAQUERA', 18, 18, 1, 100, '12032050', 1000),
('7501052474236', 'MERMELADA', 'CLEMENTE JACQUES', 'DE ZARZAMORA', 24, 25, 1, 100, '17032050', 100),
('7501053670200', 'VIÑA REAL', 'SP', 'DURAZNO  1LT', 23, 26, 4, 12, '27052017', 100),
('7501053670309', 'VIÑA REAL', 'SP', '2L DURAZNO', 82, 84, 10, 10, '18022050', 100),
('7501053670408', 'VIÑA REAL', 'SP', 'DURAZNO 500ML', 20, 22, 5, 24, '27032050', 100),
('7501053670507', 'VIÑA REAL', 'SP', 'DURAZNO', 25, 25, 1, 100, '02032050', 555),
('7501055300952', 'COCA COLA', 'COCA COLA', '1.25L RETORNABLE', 17, 18, 1, 10, '18022050', 10),
('7501055302451', 'COCA COLA', 'COCA COLA', '1LT ', 17, 20, 1, 10, '18022050', 10),
('7501055303786', 'FRESCA', 'COCA COLA', 'TORONJA 600ML', 10, 12, 10, 10, '18022050', 10),
('7501055304691', 'DELAWARE PUNCH', 'COCA COLA', '2L', 17, 18, 1, 10, '22022050', 101),
('7501055304745', 'COCA COLA', 'COCA COLA', '3LT DESECHABLE', 40, 42, 1, 10, '18022050', 10),
('7501055304790', 'FANTA', 'COCA COLA', '3L', 30, 31, 1, 10, '18022050', 100),
('7501055304813', 'FRESCA TORONJA', 'COCA COLA', '3L', 3, 31, 1, 10, '18022050', 100),
('7501055305339', 'COCA COLA', 'COCA COLA', '600 ML SIN CALORIAS', 12, 14, 1, 10, '18022050', 10),
('7501055305346', 'COCA COLA', 'COCA COLA', '1LT SIN CALORIAS', 18, 20, 1, 10, '18022050', 10),
('7501055305742', 'CIEL MIENRALIZADA', 'COCA COLA', '2L', 20, 23, 1, 10, '18022050', 100),
('7501055307906', 'CIEL', 'COCA COLA', '600ML', 7, 8, 1, 10, '22022050', 101),
('7501055308330', 'SENZAO GUARANA', 'COCA COLA', '600ML', 10, 12, 1, 10, '18022050', 9),
('7501055310227', 'COCA COLA ', 'COCA COLA', '2.5L RETORNABLE', 25, 26, 1, 10, '18022050', 10),
('7501055310883', 'CIEL', 'COCA COLA', '1L', 9, 10, 1, 10, '22022050', 101),
('7501055313068', 'COCA COLA', 'COCA COLA', '3L RETORNABLE ', 26, 31, 1, 10, '18022050', 10),
('7501055313532', 'COCA COLA', 'COCA COLA', '1.75LT', 23, 25, 1, 10, '18022050', 10),
('7501055317653', 'POWER ADE', 'COCA COLA', '1L MORAS', 20, 24, 1, 10, '22022050', 101),
('7501055317677', 'POWER ADE', 'COCA COLA', '1L SABOR NARANJA', 20, 24, 10, 10, '22022050', 101),
('7501055328321', 'FANTA', 'COCA COLA', '400ML ', 6, 7, 10, 10, '18022050', 10),
('7501055328345', 'COCA COLA', 'COCA COLA', '500ML', 10, 10, 1, 10, '18022050', 10),
('7501055328369', 'SPRITE', 'COCA COLA', '400ML', 6, 7, 1, 10, '18022050', 10),
('7501055328390', 'COCA COLA', 'COCA COLA', '400ML SIN AZUCAR', 6, 7, 1, 10, '18022050', 10),
('7501055329267', 'POWER ADE ', 'COCA COLA', '500ML MORAS', 10, 14, 1, 10, '22022056', 101),
('7501055329298', 'POWER ADE', 'COCA COLA', '500ML PONCHE DE FRUTAS', 10, 14, 1, 10, '22022050', 101),
('7501055329380', 'POWER ADE', 'COCA COLA', '500ML', 10, 14, 0, 10, '22022050', 101),
('7501055329465', 'COCA COLA', 'COCA COLA', '3LT SIN AZUCAR', 30, 32, 10, 42, '18022050', 10),
('7501055330461', 'DEL VALLE FRUT', 'COCA COLA', '2L SABOR CITRICOS', 23, 24, 1, 10, '22052050', 10),
('7501055330683', 'DEL VALLE', 'COCA COLA', '600ML SABOR CITRICOS', 10, 12, 20, 50, '22022060', 100),
('7501055330812', 'DEL VALLE FRUT', 'COCA COLA', '3L SABOR CITRICOS', 30, 31, 1, 10, '22022050', 10),
('7501055333844', 'DEL VALLE', 'COCA COLA', 'MANGO 1LT', 17, 18, 4, 12, '28012017', 100),
('75010553338444', 'DEL VALLE', 'COCA COLA', 'MANGO 1LT', 17, 24, 4, 12, '28012050', 100),
('7501055333851', 'DEL VALLE', 'COCA COLA', 'DURAZNO 1LT', 17, 24, 4, 12, '24032030', 100),
('75010553338511', 'DEL VALLE', 'COCA COLA', 'DURAZNO 1LT', 17, 18, 4, 12, '24032017', 100),
('7501055335978', 'DEL VALLE', 'DEL VALLE', 'NECTAR DE DURAZNO', 6, 7, 1, 100, '11032050', 10001),
('7501055337507', 'DEL VALLE FRUT', 'COCA COLA', '2L SABOR MANZANA', 23, 24, 1, 10, '22022050', 10),
('7501055339983', 'SIDRAL MUNDET', 'COCA COLA', '600ML', 10, 12, 10, 10, '18022050', 10),
('7501055339990', 'SIDRAL MUNDET', 'COCA COLA', '1LT ', 16, 17, 1, 10, '18022050', 10),
('7501055340002', 'SIDRAL MUNDET', 'COCA COLA', '2L MANZAMA', 17, 18, 1, 10, '18022050', 100),
('7501055340088', 'COCA COLA', 'COCA COLA', '500ML SIN AZUCAR', 8, 10, 1, 10, '18022050', 10),
('7501055342198', 'DEL VALLE', 'COCA COLA', '355ML NARANJA', 6, 7, 1, 10, '22022050', 99),
('7501055342716', 'DEL VALLE ', 'COCA COLA', 'GUAYABA', 10, 12, 10, 101, '22022050', 100),
('7501055342730', 'DEL VALLE FRUT', 'COCA COLA', '2L SABOR GUAYABA', 23, 24, 1, 10, '22022050', 10),
('7501055343447', 'DEL VALLE', 'COCA COLA', '355ML GUAYABA', 6, 7, 1, 10, '22022050', 100),
('7501055343546', 'SIDRAL MUNDET', 'COCA COLA', '500ML RETORNABLE', 8, 10, 1, 10, '18022050', 10),
('7501055344901', 'FUZE TEA', 'COCA COLA', 'DURAZNO LATA', 14, 15, 1, 10, '22022050', 100),
('7501055345014', 'PRISCO MUNDET', 'COCA COLA', '600ML', 10, 12, 1, 10, '18022050', 100),
('7501055346691', 'FUZE TEA', 'COCA COLA', 'TE NEGRO 453ML', 15, 15, 1, 10, '22022050', 10),
('75010553466911', 'FUZE TEA', 'COCA COLA', 'TE NEGRO LATA', 12, 15, 1, 10, '18022050', 100),
('7501055349807', 'SPRITE', 'COCA COLA', '235ML LATA', 6, 10, 1, 10, '18022050', 100),
('7501055349845', 'FANTA', 'COCA COLA', '235ML LATA', 8, 10, 1, 10, '18022050', 100),
('7501055355310', 'COCA COLA', 'COCA COLA', '250ML', 6, 7, 10, 10, '18022050', 10),
('7501055361540', 'COCA COLA', 'COCA COLA', '355 ML LATA', 12, 14, 1, 10, '18022050', 10),
('7501055366170', 'SPRITE', 'COCA COLA', '235ML VIDRIO', 7, 10, 1, 10, '18022050', 10),
('7501055367412', 'SIDRAL MUNDET', 'COCA COLA', '2LT SABOR PERA', 15, 18, 1, 10, '18022050', 100),
('7501055367443', 'DEL VALLE PULPY', 'COCA COLA', 'SABOR SABILA', 10, 12, 1, 10, '22022050', 101),
('7501055368136', 'COCA COLA', 'COCA COLA', '235ML RETORNABLE', 4, 5, 1, 10, '18022050', 10),
('7501055369638', 'FUZE TEA', 'COCA COLA', '1.5L TE NEGRO', 17, 18, 1, 10, '22022050', 101),
('7501055371655', 'COCA COLA', 'COCA COLA', '1.35L ', 18, 20, 10, 10, '18022021', 10),
('7501055373062', 'TOPO CHICO ', 'COCA COLA', 'HARD SELTZER', 20, 25, 10, 10, '18022050', 10),
('7501055900039', 'ALPURA 2000', 'SP', 'CLASICA 1LT', 20, 22, 5, 24, '13112050', 100),
('7501055900060', 'ALPURA', 'SP', 'CHOCOLATE 1LT', 16, 25, 8, 35, '16112050', 1000),
('7501055900077', 'ALPURA', 'SP', 'FRESA 1LT', 24, 25, 5, 30, '08112050', 1000),
('7501055900084', 'ALPURA', 'SP', 'VAINILLA 1LT', 24, 25, 5, 30, '19112050', 100),
('7501055900800', 'ALPURA 2000', 'SP', 'LIGHT 1LT', 16, 17.5, 5, 30, '06102016', 100),
('7501055901425', 'ALPURA', 'SP', 'DESLACTOSADA 1LT', 21, 23, 5, 24, '08122023', 100),
('7501055902040', 'ALPURA 2000', 'SP', 'CLASICA 250ML', 5, 6.5, 5, 30, '08102016', 100),
('7501055905812', 'ALPURA', 'SP', 'LECHE EN POLVO CLASICA 240G', 17, 19, 5, 24, '30012017', 100),
('7501055909520', 'CREMA ALPURA', 'ALPURA', '250G', 14, 14, 1, 100, '18032050', 99),
('7501055909537', 'ALPURA', 'ALPURA', '500 ML', 29, 30, 1, 100, '18032050', 100),
('7501055911301', 'VAQUITAS', 'ALPURA', 'LECHE SABOR CHOCOLATE', 9, 10, 10, 100, '2622050', 1000),
('7501055911318', 'VAQUITAS', 'ALPURA', 'LECHE SABOR FRESA', 9, 10, 0, 1000, '26022050', 1000),
('7501055911325', 'VAQUITAS', 'ALPURA', 'LECHE SABOR VAINILLA', 9, 10, 1, 10, '26022080', 1000),
('7501055912391', 'YOGHURT ALPURA', 'ALPURA', 'FRESA', 7, 7, 1, 100, '18032050', 1000),
('7501055912414', 'YOGHURT ALPURA', 'ALPURA', 'DURAZNO', 6, 7, 1, 100, '18032050', 100),
('7501055912438', 'YOGHURT ALPURA', 'ALPURA', 'MANZANA', 7, 7, 10, 100, '18032050', 100),
('7501056338534', 'SEDAL', 'SP', 'SERAMIDAS 15ML', 2, 3, 5, 50, '25082018', 100),
('7501056340087', 'SEDAL', 'SP', 'BRILLO GLOSS 300ML', 34, 35, 5, 24, '25082018', 100),
('7501056340261', 'SEDAL', 'SO', 'PROACTION 10ML', 2, 3, 5, 50, '25082018', 100),
('7501056901158', 'CLORETS', 'CLORETS', '30S', 15, 16, 1, 1001, '22032050', 1000),
('7501058610690', 'NESCAFE', 'SP', 'CLASICO 190G', 65, 68.5, 2, 12, '31052017', 100),
('7501058611062', 'CARNETION', 'NESTLE', 'CLAVEL', 16, 17, 1, 100, '16032050', 1000),
('7501058611970', 'ABUELITA', 'SP', 'CAJA 360G', 35, 38, 2, 5, '31082016', 100),
('7501058611987', 'GERBER', 'SP', 'SPLASHERS MANZANA 175ML', 12, 13, 5, 24, '26052017', 100),
('7501058611994', 'GERBER', 'SP', 'SPLASHERS PERA 175ML', 14, 16, 4, 24, '03032050', 100),
('7501058616630', 'NESCAFE', 'NESTLE', 'DULCICREMA 305G', 24, 26, 2, 12, '30042017', 100),
('7501058617705', 'NESCAFE CLASICO', 'NESTLE', '225G', 118, 119, 10, 1000, '17032050', 1000),
('7501058617873', 'LA LECHERA', 'NESTLE', '387G', 20, 25, 4, 24, '30042050', 100),
('7501058619228', 'COFFEE MATE', 'NESTLE', '160G', 24, 24.5, 1, 100, '16032050', 1000),
('7501058620101', 'NESCAFE CLASICO', 'NESTLE', '120G', 70, 72, 1, 100, '17032050', 1000),
('7501058628466', 'NESCAFE ', 'NESTLE', 'DECAF 40G', 35, 36, 1, 100, '17032050', 1000),
('7501058628664', 'SALSA TIPO INGLESA', 'SP', '50ML', 16, 17, 1, 100, '12032050', 1000),
('7501058637185', 'NIDAL', 'NESTLE', 'FORMULA DE CONTINUACION PARA LACTANTES', 20, 22, 1, 100, '16032050', 1000),
('7501058638083', 'CARLOS V', 'NESTLE', 'ORIGINAL', 8, 9, 1, 100, '22032050', 100),
('7501058711656', 'AIR WICK', 'SP', ' ACQUAMARINA 226G', 30, 32, 1, 2, '06082018', 100),
('7501058711670', 'AIR WICK M&C', 'SP', '226G', 30, 32, 1, 2, '06082016', NULL),
('7501058711687', 'AIR WICK LAVANDA', 'SP', '226G', 30, 32, 1, 2, '06082016', NULL),
('7501058720634', 'BRASSO', 'SP', 'BRILLO FACILMENTE 650ML', 41, 42, 3, 24, '25082016', 100),
('7501058743107', 'NUGGET', 'SP', 'BLANCO 60ML', 13, 14, 5, 24, '27082026', 100),
('7501058743121', 'NUGGET', 'SP', 'NEGRO 60ML', 12, 14, 5, 24, '27082026', 99),
('7501058743145', 'NUGGET', 'SP', 'CAFE 60ML', 14, 14, 5, 24, '27082026', 100),
('7501058752086', 'BRASSO', 'SP', 'SUEÑOS DE LAVANDA 90ML', 12, 13, 5, 24, '25082018', 100),
('7501059211209', 'LA LECHERA', 'SP', '100G', 10, 12, 10, 50, '07052050', 100),
('7501059223905', 'CRUNCH', 'NESTLE', '40G', 13, 15, 1, 100, '22032050', 100),
('7501059225411', 'NIDO', 'SP', 'KINDER 1-3 AÑOS 360G', 82, 94, 5, 12, '31102025', 100),
('7501059235045', 'COFFE-MATE', 'NESTLE', 'EL ORIGINAL 170G', 19, 21, 4, 12, '27052018', 100),
('7501059235243', 'NAN', 'NESTLE', 'OPTIPRO 1 350G', 100, 104, 2, 10, '30092017', 100),
('7501059235250', 'NAN', 'NESTLE', 'OPTIPRO 2 350G', 84, 92, 4, 12, '31052017', 100),
('7501059238190', 'NIDAL', 'NESTLE', 'FORMULA PARA LACTANTES 135G', 27, 28, 5, 24, '31052017', 100),
('7501059281943', 'NIDO', 'SP', 'LECHE ENTERA FORTIFICADA 120G', 13, 15, 5, 12, '22112016', 100),
('7501059281950', 'NIDO', 'SP', 'LECHE ENTERA FORTIFICADA 360G', 60, 69, 4, 12, '31102025', 100),
('7501059282117', 'NUTRI RINDES', 'SP', '240G', 22, 24, 4, 12, '31012017', 100),
('7501059284555', 'CARNATION', 'NESTLE', 'CLAVEL LECHE EVAPORADA 360G', 12, 14, 5, 24, '02012017', 100),
('7501059285354', 'NESCAFE', 'SP', 'CLASICO 95G', 32, 33.5, 5, 12, '28022018', 100),
('7501059285897', 'NESCAFE ', 'SP', 'DOLCA 85G', 15, 18, 5, 30, '27012018', 100),
('7501059285903', 'COFFEE-MATE', 'NESTLE', 'EL ORIGINAL 140G', 12, 14.5, 3, 12, '27012018', 100),
('7501059289659', 'ABUELITA', 'SP', 'CHOCOLATE EN POLVO 320G', 27, 29.5, 5, 12, '30092016', 100),
('7501059292529', 'NESCAFE', 'NESTLE', 'CAPUCCINO 20G', 7, 8, 5, 30, '31052017', 100),
('7501059295193', 'NUTRI RINDES', 'NESTLE', 'PRODUCTO LACTEO', 14, 15, 1, 100, '16032050', 1000),
('7501059296305', 'MORELIA PRESIDENCIAL', 'SP', 'CHOCOLATE EN POLVO', 30, 32, 1, 100, '17032050', 100),
('7501059297586', 'MAGGUI', 'MAGGUI', 'JUGUITO SAZONADOR', 16, 17, 1, 100, '12032050', 1000),
('7501059352575', 'ST IVES', 'SP', 'AVENA Y KARITE 532ML', 45, 47, 5, 24, '25082018', 100),
('7501061696988', 'CERVEZA INDIO', 'INDIO', '473ML', 18, 20, 1, 10, '02032050', 50),
('7501061810636', 'DORALDENT', 'SP', 'SUPERIOR', 8, 9, 12, 24, '26082021', 7),
('7501064101205', 'CORONA MEGA', 'CORONA', '1.2L', 34, 35, 1, 10, '02032050', 1111),
('7501064101410', 'CORONA EXTRA', 'CORONA', '355ML ', 14, 15, 1, 10, '02032050', 50),
('7501064112546', 'MODELO ESPECIAL', 'CORONA', '355 ML', 17, 18, 1, 10, '02032050', 1111),
('7501064115400', 'VICTORIA', 'CORONA', '355ML', 14, 15, 1, 10, '02032050', 50),
('7501064120268', 'MODELO ESPECIAL', 'CORONA', '12 PIEZAS', 200, 216, 1, 100, '02032050', 1111),
('7501064191886', 'MODELO', 'CORONA', 'ESPECIAL', 19, 20, 1, 100, '02032050', 555),
('7501064191909', 'VICTORIA', 'CORONA', 'VICTORIA CONT NET 1,2L', 32, 35, 1, 100, '24122040', 100),
('7501064193873', 'BUD LIGHT', 'SP', 'FIRE THE CANNONS', 19, 20, 10, 11, '02032050', 1111),
('7501064194139', 'VICTORIA ', 'SP', '473ML', 19, 19, 11, 100, '02032050', 546),
('7501064194146', 'VICTORIA MICIL', 'GRUPO MODELO', 'CERVEZA CONT NET. 710ML', 25, 30, 2, 12, '14032025', 100),
('7501064195334', 'VICTORIA', 'CORONA', 'VICKYCHELADA', 24, 25, 1, 10, '02032050', 555),
('7501064198168', 'MICHELOB ULTRA', 'SP', '355 ML', 18, 20, 1, 40, '02032050', 555),
('7501064198175', 'MICHELOB ULTRA ', 'SP', '6 BOTELLAS', 95, 110, 1, 110, '02032050', 555),
('7501064199172', 'SLTELLA ARTOIS', 'SP', '900ML', 37, 38, 1, 101, '02032050', 1110),
('7501065906472', 'DOWNY', 'NP', 'PASSION 800ML', 15, 17, 1, 10, '31122018', 100),
('7501065908841', 'ARIEL', 'SP', '250G', 10, 13.5, 5, 30, '05082050', 100),
('7501069210032', 'HARINA DE TRIGO TRES ESTRELLAS', 'SP', 'SAN ANTONIO 1KG', 20, 22, 3, 24, '26072050', 100),
('7501069210223', 'HOT CAKES', 'SP', 'TRADICIONALES', 38, 39.5, 1, 100, '16032050', 300),
('7501069210759', 'HARINA DE ARROZ', 'SP', 'TRES ESTRELLAS 500G', 20, 22, 5, 24, '02122050', 100),
('7501071120077', 'SQUIRT', 'PEPSI', '2L', 20, 23, 1, 100, '04032050', 10000),
('7501071120183', 'SQUIRT', 'PEPSI', '600ML', 10, 12, 1, 100, '04032050', 10000),
('7501071120305', 'SQUIRT', 'PEPSI', '3L', 30, 31, 1, 1000, '04032050', 10000),
('7501071120664', 'SQUIRT', 'PEPSI', '400ML', 7, 8, 1, 100, '04032080', 10000),
('7501071122057', 'SQUIRT', 'PEPSI', '1.25L', 14, 15, 1, 100, '04032050', 10000),
('7501071122118', 'SQUIRT', 'PEPSI', '1.75L', 17, 18, 1, 1000, '04032050', 10000),
('7501071307782', 'ISADORA', 'ISADORA', 'FRIJOLES REFRITOS BAYOS', 14, 15, 100, 100, '12032050', 1000),
('7501071307799', 'ISADORA ', 'ISADORA', 'FRIJOLES REFRITOS NEGROS', 14, 15, 1, 101, '12032050', 1000),
('7501071308598', 'ISADORA', 'SP', 'FRIJOLES REFRITOS BAYOS 400G', 13, 14.5, 5, 12, '26052019', 100),
('7501071308604', 'ISADORA', 'SP', 'FRIJOLES REFRITOS NEGROS 400G', 13, 14.5, 4, 12, '26052017', 100),
('7501071900204', 'POETT', 'SP', 'LAVANDA 900ML', 10.5, 18.5, 5, 10, '06082040', 100),
('7501071900280', 'POETT', 'SP', 'PRIMAVERA 1.2LT', 10.5, 12.5, 5, 10, '03108201', 100),
('7501071900969', 'POETT ', 'SP ', 'FRESCURA FRUTAL 900ML', 10.5, 12.5, 5, 10, '06082018', 100),
('7501071901287', 'POET', 'CLOROX', 'CLOROX BEBE', 17, 18, 1, 100, '05032050', 1000),
('7501071901355', 'POETT', 'SP', 'SUAVIDAD DE ALGODON 1.2LT', 10.5, 18.5, 5, 10, '06082050', 100),
('7501073839854', 'PEÑAFIEL', 'PEÑAFIEL', 'NARANJADA 600ML', 9, 10, 20, 200, '04082030', 100),
('7501073839861', 'PEÑAFIEL', 'PEÑAFIEL', 'NARANJADA', 22, 23, 1, 100, '17032050', 100),
('7501073839885', 'PEÑAFIEL', 'PEÑAFIEL', 'LIMONADA 600ML', 8, 10, 10, 50, '04082030', 100),
('7501073839892', 'PEÑAFIEL', 'PEÑAFIEL', 'LIMONADA 2LTS', 16, 18, 5, 50, '22082030', 100),
('7501073840379', 'PEÑAFIEL', 'PEÑAFIEL', 'ARANDANO 600ML', 9, 10, 20, 200, '10102016', 100),
('7501073840607', 'PEÑAFIEL', 'PEÑAFIEL', 'TORONJADA 600ML', 9, 10, 20, 200, '23082030', 100),
('7501073841024', 'PEÑAFIEL', 'SP', 'NARANJADA 1LT', 13, 15, 10, 50, '16032030', 100),
('7501073841031', 'PEÑAFIEL', 'PEÑAFIEL', 'LIMONADA 1LT', 14, 16, 10, 50, '29102016', 100),
('7501073841253', 'PEÑAFIEL', 'PEÑAFIEL', 'FRESADA 600ML', 9, 10, 20, 200, '01022030', 100),
('7501073841949', 'PEÑAFIEL', 'PEÑAFIEL', 'PIÑADA', 22, 23, 1, 100, '17032050', 100),
('7501073843189', 'PEÑAFIEL', '7501083100012', 'MANZANADA ', 22, 23, 1, 100, '17032050', 100),
('7501077400050', 'MASECA', 'SP', '1KG', 17, 18, 3, 24, '07112050', 100),
('7501083100012', 'VINAGRE BARRILITO', 'SP', 'ALCOHOL DE CAÑA COLOR', 10, 13.5, 5, 24, '26022050', 100),
('7501083100029', 'VINAGRE BARRILITO', 'SP', 'ALCOHOL DE CAÑA 750 ML', 10, 13.5, 5, 24, '26072050', 100),
('7501083100036', 'VINAGRE BARRILITO', 'SP', 'MANZANA 750ML', 16, 18.5, 5, 24, '26052021', 100),
('7501083100098', 'VINAGRE DE MANZANA', 'BARRILITO', '375ML', 13, 15, 1, 100, '16032050', 1000),
('7501086801015', 'EPURA', 'PEPSI', '1.5L', 10, 12, 1, 100, '04032085', 10000),
('7501086801046', 'EPURA', 'PEPSI', '1LT', 10, 10, 1, 1100, '04032050', 9999),
('7501102610003', 'KOLA LOKA', 'SP', '2G', 17, 18.5, 5, 30, '05082020', NULL),
('7501130900411', 'CHEMISSE', 'HOLANDA', 'COCO Y PIÑA 65ML', 14, 15, 10, 50, '03062050', 100),
('7501130901050', 'MORDISCO', 'HOLANDA', 'SANDWICH 115ML', 14, 15, 5, 30, '03082050', 100),
('7501130903245', 'HELADO OREO', 'HOLANDA', 'HOLANDA 473ML', 30, 32, 2, 12, '03082017', 100),
('7501130930449', 'CORNETTO', 'HOLANDA', 'CHOCOLLAGE 120ML', 17, 19, 5, 50, '03042017', 100),
('7501130932498', 'CREMISSIMO', 'HOLANDA', 'FRESA 473ML', 20, 21.5, 2, 12, '03082018', 100),
('7501130932504', 'CREMISSIMO', 'HOLANDA', 'VAINILLA 473ML', 20, 21.5, 2, 12, '03082018', 100),
('7501130932511', 'CREMISSIMO', 'HOLANDA', 'NAPOLITANO 473ML', 20, 21.5, 2, 12, '03082018', 100),
('7501130933013', 'HELADO HOLANDA', 'HOLANDA', 'LIMON 473', 20, 21.5, 2, 12, '03062018', 100),
('7501130934003', 'HELADO CORNETTO', 'HOLANDA', 'BROWNIE Y VAINILLA 240ML', 19, 20, 5, 30, '03092018', 100),
('7501130934058', 'MAX', 'HOLANDA', 'KOLORIX 32ML', 3, 4, 10, 40, '03042017', 100),
('7501130934072', 'SOLERO', 'HOLANDA', 'CASERO FRESA Y LECHE 80ML', 11, 13, 10, 40, '03062017', 100),
('7501130934386', 'MORDISCO', 'HOLANDA', 'KROC 153ML', 19, 21, 2, 12, '06062017', 100),
('7501130934669', 'MAX', 'HOLANDA', 'MII CHOC 34ML', 4, 6, 5, 40, '03052018', 100),
('7501130934973', 'CHOCO CREAM', 'HOLANDA', 'FRESA 78ML', 10, 13, 4, 50, '03062050', 100),
('7501130934980', 'CHOCO CREAM', 'HOLANDA', 'CHOCOLATE 78ML', 8, 9, 5, 40, '03122017', 100),
('7501130935512', 'SOLERO', 'HOLANDA', 'LIMON CITRUS 71G', 9, 10, 5, 50, '03022055', 100),
('7501198350012', 'CANADA DRY', 'PEPSI', 'AGUA MINERALIZADA', 10, 12, 1, 100, '04032050', 10000),
('7501198350432', 'CANADA DRY', 'PEPSI', 'GENGER ALE', 10, 12, 10, 100, '04032050', 10000),
('7501198355451', 'ORANGE CRUSH', 'SP', 'SABOR NARANJA', 10, 12, 1, 10, '22022050', 99),
('7501199412931', 'MAS OSCURA', 'SP', 'OSCUROS INTENSOS', 17, 18, 1, 100, '05032050', 1000),
('7501199413006', 'MAS COLOR', 'SP', 'COLORES INTENSOS', 17, 18, 1, 1000, '05032050', 1000),
('7501199414324', 'VIVA', 'SP', '500', 18, 19, 1, 100, '05032050', 1000),
('7501199415772', '1>2>3', 'SP', 'MAXI PODER', 23, 24, 10, 1001, '05032050', 1),
('7501219111523', 'PRIMO TAPAS', 'SP', '#16-A 50PZ', 16, 19, 5, 12, '27082026', 100),
('75012533', 'DANETTE', 'DANONE', 'DULCE A BASE DE LECHE', 6, 8, 100, 100, '18032050', 10),
('7501268200001', 'LA VALENCIANA', 'SP', 'BLANQUEADOR 1LT', 7, 10, 5, 24, '25082050', 100),
('7501268200025', 'LOS PATITOS', 'SP', 'BLANQUEADOR 1LT', 8, 12, 5, 24, '25082050', 100),
('7501268201114', 'MISTY', 'SP', 'COCO TROPICAL', 19, 20, 1, 100, '05052050', 1000),
('7501268201138', 'MISTY', 'SP', 'KIWI FRESCO', 19, 20, 1, 100, '05032050', 1000),
('7501295600126', 'SANTA CLARA', 'COCACOLA', 'LECHE ENTERA 1LT', 24, 25, 5, 24, '23112060', 99),
('7501295600614', 'SANTA CLARA', 'SANTA CLARA', 'LECHE SABOR CHOCOLATE', 10, 13, 1, 10, '26022050', 1000),
('7501295600621', 'SANTA CLARA', 'SANTA CLARA', 'FRESA 200ML', 12, 13, 1, 100, '11032050', 9999),
('75014339', 'SALSA CAPSUP', 'SP', 'DEL MONTE 220G', 10, 13, 4, 12, '26122050', 100),
('75014483', 'PURE DE TOMATE DEL MONTE', 'SP', 'NATURAL 210G', 5, 6, 4, 12, '26122016', 100),
('7501479300088', 'MANZANITA DELICIOSA', 'PEPSI', '3L', 30, 31, 1, 110, '04032050', 10000),
('7501505630073', 'SANGRIA CASERA', 'PEPSI', '600ML', 10, 12, 12, 100, '04032050', 9999),
('7501586300018', 'MINSA', 'SP', 'HARINA DE MAIZ 1KG', 17, 18, 5, 24, '16122050', 100),
('7501656300108', 'HARINA LA REINA', 'SP', 'HARINA DE TRIGO', 8, 10, 2, 10, '21012017', 100),
('75016777', 'BENSON & EDGES', 'MARLBORO', 'MENTHOL PEARL', 65, 66, 1, 10, '26022050', 1010),
('7501761810394', '3 MINUTOS', 'SP', 'AVENA 400G BOTE', 25, 28.5, 3, 24, '02042050', 100),
('7501764801061', 'JARABE DE FRUTA SAN PEDRO', 'SP', 'HORCHATA 750ML', 23, 25, 4, 24, '27022017', 100),
('7501764801078', 'JARABE DE FRUTA SAN PEDRO', 'SP', 'JAMAICA 750ML', 23, 25.5, 5, 24, '15102016', 100),
('7501764801153', 'JARABE DE FRUTA SAN PEDRO', 'TAMARINDO 750ML', 'TAMARINDO 750ML', 35, 36, 3, 24, '02022050', 100),
('7501771300946', 'CLASSY', 'SP', 'TENEDOR JUMBO 25PZ', 7, 9.5, 5, 24, '27082026', 100),
('7501771303060', 'CLASSY', 'SP', 'CUCHILLO JUMBO 25PZ', 7, 9.5, 5, 24, '27082026', 100),
('7501771303084', 'CLASSYTA', 'SP', 'CUCHARA NEVERA 500PZ', 30, 32.5, 5, 12, '27082026', 100),
('7501771316053', 'CLASSYTA', 'SP', 'CUCHARA PASTELERA 50PZ', 7, 8, 5, 50, '27082026', 100),
('7501771329114', 'CLASSYTA', 'SP', 'TENEDOR PASTELERO 50PZ', 7, 8, 4, 30, '27082026', 100),
('7501771330127', 'TENEDOR JUMBO', 'SP', '25 TENEDORES ', 10, 11, 100, 10, '31032022', 10),
('7501782311467', 'VASOS SAN JORGE', 'SP', 'NO 14 IRROMPIBLE 50PZ', 19, 20, 5, 30, '27082026', 100),
('75019280', 'FLAN CON QUESO', 'FUD', 'YOPALIT', 7, 8, 1, 100, '18032050', 100),
('7501943412217', 'PETALO', 'SP', 'ULTRA RESISTENTE', 27, 28, 1, 100, '17032050', 1100),
('7501943459038', 'PETALO', 'SP', 'ULTRA RESISTENTE 4PZ', 10, 12.5, 5, 40, '27082026', 100),
('7501943461918', 'VOGUE', 'SP', 'MANZANILLA 4PZS', 26, 38, 5, 24, '27082026', 100),
('7501943462571', 'VOGUE', 'SP', 'CON MANZANILLA 1PZA', 5, 8, 12, 72, '27082026', 100),
('7501943466340', 'PETALO', 'SP', 'SERVILLETA 450 PZ', 35, 38.5, 5, 24, '27082026', 100),
('75021597', 'MARLBORO', 'MARLBORO', 'CAPSULA MENTOLADA', 65, 66, 10, 10, '26022050', 1000),
('7502208205995', 'PLATO REYMA', 'SP', 'TERMICO NO PH4 25PZ', 6, 8, 5, 24, '02092026', 100),
('7502208800015', 'VASO DESECHABLE', 'REYMA', 'NO. 4A', 15, 16, 50, 3, '31012024', 10),
('7502208800022', 'VASOS REYMA', 'SP', 'NO 4CH 50PZ', 12, 14.5, 4, 24, '27082026', 100),
('7502208800046', 'VOSOS REYMA', 'SP', 'NO. 5 1/2 50 PZ', 14, 16, 5, 24, '27082026', 100),
('7502208800053', 'VASO DESECHABLE ', 'REYMA', 'NO 6', 17, 18, 1000, 10, '10022050', 100),
('7502208800077', 'VASOS REYMA', 'SP', 'NO. 8 50PZ', 14, 18, 5, 24, '27082026', 100),
('7502208800084', 'VASOS REYMAN', 'SP', 'NO 10 50PZ', 21, 25, 10, 50, '27082026', 100),
('7502208800091', 'VASOS REYMA ', 'SP', 'NO.12 50PZ', 24, 25, 4, 20, '27082050', 100),
('7502208800114', 'VASOS REYMA', 'SP', 'NO 16 25PZ', 16, 17.5, 5, 30, '27082026', 100),
('7502208800121', 'VASO PLÁSTICO 16L', 'REYMA', '25 PIEZAS ', 19, 20, 100, 10, '31052022', 30),
('7502208800145', 'CONTENEDOR REYMA', 'SP', '25 PZ 1LT', 68, 69.5, 2, 12, '27082026', 3),
('7502208804952', 'CHAROLA TERMICA 066', 'REYMA', 'BIO', 20, 22, 1, 100, '23032050', 100),
('7502208805027', 'CHAROLA TERMICA', 'SP', 'REYMA 50PZA NO7', 20, 22.5, 5, 20, '26082022', 100),
('7502208805041', 'CHAROLA TERMICA 835', 'REYMA', '50 PIEZAS', 18, 20, 1, 100, '23032080', 100),
('7502208805218', 'PLATO TERMICO REIMA', 'SP', 'NO PH8 25PZAS', 11, 14, 4, 12, '26082026', 100),
('7502208805454', 'CHAROLA TERMICA 855', 'REYMA', '50 PIEZAS', 24, 25, 1, 100, '23032050', 100),
('7502223770508', 'CAPULLO', 'SP', 'CARDIOMEGAS 204G', 30, 32.5, 3, 12, '31082016', 100),
('7502223770805', 'ACEITE CAPULLO', 'SP', 'CARDIOMEGAS 905ML', 25, 27, 5, 24, '12112016', 100),
('7502223772250', 'CAPULLO', 'SP', 'ACEITE COMESTIBLE', 33, 34, 1, 100, '16032050', 1000),
('7502223775008', 'KARO', 'SP', 'MAPLE 340G', 25, 29, 5, 30, '27112030', 100),
('7502230530331', 'VELADORA EL CIELO', 'SP', 'ROSAS', 13, 15, 5, 24, '27082026', 100),
('7502230530485', 'VELADORA EL CIELO', 'SP', 'LIMONCITO', 8, 9, 10, 60, '27082026', 100),
('7502230530980', 'VELADORA EL CIELO', 'SP', 'FLOR AMARILLA', 13, 15, 5, 24, '27082026', 100),
('7502230531109', 'VELADORA EL CIELO', 'SP', 'VELADORA FLOREADA', 13, 15, 5, 24, '27082026', 100),
('7502240972206', 'CUCHARA GIGANTE BIODEGRADABLE', 'SP', '25 PIEZAS ', 14, 15, 1009, 10, '31032023', 100),
('7502251196486', 'OYUKI', 'SP', 'CHICHARRON DE HARINA', 6, 6, 1, 10, '18022050', 100),
('7502252634116', 'LINK', 'SP', 'CIGARROS', 30, 30, 1, 100, '11032050', 998),
('7502263310214', 'MIGUELITO', 'SP', 'ORIGINAL 250G', 12, 13.5, 2, 12, '08042017', 100),
('75022633102141', 'MIGUELITO', 'SP', 'ORIGINAL 250G', 12, 13.5, 2, 12, '08042017', 100),
('7502263310221', 'MIGUELITO', 'SP', 'TAMARINDO 250G', 19, 20, 0, 1000, '16032050', 1000),
('7502263310276', 'MIGUELITO', 'SP', 'UVA 250G', 19, 20, 1, 100, '16032060', 1000),
('7502263310283', 'MIGUELITO', 'SP', 'MORA AZUL 250G', 19, 20, 1, 100, '16032050', 1000),
('7502263310306', 'MIGUELITO', 'SP', 'FRESA 250G', 19, 20, 1, 100, '16032050', 1000),
('75026196', 'DANY', 'DANONE', 'GELATINA DE UVA', 5, 6, 1, 100, '18032050', 1100),
('75026967', 'VICTORIA', 'CORONA', '210ML', 10, 12, 10, 120, '02032050', 555),
('75027285', 'MODELO ', 'CORONA', 'NEGRA 355ML', 18, 20, 10, 111, '02032050', 50),
('75027766', 'PALL MALL', 'SP', 'XL SWITCH', 54, 55, 1, 10, '26022050', 100),
('75027971', 'BON O BON', 'SP', '15G', 4, 5, 1, 100, '22032050', 1000),
('7503000234053', 'PAPAS FRITAS', 'SP', 'DORIS', 15, 18, 1, 10, '18022050', 100),
('7503001453200', 'CAFE OLE', 'FUD', 'CAPUCCINO MOKA', 24, 25, 1, 100, '18032050', 1000),
('7503002398074', 'VELADORA LIMONERA', 'SP', 'VELADORAS MISTICAS ', 15, 16, 5, 24, '27082026', 100),
('75030023980741', 'VELADORA LIMONERA', 'SP', 'VELADORAS MISTICAS ', 15, 16, 5, 24, '27082026', 100),
('7503006164057', 'VAINILLA ARVT', 'SP', '500ML', 32, 34, 2, 12, '02042018', 100),
('75030061640571', 'VAINILLA ARVT', 'SP', '500ML', 32, 34, 2, 12, '02042018', 100),
('7503006897030', 'RED COLA ', 'JARRITOS', '2L ', 18, 19, 1, 10, '18022050', 9),
('750300689754112', 'JARRITOS', 'JARRITOS', 'MANZANA 500ML', 4, 5, 10, 50, '27062030', 100),
('7503006897542', 'JARRITOS', 'JARRITOS', 'MANZANA 500ML', 4, 5, 10, 50, '27062030', 100),
('7503006897597', 'JARRITOS', 'JARRITOS', '2LT UVA', 17, 18, 1, 10, '22022050', 101),
('7503006897627', 'JARRITOS', 'JARRITOS', 'PIÑA 400ML', 6, 7, 1, 10, '18022050', 10),
('7503006897641', 'JARRITOS', 'JARRITOS', 'TUTI FRUTI 355ML', 5, 6, 1, 10, '18022050', 10),
('7503006897665', 'JARRITOS', 'SP', 'MANZANA 355ML', 5, 6, 10, 10, '18022050', 10),
('75030106944141', 'DOÑA PACHIS', 'PASIÓN MEXICANA', 'TOSTADA POZOLERA 227G', 20, 21, 2, 12, '25022030', 100),
('7503010694441', 'DOÑA PACHIS', 'PASIÓN MEXICANA', 'TOSTADA POZOLERA 227G', 20, 21, 2, 12, '25022030', 100),
('75030157154612', 'LA SANTINA', 'SP', 'TARRITO', 8, 9, 5, 60, '27082026', 100),
('7503015715462', 'LA SANTINA', 'SP', 'TARRITO', 8, 9, 5, 60, '27082026', 100),
('7503015719057', 'VELADORA LA SANTINA', 'SP', 'MEZCALERO', 7, 9, 5, 40, '27082026', 100),
('750301571905711', 'VELADORA LA SANTINA', 'SP', 'MEZCALERO', 7, 9, 5, 40, '27082026', 100),
('7503018544434', 'TARTALETAS', 'SP', 'CON MORAS', 14, 15, 10, 10, '16022050', 10),
('7503018544595', 'WAPAS', 'BARCEL', 'SALSA NEGRA', 8, 10, 1, 100, '15032050', 100),
('7503018544625', 'WAPAS', 'BARCEL', 'FUEGO', 14, 15, 1, 100, '15032050', 1000),
('7503018544823', 'GANSITO', 'SP', 'GOLD', 8, 12, 10, 10, '15022050', 1000),
('750301854482311', 'GANSITO', 'SP', 'GOLD', 8, 10, 10, 10, '15022050', 1),
('7503018544861', 'WATZ', 'BARCEL', 'CHEESE SHOCK', 8, 10, 1, 100, '15032050', 1000),
('7503020760006', 'CHURRITOS', 'SP', 'BOTANAS CHARLY', 10, 12, 10, 10, '18022050', 100),
('7503023222068', 'FIBRAZUL', 'SP', 'FIBRA DE LIMPIEZA', 7, 8, 1, 10, '05032050', 100),
('7503023836135', 'VUALA ', 'GAMESA', 'VAINILLA', 10, 13, 1, 10, '18022050', 10),
('7503023836142', 'VUALA', 'SP', 'CHOCOLATE', 13, 13, 10, 10, '16022050', 10),
('7503023959117', 'CAMEL', 'JTI', 'ACTIVA MAX DOUBLE', 57, 59, 1, 10, '26022050', 100),
('7503023959148', 'CAMEL', 'BRITISH AMERICAN TOBACCO MÉXICO', 'NATURAL FLAVOR', 65, 66, 1, 10, '26022050', 1000),
('7503023959162', 'WINSTON', 'JTI', 'SPARKLING MIX', 50, 52, 1, 10, '26022050', 10),
('7503024416817', 'TECATE', 'CORONA', 'AMBAR', 19, 20, 10, 111, '02032050', 555),
('7503024460070', 'MODELO NEGRA', 'CORONA', '1L', 38, 38, 1, 100, '02032050', 1111),
('7503024460216', 'VICTORIA', 'CORONA', 'CHINGONES', 25, 27, 1, 10, '02032085', 1111),
('7503027753629', 'VOLT', 'COCA COLA', 'YELLOW ENERGY', 15, 17, 1, 10, '22022050', 100),
('7503027753650', 'VOLT', 'SP', 'BLUE ENERGY', 15, 17, 10, 10, '18022050', 10),
('750302775365011', 'VOLT', 'COCA COLA', 'BLUE ENERGY', 15, 17, 1, 10, '22022050', 100),
('7503028643417', 'TARTINAS', 'SP', 'FRESA', 10, 12, 10, 10, '16022050', 100),
('7503028643424', 'TARTINAS', 'SP', 'PIÑA', 8, 12, 10, 10, '16022050', 100),
('7503028643431', 'TARTINAS', 'SP|', 'ZARZAMORAS', 9, 12, 10, 10, '16022050', 100),
('7503028643509', 'GOLDEN NUTS', 'SP', 'ENCHILADOS', 10, 15, 10, 10, '16022050', 10),
('7503028643516', 'GOLDEN NUTS', 'S', 'SALADOS', 15, 15, 10, 10, '16022050', 10),
('7503028643615', 'POP', 'BARCEL', 'MANTEQUILLA', 8, 10, 1, 100, '15032050', 1000),
('7503028643745', 'CHIPS ', 'BARCEL', 'ADOBADAS', 14, 15, 1, 100, '15032050', 1000),
('7503029151638', 'PANQUE', 'SP', 'PAN DULCE', 20, 24, 10, 10, '16022040', 100),
('7503029151782', 'BIMBO CERO CERO', 'SP', 'CHICO', 22, 24, 1, 10, '14022050', 1),
('750302915178211', 'BIMBO CERO CERO', 'SP', 'CHICO', 22, 24, 1, 10, '14022050', 1),
('7503029151829', 'PLATIVOLOS', 'SP', 'GALLETAS SANDWICH', 8, 10, 10, 10, '17022050', 10),
('7503029771904', 'WAPAS', 'BARCEL', 'FUEGO', 8, 10, 1, 100, '15032050', 1000),
('7503030043243', 'WAPAS', 'BARCEL', 'QUESO LOCO', 8, 10, 1, 100, '15032050', 1000),
('7503030199186', 'TOSTACHOS', 'BARCEL', 'FUEGO', 8, 10, 1, 100, '15032050', 1000),
('7503030199612', 'RUNNERS', 'BARCEL', 'FRITURAS DE MAIZ', 8, 10, 1, 100, '15032050', 1000),
('7503030199636', 'CHIPOTLES', 'BARCEL', 'CHIPOTLE Y QUESO', 8, 10, 1, 100, '15032050', 1000),
('7503030199643', 'TOSTACHOS', 'BARCEL', 'QUESO JALAPEÑO', 8, 10, 1, 100, '15032050', 1000),
('7503030199650', 'CHURRITOS STIK', 'BARCEL', 'FUEGO', 8, 10, 1, 100, '15032050', 1000),
('7503030199667', 'CHURRITOS STIK', 'BARCEL', 'CHILE Y LIMON', 8, 10, 1, 100, '15032050', 1000),
('7503030199681', 'CHIPS', 'BARCEL', 'FUEGO', 14, 15, 1, 1010, '15032050', 1000),
('7503030199698', 'WAPAS', 'BARCEL', 'QUESO LOCO', 14, 15, 1, 1001, '15032050', 1000),
('7503030199995', 'ROLES', 'SP', 'CON CANELA', 14, 15, 1, 410, '15022060', 10),
('750303019999511', 'ROLES', 'SP', 'CON CANELA', 14, 15, 1, 410, '15022060', 10),
('7503030374002', 'ROLES', 'SP', 'CANELA GLASEADOS', 11, 15, 10, 10, '15022060', 10),
('750303037400211', 'ROLES', 'SP', 'CANELA GLASEADOS', 11, 15, 10, 10, '15022060', 10),
('7503030374019', 'CROSSANTINES', 'SP', 'RELLENO DE CHOCOLATE', 5, 5, 10, 10, '14022050', 1010);
INSERT INTO `tbl_productos` (`codigo_barras`, `nombre_producto`, `Proveedor`, `descripcion`, `precio_compra`, `precio_venta`, `stock_min`, `stock_max`, `caducidad`, `cantidad_existente`) VALUES
('750303037401911', 'CROSSANTINES', 'SP', 'RELLENO DE CHOCOLATE', 5, 5, 10, 10, '14022050', 1010),
('7503030374309', 'PANQUE', 'SP', 'SABOR CHOCOLATE', 24, 32, 10, 10, '15022060', 10000),
('750303037430911', 'PANQUE', 'SP', 'SABOR CHOCOLATE', 24, 30, 10, 10, '15022060', 10),
('7503030374392', 'BARRITAS', 'SP', 'MORA', 8, 10, 10, 10, '16022040', 10),
('7503030374842', 'MAXITUBO', 'SP', 'SPONCH', 19, 23, 10, 10, '16022050', 10),
('7503030572712', 'EMPANADITAS', 'SP', 'PAN DULCE', 5, 5, 10, 10, '16022050', 10),
('7503031028027', 'MUFFIN', 'SO', 'CHOCOLATE', 10, 12, 10, 10, '16022050', 10),
('7503031028119', 'MOMENTOS VERDADEROS', 'SP', 'PAN DULCE + CAFE', 10, 12, 10, 10, '16022050', 10),
('7503031028379', 'MINI ROSCA', 'S´', 'PANQUE', 14, 15, 10, 10, '14022050', 1010),
('750303102837911', 'MINI ROSCA', 'S´', 'PANQUE', 14, 15, 10, 10, '14022050', 1010),
('7503031028638', 'TARTALETAS', 'SP', 'CON FRESA', 14, 15, 10, 10, '16022050', 10),
('7503031287370', 'PRINCIPE ', 'SP', 'AVELLANA TENTACION', 19, 23, 10, 10, '16022050', 10),
('7503031361186', 'HOTKIS', 'SP', '2 PIEZAS', 14, 15, 10, 10, '14022050', 1010),
('750303136118611', 'HOTKIS', 'SP', '2 PIEZAS', 14, 15, 10, 10, '14022050', 1010),
('7503031361544', 'BIG MIX', 'BARCEL', 'FUEGO', 10, 12, 1, 100, '15032050', 100),
('7503031361551', 'BIG MIX', 'BARCEL', 'JALAPEÑO', 10, 12, 1, 100, '15032050', 100),
('7503031361568', 'BIG MIX', 'BARCEL', 'CLASICO', 8, 10, 0, 100, '15032050', 1000),
('7503032248073', 'TOSTADAS ONDULADAS', 'BIMBO', '240G', 16, 20, 1, 100, '10032050', 10000),
('7503032248257', 'CHIPS', 'BARCEL', 'JALAPEÑO', 8, 10, 1, 100, '15032050', 1000),
('75030551', 'FLAN ', 'FUD ', 'SABOR VAINILLA', 6, 7, 10, 1, '18032021', 8),
('75031053', 'MARLBORO', 'MARLBORO', 'MAGA ICE XPRESS 20´S', 65, 66, 1, 10, '26022050', 1000),
('75035259', 'MARLBORO', 'MARLBORO', 'GOLD CAPSULE 20´S', 65, 66, 1, 10, '26022050', 1000),
('75036393', 'DANETTE', 'DANONE', 'GELANITA DE FRESA', 6, 7, 1, 100, '18032050', 1100),
('75036553', 'CERILLOS LA CENTRAL', 'SP', 'CLASICOS 50PZS', 1, 2, 20, 200, '26082023', 99),
('75038649', 'BONAFONT', 'BONAFONT', 'AGUA NATURAL KIDS 300ML', 4, 6, 10, 50, '02092020', 100),
('75038656', 'BONAFONT', 'BONAFONT', 'KIDS MANZANA 300ML', 4, 6, 5, 50, '02092030', 100),
('75038663', 'BONAFONT', 'BONAFONT', 'UVA KIDS 300ML', 4, 6, 10, 50, '02092030', 100),
('75040840', 'BONAFONT', 'BONAFONT', 'AGUA NATURAL 250ML', 3, 5, 5, 50, '02092050', 100),
('75042660', 'LALA ENTERA', 'LALA', '250ML', 8, 8, 100, 1000, '11032050', 10000),
('75043117', 'BONAFONT', 'BONAFONT', 'KIDS MANGO 300ML', 4, 6, 5, 50, '02092020', 100),
('75044916', 'MARLBORO', 'MARLBORO', 'KRETEK MINT 20 CIGARROS', 65, 66, 1, 10, '26022050', 100),
('75045616', 'TRIDENT', 'TRIDENT', 'YERBA BUENA', 1, 2, 1, 100, '22032050', 100),
('75045623', 'TRIDENT', 'TRINDET', 'MENTA', 2, 2, 1, 100, '22032050', 100),
('75045692', 'BENSON & EDGES', 'MARLBORO', 'POLAR ICE', 65, 66, 10, 10, '26022050', 1010),
('75046521', 'LUCKY STRIKE ', 'BRITISH AMERICAN TOBACCO MÉXICO', 'ORIGINAL', 59, 59, 11, 21, '26022050', 1000),
('75049232', 'KNORK', 'SP', 'MI ARROZ ROJO 17G', 4, 4.5, 4, 20, '25082019', 100),
('75049577', 'CHESTERFIELD', 'GRUPO ALTRIA', '18 ', 30, 33, 5, 30, '05082030', NULL),
('75050047', 'PALL MALL', 'SP', 'IBIZA SUNSET', 56, 59, 1, 10, '26022050', 100),
('75050443', 'BENSON & HYEDGES', 'MARLBORO', 'GOLD PEARL', 66, 66, 1, 10, '26022050', 1010),
('75052836', 'PALL MALL', 'BRITISH AMERICAN TOBACCO MÉXICO', 'TOKYO MINDNIGT', 59, 59, 1, 10, '26022050', 998),
('75053901', 'SALSA CATSUP DEL MONTE', 'SP', '320G', 11, 15, 4, 12, '26072050', 99),
('75055677', 'BONAFONT', 'BONAFONT', 'AGUA NATURAL KIDS 300ML', 5, 6, 5, 50, '02092020', 100),
('75056001', 'MARLBORO', 'MARLBORO', 'DOUBLE FUSION AMBER', 65, 66, 1, 10, '26022050', 1000),
('75056308', 'BENSON HEDGES', 'MARLBORO', 'CRYSTAL VIOLET', 57, 58, 1, 10, '26022050', 1010),
('7506105606053', 'TRIDENT', 'TRIDENT', 'VAL-U-PACK MENTA', 14, 16, 1, 100, '22032050', 100),
('7506105606060', 'TRIDENT', 'TRIDENT', 'VAL-U-PACK', 15, 16, 1, 100, '22032050', 100),
('7506105606077', 'TRIDENT', 'TRIDENT', 'FRESHMINT ', 15, 16, 1, 10, '22032050', 100),
('75061371', 'FUD SNAK', 'FUD', 'DEDOS DE QUESO', 6, 7, 10, 1, '18032021', 5),
('7506192503433', 'SAVILE', 'SP', 'SHAMPOO 24ML', 2, 2.5, 1, 100, '05032060', 100),
('7506192505802', 'RIKO POLLO', 'SP', '3 CUBOS ', 4, 5, 1, 10, '05032050', 100),
('7506192505918', 'VIVE 100', 'SP', 'ENERGIA PARA TU DIA A DIA', 10, 14, 1, 10, '22022050', 101),
('7506192506953', 'VIVE 100', 'SP', 'FUZION', 10, 14, 1, 10, '22022050', 101),
('7506192507349', 'AMPER', 'PEPSI', 'ENERGY', 13, 15, 20, 100, '11032021', 50),
('7506192507417', 'VIVE 100', 'SP', 'GIN-CITRUS', 14, 14, 1, 10, '22022050', 101),
('7506192507714', 'AMPER ', 'SP', 'BLUEBERRY', 14, 15, 1, 100, '02032050', 552),
('7506192508001', 'VIVE100', 'SP', 'GOYI', 10, 14, 1, 100, '22022050', 101),
('7506192508209', 'VITALOE', 'SP', 'MANDARINA CON NARANJA', 10, 12, 1, 10, '22022050', 101),
('7506195169995', 'SAQLVO LIMON', 'SP', '1KG', 42, 44, 1, 100, '05032050', 1000),
('7506195178188', 'ALWAYS', 'SP', 'NOCHES TRANQUILAS', 33, 34, 1, 100, '1752050', 1100),
('7506195196984', 'SALVO', 'SP ', '300ML', 16, 17.5, 1, 10, '05032050', 95),
('7506241204144', 'VOLT ', 'SP', 'FOCUS ENERGY', 14, 17, 1, 10, '02032050', 50),
('7506241205646', 'VOLT', 'SP', 'PINK ENERGY', 15, 17, 1, 10, '02032050', 50),
('7506306221215', 'SAVILE ', 'SP', 'SHAMPOO 24ML', 2, 2.5, 2, 101, '05032050', 100),
('7506306231955', 'MAGNUM', 'HOLANDA', 'MANZANA Y CANELA 100ML', 23, 25, 5, 40, '03052017', 100),
('7506306231962', 'MAGNUM', 'HOLANDA', 'CARAMELO Y DULCE 100ML', 23, 25, 5, 40, '02082018', 100),
('7506306231979', 'MAGNUM', 'HOLANDA', 'CAFE Y GALLETAS 100ML', 23, 25, 2, 12, '03062017', 100),
('7506306238336', 'ZEST', 'SP', 'JABON DE TOCADOR', 14, 15, 1, 100, '05032050', 100),
('7506306307964', 'MAYONESA HELLMANNS', 'SP', 'CLASICA+LIMON 170G', 13, 14, 5, 24, '26122016', 100),
('7506306400115', 'CHIPS AHOY', 'HOLANDA', '473ML', 30, 32, 2, 12, '03082017', 100),
('7506306412354', 'MAX', 'HOLANDA', 'APOLO PINTA LENGUA 50ML', 3, 5, 10, 50, '03042017', 100),
('7506306412705', 'MAX', 'HOLANDA', 'HERSHEY\'S 65ML', 9, 10, 4, 50, '03072018', 100),
('7506306413009', 'CORNETTO', 'HOLANDA', 'OREO 120ML', 18, 20, 5, 50, '03072030', 100),
('7506306413016', 'MAX', 'HOLANDA', 'PELON PELO RICO 60ML', 8, 10, 5, 40, '03042018', 100),
('7506306413054', 'SOLERO PARADISE', 'HOLANDA', 'FRUTOS ROJOS 100ML', 20, 22, 5, 50, '03072050', 100),
('7506306413177', 'MORDISCO', 'HOLANDA', 'BROWNIE 113ML', 12, 14, 5, 40, '02022017', 100),
('7506306413320', 'MAGNUM', 'HOLANDA', 'COOKIES & CREAM', 28, 30, 1, 100, '17032055', 1000),
('7506306413368', 'MAGNUM', 'HOLANDA', 'ALMENDRAS 100ML', 22, 23, 5, 40, '03082018', 100),
('7506306413375', 'MAGNUM', 'HOLANDA', 'CLASICA 100ML', 20, 22, 5, 40, '03032018', 100),
('7506306413399', 'MAGNUM', 'HOLANDA', 'YOGHURT SUPREMO 100ML', 22, 24, 5, 40, '03042018', 100),
('7506306413405', 'MAGNUM', 'HOLANDA', 'INFINITY FRAMBUESA 100ML', 23, 25, 2, 12, '03062018', 100),
('7506306413412', 'MAGNUM', 'HOLANDA', 'INFINITY CARAMELO 100ML', 23, 25, 5, 40, '03022018', 100),
('7506306413436', 'CORNETTO', 'HOLANDA', 'CHEESECAKE FRUTOS ROJOS 120ML', 17, 19, 5, 40, '03032017', 100),
('7506306414471', 'CORNETTO', 'HOLANDA', 'BROWNIE & VAINILLA', 24, 25, 1, 100, '17032055', 100),
('7506306414945', 'SOLERO ARTESANAL', 'HOLANDA', 'MANGOS DE NAYARIT', 17, 18, 1, 1000, '17032040', 100),
('7506306414969', 'SOLERO', 'HOLANDA', 'COCOS DE VERDAD', 17, 18, 1, 100, '17032080', 1000),
('7506306415010', 'MAGNUM', 'HOLANDA', 'PRALINE', 28, 30, 1, 100, '17032050', 1000),
('7506306415294', 'MAGNUM', 'HOLANDA', 'DOUBLE CHOCOLATE', 33, 34, 1, 100, '17032050', 1000),
('7506306415423', 'MORDISKO', 'HOLANDA', 'CHOCO AVELLANA', 14, 15, 1, 100, '17032050', 100),
('7506306415560', 'CHIKI POP YUMI', 'HOLANDA', 'DISTROLLER', 1, 15, 1, 100, '17032050', 1000),
('7506306415775', 'MAGNUM', 'HOLANDA', 'ALMENDRAS', 27, 28, 1, 100, '17032050', 1000),
('7506306415881', 'MAGNUM', 'HOLANDA', 'DOUBLE FRAMBUESA', 33, 34, 1, 100, '17032050', 1000),
('7506306415980', 'MIRDISKO', 'HOLANDA', 'PAY DE LIMON', 12, 13, 1, 100, '17032050', 1000),
('7506306416079', 'MAGNUM', 'HOLANDA', 'CHOCOLATE BLANCO', 28, 30, 100, 300, '17032050', 1000),
('7506306416215', 'CORNNETTO', 'HOLANDA', 'FRESAS  CON CREMA', 24, 25, 1, 100, '17032050', 100),
('7506306416253', 'CHOCO CREAM', 'HOLANDA', 'VAINILLA', 12, 13, 1, 100, '17032050', 1000),
('7506306416260', 'CHOCO CREAM', 'HOLANDA', 'VAINILLA CON ALMENDRAS', 11, 13, 1, 100, '17032050', 100),
('7506339304824', 'SALVO', 'SP', 'LIMON 750ML', 34, 36, 5, 10, '06082050', 100),
('7506339394719', 'NATURELLA', 'SP', 'CUIDADO NOCTURNO', 27, 28, 1, 100, '17032050', 1100),
('75063504', 'LUCKY STRIKE ', 'BRITISH AMERICAN TOBACCO MÉXICO', 'INDIGO WILD', 66, 66, 1, 10, '26022050', 1000),
('75063771', 'CHESTERFIELD', 'MARLBORO', 'REMIX PASSION', 52, 53, 1, 11, '26052050', 1010),
('75063801', 'CHESTERFIELD', 'MARLBORO', 'REMIX ', 52, 53, 1, 10, '26022080', 1010),
('7506425600397', 'SERVILLETAS PETALO', 'PETALO', '420 SERVILLETAS', 44, 45, 100, 1, '30072022', 100),
('7506425602759', 'SERVILLETAS DELSEY', 'DELSEY', '100 SERVILLETAS', 10, 11, 100, 1, '29102022', 100),
('7506425605330', 'VOGUE', 'SP', '600 HOJAS', 38, 38, 1, 100, '17032050', 1100),
('7506425606917', 'ESCUDO', 'SP', 'JABON', 14, 15.5, 1, 100, '05032050', 100),
('7506425606924', 'ESCUDO', 'SP', 'JABON CORPORAL', 15.5, 15.5, 1, 10, '05032050', 100),
('7506443101968', 'DANMIX', 'DANONE', 'M&M', 16, 17, 1, 100, '18032050', 1100),
('7506443102316', 'ACTIVIA', 'DANONE', 'CHIA', 10, 12, 1, 100, '18032050', 100),
('7506443104471', 'DNP', 'DANONE', 'FRESA 450G', 16, 17, 1, 100, '18032050', 1000),
('7506443105232', 'DANONE MIX', 'DANONE', 'YOGHURT SABOR PLATANO', 12, 13, 1, 100, '18032050', 100),
('7506443105386', 'SNP', 'DANONE', 'PIÑA COCO 450G', 16, 17, 1, 100, '18032050', 1000),
('75064648', 'PALL MALL', 'BRITISH AMERICAN TOBACCO MÉXICO', 'MYKONOS NIGHTFALL', 59, 59, 1, 10, '26022050', 1000),
('75064747', 'SHOTS ', 'BRITISH AMERICAN TOBACCO MÉXICO', '15 CIGARROS', 37, 39, 1, 10, '26022050', 999),
('75064754', 'SHOTS ', 'BRITISH AMERICAN TOBACCO MÉXICO', '25 CIGARROS', 57, 58, 1, 10, '26022050', 1000),
('75065560', 'MONTANA ', 'BRITISH AMERICAN TOBACCO MÉXICO', '20 CIGARROS', 52, 53, 1, 10, '26022050', 1010),
('75066345', 'MARLBORO', 'MARLBORO', 'FUSION SUMMER 20´S', 56, 59, 10, 10, '26022050', 1000),
('75066932', 'TRIDENT', 'TRIDENT', 'CANELA', 1, 2, 1, 100, '22032050', 100),
('75067823', 'CHESTERFIELD', 'MARLBORO', '15 CIGARROS', 38, 39, 1, 10, '26022050', 998),
('75067854', 'CHESTERFIELD', 'MARLBORO', '25 CIGARROS ', 57, 58, 1, 10, '26022050', 1009),
('75068738', 'MARLBORO', 'MARLBORO', 'GOLD 20´S', 65, 66, 10, 10, '26022021', 1000),
('75068769', 'MARLBORO', 'MARLBORO', 'DOUBLE FUSION VELVET', 65, 66, 1, 10, '26022050', 1010),
('75068776', 'BENSON & EDGES', 'MARLBORO', 'GOLD', 65, 66, 1, 10, '26022050', 1010),
('75068783', 'MARLBORO', 'MARLBORO', 'DOUBLE FUSSION RUBY', 66, 66, 1, 10, '26022050', 1010),
('75069490', 'PALL MALL', 'BRITISH AMERICAN TOBACCO MÉXICO', 'CALIFORNIA NIGTHS', 58, 59, 1, 10, '26022050', 1000),
('75069506', 'CHESTERFIELD', 'MARLBORO', 'ORIGINAL REMIX 20 CIGARROS ', 52, 53, 1, 10, '26022050', 1010),
('75069902', 'L&M', 'MARLBORO', 'FINAMENTE CORTADO', 39, 40, 1, 10, '26022060', 1010),
('75070090', 'PALL MALL', 'BRITISH AMERICAN TOBACCO MÉXICO', 'MIX PACK', 52, 53, 1, 10, '26022050', 1000),
('75071295', 'PALL MALL', 'BRITISH AMERICAN TOBACCO MÉXICO', 'ALASKA DUSK', 58, 59, 1, 10, '26022050', 9),
('75073237', 'BUBBALOO', 'BUBBALOO', 'PIÑA CHAMOY', 1, 1, 1, 100, '22032050', 100),
('75073244', 'BUBBALOO', 'BUBBALOO', 'FRESA', 1, 1, 1, 100, '22032050', 100),
('75073251', 'BUBBALOO', 'BUBBALOO', 'MENTA', 1, 1, 1, 100, '22032050', 100),
('75073268', 'BUBBALOO', 'BUBBALOO', 'MORA AZUL', 1, 1, 1, 100, '22032050', 100),
('75073275', 'BUBBALOO', 'BUBBALOO', 'PLATANO', 1, 1, 1, 100, '22032050', 100),
('75073282', 'BUBBALOO', 'BUBBALOO', 'TUTTI FRUTTI', 1, 1, 1, 100, '22032050', 100),
('75073299', 'BUBBALOO', 'BUBBALOO', 'YERBA BUENA', 1, 1, 1, 100, '22032050', 100),
('7509546006437', 'FABULOSO', 'SP', 'AROMA DE BEBE 1L', 14, 16, 5, 10, '06082016', 100),
('7509546007083', 'COLGATE ', 'SP', 'TOTAL 12 ', 17, 18, 1, 100, '17032060', 1000),
('7509546008202', 'FABULOSO', 'SP', 'ENERGIA NARANJA 1L', 14, 25, 5, 10, '06082050', 100),
('7509546008295', 'FABULOSO ', 'SP', 'PASION DE FRUTAS', 24, 25, 1, 100, '05032050', 1000),
('7509546016306', 'SUAVITEL CUIDADO SUPERIOR', 'SP', 'FRESCA PRIMAVERA', 23, 24, 10, 110, '05032050', 100),
('7509546016313', 'SUAVITEL ', 'SP ', 'FRESCO AROMA DE SOL 850ML', 14, 16, 5, 10, '01082016', 100),
('7509546017808', 'SUAVITEL', 'SP', 'ADIOS AL ENJUAGUE 500ML', 11, 13.5, 10, 15, '01012050', 100),
('7509546032856', 'SUAVITEL', 'SP', 'ABRAZO DE AMOR 750ML', 18, 26, 5, 15, '06082050', 100),
('7509546043579', 'SUAVITEL', 'SP', 'BABY ANTIBACTERIAL 850ML', 15, 16, 5, 30, '05082020', 100),
('7509546045689', 'VEL ROSITA', 'SP', '450ML', 25, 26, 10, 110, '05032050', 1000),
('7509546059167', 'PALMOLIVE', 'SP', 'VERDE', 11, 13, 5, 10, '06082016', NULL),
('7509546059211', 'PALMOLIVE', 'SP', 'FRESA', 11, 13, 5, 10, '06082016', NULL),
('7509546059228', 'PALMOLIVE', 'SP', 'COCO Y ALGODON 160G', 11, 13, 5, 10, '06082016', 100),
('7509546059235', 'PALMOLIVE', 'SP', 'YOGUTH Y ACEITE DE ALMENDRAS 160G', 11, 12, 5, 24, '25082018', 100),
('7509546059273', 'PALMOLIVE', 'SP', 'NEUTRO BALANCE 160G', 10, 13, 5, 30, '05082020', 100),
('7509546067513', 'SUAVITEL', 'SP', 'COMPLETE 1 LITRO', 23, 26, 5, 15, '06082050', 100),
('7509546067520', 'SUAVITEL COMPLETE', 'SP', 'AROMA DE SOL', 23, 24, 1, 100, '05032050', 100),
('7509546067551', 'SUAVITEL', 'SP', 'ORQUIDEASBLANCAS', 17, 19, 5, 30, '05082017', NULL),
('7509546068909', 'COLGATE', 'SP', 'TRIPLE ACCION', 18, 18.5, 1, 100, '17032050', 999),
('7509546074627', 'PALMOLIVE', 'SO', 'SENSACION HUMECTANTE', 15, 16, 1, 10, '05032050', 100),
('7509546074979', 'PALMOLIVE', 'SP', 'DERMOLIMPIADOR', 16, 16, 1, 100, '05032050', 100),
('752216031094', 'JAGUAR PACTIV', 'SP', '#8 INROMPIBLE 50PZ', 14, 18, 5, 24, '27082050', 100),
('752216051047', 'JAGUAR PACTIV', 'SP', 'PLATO LISO #6 20PZ', 6, 8, 5, 24, '27082026', 100),
('752216081044', 'CHAROLA JAGUAR', 'SP', '#66 TERMICA 50PZAS', 15, 17, 5, 12, '26082026', 100),
('752216095263', 'TAPAS JAGUAR', 'SP', '1 Y1\\2LL 25PZ', 20, 22, 5, 30, '27082026', 100),
('756702133149', 'CHARRAS', 'PASION MEXICANA', 'TOSTADAS 225G', 19, 21, 2, 12, '01122016', 100),
('756702134719', 'TOSTADAS ONDULADAS', 'SP', 'CHARRAS', 20, 24, 10, 10, '14022050', 10),
('757528001742', 'HOT NUTS', 'SP', 'FUEGO', 5, 8, 10, 10, '16022050', 10),
('757528001889', 'CHIPS', 'BARCEL', 'FUEGO170G', 36, 37, 1, 100, '15032050', 100),
('757528012564', 'POP', 'BARCEL', 'KARAMELADAS', 4, 5, 1, 100, '15032050', 100),
('757528020859', 'PAPATINAS', 'BARCEL', 'FUEGO', 6, 7, 1, 100, '150520501', 1000),
('757528020897', 'GOLDEN NUTS', 'SP', 'PIPITAS', 10, 12, 10, 10, '16022050', 10),
('757528033330', 'LUNETAS', 'S´P', 'DULCE CONFITADO', 10, 12, 10, 10, '16022050', 10),
('757528035877', 'HOT NUTS', 'BARCEL', 'ORIGINAL', 9, 10, 1, 100, '12032050', 1000),
('757528035884', 'HOT NUTS', 'SP', 'FUEGO', 10, 10, 10, 10, '16022050', 10),
('757528035891', 'CACAHUATES KIYAKIS', 'BIMBO', 'CLASICO', 9, 10, 1, 110, '12032040', 1000),
('757528036638', 'VALENTONES', 'BARCEL', 'FUEGO', 8, 10, 1, 100, '15032050', 1000),
('757528039073', 'CHOCO RETAS', 'SP', 'DULCE SABOR MENTA', 10, 12, 10, 10, '16022040', 100),
('757528039080', 'DULCI GOMAS', 'SP', 'GOMITAS', 10, 12, 10, 10, '16022050', 100),
('757528039097', 'GOMILOCAS', 'SP', 'DIENTES', 10, 12, 1, 10, '16022050', 100),
('757528039103', 'GOMILOCAS', 'SP', 'PINGUINOS', 10, 12, 10, 10, '16022050', 100),
('757528039110', 'KRANKY', 'SP', 'HOJUELA DE MAIZ ', 10, 12, 10, 10, '16022060', 1000),
('757528039127', 'MORITAS', 'SP', 'GOMAS', 10, 12, 10, 10, '16022050', 1000),
('757528039134', 'PANDITAS', 'SP', 'CLASICOS', 10, 12, 10, 10, '16022050', 9),
('757528039141', 'PANDITAS', 'SP', 'ACIDOS', 10, 12, 1, 10, '16022050', 1000),
('757528039172', 'PANDITAS', 'SP', 'RELLENOS', 10, 12, 10, 10, '16022050', 10),
('757528039189', 'PANDITAS', 'SO', 'ROJOS', 10, 12, 1, 101, '16022050', 100),
('757528039196', 'PASITAS', 'SP', 'CON COBERTURA DE CHOCOLATE', 10, 12, 1, 10, '16022050', 1000),
('757528039240', 'ALMENDRAS', 'SO', 'CON COBERTURA DE CHOCOLATE', 10, 12, 10, 10, '16022050', 10),
('757528039257', 'GOMILOCAS', 'SP', 'HAMBURGUESAS', 10, 12, 10, 10, '16022055', 1000),
('757528039578', 'PAPAS TOREADAS', 'BARCEL', 'CHILE ABANERO', 12, 13, 1, 100, '15032050', 1000),
('757528040642', 'GOLDEN NUTS', 'BARCEL', 'SURTIDO SELECTO', 9, 10, 1, 110, '12032050', 1000),
('757528041045', 'TAKIS', 'BARCEL', 'FUEGO', 14, 15, 1, 100, '15032050', 1000),
('757528042400', 'TAKIS', 'BARCEL', 'ORIGINAL', 10, 12, 1, 100, '15032050', 1000),
('757528042417', 'TAKIS', 'BARCEL', 'FUEGO', 10, 12, 1, 100, '15032050', 1000),
('757528042424', 'TAKIS', 'BARCEL', 'HUAKAMOLES', 10, 12, 1, 100, '15032050', 1000),
('757528042431', 'TAKIS', 'BARCEL', 'SALSA BRAVA', 10, 12, 1, 100, '15032050', 1000),
('757528042592', 'CHIPS', 'BARCEL', 'SAL', 14, 15, 1, 100, '15032050', 1000),
('757528042608', 'CHIPS', 'BARCEL', 'JALAPEÑO', 14, 15, 1, 100, '15032050', 1000),
('757528043049', 'CHIPS', 'BARCEL', 'ADOBADAS', 14, 15, 1, 100, '15032050', 1000),
('757528044015', 'CACAHUATES KIYAKIS', 'BIMBO', 'CLASICO', 14, 15, 1, 100, '12032050', 1000),
('757528044121', 'HOT NUTS', 'SP', 'ORIGINAL', 10, 15, 10, 10, '16022050', 10),
('757528044138', 'HOT NUTS', 'BARCEL', 'FUEGO', 14, 15, 1, 100, '12032050', 1000),
('757528044145', 'GOLDEN NUTS', 'SP', 'ENCHILADOS', 10, 10, 10, 10, '16022050', 10),
('757528044152', 'GOLDEN NUTS', 'SP', 'SALADOS', 10, 10, 10, 10, '16022050', 10),
('758104000159', 'BONAFONT', 'BONAFONT', 'AGUA NATURAL 1.5LT', 9, 13, 50, 200, '02092050', 100),
('758104001712', 'BONAFONT', 'BONAFONT', 'NATURAL 600ML', 5, 8, 20, 200, '02092040', 100),
('758104001972', 'BONAFONT', 'BONAFONT', 'AGUA NATURAL 2LTS', 11, 15, 50, 200, '02092050', 100),
('758104002511', 'BONAFONT', 'BONAFONT', 'JUGO DE NARANJA 1.5LTS', 13, 15, 10, 50, '02092030', 100),
('758104002535', 'BONAFONT', 'BONAFONT', 'JUGO DE MANZANA 1.5LT', 13, 15, 5, 50, '25122030', 100),
('758104002986', 'BONAFONT', 'BONAFONT', 'JUGO DE MANGO 1.5LT', 13, 15, 5, 50, '02092030', 100),
('758104003907', 'BONAFONT', 'BONAFONT', 'LEVITE FRESA 1LT', 8, 10, 20, 80, '19042017', 100),
('758104005147', 'BONAFONT', 'BONAFONT', 'LEVITE PIÑACOCO 1LT', 8, 10, 20, 80, '22042017', 100),
('758104005246', 'BONAFONT', 'BONAFONT', 'JUIZZY JAMAICA 1LT', 8, 10, 20, 80, '28022017', 100),
('758104006229', 'BONAFONT JUIZZY', 'BONAFONT', 'AGUA FRESCA DE NARANJA 1LT ', 15, 17, 1, 101, '01032056', 1000),
('758104006328', 'BONAFONT JUIZZY', 'BONAFONT', 'AGUA FRESCA DE JAMICA 1LT', 15, 17, 10, 1010, '01032050', 1000),
('758104006731', 'BONAFONT LEVITE', 'BONAFONT', 'AGUA INFUSIONADA SABOR LIMON 1L', 15, 17, 1, 10, '01032050', 10101),
('758104006939', 'BONAFONT JUIZZY', 'BONAFONT', 'AGUA FRESCA DE PIÑA 1LT', 15, 17, 1, 10, '01032050', 1000),
('758104006984', 'BONAFONT JUIZZY', 'BONAFONT', 'AGUA FRESCA DE UVA', 15, 17, 1, 10, '01032050', 1000),
('758104006991', 'BONAFONT', 'BONAFONT', 'JUIZZY GUANABANA', 12, 13, 1, 100, '16032050', 1000),
('758104007714', 'BONAFONT JUIZZY', 'BONAFONT', '4L AGUA FRESCA', 33, 33, 1, 100, '17032050', 1000),
('758104100422', 'BONAFONT', 'BONAFONT', 'AGUA NATURAL 1LT', 7, 11, 20, 200, '02092050', 100),
('7590002040003', 'DOWNY ', 'SP', 'PUREZA SILVESTRE 800ML', 20, 25, 5, 10, '31122040', 100),
('7622210265999', 'PHILADELPHIA', 'FUD', '144G', 20, 22, 10, 10, '18032021', 5),
('7622210267825', 'HALLS', 'SP', 'CEREZA', 7, 8, 1, 100, '22032050', 100),
('7622210267863', 'HALLS', 'SP', 'MIEL', 7, 8, 1, 100, '22032050', 100),
('7622210427106', 'HALLS', 'SP', 'EXTRA STRONG', 7, 8, 1, 100, '22032050', 100),
('7622210464835', 'TRIDET', 'TRIDENT', 'COOL BUBBLE', 7, 8, 1, 100, '22032050', 100),
('7622210551368', 'TRIDENT', 'TRIDENT', 'EXTRA STRONG ', 16, 16, 1, 100, '22032050', 100),
('7622210561558', 'PHILADELPHIA', 'FUD', '180G', 33, 34, 1, 100, '18032050', 100),
('7622210581914', 'TRIDENT', 'TRIDENT', 'MENTA', 5, 6, 1, 100, '22032050', 1000),
('7622210774163', 'TRIDENT', 'TRIDENT', 'FRESH MIX EUCALIPTO', 16, 16, 1, 100, '22032050', 100),
('7622210833662', 'GALLETAS OREO', 'SP', 'SABOR VAINILLA', 14, 15, 10, 10, '16022050', 10),
('7622210938282', 'TRIDENT', 'TRIDENT', 'VAL-U-PACK', 15, 16, 1, 100, '22032060', 100),
('7622210938367', 'TRIDENT', 'TRIDENT', 'XTWIST', 7, 8, 1, 100, '22032050', 1000),
('7622210938732', 'TRIDENT', 'TRIDENT', 'XTWIST', 7, 8, 1, 100, '22032050', 1000),
('7702018880409', 'GILLETE ', 'GILLETE ', 'PRESTOBARBA 3', 23, 24, 1, 100, '05032050', 100),
('7790073034257', 'ALWAYS', 'SP', 'ACTIVE 10PZS', 20, 21, 5, 12, '27082026', 100),
('779007303425711', 'ALWAYS', 'SP', 'ACTIVE 10PZS', 20, 21, 5, 12, '27082026', 100),
('789742895050', 'NUTELLA', 'SP', '350G', 73, 74, 1, 100, '17032050', 1000),
('793573950079', 'RED COLA', 'JARRITOS', '3LT ', 23, 25, 1, 10, '18022050', 10),
('8000920200087', 'VIENNETA', 'HOLANDA', 'CHOCOLATE', 83, 84, 1, 100, '17032050', 1000),
('80050100', 'NUTELLA', 'SP', '&GO', 25, 26.5, 1, 100, '17032050', 1000),
('80051831', 'KINDER SORPRESA', 'KINDER', 'KATOONS', 20, 22, 1, 100, '22032060', 100),
('80135692', 'KINDER SORPRESA', 'KINDER', 'JUSTICE LEAGUE', 20, 22, 1, 100, '22032050', 100),
('80892816', 'KINDER SORPRESA', 'KINDER', 'MINION', 20, 22, 1, 100, '22032050', 100),
('823703170074', 'ENER+PLUS', 'SP', 'FOCO LED', 40, 42, 1, 100, '17032050', 1000),
('823703800018', 'MAXIMA', 'SP', 'MITADES DE DURAZNO EN ALMIBAR 480G', 45, 47, 4, 12, '21012050', 100),
('823703800032', 'MAXIMA', 'SP', 'TROZOS DE PIÑA EN ALMIBAR 800G', 26, 28.5, 4, 12, '26122017', 100),
('823703800148', 'PAPEL ALUMINIO MAXIMA', 'SP', '1 ROLLO 10MTS', 29, 30, 5, 24, '02092026', 100),
('823703801008', 'ACEITUNAS', 'SP', 'CON HUESO', 28, 29.5, 1, 101, '01032050', 100),
('823703801015', 'ACEITUNAS DESHUESADAS', 'SP', 'MAXIMA PREMIUM 235G', 21, 22, 5, 24, '26032018', 100),
('823703801824', 'REBANADAS DE PIÑA', 'MAXIMA', 'EN ALMIBAR', 42, 42, 1, 100, '16032050', 1000),
('8710908410314', 'ZEST', 'SP', 'JABON LIQUIDO CORPORAL', 20, 22, 1, 100, '05032050', 1000),
('8711327446045', 'VIENNETTA', 'HOLANDA', 'CAPPUCCINO', 83, 84, 1, 100, '17032050', 1000),
('8802257222127', 'PLUS ROYAL', 'SP', 'NO 200 COLORES VARIADOS', 14, 15, 4, 12, '26082020', 10),
('9002490100070', 'RED BULL', 'SP', 'ENERGY DRINK', 30, 33, 1, 100, '02032050', 555);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_proveedores`
--

CREATE TABLE `tbl_proveedores` (
  `id_Proveedor` varchar(45) NOT NULL,
  `telefono_Proveedor` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_sucursales`
--

CREATE TABLE `tbl_sucursales` (
  `id_Sucursales` bigint(20) NOT NULL,
  `nombre_Sucursal` varchar(100) DEFAULT NULL,
  `direccion_Sucursal` varchar(255) DEFAULT NULL,
  `clave_Sucursal` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tbl_sucursales`
--

INSERT INTO `tbl_sucursales` (`id_Sucursales`, `nombre_Sucursal`, `direccion_Sucursal`, `clave_Sucursal`) VALUES
(1, 'LeadTo', 's/d', 'Lt021'),
(2, 'El Puma', 's/d', 'ep21');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_tickets`
--

CREATE TABLE `tbl_tickets` (
  `folio_Ventas` mediumint(9) DEFAULT NULL,
  `id_Productos` varchar(50) DEFAULT NULL,
  `nombre_Producto` varchar(45) DEFAULT NULL,
  `descriocion_producto` varchar(100) DEFAULT NULL,
  `cantidad_Producto` double DEFAULT NULL,
  `precio_Unitario_Producto` double DEFAULT NULL,
  `costo_Total_Producto` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tbl_tickets`
--

INSERT INTO `tbl_tickets` (`folio_Ventas`, `id_Productos`, `nombre_Producto`, `descriocion_producto`, `cantidad_Producto`, `precio_Unitario_Producto`, `costo_Total_Producto`) VALUES
(0, '011848455570', 'ACHIOTE LA ANITA', '110G', 1, 12, 12),
(0, '014800515336', 'CLAMATO', '946ML', 1, 32, 32),
(0, '032239052000', 'DEL VALLE ', 'MANGO 413 ML', 1, 10, 10),
(1, '032239052000', 'DEL VALLE ', 'MANGO 413 ML', 2, 10, 20),
(1, '014800515336', 'CLAMATO', '946ML', 1, 32, 32),
(2, '014800515336', 'CLAMATO', '946ML', 2, 32, 64),
(2, '011848455570', 'ACHIOTE LA ANITA', '110G', 1, 12, 12),
(3, '024474393529', 'COSECHA PURA', 'PIÑA 1LT', 1, 17, 17),
(3, '097339000047', 'VALENTINA', 'ETIQUETA NEGRA 1LT', 1, 16.5, 16.5),
(3, '097339000061', 'VALENTINA', 'ETIQUETA NEGRA 370ML', 1, 9.5, 9.5),
(4, '014800515329', 'CLAMATO', '473ML', 1, 18, 18),
(4, '024474393529', 'COSECHA PURA', 'PIÑA 1LT', 1, 17, 17),
(4, '011848455570', 'ACHIOTE LA ANITA', '110G', 1, 12, 12),
(5, '010900000406', 'ALUMINIO REYNOLDS WRAP', '1 ROLLO 7.6MTS', 2, 27.5, 55),
(5, '014800515336', 'CLAMATO', '946ML', 1, 32, 32),
(6, '123', 'AGUACATE', 'HASS', 1, 60, 60);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_tipo_pagos`
--

CREATE TABLE `tbl_tipo_pagos` (
  `id_Pago` int(11) NOT NULL,
  `tipo_Pago` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tbl_tipo_pagos`
--

INSERT INTO `tbl_tipo_pagos` (`id_Pago`, `tipo_Pago`) VALUES
(1, 'EFECTIVO'),
(2, 'TARJETA'),
(3, 'CODIGOQR'),
(4, 'CODIGOB');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_usuarios`
--

CREATE TABLE `tbl_usuarios` (
  `id_Usuario` bigint(20) NOT NULL,
  `id_Sucursal` bigint(20) DEFAULT NULL,
  `nombre_Usuario` varchar(100) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `password` varchar(45) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `permiso` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_ventas`
--

CREATE TABLE `tbl_ventas` (
  `id_Venta` mediumint(9) NOT NULL,
  `folio_Venta` mediumint(9) DEFAULT NULL,
  `fecha_Venta` date DEFAULT NULL,
  `id_Usuario` int(11) DEFAULT NULL,
  `monto_Total_Venta` double DEFAULT NULL,
  `id_Sucursal` int(11) DEFAULT NULL,
  `id_Tipo_Pago` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tbl_ventas`
--

INSERT INTO `tbl_ventas` (`id_Venta`, `folio_Venta`, `fecha_Venta`, `id_Usuario`, `monto_Total_Venta`, `id_Sucursal`, `id_Tipo_Pago`) VALUES
(0, 0, '2020-12-23', 1, 54, 1, 1),
(1, 1, '2020-12-23', 1, 52, 1, 1),
(2, 2, '2020-12-23', 1, 76, 1, 1),
(3, 3, '2020-12-23', 1, 43, 1, 1),
(4, 4, '2020-12-23', 1, 47, 1, 1),
(5, 5, '2021-01-04', 1, 87, 1, 1),
(6, 6, '2021-01-13', 1, 60, 1, 1);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `tbl_bascula`
--
ALTER TABLE `tbl_bascula`
  ADD PRIMARY KEY (`id_Bascula`);

--
-- Indices de la tabla `tbl_cajas`
--
ALTER TABLE `tbl_cajas`
  ADD PRIMARY KEY (`id_Caja`);

--
-- Indices de la tabla `tbl_productos`
--
ALTER TABLE `tbl_productos`
  ADD PRIMARY KEY (`codigo_barras`);

--
-- Indices de la tabla `tbl_proveedores`
--
ALTER TABLE `tbl_proveedores`
  ADD PRIMARY KEY (`id_Proveedor`);

--
-- Indices de la tabla `tbl_sucursales`
--
ALTER TABLE `tbl_sucursales`
  ADD PRIMARY KEY (`id_Sucursales`);

--
-- Indices de la tabla `tbl_tipo_pagos`
--
ALTER TABLE `tbl_tipo_pagos`
  ADD PRIMARY KEY (`id_Pago`);

--
-- Indices de la tabla `tbl_usuarios`
--
ALTER TABLE `tbl_usuarios`
  ADD PRIMARY KEY (`id_Usuario`);

--
-- Indices de la tabla `tbl_ventas`
--
ALTER TABLE `tbl_ventas`
  ADD PRIMARY KEY (`id_Venta`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `tbl_cajas`
--
ALTER TABLE `tbl_cajas`
  MODIFY `id_Caja` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT de la tabla `tbl_sucursales`
--
ALTER TABLE `tbl_sucursales`
  MODIFY `id_Sucursales` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `tbl_usuarios`
--
ALTER TABLE `tbl_usuarios`
  MODIFY `id_Usuario` bigint(20) NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
