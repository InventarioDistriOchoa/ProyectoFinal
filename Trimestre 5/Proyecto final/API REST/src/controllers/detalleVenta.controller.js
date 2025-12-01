import DetalleVenta from "../models/detalleVenta.model.js";
import Venta from "../models/venta.model.js";
import Producto from "../models/producto.model.js"; // Para validar y actualizar stock

// ──────────────────────────────────────────────
// Función auxiliar: recalcular total de la venta
async function actualizarTotalVenta(Venta_id) {
  const total = await DetalleVenta.sum("Subtotal", { where: { Venta_id } });
  await Venta.update({ Total: total || 0 }, { where: { idVenta: Venta_id } });
}

// ──────────────────────────────────────────────
// Crear detalle de venta
export const createDetalleVenta = async (req, res) => {
  try {
    const { Cantidad, PrecioUnitario, Subtotal, Venta_id, Producto_id } = req.body;

    // 1️⃣ Validar cantidad
    const cantidadSolicitada = Number(Cantidad);
    if (isNaN(cantidadSolicitada) || cantidadSolicitada <= 0) {
      return res.status(400).json({
        ok: false,
        status: 400,
        Message: "La cantidad debe ser un número mayor que cero",
      });
    }

    // 2️⃣ Verificar producto
    const producto = await Producto.findByPk(Producto_id);
    if (!producto) {
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Producto no encontrado",
      });
    }

    // 3️⃣ Validar stock (usa el nombre real del campo de stock)
    if (producto.Cantidad_Actual < cantidadSolicitada) {
      return res.status(400).json({
        ok: false,
        status: 400,
        Message: `Stock insuficiente. Cantidad disponible: ${producto.Cantidad_Actual}`,
      });
    }

    // 4️⃣ Crear el detalle de venta
    const detalle = await DetalleVenta.create({
      Cantidad: cantidadSolicitada,
      PrecioUnitario,
      Subtotal,
      Venta_id,
      Producto_id,
    });

    // 5️⃣ Descontar stock
    await producto.update({
      Cantidad_Actual: producto.Cantidad_Actual - cantidadSolicitada,
    });

    // 6️⃣ Actualizar total de la venta
    await actualizarTotalVenta(Venta_id);

    return res.status(201).json({
      ok: true,
      status: 201,
      Message: "Detalle de venta creado y stock actualizado",
      body: detalle,
    });
  } catch (error) {
    return res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al crear detalle de venta",
      error: error.message,
    });
  }
};

// ──────────────────────────────────────────────
// Listar todos los detalles
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

// ──────────────────────────────────────────────
// Mostrar detalle por ID
export const showIdDetalleVenta = async (req, res) => {
  try {
    const { id } = req.params;
    const detalle = await DetalleVenta.findOne({ where: { idDetalleVenta: id } });

    if (!detalle) {
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Detalle de venta no encontrado",
      });
    }

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

// ──────────────────────────────────────────────
// Actualizar detalle de venta
export const updateDetalleVenta = async (req, res) => {
  try {
    const { id } = req.params;
    const detalle = await DetalleVenta.findByPk(id);

    if (!detalle) {
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Detalle de venta no encontrado",
      });
    }

    await detalle.update(req.body);

    // Recalcular total de la venta
    await actualizarTotalVenta(detalle.Venta_id);

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Detalle de venta actualizado",
      body: detalle,
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

// ──────────────────────────────────────────────
// Eliminar detalle de venta
export const deleteDetalleVenta = async (req, res) => {
  try {
    const { id } = req.params;
    const detalle = await DetalleVenta.findByPk(id);

    if (!detalle) {
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Detalle de venta no encontrado",
      });
    }

    const ventaId = detalle.Venta_id;
    await detalle.destroy();

    // Recalcular total después de eliminar
    await actualizarTotalVenta(ventaId);

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
