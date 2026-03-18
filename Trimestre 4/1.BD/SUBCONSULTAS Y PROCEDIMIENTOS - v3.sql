select res.Cliente, res.FechaVenta, res.NumeroFactura, res.Cantidad, res.Total from(
SELECT P.nombre Cliente, V.fecha FechaVenta,V.idVenta NumeroFactura, pr.nombre Producto, pr.precio,sum(DV.cantidad) Cantidad, sum(DV.subtotal) Total
FROM venta V
INNER JOIN detalleventa DV ON DV.idDetalleVenta = V.idVenta
INNER JOIN persona P ON P.idPersona = V.Persona_idPersona
inner join productos pr ON pr.idProducto = DV.Producto_idProducto
group by P.nombre, V.fecha,V.idVenta, pr.nombre, pr.precio)res;

SELECT RES.*, 'Alto Stock' AS Observacion 
FROM (SELECT P.idProducto, P.nombre AS Producto, C.Nombre_Categoria AS Categoria, P.precio, P.cantidad_Actual AS Stock
    FROM productos P
    INNER JOIN categorias C ON C.idCategoria = P.Categoria_idCategoria) RES
WHERE RES.Stock >= 50

UNION ALL

SELECT RES.*, 'Bajo Stock' AS Observacion 
FROM (SELECT P.idProducto, P.nombre AS Producto, C.Nombre_Categoria AS Categoria, P.precio, P.cantidad_Actual AS Stock
    FROM productos P
    INNER JOIN categorias C ON C.idCategoria = P.Categoria_idCategoria) RES
WHERE RES.Stock < 50;

##Productos con más devoluciones que el promedio general
SELECT p.idProducto,p.nombre AS Producto,c.Nombre_Categoria AS Categoria,
(SELECT SUM(CAST(dv.cantidad AS SIGNED)) 
FROM Devoluciones dv 
WHERE dv.Producto_idProducto = p.idProducto) AS Total_Devoluciones
FROM Productos p
INNER JOIN Categorias c ON p.Categoria_idCategoria = c.idCategoria
WHERE (SELECT SUM(CAST(dv.cantidad AS SIGNED)) 
FROM Devoluciones dv 
WHERE dv.Producto_idProducto = p.idProducto) > (
SELECT AVG(DevolucionesTotales) 
FROM (SELECT SUM(CAST(dv2.cantidad AS SIGNED)) AS DevolucionesTotales
FROM Devoluciones dv2
GROUP BY dv2.Producto_idProducto) AS sub);


##Productos con su proveedor, categoría y total vendido
SELECT p.nombre AS Producto,c.Nombre_Categoria AS Categoria,pr.Nombre_Empresa AS Proveedor,
(SELECT SUM(dv.cantidad)
FROM detalleventa dv
WHERE dv.Producto_idProducto = p.idProducto) AS TotalVendido
FROM productos p
LEFT JOIN categorias c ON p.Categoria_idCategoria = c.idCategoria
INNER JOIN entradas e ON e.Producto_idProducto = p.idProducto
LEFT JOIN proveedores pr ON e.Proveedor_idProveedor = pr.idProveedor
GROUP BY p.idProducto;

##Facturas con cliente, total gastado y fecha de compra más reciente
SELECT v.idVenta,pe.nombre AS Cliente,
(SELECT MAX(v2.fecha)
FROM venta v2
WHERE v2.Persona_idPersona = pe.idPersona) AS FechaUltimaCompra,
SUM(dv.subtotal) AS TotalGastado
FROM venta v
RIGHT JOIN persona pe ON v.Persona_idPersona = pe.idPersona
INNER JOIN detalleventa dv ON dv.idDetalleVenta = v.idVenta
GROUP BY v.idVenta, pe.nombre;

##Mostrar ventas por fecha
DELIMITER //
CREATE PROCEDURE MostrarVentaPorFecha(IN fecha_busqueda DATE)
BEGIN
    SELECT v.idVenta AS NumeroVenta,p.nombre AS Cliente,v.fecha AS FechaVenta,pr.nombre AS Producto,dv.cantidad AS Cantidad,
        dv.subtotal AS Subtotal
    FROM venta v
    INNER JOIN persona p ON v.Persona_idPersona = p.idPersona
    INNER JOIN detalleventa dv ON dv.idDetalleVenta = v.idVenta
    INNER JOIN productos pr ON dv.Producto_idProducto = pr.idProducto
    WHERE v.fecha = fecha_busqueda;
END //
DELIMITER ;




#mostrar devoluciones por fecha
DELIMITER //
CREATE PROCEDURE MostrarDevolucionesPorFecha(IN fecha_busqueda DATE)
BEGIN
    SELECT d.idDevolucion AS NumeroDevolucion,d.fecha AS FechaDevolucion,pr.nombre AS Producto,d.cantidad AS CantidadDevuelta
    FROM devoluciones d
    INNER JOIN productos pr ON d.Producto_idProducto = pr.idProducto
    WHERE d.fecha = fecha_busqueda;
END //
DELIMITER ;

DELIMITER //

#Filtrar productos por letra
CREATE PROCEDURE FiltrarProductosPorLetra(IN letra CHAR(1))
BEGIN
    SELECT p.idProducto AS ID,p.nombre AS Producto,p.cantidad_Actual AS Cantidad,c.Nombre_Categoria AS Categoria,pr.Nombre_Empresa AS Proveedor
    FROM productos p
    INNER JOIN categorias c ON p.Categoria_idCategoria = c.idCategoria
    INNER JOIN entradas e ON p.idProducto = e.Producto_idProducto
    INNER JOIN proveedores pr ON e.Proveedor_idProveedor = pr.idProveedor
    WHERE p.nombre LIKE CONCAT(letra, '%')
    GROUP BY p.idProducto;
END //

DELIMITER ;






