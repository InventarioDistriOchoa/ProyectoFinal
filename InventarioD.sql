CREATE DATABASE  IF NOT EXISTS `inventariodistriochoa` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;
USE `inventariodistriochoa`;
-- MySQL dump 10.13  Distrib 8.0.40, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: inventariodistriochoa
-- ------------------------------------------------------
-- Server version	5.5.5-10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `categorias`
--

DROP TABLE IF EXISTS `categorias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categorias` (
  `idCategoria` int(11) NOT NULL,
  `Nombre_Categoria` varchar(60) NOT NULL,
  `descripcion` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`idCategoria`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categorias`
--

LOCK TABLES `categorias` WRITE;
/*!40000 ALTER TABLE `categorias` DISABLE KEYS */;
INSERT INTO `categorias` VALUES (1,'Frutas','Alimentos dulces y jugosos como manzana o piña'),(2,'Verduras','Hortalizas verdes como lechuga o espinaca'),(3,'Tuberculos','Raíces comestibles como papa o yuca'),(4,'Legumbres','Semillas en vaina como fríjol o lenteja'),(5,'Hierbas Aromaticas','Plantas aromáticas como cilantro o albahaca');
/*!40000 ALTER TABLE `categorias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `detalleventa`
--

DROP TABLE IF EXISTS `detalleventa`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `detalleventa` (
  `idDetalleVenta` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `PrecioUnitario` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  `Venta_idVenta` int(11) NOT NULL,
  `Producto_idProducto` int(11) NOT NULL,
  PRIMARY KEY (`idDetalleVenta`),
  KEY `Venta_idVenta` (`Venta_idVenta`),
  KEY `Producto_idProducto` (`Producto_idProducto`),
  CONSTRAINT `detalleventa_ibfk_1` FOREIGN KEY (`Venta_idVenta`) REFERENCES `venta` (`idVenta`),
  CONSTRAINT `detalleventa_ibfk_2` FOREIGN KEY (`Producto_idProducto`) REFERENCES `productos` (`idProducto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detalleventa`
--

LOCK TABLES `detalleventa` WRITE;
/*!40000 ALTER TABLE `detalleventa` DISABLE KEYS */;
INSERT INTO `detalleventa` VALUES (1,2,1200.00,2400.00,1,1),(2,3,500.00,1500.00,2,3),(3,4,400.00,1600.00,3,5),(4,2,1150.00,2300.00,4,14),(5,5,600.00,3000.00,5,12),(6,2,850.00,1700.00,6,2),(7,3,600.00,1800.00,7,17),(8,2,1050.00,2100.00,8,25),(9,4,650.00,2600.00,9,30),(10,4,800.00,3200.00,10,31),(11,3,700.00,2100.00,11,11),(12,2,950.00,1900.00,12,22),(13,5,500.00,2500.00,13,13),(14,3,600.00,1800.00,14,16),(15,4,550.00,2200.00,15,21),(16,3,800.00,2400.00,16,4),(17,2,650.00,1300.00,17,18),(18,4,700.00,2800.00,18,32),(19,3,900.00,2700.00,19,33),(20,5,620.00,3100.00,20,23),(21,5,500.00,2500.00,21,50),(22,4,500.00,2000.00,22,28),(23,3,630.00,1890.00,23,44),(24,4,650.00,2600.00,24,29),(25,2,850.00,1700.00,25,42),(26,4,550.00,2200.00,26,43),(27,5,460.00,2300.00,27,35),(28,6,450.00,2700.00,28,36),(29,3,700.00,2100.00,29,9),(30,4,775.00,3100.00,30,8),(31,4,650.00,2600.00,31,7),(32,3,800.00,2400.00,32,6),(33,3,500.00,1500.00,33,5),(34,4,575.00,2300.00,34,4),(35,2,950.00,1900.00,35,3),(36,2,900.00,1800.00,36,2),(37,4,600.00,2400.00,37,1),(38,5,500.00,2500.00,38,10),(39,4,650.00,2600.00,39,20),(40,2,1100.00,2200.00,40,40),(41,4,500.00,2000.00,41,19),(42,3,700.00,2100.00,42,18),(43,2,1150.00,2300.00,43,17),(44,5,500.00,2500.00,44,16),(45,2,950.00,1900.00,45,15),(46,2,850.00,1700.00,46,14),(47,4,700.00,2800.00,47,13),(48,4,650.00,2600.00,48,12),(49,4,600.00,2400.00,49,11),(50,5,600.00,3000.00,50,10),(51,3,700.00,2100.00,51,9),(52,2,900.00,1800.00,52,8),(53,4,575.00,2300.00,53,7),(54,3,800.00,2400.00,54,6),(55,3,900.00,2700.00,55,5),(56,5,500.00,2500.00,56,4),(57,2,800.00,1600.00,57,3),(58,4,500.00,2000.00,58,2),(59,2,1150.00,2300.00,59,1),(60,4,700.00,2800.00,60,1);
/*!40000 ALTER TABLE `detalleventa` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `devolucion`
--

DROP TABLE IF EXISTS `devolucion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `devolucion` (
  `idDevolucion` int(11) NOT NULL,
  `fecha` date NOT NULL,
  `motivo` varchar(200) NOT NULL,
  `cantidad` varchar(50) NOT NULL,
  `Producto_idProducto` int(11) NOT NULL,
  `Persona_idPersona` int(11) NOT NULL,
  `Persona_Tipo_Documento_idTipo_Documento` int(11) NOT NULL,
  `Persona_Rol_idRol` int(11) NOT NULL,
  `TipoDevolucion_idTipoDevolucion` int(11) NOT NULL,
  PRIMARY KEY (`idDevolucion`),
  KEY `Producto_idProducto` (`Producto_idProducto`),
  KEY `Persona_idPersona` (`Persona_idPersona`,`Persona_Tipo_Documento_idTipo_Documento`,`Persona_Rol_idRol`),
  KEY `TipoDevolucion_idTipoDevolucion` (`TipoDevolucion_idTipoDevolucion`),
  CONSTRAINT `devolucion_ibfk_1` FOREIGN KEY (`Producto_idProducto`) REFERENCES `productos` (`idProducto`),
  CONSTRAINT `devolucion_ibfk_2` FOREIGN KEY (`Persona_idPersona`, `Persona_Tipo_Documento_idTipo_Documento`, `Persona_Rol_idRol`) REFERENCES `persona` (`idPersona`, `Tipo_Documento_idTipo_Documento`, `Rol_idRol`),
  CONSTRAINT `devolucion_ibfk_3` FOREIGN KEY (`TipoDevolucion_idTipoDevolucion`) REFERENCES `tipodevolucion` (`idTipoDevolucion`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `devolucion`
--

LOCK TABLES `devolucion` WRITE;
/*!40000 ALTER TABLE `devolucion` DISABLE KEYS */;
INSERT INTO `devolucion` VALUES (1,'2024-05-10','Producto danado','2',1,1,1,1,1),(2,'2024-05-11','Vencido','1',2,2,1,2,2),(3,'2024-05-12','Error en entrega','3',3,3,2,2,1),(4,'2024-05-13','Producto danado','2',4,4,1,1,2),(5,'2024-05-14','Vencido','1',5,5,2,2,1),(6,'2024-05-15','Producto danado','2',6,6,1,2,2),(7,'2024-05-16','Error en entrega','2',7,7,1,2,1),(8,'2024-05-17','Producto danado','1',8,8,1,1,2),(9,'2024-05-18','Vencido','1',9,9,2,2,1),(10,'2024-05-19','Error en entrega','3',10,10,1,2,1),(11,'2024-05-20','Producto danado','2',11,1,1,1,2),(12,'2024-05-21','Vencido','1',12,2,1,2,1),(13,'2024-05-22','Error en entrega','3',13,3,2,2,1),(14,'2024-05-23','Producto danado','2',14,4,1,1,1),(15,'2024-05-24','Vencido','1',15,5,2,2,2),(16,'2024-05-25','Producto danado','2',16,6,1,2,1),(17,'2024-05-26','Error en entrega','2',17,7,1,2,2),(18,'2024-05-27','Producto danado','1',18,8,1,1,1),(19,'2024-05-28','Vencido','1',19,9,2,2,2),(20,'2024-05-29','Error en entrega','3',20,10,1,2,1),(21,'2024-05-30','Producto danado','2',21,1,1,1,2),(22,'2024-05-31','Vencido','1',22,2,1,2,1),(23,'2024-06-01','Error en entrega','3',23,3,2,2,1),(24,'2024-06-02','Producto danado','2',24,4,1,1,1),(25,'2024-06-03','Vencido','1',25,5,2,2,2),(26,'2024-06-04','Producto danado','2',26,6,1,2,1),(27,'2024-06-05','Error en entrega','2',27,7,1,2,2),(28,'2024-06-06','Producto danado','1',28,8,1,1,1),(29,'2024-06-07','Vencido','1',29,9,2,2,2),(30,'2024-06-08','Error en entrega','3',30,10,1,2,1),(31,'2024-06-09','Producto danado','2',31,1,1,1,2),(32,'2024-06-10','Vencido','1',32,2,1,2,1),(33,'2024-06-11','Error en entrega','3',33,3,2,2,1),(34,'2024-06-12','Producto danado','2',34,4,1,1,1),(35,'2024-06-13','Vencido','1',35,5,2,2,2),(36,'2024-06-14','Producto danado','2',36,6,1,2,1),(37,'2024-06-15','Error en entrega','2',37,7,1,2,2),(38,'2024-06-16','Producto danado','1',38,8,1,1,1),(39,'2024-06-17','Vencido','1',39,9,2,2,2),(40,'2024-06-18','Error en entrega','3',40,10,1,2,1),(41,'2024-06-19','Producto danado','2',41,1,1,1,2),(42,'2024-06-20','Vencido','1',42,2,1,2,1),(43,'2024-06-21','Error en entrega','3',43,3,2,2,1),(44,'2024-06-22','Producto danado','2',44,4,1,1,1),(45,'2024-06-23','Vencido','1',45,5,2,2,2),(46,'2024-06-24','Producto danado','2',46,6,1,2,1),(47,'2024-06-25','Error en entrega','2',47,7,1,2,2),(48,'2024-06-26','Producto danado','1',48,8,1,1,1),(49,'2024-06-27','Vencido','1',49,9,2,2,2),(50,'2024-06-28','Error en entrega','3',50,10,1,2,1),(51,'2024-06-29','Producto danado','2',51,1,1,1,2),(52,'2024-06-30','Vencido','1',52,2,1,2,1),(53,'2024-07-01','Error en entrega','3',53,3,2,2,1),(54,'2024-07-02','Producto danado','2',54,4,1,1,1),(55,'2024-07-03','Vencido','1',55,5,2,2,2),(56,'2024-07-04','Producto danado','2',56,6,1,2,1),(57,'2024-07-05','Error en entrega','2',57,7,1,2,2),(58,'2024-07-06','Producto danado','1',58,8,1,1,1),(59,'2024-07-07','Vencido','1',59,9,2,2,2),(60,'2024-07-08','Error en entrega','3',60,10,1,2,1),(61,'2024-07-09','Producto dañado','2',10,10,1,2,1),(62,'2024-07-10','Vencido','1',10,10,1,2,2),(63,'2024-07-11','Error en entrega','3',10,10,1,2,1),(64,'2024-07-12','Producto dañado','1',10,10,1,2,2),(65,'2024-07-13','Vencido','2',10,10,1,2,1),(66,'2024-07-14','Error en entrega','2',10,10,1,2,2),(67,'2024-07-15','Producto dañado','3',10,10,1,2,1),(68,'2024-07-16','Error en entrega','1',10,10,1,2,2),(69,'2024-07-17','Producto dañado','2',10,10,1,2,1),(70,'2024-07-18','Vencido','1',10,10,1,2,1),(71,'2025-06-20','Producto dañado','2',10,10,1,2,1),(72,'2025-06-21','Vencido','1',10,10,1,2,2),(73,'2025-06-22','Error en entrega','3',10,10,1,2,1);
/*!40000 ALTER TABLE `devolucion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `entradas`
--

DROP TABLE IF EXISTS `entradas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `entradas` (
  `idEntrada` int(11) NOT NULL,
  `fecha` date NOT NULL,
  `cantidad` int(11) DEFAULT NULL,
  `Producto_idProducto` int(11) NOT NULL,
  `Proveedor_idProveedor` int(11) NOT NULL,
  `Persona_idPersona` int(11) NOT NULL,
  `Persona_Tipo_Documento_idTipo_Documento` int(11) NOT NULL,
  `Persona_Rol_idRol` int(11) NOT NULL,
  PRIMARY KEY (`idEntrada`),
  KEY `Producto_idProducto` (`Producto_idProducto`),
  KEY `Proveedor_idProveedor` (`Proveedor_idProveedor`),
  KEY `Persona_idPersona` (`Persona_idPersona`,`Persona_Tipo_Documento_idTipo_Documento`,`Persona_Rol_idRol`),
  CONSTRAINT `entradas_ibfk_1` FOREIGN KEY (`Producto_idProducto`) REFERENCES `productos` (`idProducto`),
  CONSTRAINT `entradas_ibfk_2` FOREIGN KEY (`Proveedor_idProveedor`) REFERENCES `proveedores` (`idProveedor`),
  CONSTRAINT `entradas_ibfk_3` FOREIGN KEY (`Persona_idPersona`, `Persona_Tipo_Documento_idTipo_Documento`, `Persona_Rol_idRol`) REFERENCES `persona` (`idPersona`, `Tipo_Documento_idTipo_Documento`, `Rol_idRol`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `entradas`
--

LOCK TABLES `entradas` WRITE;
/*!40000 ALTER TABLE `entradas` DISABLE KEYS */;
INSERT INTO `entradas` VALUES (1,'2024-01-10',20,1,1,1,1,1),(2,'2024-01-11',15,2,2,2,1,2),(3,'2024-01-12',30,3,3,3,2,2),(4,'2024-01-13',25,4,4,4,1,1),(5,'2024-01-14',40,5,5,5,2,2),(6,'2024-01-15',18,6,6,6,1,2),(7,'2024-01-16',22,7,7,7,1,2),(8,'2024-01-17',35,8,8,8,1,1),(9,'2024-01-18',28,9,9,9,2,2),(10,'2024-01-19',45,10,10,10,1,2),(11,'2024-01-20',20,11,1,1,1,1),(12,'2024-01-21',15,12,2,2,1,2),(13,'2024-01-22',30,13,3,3,2,2),(14,'2024-01-23',25,14,4,4,1,1),(15,'2024-01-24',40,15,5,5,2,2),(16,'2024-01-25',18,16,6,6,1,2),(17,'2024-01-26',22,17,7,7,1,2),(18,'2024-01-27',35,18,8,8,1,1),(19,'2024-01-28',28,19,9,9,2,2),(20,'2024-01-29',45,20,10,10,1,2),(21,'2024-01-30',20,21,1,1,1,1),(22,'2024-01-31',15,22,2,2,1,2),(23,'2024-02-01',30,23,3,3,2,2),(24,'2024-02-02',25,24,4,4,1,1),(25,'2024-02-03',40,25,5,5,2,2),(26,'2024-02-04',18,26,6,6,1,2),(27,'2024-02-05',22,27,7,7,1,2),(28,'2024-02-06',35,28,8,8,1,1),(29,'2024-02-07',28,29,9,9,2,2),(30,'2024-02-08',45,30,10,10,1,2),(31,'2024-02-09',20,31,1,1,1,1),(32,'2024-02-10',15,32,2,2,1,2),(33,'2024-02-11',30,33,3,3,2,2),(34,'2024-02-12',25,34,4,4,1,1),(35,'2024-02-13',40,35,5,5,2,2),(36,'2024-02-14',18,36,6,6,1,2),(37,'2024-02-15',22,37,7,7,1,2),(38,'2024-02-16',35,38,8,8,1,1),(39,'2024-02-17',28,39,9,9,2,2),(40,'2024-02-18',45,40,10,10,1,2),(41,'2024-02-19',20,41,1,1,1,1),(42,'2024-02-20',15,42,2,2,1,2),(43,'2024-02-21',30,43,3,3,2,2),(44,'2024-02-22',25,44,4,4,1,1),(45,'2024-02-23',40,45,5,5,2,2),(46,'2024-02-24',18,46,6,6,1,2),(47,'2024-02-25',22,47,7,7,1,2),(48,'2024-02-26',35,48,8,8,1,1),(49,'2024-02-27',28,49,9,9,2,2),(50,'2024-02-28',45,50,10,10,1,2),(51,'2024-03-01',20,51,1,1,1,1),(52,'2024-03-02',15,52,2,2,1,2),(53,'2024-03-03',30,53,3,3,2,2),(54,'2024-03-04',25,54,4,4,1,1),(55,'2024-03-05',40,55,5,5,2,2),(56,'2024-03-06',18,56,6,6,1,2),(57,'2024-03-07',22,57,7,7,1,2),(58,'2024-03-08',35,58,8,8,1,1),(59,'2024-03-09',28,59,9,9,2,2),(60,'2024-03-10',45,60,10,10,1,2);
/*!40000 ALTER TABLE `entradas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `fecha_entrega_productos`
--

DROP TABLE IF EXISTS `fecha_entrega_productos`;
/*!50001 DROP VIEW IF EXISTS `fecha_entrega_productos`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `fecha_entrega_productos` AS SELECT 
 1 AS `idProducto`,
 1 AS `Producto`,
 1 AS `Cantidad`,
 1 AS `Fecha_entrega`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `observaciones_del_stock`
--

DROP TABLE IF EXISTS `observaciones_del_stock`;
/*!50001 DROP VIEW IF EXISTS `observaciones_del_stock`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `observaciones_del_stock` AS SELECT 
 1 AS `idProducto`,
 1 AS `Producto`,
 1 AS `Categoria`,
 1 AS `precio`,
 1 AS `Stock`,
 1 AS `Observacion`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `persona`
--

DROP TABLE IF EXISTS `persona`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `persona` (
  `idPersona` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `correo` varchar(100) NOT NULL,
  `Contrasena` varchar(45) NOT NULL,
  `Tipo_Documento_idTipo_Documento` int(11) NOT NULL,
  `Rol_idRol` int(11) NOT NULL,
  `fotoPerfil` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`idPersona`,`Tipo_Documento_idTipo_Documento`,`Rol_idRol`),
  UNIQUE KEY `correo` (`correo`),
  KEY `Tipo_Documento_idTipo_Documento` (`Tipo_Documento_idTipo_Documento`),
  KEY `Rol_idRol` (`Rol_idRol`),
  CONSTRAINT `persona_ibfk_1` FOREIGN KEY (`Tipo_Documento_idTipo_Documento`) REFERENCES `tipo_documento` (`idTipo_Documento`),
  CONSTRAINT `persona_ibfk_2` FOREIGN KEY (`Rol_idRol`) REFERENCES `rol` (`idRol`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `persona`
--

LOCK TABLES `persona` WRITE;
/*!40000 ALTER TABLE `persona` DISABLE KEYS */;
INSERT INTO `persona` VALUES (1,'Laura Mendoza','laura1@distriochoa.com','clave1',1,1,NULL),(2,'Carlos Ruiz','carlos2@distriochoa.com','clave2',1,2,NULL),(3,'Ana Torres','ana3@distriochoa.com','clave3',2,2,NULL),(4,'Santiago Diaz','santiago4@distriochoa.com','clave4',1,1,NULL),(5,'Marta Rojas','marta5@distriochoa.com','clave5',2,2,NULL),(6,'Camilo Ramirez','camilo6@distriochoa.com','clave6',1,2,NULL),(7,'Andrea Lopez','andrea7@distriochoa.com','clave7',1,2,NULL),(8,'Juan Ochoa','juan8@distriochoa.com','clave8',1,1,NULL),(9,'Tatiana Herrera','tatiana9@distriochoa.com','clave9',2,2,NULL),(10,'Esteban Perez','esteban10@distriochoa.com','clave10',1,2,NULL);
/*!40000 ALTER TABLE `persona` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `productos`
--

DROP TABLE IF EXISTS `productos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `productos` (
  `idProducto` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `precio` decimal(10,2) NOT NULL,
  `cantidad_Actual` int(11) NOT NULL,
  `Proveedor_idProveedor` int(11) NOT NULL,
  `Proveedor_Persona_idPersona` int(11) NOT NULL,
  `Proveedor_Persona_Tipo_Documento_idTipo_Documento` int(11) NOT NULL,
  `Categoria_idCategoria` int(11) NOT NULL,
  PRIMARY KEY (`idProducto`),
  KEY `Proveedor_idProveedor` (`Proveedor_idProveedor`),
  KEY `Categoria_idCategoria` (`Categoria_idCategoria`),
  CONSTRAINT `productos_ibfk_1` FOREIGN KEY (`Proveedor_idProveedor`) REFERENCES `proveedores` (`idProveedor`),
  CONSTRAINT `productos_ibfk_2` FOREIGN KEY (`Categoria_idCategoria`) REFERENCES `categorias` (`idCategoria`)
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `productos`
--

LOCK TABLES `productos` WRITE;
/*!40000 ALTER TABLE `productos` DISABLE KEYS */;
INSERT INTO `productos` VALUES (1,'Manzana Roja',1200.00,50,1,1,1,1),(2,'Pera Verde',1500.00,40,2,2,1,1),(3,'Banano',800.00,100,3,3,2,1),(4,'Papaya',2000.00,30,4,4,1,1),(5,'Mango Tommy',1800.00,60,5,5,2,1),(6,'Fresa',2500.00,20,6,6,1,1),(7,'Pina',2200.00,25,7,7,1,1),(8,'Uva Verde',3000.00,40,8,8,1,1),(9,'Melon',1800.00,15,9,9,2,1),(10,'Sandia',2200.00,10,10,10,1,1),(11,'Zanahoria',1000.00,70,1,1,1,2),(12,'Cebolla Cabezona',1300.00,60,2,2,1,2),(13,'Lechuga Batavia',900.00,40,3,3,2,2),(14,'Tomate Chonto',1100.00,80,4,4,1,2),(15,'Brocoli',2500.00,30,5,5,2,2),(16,'Coliflor',2400.00,25,6,6,1,2),(17,'Pepino Cohombro',1000.00,50,7,7,1,2),(18,'Acelga',1200.00,35,8,8,1,2),(19,'Espinaca',1300.00,45,9,9,2,2),(20,'Remolacha',1400.00,20,10,10,1,2),(21,'Papa Criolla',1600.00,100,1,1,1,3),(22,'Papa Pastusa',1500.00,90,2,2,1,3),(23,'Papa R-12',1400.00,80,3,3,2,3),(24,'Yuca',1200.00,60,4,4,1,3),(25,'name',1100.00,40,5,5,2,3),(26,'Arracacha',1300.00,50,6,6,1,3),(27,'Papa Salentuna',1700.00,45,7,7,1,3),(28,'Papa Capira',1600.00,30,8,8,1,3),(29,'Papa Criolla Peque?a',1500.00,25,9,9,2,3),(30,'Yuca Amarilla',1400.00,35,10,10,1,3),(31,'Frijol Bola Roja',4500.00,20,1,1,1,4),(32,'Frijol Verde',4300.00,15,2,2,1,4),(33,'Lenteja',3900.00,50,3,3,2,4),(34,'Garbanzo',4100.00,25,4,4,1,4),(35,'Arveja Verde',4200.00,35,5,5,2,4),(36,'Frijol Cargamanto',4600.00,20,6,6,1,4),(37,'Haba Verde',4400.00,15,7,7,1,4),(38,'Frijol Blanco',4000.00,18,8,8,1,4),(39,'Frijol Negro',4200.00,20,9,9,2,4),(40,'Frijol Rosado',4300.00,22,10,10,1,4),(41,'Cilantro',800.00,80,1,1,1,5),(42,'Perejil',850.00,75,2,2,1,5),(43,'Hierbabuena',900.00,60,3,3,2,5),(44,'Ruda',1000.00,40,4,4,1,5),(45,'Albahaca',950.00,50,5,5,2,5),(46,'Apio',1100.00,55,6,6,1,5),(47,'Laurel',1200.00,30,7,7,1,5),(48,'Tomillo',1300.00,35,8,8,1,5),(49,'Oregano',1100.00,60,9,9,2,5),(50,'Romero',1200.00,45,10,10,1,5),(51,'Aguacate Hass',2500.00,40,1,1,1,1),(52,'Lulo',1800.00,30,2,2,1,1),(53,'Guayaba',1900.00,35,3,3,2,1),(54,'Mandarina',2000.00,50,4,4,1,1),(55,'Limon Tahito',1700.00,60,5,5,2,1),(56,'Naranja Valencia',2100.00,70,6,6,1,1),(57,'Zapallo',1500.00,45,7,7,1,2),(58,'Berenjena',1600.00,50,8,8,1,2),(59,'Calabacin',1550.00,55,9,9,2,2),(60,'Repollo Verde',1400.00,60,10,10,1,2);
/*!40000 ALTER TABLE `productos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `productos_vendidos_encima_promedio`
--

DROP TABLE IF EXISTS `productos_vendidos_encima_promedio`;
/*!50001 DROP VIEW IF EXISTS `productos_vendidos_encima_promedio`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `productos_vendidos_encima_promedio` AS SELECT 
 1 AS `idProducto`,
 1 AS `Producto`,
 1 AS `Categoria`,
 1 AS `Proveedor`,
 1 AS `Total_vendido`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `proveedores`
--

DROP TABLE IF EXISTS `proveedores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `proveedores` (
  `idProveedor` int(11) NOT NULL,
  `Nombre_Empresa` varchar(60) NOT NULL,
  `Direccion` varchar(45) NOT NULL,
  PRIMARY KEY (`idProveedor`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `proveedores`
--

LOCK TABLES `proveedores` WRITE;
/*!40000 ALTER TABLE `proveedores` DISABLE KEYS */;
INSERT INTO `proveedores` VALUES (1,'AgroFrutas S.A.S','Cra 10 #12-34'),(2,'Verduras del Campo','Calle 8 #45-67'),(3,'Frutas Tropicales','Av 30 #9-99'),(4,'Frescampo Ltda','Calle 55 #78-12'),(5,'Natural Fresh','Cra 33 #21-56'),(6,'La Huerta','Calle 40 #60-80'),(7,'EcoFrutas','Av 7 #70-10'),(8,'VerdeVida','Transv 18 #5-45'),(9,'Delicias Naturales','Calle 3 #13-20'),(10,'Campo Limpio','Carrera 24 #17-60');
/*!40000 ALTER TABLE `proveedores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `proveedores_con_varias_categorias`
--

DROP TABLE IF EXISTS `proveedores_con_varias_categorias`;
/*!50001 DROP VIEW IF EXISTS `proveedores_con_varias_categorias`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `proveedores_con_varias_categorias` AS SELECT 
 1 AS `idProveedor`,
 1 AS `Empresa`,
 1 AS `Cateogria`,
 1 AS `cantidad_productos`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `rol`
--

DROP TABLE IF EXISTS `rol`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rol` (
  `idRol` int(11) NOT NULL,
  `Descripcion_Rol` varchar(70) NOT NULL,
  PRIMARY KEY (`idRol`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rol`
--

LOCK TABLES `rol` WRITE;
/*!40000 ALTER TABLE `rol` DISABLE KEYS */;
INSERT INTO `rol` VALUES (1,'Administrador'),(2,'Auxiliar');
/*!40000 ALTER TABLE `rol` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tipo_documento`
--

DROP TABLE IF EXISTS `tipo_documento`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tipo_documento` (
  `idTipo_Documento` int(11) NOT NULL,
  `descripcion` varchar(20) NOT NULL,
  PRIMARY KEY (`idTipo_Documento`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tipo_documento`
--

LOCK TABLES `tipo_documento` WRITE;
/*!40000 ALTER TABLE `tipo_documento` DISABLE KEYS */;
INSERT INTO `tipo_documento` VALUES (1,'Cedula de Ciudadania'),(2,'Tarjeta de Identidad'),(3,'Cedula de Extranjero');
/*!40000 ALTER TABLE `tipo_documento` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tipodevolucion`
--

DROP TABLE IF EXISTS `tipodevolucion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tipodevolucion` (
  `idTipoDevolucion` int(11) NOT NULL,
  `nombreTipo` varchar(45) NOT NULL,
  PRIMARY KEY (`idTipoDevolucion`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tipodevolucion`
--

LOCK TABLES `tipodevolucion` WRITE;
/*!40000 ALTER TABLE `tipodevolucion` DISABLE KEYS */;
INSERT INTO `tipodevolucion` VALUES (1,'Cliente'),(2,'Proveedor');
/*!40000 ALTER TABLE `tipodevolucion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `v_ventas_x_cliente`
--

DROP TABLE IF EXISTS `v_ventas_x_cliente`;
/*!50001 DROP VIEW IF EXISTS `v_ventas_x_cliente`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_ventas_x_cliente` AS SELECT 
 1 AS `Cliente`,
 1 AS `FechaVenta`,
 1 AS `NumeroFactura`,
 1 AS `Cantidad`,
 1 AS `Total`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `venta`
--

DROP TABLE IF EXISTS `venta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `venta` (
  `idVenta` int(11) NOT NULL,
  `fecha` date NOT NULL,
  `total` decimal(10,2) NOT NULL,
  `Persona_idPersona` int(11) NOT NULL,
  `Persona_Tipo_Documento_idTipo_Documento` int(11) NOT NULL,
  `Persona_Rol_idRol` int(11) NOT NULL,
  PRIMARY KEY (`idVenta`),
  KEY `Persona_idPersona` (`Persona_idPersona`,`Persona_Tipo_Documento_idTipo_Documento`,`Persona_Rol_idRol`),
  CONSTRAINT `venta_ibfk_1` FOREIGN KEY (`Persona_idPersona`, `Persona_Tipo_Documento_idTipo_Documento`, `Persona_Rol_idRol`) REFERENCES `persona` (`idPersona`, `Tipo_Documento_idTipo_Documento`, `Rol_idRol`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `venta`
--

LOCK TABLES `venta` WRITE;
/*!40000 ALTER TABLE `venta` DISABLE KEYS */;
INSERT INTO `venta` VALUES (1,'2024-03-11',2400.00,1,1,1),(2,'2024-03-12',1500.00,2,1,2),(3,'2024-03-13',1600.00,3,2,2),(4,'2024-03-14',2300.00,4,1,1),(5,'2024-03-15',3000.00,5,2,2),(6,'2024-03-16',1700.00,6,1,2),(7,'2024-03-17',1800.00,7,1,2),(8,'2024-03-18',2100.00,8,1,1),(9,'2024-03-19',2600.00,9,2,2),(10,'2024-03-20',3200.00,10,1,2),(11,'2024-03-21',2100.00,1,1,1),(12,'2024-03-22',1900.00,2,1,2),(13,'2024-03-23',2500.00,3,2,2),(14,'2024-03-24',1800.00,4,1,1),(15,'2024-03-25',2200.00,5,2,2),(16,'2024-03-26',2400.00,6,1,2),(17,'2024-03-27',1300.00,7,1,2),(18,'2024-03-28',2800.00,8,1,1),(19,'2024-03-29',2700.00,9,2,2),(20,'2024-03-30',3100.00,10,1,2),(21,'2024-03-31',2500.00,1,1,1),(22,'2024-04-01',2000.00,2,1,2),(23,'2024-04-02',1900.00,3,2,2),(24,'2024-04-03',2600.00,4,1,1),(25,'2024-04-04',1700.00,5,2,2),(26,'2024-04-05',2200.00,6,1,2),(27,'2024-04-06',2300.00,7,1,2),(28,'2024-04-07',2700.00,8,1,1),(29,'2024-04-08',2100.00,9,2,2),(30,'2024-04-09',3100.00,10,1,2),(31,'2024-04-10',2600.00,1,1,1),(32,'2024-04-11',2400.00,2,1,2),(33,'2024-04-12',1500.00,3,2,2),(34,'2024-04-13',2300.00,4,1,1),(35,'2024-04-14',1900.00,5,2,2),(36,'2024-04-15',1800.00,6,1,2),(37,'2024-04-16',2400.00,7,1,2),(38,'2024-04-17',2500.00,8,1,1),(39,'2024-04-18',2600.00,9,2,2),(40,'2024-04-19',2200.00,10,1,2),(41,'2024-04-20',2000.00,1,1,1),(42,'2024-04-21',2100.00,2,1,2),(43,'2024-04-22',2300.00,3,2,2),(44,'2024-04-23',2500.00,4,1,1),(45,'2024-04-24',1900.00,5,2,2),(46,'2024-04-25',1700.00,6,1,2),(47,'2024-04-26',2800.00,7,1,2),(48,'2024-04-27',2600.00,8,1,1),(49,'2024-04-28',2400.00,9,2,2),(50,'2024-04-29',3000.00,10,1,2),(51,'2024-04-30',2100.00,1,1,1),(52,'2024-05-01',1800.00,2,1,2),(53,'2024-05-02',2300.00,3,2,2),(54,'2024-05-03',2400.00,4,1,1),(55,'2024-05-04',2700.00,5,2,2),(56,'2024-05-05',2500.00,6,1,2),(57,'2024-05-06',1600.00,7,1,2),(58,'2024-05-07',2000.00,8,1,1),(59,'2024-05-08',2300.00,9,2,2),(60,'2024-05-09',2800.00,10,1,2),(62,'2024-03-18',1800.00,1,1,1),(63,'2024-03-18',1900.00,2,1,2),(65,'2024-03-18',1900.00,2,1,2),(66,'2024-03-18',1800.00,1,1,1),(67,'2024-03-19',1900.00,2,1,2),(68,'2024-03-19',1800.00,1,1,1),(69,'2024-03-19',1900.00,2,1,2),(70,'2024-03-19',1800.00,1,1,1),(71,'2024-03-19',1900.00,2,1,2),(72,'2024-03-19',1800.00,1,1,1),(73,'2024-03-19',1900.00,2,1,2);
/*!40000 ALTER TABLE `venta` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `fecha_entrega_productos`
--

/*!50001 DROP VIEW IF EXISTS `fecha_entrega_productos`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `fecha_entrega_productos` AS select `p`.`idProducto` AS `idProducto`,`p`.`nombre` AS `Producto`,`e`.`cantidad` AS `Cantidad`,`e`.`fecha` AS `Fecha_entrega` from (`entradas` `e` join `productos` `p` on(`e`.`Producto_idProducto` = `p`.`idProducto`)) where `e`.`fecha` = (select max(`e2`.`fecha`) from `entradas` `e2` where `e2`.`Producto_idProducto` = `e`.`Producto_idProducto`) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `observaciones_del_stock`
--

/*!50001 DROP VIEW IF EXISTS `observaciones_del_stock`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `observaciones_del_stock` AS select `res`.`idProducto` AS `idProducto`,`res`.`Producto` AS `Producto`,`res`.`Categoria` AS `Categoria`,`res`.`precio` AS `precio`,`res`.`Stock` AS `Stock`,'Alto Stock' AS `Observacion` from (select distinct `p`.`idProducto` AS `idProducto`,`p`.`nombre` AS `Producto`,`c`.`Nombre_Categoria` AS `Categoria`,`p`.`precio` AS `precio`,`p`.`cantidad_Actual` AS `Stock` from ((`productos` `p` join `categorias` `c` on(`c`.`idCategoria` = `p`.`Categoria_idCategoria`)) left join `proveedores` `pe` on(`pe`.`idProveedor` = `p`.`Proveedor_idProveedor`))) `res` where `res`.`Stock` >= 50 union all select `res`.`idProducto` AS `idProducto`,`res`.`Producto` AS `Producto`,`res`.`Categoria` AS `Categoria`,`res`.`precio` AS `precio`,`res`.`Stock` AS `Stock`,'Bajo Stock' AS `Observacion` from (select distinct `p`.`idProducto` AS `idProducto`,`p`.`nombre` AS `Producto`,`c`.`Nombre_Categoria` AS `Categoria`,`p`.`precio` AS `precio`,`p`.`cantidad_Actual` AS `Stock` from ((`productos` `p` join `categorias` `c` on(`c`.`idCategoria` = `p`.`Categoria_idCategoria`)) left join `proveedores` `pe` on(`pe`.`idProveedor` = `p`.`Proveedor_idProveedor`))) `res` where `res`.`Stock` < 50 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `productos_vendidos_encima_promedio`
--

/*!50001 DROP VIEW IF EXISTS `productos_vendidos_encima_promedio`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `productos_vendidos_encima_promedio` AS select `p`.`idProducto` AS `idProducto`,`p`.`nombre` AS `Producto`,`c`.`Nombre_Categoria` AS `Categoria`,`pr`.`Nombre_Empresa` AS `Proveedor`,sum(`dv`.`cantidad`) AS `Total_vendido` from (((`detalleventa` `dv` join `productos` `p` on(`dv`.`Producto_idProducto` = `p`.`idProducto`)) join `categorias` `c` on(`p`.`Categoria_idCategoria` = `c`.`idCategoria`)) join `proveedores` `pr` on(`p`.`Proveedor_idProveedor` = `pr`.`idProveedor`)) group by `p`.`idProducto`,`p`.`nombre`,`c`.`Nombre_Categoria`,`pr`.`Nombre_Empresa` having sum(`dv`.`cantidad`) > (select avg(`sub`.`cantidad_total`) from (select sum(`detalleventa`.`cantidad`) AS `cantidad_total` from `detalleventa` group by `detalleventa`.`Producto_idProducto`) `sub`) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `proveedores_con_varias_categorias`
--

/*!50001 DROP VIEW IF EXISTS `proveedores_con_varias_categorias`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `proveedores_con_varias_categorias` AS select `pr`.`idProveedor` AS `idProveedor`,`pr`.`Nombre_Empresa` AS `Empresa`,`c`.`Nombre_Categoria` AS `Cateogria`,count(`p`.`idProducto`) AS `cantidad_productos` from ((`proveedores` `pr` join `productos` `p` on(`pr`.`idProveedor` = `p`.`Proveedor_idProveedor`)) join `categorias` `c` on(`p`.`Categoria_idCategoria` = `c`.`idCategoria`)) where `pr`.`idProveedor` in (select `p`.`Proveedor_idProveedor` from `productos` `p` group by `p`.`Proveedor_idProveedor` having count(distinct `p`.`Categoria_idCategoria`) > 1) group by `pr`.`idProveedor`,`c`.`idCategoria` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_ventas_x_cliente`
--

/*!50001 DROP VIEW IF EXISTS `v_ventas_x_cliente`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_ventas_x_cliente` AS select `res`.`Cliente` AS `Cliente`,`res`.`FechaVenta` AS `FechaVenta`,`res`.`NumeroFactura` AS `NumeroFactura`,`res`.`Cantidad` AS `Cantidad`,`res`.`Total` AS `Total` from (select `p`.`nombre` AS `Cliente`,`v`.`fecha` AS `FechaVenta`,`v`.`idVenta` AS `NumeroFactura`,`pr`.`nombre` AS `Producto`,`pr`.`precio` AS `precio`,sum(`dv`.`cantidad`) AS `Cantidad`,sum(`dv`.`subtotal`) AS `Total` from (((`venta` `v` join `detalleventa` `dv` on(`dv`.`idDetalleVenta` = `v`.`idVenta`)) join `persona` `p` on(`p`.`idPersona` = `v`.`Persona_idPersona`)) join `productos` `pr` on(`pr`.`idProducto` = `dv`.`Producto_idProducto`)) group by `p`.`nombre`,`v`.`fecha`,`v`.`idVenta`,`pr`.`nombre`,`pr`.`precio`) `res` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-07-05 12:38:44
