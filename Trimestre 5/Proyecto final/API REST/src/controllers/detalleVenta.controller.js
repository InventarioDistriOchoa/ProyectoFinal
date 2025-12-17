import DetalleVenta from "../models/detalleVenta.model.js";
import Venta from "../models/venta.model.js";
import Producto from "../models/producto.model.js";
import { registrarAuditoria } from "../utils/registrarAuditoria.js";

async function actualizarTotalVenta(Venta_id) {
  const total = await DetalleVenta.sum("Subtotal", { where: { Venta_id } });
  await Venta.update({ Total: total || 0 }, { where: { idVenta: Venta_id } });
}

// =============================================
//   CREAR DETALLE (CREATE)
// =============================================
export const createDetalleVenta = async (req, res) => {
  try {
    const { Cantidad, PrecioUnitario, Subtotal, Venta_id, Producto_id } = req.body;

    const producto = await Producto.findByPk(Producto_id);
    if (!producto)
      return res.status(404).json({ Message: "Producto no encontrado" });

    if (producto.Cantidad_Actual < Cantidad)
      return res.status(400).json({
        Message: `Stock insuficiente. Disponible: ${producto.Cantidad_Actual}`,
      });

    const detalle = await DetalleVenta.create({
      Cantidad,
      PrecioUnitario,
      Subtotal,
      Venta_id,
      Producto_id,
    });

    await producto.update({
      Cantidad_Actual: producto.Cantidad_Actual - Cantidad,
    });

    await actualizarTotalVenta(Venta_id);

    await registrarAuditoria({
      usuario: req.userId,
      accion: "CREATE",
      coleccion: "DetalleVenta",
      documentoId: detalle.idDetalleVenta,
      datosAnteriores: null,
      datosNuevos: detalle.toJSON(),
      ip: req.ip,
    });

    return res.status(201).json({
      ok: true,
      Message: "Detalle creado",
      body: detalle,
    });

  } catch (error) {
    res.status(500).json({ Message: "Error al crear detalle", error: error.message });
  }
};


// =============================================
//   MOSTRAR TODOS
// =============================================
export const showDetalleVenta = async (req, res) => {
  try {
    const detalles = await DetalleVenta.findAll();
    res.json({ ok: true, body: detalles });

  } catch (error) {
    res.status(500).json({ Message: "Error al obtener detalles" });
  }
};


// =============================================
//   MOSTRAR POR ID
// =============================================
export const showIdDetalleVenta = async (req, res) => {
  try {
    const { id } = req.params;
    const detalle = await DetalleVenta.findByPk(id);

    if (!detalle)
      return res.status(404).json({ Message: "Detalle no encontrado" });

    res.json({ ok: true, body: detalle });

  } catch (error) {
    res.status(500).json({ Message: "Error al obtener detalle" });
  }
};


// =============================================
//   ACTUALIZAR DETALLE (UPDATE)
// =============================================
export const updateDetalleVenta = async (req, res) => {
  try {
    const { id } = req.params;
    const detalle = await DetalleVenta.findByPk(id);

    if (!detalle)
      return res.status(404).json({ Message: "Detalle no encontrado" });

    const datosAnteriores = detalle.toJSON();

    await detalle.update(req.body);

    const datosNuevos = detalle.toJSON();

    await actualizarTotalVenta(detalle.Venta_id);

    await registrarAuditoria({
      usuario: req.userId,
      accion: "UPDATE",
      coleccion: "DetalleVenta",
      documentoId: id,
      datosAnteriores,
      datosNuevos,
      ip: req.ip,
    });

    res.json({
      ok: true,
      Message: "Detalle actualizado",
      body: detalle,
    });

  } catch (error) {
    res.status(500).json({ Message: "Error al actualizar detalle" });
  }
};


// =============================================
//   ELIMINAR DETALLE (DELETE)
// =============================================
export const deleteDetalleVenta = async (req, res) => {
  try {
    const { id } = req.params;
    const detalle = await DetalleVenta.findByPk(id);

    if (!detalle)
      return res.status(404).json({ Message: "Detalle no encontrado" });

    const datosAnteriores = detalle.toJSON();

    await detalle.destroy();

    await actualizarTotalVenta(detalle.Venta_id);

    await registrarAuditoria({
      usuario: req.userId,
      accion: "DELETE",
      coleccion: "DetalleVenta",
      documentoId: id,
      datosAnteriores,
      datosNuevos: null,
      ip: req.ip,
    });

    res.json({
      ok: true,
      Message: "Detalle eliminado",
    });

  } catch (error) {
    res.status(500).json({ Message: "Error al eliminar detalle" });
  }
};
