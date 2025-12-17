### 1. Productos con más devoluciones que el promedio general
SELECT 
  p.idProducto,
  p.nombre AS Producto,
  c.Nombre_Categoria AS Categoria,
  (
    SELECT SUM(CAST(dv.cantidad AS SIGNED)) 
    FROM Devoluciones dv 
    WHERE dv.Producto_idProducto = p.idProducto
  ) AS Total_Devoluciones
FROM Productos p
INNER JOIN Categorias c ON p.Categoria_idCategoria = c.idCategoria
WHERE (
  SELECT SUM(CAST(dv.cantidad AS SIGNED)) 
  FROM Devoluciones dv 
  WHERE dv.Producto_idProducto = p.idProducto
) > (
  SELECT AVG(DevolucionesTotales) 
  FROM (
    SELECT SUM(CAST(dv2.cantidad AS SIGNED)) AS DevolucionesTotales
    FROM Devoluciones dv2
    GROUP BY dv2.Producto_idProducto
  ) AS sub
);


###2. Productos con su proveedor, categoría y total vendido
SELECT 
  p.nombre AS Producto,
  c.Nombre_Categoria AS Categoria,
  pr.Nombre_Empresa AS Proveedor,
  (
    SELECT SUM(dv.cantidad)
    FROM detalleventa dv
    WHERE dv.Producto_idProducto = p.idProducto
  ) AS TotalVendido
FROM productos p
LEFT JOIN categorias c ON p.Categoria_idCategoria = c.idCategoria
INNER JOIN entradas e ON e.Producto_idProducto = p.idProducto
LEFT JOIN proveedores pr ON e.Proveedor_idProveedor = pr.idProveedor
GROUP BY p.idProducto;


###3. Facturas con cliente, total gastado y fecha de compra más reciente
SELECT 
  v.idVenta,
  pe.nombre AS Cliente,
  (
    SELECT MAX(v2.fecha)
    FROM venta v2
    WHERE v2.Persona_idPersona = pe.idPersona
  ) AS FechaUltimaCompra,
  SUM(dv.subtotal) AS TotalGastado
FROM venta v
RIGHT JOIN persona pe ON v.Persona_idPersona = pe.idPersona
INNER JOIN detalleventa dv ON dv.idDetalleVenta = v.idVenta
GROUP BY v.idVenta, pe.nombre;

###4. 4. Productos clasificados por nivel de stock (Alto / Bajo)
SELECT RES.*, 'Alto Stock' AS Observacion 
FROM (
  SELECT 
    P.idProducto, 
    P.nombre AS Producto, 
    C.Nombre_Categoria AS Categoria, 
    P.precio, 
    P.cantidad_Actual AS Stock
  FROM productos P
  INNER JOIN categorias C ON C.idCategoria = P.Categoria_idCategoria
) RES
WHERE RES.Stock >= 50

UNION ALL

SELECT RES.*, 'Bajo Stock' AS Observacion 
FROM (
  SELECT 
    P.idProducto, 
    P.nombre AS Producto, 
    C.Nombre_Categoria AS Categoria, 
    P.precio, 
    P.cantidad_Actual AS Stock
  FROM productos P
  INNER JOIN categorias C ON C.idCategoria = P.Categoria_idCategoria
) RES
WHERE RES.Stock < 50;


###5. Vista general de ventas con cliente, fecha y total
SELECT 
  res.Cliente, 
  res.FechaVenta, 
  res.NumeroFactura, 
  res.Cantidad, 
  res.Total 
FROM (
  SELECT 
    P.nombre AS Cliente, 
    V.fecha AS FechaVenta,
    V.idVenta AS NumeroFactura, 
    pr.nombre AS Producto, 
    pr.precio,
    SUM(DV.cantidad) AS Cantidad, 
    SUM(DV.subtotal) AS Total
  FROM venta V
  INNER JOIN detalleventa DV ON DV.idDetalleVenta = V.idVenta
  INNER JOIN persona P ON P.idPersona = V.Persona_idPersona
  INNER JOIN productos pr ON pr.idProducto = DV.Producto_idProducto
  GROUP BY P.nombre, V.fecha, V.idVenta, pr.nombre, pr.precio
) res;


