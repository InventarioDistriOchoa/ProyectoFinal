import Venta from "../models/venta.model.js";
import { registrarAuditoria } from "../utils/registrarAuditoria.js";

// ===============================
//   CREAR VENTA  (CREATE)
// ===============================
export const createVenta = async (req, res) => {
  try {
    const venta = await Venta.create(req.body);

    await registrarAuditoria({
      usuario: req.userId,
      accion: "CREATE",
      coleccion: "Venta",
      documentoId: venta.idVenta,
      datosAnteriores: null,
      datosNuevos: venta.toJSON(),
      ip: req.ip,
    });

    res.status(201).json({
      ok: true,
      status: 201,
      Message: "Venta creada",
      body: venta,
    });

  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al crear venta",
      error: error.message,
    });
  }
};


// ===============================
//   LISTAR TODAS
// ===============================
export const showVenta = async (req, res) => {
  try {
    const ventas = await Venta.findAll();
    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Listado de ventas",
      body: ventas,
    });

  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al obtener ventas",
      error: error.message,
    });
  }
};


// ===============================
//   LISTAR POR ID
// ===============================
export const showIdVenta = async (req, res) => {
  try {
    const { id } = req.params;
    const venta = await Venta.findOne({ where: { idVenta: id } });

    if (!venta)
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Venta no encontrada",
      });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Venta encontrada",
      body: venta,
    });

  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al obtener venta",
      error: error.message,
    });
  }
};


// ===============================
//   ACTUALIZAR VENTA (UPDATE)
// ===============================
export const updateVenta = async (req, res) => {
  try {
    const { id } = req.params;
    const venta = await Venta.findByPk(id);

    if (!venta) {
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Venta no encontrada",
      });
    }

    const datosAnteriores = venta.toJSON();

    await venta.update(req.body);

    const datosNuevos = venta.toJSON();

    await registrarAuditoria({
      usuario: req.userId,
      accion: "UPDATE",
      coleccion: "Venta",
      documentoId: id,
      datosAnteriores,
      datosNuevos,
      ip: req.ip,
    });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Venta actualizada",
      body: venta,
    });

  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al actualizar venta",
      error: error.message,
    });
  }
};


// ===============================
//   DESACTIVAR VENTA (DELETE)
// ===============================
// ⚠ SI TU MODELO **NO TIENE** ESTADO, DEBES AGREGARLO para usar esto.
// Caso contrario, uso destroy().

export const deleteVenta = async (req, res) => {
  try {
    const { id } = req.params;

    const venta = await Venta.findOne({ where: { idVenta: id } });

    if (!venta) {
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Venta no encontrada",
      });
    }

    const datosAnteriores = venta.toJSON();

    // Si NO tienes campo Estado, CAMBIAR por destroy
    await venta.update({ Estado: false });

    await registrarAuditoria({
      usuario: req.userId,
      accion: "DELETE",
      coleccion: "Venta",
      documentoId: id,
      datosAnteriores,
      datosNuevos: { Estado: false },
      ip: req.ip,
    });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Venta desactivada",
    });

  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al desactivar venta",
      error: error.message,
    });
  }
};


// ===============================
//   ACTIVAR VENTA (ACTIVATE)
// ===============================
export const activateVenta = async (req, res) => {
  try {
    const { id } = req.params;

    const venta = await Venta.findByPk(id);

    if (!venta) {
      return res.status(404).json({
        ok: false,
        Message: "Venta no encontrada",
      });
    }

    const datosAnteriores = venta.toJSON();

    await venta.update({ Estado: true });

    const datosNuevos = venta.toJSON();

    await registrarAuditoria({
      usuario: req.userId,
      accion: "ACTIVATE",
      coleccion: "Venta",
      documentoId: id,
      datosAnteriores,
      datosNuevos,
      ip: req.ip,
    });

    res.json({
      ok: true,
      Message: "Venta activada correctamente",
      body: venta,
    });

  } catch (err) {
    res.status(500).json({ message: "Error al activar venta" });
  }
};
