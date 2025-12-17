CREATE DATABASE distriochoa1;
USE distriochoa1;

-- TABLA: Proveedores
CREATE TABLE Proveedores (
  idProveedor INT AUTO_INCREMENT PRIMARY KEY,
  Nombre_Empresa VARCHAR(60) NOT NULL,
  Direccion VARCHAR(100) NOT NULL
);

-- TABLA: Categorias
CREATE TABLE Categorias (
  idCategoria INT AUTO_INCREMENT PRIMARY KEY,
  Nombre_Categoria VARCHAR(60) NOT NULL,
  Descripcion VARCHAR(200) NOT NULL
);

-- TABLA: Tipo_Documento
CREATE TABLE Tipo_Documento (
  idTipo_Documento INT AUTO_INCREMENT PRIMARY KEY,
  Descripcion VARCHAR(20) NOT NULL
);

-- TABLA: Rol
CREATE TABLE Rol (
  idRol INT AUTO_INCREMENT PRIMARY KEY,
  Descripcion_Rol VARCHAR(70) NOT NULL
);

-- TABLA: Persona
CREATE TABLE Persona (
  idPersona INT AUTO_INCREMENT PRIMARY KEY,
  Nombre VARCHAR(100) NOT NULL,
  Correo VARCHAR(100) NOT NULL UNIQUE,
  Contrasena VARCHAR(100) NOT NULL,
  Tipo_Documento_id INT NOT NULL,
  Rol_id INT NOT NULL,
  FOREIGN KEY (Tipo_Documento_id) REFERENCES Tipo_Documento(idTipo_Documento),
  FOREIGN KEY (Rol_id) REFERENCES Rol(idRol)
);

-- TABLA: Productos
CREATE TABLE Productos (
  idProducto INT AUTO_INCREMENT PRIMARY KEY,
  Nombre VARCHAR(100) NOT NULL,
  Precio DECIMAL(10,2) NOT NULL,
  Cantidad_Actual INT NOT NULL,
  Categoria_id INT NOT NULL,
  FOREIGN KEY (Categoria_id) REFERENCES Categorias(idCategoria)
);

-- TABLA: Entradas
CREATE TABLE Entradas (
  idEntrada INT AUTO_INCREMENT PRIMARY KEY,
  Fecha DATE NOT NULL,
  Cantidad INT NOT NULL,
  Producto_id INT NOT NULL,
  Proveedor_id INT NOT NULL,
  Persona_id INT NOT NULL,
  FOREIGN KEY (Producto_id) REFERENCES Productos(idProducto),
  FOREIGN KEY (Proveedor_id) REFERENCES Proveedores(idProveedor),
  FOREIGN KEY (Persona_id) REFERENCES Persona(idPersona)
);

-- TABLA: Venta
CREATE TABLE Venta (
  idVenta INT AUTO_INCREMENT PRIMARY KEY,
  Fecha DATE NOT NULL,
  Total DECIMAL(10,2) NOT NULL,
  Persona_id INT NOT NULL,
  FOREIGN KEY (Persona_id) REFERENCES Persona(idPersona)
);

-- TABLA: DetalleVenta
CREATE TABLE DetalleVenta (
  idDetalleVenta INT AUTO_INCREMENT PRIMARY KEY,
  Cantidad INT NOT NULL,
  PrecioUnitario DECIMAL(10,2) NOT NULL,
  Subtotal DECIMAL(10,2) NOT NULL,
  Venta_id INT NOT NULL,
  Producto_id INT NOT NULL,
  FOREIGN KEY (Venta_id) REFERENCES Venta(idVenta),
  FOREIGN KEY (Producto_id) REFERENCES Productos(idProducto)
);

-- TABLA: TipoDevolucion
CREATE TABLE TipoDevolucion (
  idTipoDevolucion INT AUTO_INCREMENT PRIMARY KEY,
  NombreTipo VARCHAR(45) NOT NULL
);

-- TABLA: Devolucion
CREATE TABLE Devolucion (
  idDevolucion INT AUTO_INCREMENT PRIMARY KEY,
  Fecha DATE NOT NULL,
  Motivo VARCHAR(200) NOT NULL,
  Cantidad INT NOT NULL,
  Producto_id INT NOT NULL,
  Persona_id INT NOT NULL,
  TipoDevolucion_id INT NOT NULL,
  FOREIGN KEY (Producto_id) REFERENCES Productos(idProducto),
  FOREIGN KEY (Persona_id) REFERENCES Persona(idPersona),
  FOREIGN KEY (TipoDevolucion_id) REFERENCES TipoDevolucion(idTipoDevolucion)
);
