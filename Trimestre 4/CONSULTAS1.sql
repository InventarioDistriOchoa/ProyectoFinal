#1. Mostar el reporte de las ventas realizadas  por día, con datos del vendedor.
SELECT 
  v.fecha AS Fecha,
  per.nombre AS Vendedor,
  SUM(v.total) AS Total_Ventas,
  COUNT(v.idVenta) AS Num_Ventas
FROM venta v
INNER JOIN persona per ON per.idPersona = v.Persona_idPersona
INNER JOIN roles r ON r.idRol = per.Rol_idRol
GROUP BY v.fecha, per.nombre
ORDER BY Fecha DESC;
#2. Obtener el historial de cada producto, las entradas al inventario y sus ventas (salidas), mostrando fechas y cantidades
 SELECT 
  p.nombre AS Producto,
  e.fecha AS Fecha_Entrada,
  e.cantidad AS Cant_Entrada,
  v.fecha AS Fecha_Venta,
  dv.cantidad AS Cant_Vendida
FROM productos p
LEFT JOIN entradas e ON e.Producto_idProducto = p.idProducto
LEFT JOIN detalleventa dv ON dv.Producto_idProducto = p.idProducto
LEFT JOIN venta v ON v.idVenta = dv.Venta_idVenta;

#3. Mostrar productos con bajo stock (-20), su categoría, el proveedor de la última entrada y la persona que hizo el registro de la entrada del producto.
SELECT 
  p.nombre AS Producto,
  p.cantidad_Actual AS Stock,
  c.Nombre_Categoria AS Categoria,
  pr.Nombre_Empresa AS Ultimo_Proveedor,
  per.nombre AS Registrado_Por
FROM productos p
INNER JOIN categorias c ON c.idCategoria = p.Categoria_idCategoria
LEFT JOIN entradas e ON e.Producto_idProducto = p.idProducto
LEFT JOIN proveedores pr ON pr.idProveedor = e.Proveedor_idProveedor
LEFT JOIN persona per ON per.idPersona = e.Persona_idPersona
WHERE p.cantidad_Actual < 20
ORDER BY p.cantidad_Actual ASC;
#4. Calcular la suma total vendida agrupada por categoría de producto.
SELECT 
  c.Nombre_Categoria,
  per.nombre AS Cliente,
  SUM(dv.subtotal) AS Total_Vendido
FROM detalleventa dv
INNER JOIN productos p ON p.idProducto = dv.Producto_idProducto
INNER JOIN categorias c ON c.idCategoria = p.Categoria_idCategoria
INNER JOIN venta v ON v.idVenta = dv.Venta_idVenta
INNER JOIN persona per ON per.idPersona = v.Persona_idPersona
GROUP BY c.Nombre_Categoria, per.nombre;
#5. Mostrar cuántas devoluciones ha tenido cada producto y registro del motivo

SELECT 
  p.nombre AS Producto,
  d.motivo,
  per.nombre AS Responsable,
  COUNT(*) AS Total_Devoluciones
FROM devoluciones d
INNER JOIN productos p ON p.idProducto = d.Producto_idProducto
INNER JOIN persona per ON per.idPersona = d.Persona_idPersona
INNER JOIN tipodevolucion td ON td.idTipoDevolucion = d.TipoDevolucion_idTipoDevolucion
GROUP BY p.nombre, d.motivo, per.nombre;
#6. Ventas del mes actual, con datos del vendedor y cliente.
SELECT 
  v.fecha,
  per.nombre AS Cliente,
  r.Descripcion_Rol AS Rol,
  SUM(dv.subtotal) AS Total_Venta
FROM venta v
INNER JOIN detalleventa dv ON dv.Venta_idVenta = v.idVenta
INNER JOIN persona per ON per.idPersona = v.Persona_idPersona
INNER JOIN roles r ON r.idRol = per.Rol_idRol
WHERE MONTH(v.fecha) = MONTH(CURDATE()) AND YEAR(v.fecha) = YEAR(CURDATE())
GROUP BY v.fecha, per.nombre, r.Descripcion_Rol;
#7. Calcular la cantidad total de productos entregados por cada proveedor al sistema.
SELECT 
  pr.Nombre_Empresa AS Proveedor,
  per.nombre AS Registrado_Por,
  r.Descripcion_Rol,
  SUM(e.cantidad) AS Total_Entregado
FROM entradas e
INNER JOIN proveedores pr ON pr.idProveedor = e.Proveedor_idProveedor
INNER JOIN persona per ON per.idPersona = e.Persona_idPersona
INNER JOIN roles r ON r.idRol = per.Rol_idRol
GROUP BY pr.Nombre_Empresa, per.nombre, r.Descripcion_Rol;
#8. Mostrar cuántas devoluciones ha tenido cada producto, clasificadas por tipo de devolución (cliente o proveedor).
SELECT 
  p.nombre AS Producto,
  td.nombreTipo AS Tipo_Devolucion,
  COUNT(*) AS Frecuencia
FROM devoluciones d
INNER JOIN productos p ON p.idProducto = d.Producto_idProducto
INNER JOIN tipodevolucion td ON td.idTipoDevolucion = d.TipoDevolucion_idTipoDevolucion
GROUP BY p.nombre, td.nombreTipo;

#9. Mostrar los productos más vendidos, su categoría, el nombre del vendedor y el cliente que compró
SELECT 
  p.nombre AS Producto,
  c.Nombre_Categoria AS Categoria,
  per.nombre AS Cliente,
  v.fecha AS Fecha_Venta,
  SUM(dv.cantidad) AS Total_Vendido
FROM detalleventa dv
INNER JOIN productos p ON p.idProducto = dv.Producto_idProducto
INNER JOIN categorias c ON c.idCategoria = p.Categoria_idCategoria
INNER JOIN venta v ON v.idVenta = dv.Venta_idVenta
INNER JOIN persona per ON per.idPersona = v.Persona_idPersona
GROUP BY p.nombre, c.Nombre_Categoria, per.nombre, v.fecha
ORDER BY Total_Vendido DESC;
#10. Mostrar la cantidad de devoluciones por mes, motivo, tipo de devolución (cliente/proveedor) y la persona que la registró.
SELECT 
  MONTH(d.fecha) AS Mes,
  d.motivo,
  td.nombreTipo AS Tipo_Devolucion,
  per.nombre AS Registrado_Por,
  COUNT(*) AS Total_Devoluciones
FROM devoluciones d
INNER JOIN tipodevolucion td ON td.idTipoDevolucion = d.TipoDevolucion_idTipoDevolucion
INNER JOIN persona per ON per.idPersona = d.Persona_idPersona
INNER JOIN productos p ON p.idProducto = d.Producto_idProducto
INNER JOIN roles r ON r.idRol = per.Rol_idRol
GROUP BY Mes, d.motivo, td.nombreTipo, per.nombre
ORDER BY Mes, Total_Devoluciones DESC;