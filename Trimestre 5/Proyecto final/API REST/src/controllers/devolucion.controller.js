// controllers/devolucion.controller.js
import Devolucion from "../models/devolucion.model.js";
import Producto from "../models/producto.model.js";
import TipoDevolucion from "../models/tipoDevolucion.model.js";

// ================== Crear devolución ==================
export const createDevolucion = async (req, res) => {
  try {
    // 1️⃣ Crear registro de la devolución
    const devolucion = await Devolucion.create(req.body);

    // 2️⃣ Ajustar inventario SOLO si la devolución es al proveedor
    const tipo = await TipoDevolucion.findByPk(req.body.TipoDevolucion_id);

    if (tipo && tipo.NombreTipo && tipo.NombreTipo.toLowerCase() === "proveedor") {
      const producto = await Producto.findByPk(req.body.Producto_id);

      if (producto) {
        const cantidadDevuelta = Number(req.body.Cantidad) || 0;
        const nuevaCantidad = producto.Cantidad_Actual - cantidadDevuelta;

        if (nuevaCantidad <= 0) {
          // 🔴 Eliminar el producto si queda sin stock
          await Producto.destroy({ where: { idProducto: producto.idProducto } });
        } else {
          // 🟢 Solo actualizar la cantidad
          await Producto.update(
            { Cantidad_Actual: nuevaCantidad },
            { where: { idProducto: producto.idProducto } }
          );
        }
      }
    }

    // 3️⃣ Respuesta al cliente
    res.status(201).json({
      ok: true,
      status: 201,
      Message: "Devolución creada y stock actualizado",
      body: devolucion,
    });
  } catch (error) {
    console.error("❌ Error en createDevolucion:", error);
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al crear devolución",
      error: error.message,
    });
  }
};

// Mostrar todas
export const showDevolucion = async (req, res) => {
  try {
    const devoluciones = await Devolucion.findAll();
    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Listado de devoluciones",
      body: devoluciones,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al obtener devoluciones",
      error: error.message,
    });
  }
};

// Mostrar por ID
export const showIdDevolucion = async (req, res) => {
  try {
    const { id } = req.params;
    const devolucion = await Devolucion.findOne({ where: { idDevolucion: id } });

    if (!devolucion) {
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Devolución no encontrada",
      });
    }

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Devolución encontrada",
      body: devolucion,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al obtener devolución",
      error: error.message,
    });
  }
};

// Actualizar devolución
export const updateDevolucion = async (req, res) => {
  try {
    const { id } = req.params;
    const updated = await Devolucion.update(req.body, {
      where: { idDevolucion: id },
    });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Devolución actualizada",
      body: updated,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al actualizar devolución",
      error: error.message,
    });
  }
};

// Eliminar devolución
export const deleteDevolucion = async (req, res) => {
  try {
    const { id } = req.params;
    await Devolucion.destroy({ where: { idDevolucion: id } });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Devolución eliminada",
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al eliminar devolución",
      error: error.message,
    });
  }
};
