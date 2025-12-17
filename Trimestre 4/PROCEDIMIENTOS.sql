###PROCEDIMIENTOS EJEMPLOS


DELIMITER //

CREATE PROCEDURE MostrarVentaPorFecha(IN fecha_busqueda DATE)
BEGIN
    SELECT 
        v.idVenta AS NumeroVenta,
        p.nombre AS Cliente,
        v.fecha AS FechaVenta,
        pr.nombre AS Producto,
        dv.cantidad AS Cantidad,
        dv.subtotal AS Subtotal
    FROM venta v
    INNER JOIN persona p ON v.Persona_idPersona = p.idPersona
    INNER JOIN detalleventa dv ON dv.idDetalleVenta = v.idVenta
    INNER JOIN productos pr ON dv.Producto_idProducto = pr.idProducto
    WHERE v.fecha = fecha_busqueda;
END //

DELIMITER ;

CALL MostrarVentaPorFecha('2024-03-05');



###

DELIMITER //

CREATE PROCEDURE MostrarDevolucionesPorFecha(IN fecha_busqueda DATE)
BEGIN
    SELECT 
        d.idDevolucion AS NumeroDevolucion,
        d.fecha AS FechaDevolucion,
        pr.nombre AS Producto,
        d.cantidad AS CantidadDevuelta
    FROM devoluciones d
    INNER JOIN productos pr ON d.Producto_idProducto = pr.idProducto
    WHERE d.fecha = fecha_busqueda;
END //

DELIMITER ;

CALL MostrarDevolucionesPorFecha('2024-03-03');

###

DELIMITER //

CREATE PROCEDURE FiltrarProductosPorLetra(IN letra CHAR(1))
BEGIN
    SELECT 
        p.idProducto AS ID,
        p.nombre AS Producto,
        p.cantidad_Actual AS Cantidad,
        c.Nombre_Categoria AS Categoria,
        pr.Nombre_Empresa AS Proveedor
    FROM productos p
    INNER JOIN categorias c ON p.Categoria_idCategoria = c.idCategoria
    INNER JOIN entradas e ON p.idProducto = e.Producto_idProducto
    INNER JOIN proveedores pr ON e.Proveedor_idProveedor = pr.idProveedor
    WHERE p.nombre LIKE CONCAT(letra, '%')
    GROUP BY p.idProducto;
END //

DELIMITER ;
CALL FiltrarProductosPorLetra('A');



