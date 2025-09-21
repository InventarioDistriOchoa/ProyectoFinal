import DetalleVenta from "../models/detalleVenta.model.js";

// Crear detalle de venta
export const createDetalleVenta = async (req, res) => {
  try {
    const { Cantidad, PrecioUnitario, Subtotal, Venta_id, Producto_id } = req.body;
    const detalle = await DetalleVenta.create({
      Cantidad,
      PrecioUnitario,
      Subtotal,
      Venta_id,
      Producto_id,
    });

    res.status(201).json({
      ok: true,
      status: 201,
      Message: "Detalle de venta creado",
      body: detalle,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al crear detalle de venta",
      error: error.message,
    });
  }
};

// Mostrar todos los detalles de venta
export const showDetalleVenta = async (req, res) => {
  try {
    const detalles = await DetalleVenta.findAll();
    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Listado de detalles de venta",
      body: detalles,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al obtener detalles de venta",
      error: error.message,
    });
  }
};

// Mostrar detalle por ID
export const showIdDetalleVenta = async (req, res) => {
  try {
    const { id } = req.params;
    const detalle = await DetalleVenta.findOne({ where: { idDetalleVenta: id } });

    if (!detalle)
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Detalle de venta no encontrado",
      });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Detalle de venta encontrado",
      body: detalle,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al obtener detalle de venta",
      error: error.message,
    });
  }
};

// Actualizar detalle de venta
export const updateDetalleVenta = async (req, res) => {
  try {
    const { id } = req.params;
    const updated = await DetalleVenta.update(req.body, { where: { idDetalleVenta: id } });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Detalle de venta actualizado",
      body: updated,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al actualizar detalle de venta",
      error: error.message,
    });
  }
};

// Eliminar detalle de venta
export const deleteDetalleVenta = async (req, res) => {
  try {
    const { id } = req.params;
    await DetalleVenta.destroy({ where: { idDetalleVenta: id } });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Detalle de venta eliminado",
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al eliminar detalle de venta",
      error: error.message,
    });
  }
};
