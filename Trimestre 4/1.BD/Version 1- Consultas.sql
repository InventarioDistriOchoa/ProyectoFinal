
#1. Total vendido por categoría y mes con nombre del mes y responsable de la venta
SELECT 
  MONTHNAME(v.fecha) AS Mes,
  c.Nombre_Categoria AS Categoria,
  per.nombre AS Vendedor,
  SUM(dv.cantidad * dv.PrecioUnitario) AS Total_Vendido
FROM detalleventa dv
JOIN venta v ON v.idVenta = dv.Venta_idVenta
JOIN persona per ON per.idPersona = v.Persona_idPersona
JOIN productos p ON p.idProducto = dv.Producto_idProducto
JOIN categorias c ON c.idCategoria = p.Categoria_idCategoria
GROUP BY Mes, Categoria, Vendedor
ORDER BY Mes, Total_Vendido DESC;


#2. Reporte de productos con bajo stock y proveedor de la última entrada
SELECT 
  p.nombre AS Producto,
  c.Nombre_Categoria,
  p.cantidad_Actual AS Stock,
  pr.Nombre_Empresa AS Ultimo_Proveedor,
  MAX(e.fecha) AS Fecha_Entrada
FROM productos p
JOIN categorias c ON c.idCategoria = p.Categoria_idCategoria
LEFT JOIN entradas e ON e.Producto_idProducto = p.idProducto
LEFT JOIN proveedores pr ON pr.idProveedor = e.Proveedor_idProveedor
WHERE p.cantidad_Actual < 25
GROUP BY p.idProducto;

#3.Entradas realizadas entre febrero y marzo 2024
SELECT 
  e.fecha,
  p.nombre AS Producto,
  pr.Nombre_Empresa AS Proveedor,
  per.nombre AS Responsable,
  e.Cantidad
FROM entradas e
JOIN productos p ON e.Producto_idProducto = p.idProducto
JOIN proveedores pr ON e.Proveedor_idProveedor = pr.idProveedor
JOIN persona per ON e.Persona_idPersona = per.idPersona
WHERE e.fecha BETWEEN '2024-02-27' AND '2024-03-10'
ORDER BY e.fecha ASC;


#4. Calcular las ventas por vendedor y categoría del producto
SELECT 
  per.nombre AS Vendedor,
  c.Nombre_Categoria,
  SUM(dv.cantidad * dv.PrecioUnitario) AS Total_Vendido
FROM venta v
JOIN persona per ON per.idPersona = v.Persona_idPersona
JOIN detalleventa dv ON dv.Venta_idVenta = v.idVenta
JOIN productos p ON p.idProducto = dv.Producto_idProducto
JOIN categorias c ON c.idCategoria = p.Categoria_idCategoria
GROUP BY Vendedor, Nombre_Categoria;


#5. Mostrar el total de devoluciones por mes y persona responsable
SELECT 
  MONTHNAME(d.fecha) AS Mes,
  per.nombre AS Responsable,
  COUNT(d.idDevolucion) AS Total_Devoluciones
FROM devoluciones d
JOIN persona per ON per.idPersona = d.Persona_idPersona
GROUP BY Mes, Responsable;

#6.Mostrar el stock total de productos agrupado por proveedor y categoría
SELECT 
  pr.Nombre_Empresa AS Proveedor,
  c.Nombre_Categoria,
  SUM(p.cantidad_Actual) AS Stock_Total
FROM productos p
JOIN categorias c ON c.idCategoria = p.Categoria_idCategoria
JOIN entradas e ON e.Producto_idProducto = p.idProducto
JOIN proveedores pr ON pr.idProveedor = e.Proveedor_idProveedor
GROUP BY Proveedor, Nombre_Categoria;


#7. Porcentaje de productos vendidos por categoría (en marzo 2024)
SELECT 
  c.Nombre_Categoria,
  CONCAT(ROUND(SUM(dv.cantidad) * 100.0 / 
      (SELECT SUM(dv2.cantidad)
       FROM venta v2
       JOIN detalleventa dv2 ON v2.idVenta = dv2.Venta_idVenta
       WHERE MONTH(v2.fecha) = 3 AND YEAR(v2.fecha) = 2024
      ), 2), '%') AS Porcentaje_Vendido
FROM venta v
JOIN detalleventa dv ON v.idVenta = dv.Venta_idVenta
JOIN productos p ON p.idProducto = dv.Producto_idProducto
JOIN categorias c ON c.idCategoria = p.Categoria_idCategoria
JOIN persona per ON per.idPersona = v.Persona_idPersona
WHERE MONTH(v.fecha) = 3 AND YEAR(v.fecha) = 2024
GROUP BY c.Nombre_Categoria;



#8. Productos más vendidos por categoría y día en marzo 2024
SELECT 
  DATE(v.fecha) AS Fecha_Venta,
  c.Nombre_Categoria,
  p.nombre AS Producto,
  SUM(dv.cantidad) AS Cantidad_Vendida
FROM venta v
JOIN detalleventa dv ON v.idVenta = dv.Venta_idVenta
JOIN productos p ON p.idProducto = dv.Producto_idProducto
JOIN categorias c ON c.idCategoria = p.Categoria_idCategoria
WHERE v.fecha BETWEEN '2024-03-01' AND '2024-03-31'
GROUP BY Fecha_Venta, c.Nombre_Categoria, p.nombre
ORDER BY Fecha_Venta ASC, Cantidad_Vendida DESC;




#9.  Productos más devueltos con detalles
SELECT    
  p.nombre AS Producto,  
  c.Nombre_Categoria AS Categoria,  
  td.nombreTipo AS Tipo_Devolucion,  
  MAX(d.fecha) AS Fecha_Ultima_Devolucion,  
  SUM(d.cantidad) AS Total_Devoluciones
FROM devoluciones d
JOIN productos p ON d.Producto_idProducto = p.idProducto
JOIN categorias c ON p.Categoria_idCategoria = c.idCategoria
JOIN tipodevolucion td ON d.TipoDevolucion_idTipoDevolucion = td.idTipoDevolucion
WHERE d.fecha BETWEEN '2024-02-01' AND '2024-06-30'
GROUP BY p.nombre, c.Nombre_Categoria, td.nombreTipo
ORDER BY Total_Devoluciones DESC
LIMIT 10;



#10.  Total de devoluciones por tipo (Cliente o Proveedor) y categoría de producto, agrupado por mes, con funciones de fecha y ordenado por cantidad devuelta.
SELECT
  MONTHNAME(d.fecha) AS Mes,
  td.nombreTipo AS Tipo_Devolucion,
  c.Nombre_Categoria AS Categoria,
  SUM(d.cantidad) AS Total_Devuelto
FROM devoluciones d
JOIN productos p ON d.Producto_idProducto = p.idProducto
JOIN categorias c ON p.Categoria_idCategoria = c.idCategoria
JOIN tipodevolucion td ON d.TipoDevolucion_idTipoDevolucion = td.idTipoDevolucion
WHERE d.fecha BETWEEN '2024-03-01' AND '2024-06-30'
GROUP BY Mes, Tipo_Devolucion, Categoria
ORDER BY Mes, Total_Devuelto DESC;


 ###11. Valor total vendido por vendedor y categoría en el primer trimestre 2024, con nombre de mes

SELECT 
  MONTHNAME(v.fecha) AS Mes,
  per.nombre AS Vendedor,
  c.Nombre_Categoria AS Categoria,
  SUM(dv.subtotal) AS Total_Vendido
FROM Venta v
JOIN Persona per ON per.idPersona = v.Persona_idPersona
JOIN DetalleVenta dv ON dv.Venta_idVenta = v.idVenta
JOIN Productos p ON p.idProducto = dv.Producto_idProducto
JOIN Categorias c ON c.idCategoria = p.Categoria_idCategoria
WHERE v.fecha BETWEEN '2024-01-01' AND '2024-03-31'
GROUP BY Mes, Vendedor, Categoria
ORDER BY Mes, Total_Vendido DESC;

###12. Productos con más devoluciones agrupadas por tipo de devolución, categoría y responsable

SELECT    
  per.nombre AS Responsable,  
  td.nombreTipo AS Tipo_Devolucion,  
  c.Nombre_Categoria AS Categoria,  
  p.nombre AS Producto,  
  SUM(CAST(d.cantidad AS UNSIGNED)) AS Total_Devoluciones
FROM Devoluciones d
JOIN Persona per ON per.idPersona = d.Persona_idPersona
JOIN Productos p ON p.idProducto = d.Producto_idProducto
JOIN Categorias c ON c.idCategoria = p.Categoria_idCategoria
JOIN TipoDevolucion td ON td.idTipoDevolucion = d.TipoDevolucion_idTipoDevolucion
WHERE d.fecha BETWEEN '2024-02-01' AND '2024-06-30'
GROUP BY Responsable, Tipo_Devolucion, Categoria, Producto
ORDER BY Total_Devoluciones DESC
LIMIT 10;


###13.Stock final de cada producto considerando entradas y devoluciones del primer semestre 2024
SELECT 
  p.nombre AS Producto,
  c.Nombre_Categoria AS Categoria,
  SUM(e.cantidad) AS Total_Entradas,
  SUM(CAST(d.cantidad AS UNSIGNED)) AS Total_Devoluciones,
  (SUM(e.cantidad) - SUM(CAST(d.cantidad AS UNSIGNED))) AS Stock_Final
FROM Productos p
JOIN Categorias c ON c.idCategoria = p.Categoria_idCategoria
LEFT JOIN Entradas e ON e.Producto_idProducto = p.idProducto 
    AND e.fecha BETWEEN '2024-01-01' AND '2024-06-30'
LEFT JOIN Devoluciones d ON d.Producto_idProducto = p.idProducto 
    AND d.fecha BETWEEN '2024-01-01' AND '2024-06-30'
GROUP BY Producto, Categoria
ORDER BY Stock_Final DESC;


###14.Relación de ventas con devoluciones, por cliente, tipo de documento y rol
SELECT 
  per.nombre AS Cliente,
  td.descripcion AS Tipo_Documento,
  r.Descripcion_Rol AS Rol,
  COUNT(DISTINCT v.idVenta) AS Total_Ventas,
  COUNT(DISTINCT d.idDevolucion) AS Total_Devoluciones
FROM Persona per
JOIN Tipo_Documento td ON td.idTipo_Documento = per.Tipo_Documento_idTipo_Documento
JOIN Roles r ON r.idRol = per.Rol_idRol
LEFT JOIN Venta v ON v.Persona_idPersona = per.idPersona
LEFT JOIN Devoluciones d ON d.Persona_idPersona = per.idPersona
GROUP BY Cliente, Tipo_Documento, Rol
ORDER BY Total_Ventas DESC;


###15.Total de productos devueltos por proveedor, categoría y día de la semana entre febrero y junio 2024"
SELECT
  DATE_FORMAT(d.fecha, '%W') AS Dia_Semana,
  pr.Nombre_Empresa AS Proveedor,
  c.Nombre_Categoria AS Categoria,
  p.nombre AS Producto,
  SUM(CAST(d.cantidad AS UNSIGNED)) AS Total_Devuelto
FROM Devoluciones d
JOIN Productos p ON d.Producto_idProducto = p.idProducto
JOIN Categorias c ON p.Categoria_idCategoria = c.idCategoria
JOIN Entradas e ON e.Producto_idProducto = p.idProducto
JOIN Proveedores pr ON pr.idProveedor = e.Proveedor_idProveedor
WHERE d.fecha BETWEEN '2024-02-01' AND '2024-06-30'
GROUP BY Dia_Semana, Proveedor, Categoria, Producto
ORDER BY Total_Devuelto DESC
LIMIT 15;

