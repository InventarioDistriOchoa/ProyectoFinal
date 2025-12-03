// src/controllers/stock.controller.js
import Producto from "../models/producto.model.js";
import Categoria from "../models/categoria.model.js";
import Entrada from "../models/entrada.model.js";
import DetalleVenta from "../models/detalleVenta.model.js";
import Devolucion from "../models/devolucion.model.js";
import TipoDevolucion from "../models/tipoDevolucion.model.js";

export const getStock = async (req, res) => {
  try {
    // 1️⃣ Traer productos junto con su categoría
    const productos = await Producto.findAll({
      include: [
        {
          model: Categoria,
          as: "Categoria",                  // 👈 usa el alias correcto de la relación
          attributes: ["Nombre_Categoria"], // solo este campo
        },
      ],
      order: [["Nombre", "ASC"]],
    });

    // 2️⃣ Calcular stock producto por producto
    const stockData = await Promise.all(
      productos.map(async (p) => {
        const entradas =
          (await Entrada.sum("Cantidad", { where: { Producto_id: p.idProducto } })) || 0;
        const salidas =
          (await DetalleVenta.sum("Cantidad", { where: { Producto_id: p.idProducto } })) || 0;

        // ✅ Devoluciones separadas por tipo
        const devolucionesProveedor =
          (await Devolucion.sum("Cantidad", {
            where: { Producto_id: p.idProducto },
            include: [
              {
                model: TipoDevolucion,
                as: "TipoDevolucion",
                where: { NombreTipo: "proveedor" },
              },
            ],
          })) || 0;

        const devolucionesCliente =
          (await Devolucion.sum("Cantidad", {
            where: { Producto_id: p.idProducto },
            include: [
              {
                model: TipoDevolucion,
                as: "TipoDevolucion",
                where: { NombreTipo: "cliente" },
              },
            ],
          })) || 0;

        // Estado del stock
        let estado = "verde";
        if (p.Cantidad_Actual <= 0) estado = "rojo";
        else if (p.Cantidad_Actual <= 5) estado = "amarillo";

        return {
          id: p.idProducto,
          producto: p.Nombre,
          categoria: p.Categoria?.Nombre_Categoria || "Sin categoría", // 👈 categoría lista
          estado,
          disponible: p.Cantidad_Actual,
          entradas,
          salidas,
          devolucionesProveedor,
          devolucionesCliente,
        };
      })
    );

    res.json({ body: stockData });
  } catch (error) {
    console.error(error);
    res
      .status(500)
      .json({ ok: false, message: "Error al traer stock", error: error.message });
  }
};
