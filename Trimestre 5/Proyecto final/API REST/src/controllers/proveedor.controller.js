// controllers/proveedor.controller.js
import Proveedor from "../models/proveedor.model.js";
import { registrarAuditoria } from "../utils/registrarAuditoria.js";

// Crear proveedor
export const createProveedor = async (req, res) => {
  try {
    const { Nombre_Empresa } = req.body;

    // Buscar proveedor por nombre (puedes ajustar criterio si quieres)
    const existente = await Proveedor.findOne({
      where: { Nombre_Empresa },
    });

    // ✅ Existe pero está desactivado → ofrecer reactivar desde el front
    if (existente && existente.Estado === false) {
      return res.status(409).json({
        ok: false,
        status: 409,
        desactivado: true,
        idProveedor: existente.idProveedor,
        message: "Este proveedor ya existe pero está desactivado. ¿Deseas reactivarlo?",
      });
    }

    // ❌ Ya existe y está activo
    if (existente) {
      return res.status(409).json({
        ok: false,
        status: 409,
        desactivado: false,
        message: "El proveedor ya existe y está activo.",
      });
    }

    // Crear nuevo proveedor
    const proveedor = await Proveedor.create({
      ...req.body,
      Estado: true,
    });

    // Auditoría
    await registrarAuditoria({
      usuario: req.userId,
      accion: "CREATE",
      coleccion: "Proveedor",
      documentoId: proveedor.idProveedor,
      datosAnteriores: null,
      datosNuevos: proveedor.toJSON(),
      ip: req.ip,
    });

    res.status(201).json({
      ok: true,
      status: 201,
      Message: "Proveedor creado",
      body: proveedor,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al crear proveedor",
      error: error.message,
    });
  }
};

// Mostrar todos los proveedores (solo activos)
export const showProveedor = async (req, res) => {
  try {
    const proveedores = await Proveedor.findAll({
      where: { Estado: true },
    });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Listado de proveedores",
      body: proveedores,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al obtener proveedores",
      error: error.message,
    });
  }
};

// Mostrar proveedor por ID (puedes decidir si permitir ver inactivos o no)
export const showIdProveedor = async (req, res) => {
  try {
    const { id } = req.params;
    const proveedor = await Proveedor.findOne({
      where: { idProveedor: id },
    });

    if (!proveedor)
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Proveedor no encontrado",
      });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Proveedor encontrado",
      body: proveedor,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al obtener proveedor",
      error: error.message,
    });
  }
};

// Actualizar proveedor
export const updateProveedor = async (req, res) => {
  try {
    const { id } = req.params;
    const proveedor = await Proveedor.findByPk(id);

    if (!proveedor) {
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Proveedor no encontrado",
      });
    }

    const datosAnteriores = { ...proveedor.dataValues };

    await proveedor.update(req.body);

    const datosNuevos = { ...proveedor.dataValues };

    await registrarAuditoria({
      usuario: req.userId,
      accion: "UPDATE",
      coleccion: "Proveedor",
      documentoId: id,
      datosAnteriores,
      datosNuevos,
      ip: req.ip,
    });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Proveedor actualizado",
      body: proveedor,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al actualizar proveedor",
      error: error.message,
    });
  }
};

// Desactivar proveedor (soft delete)
export const deleteProveedor = async (req, res) => {
  try {
    const { id } = req.params;

    const proveedor = await Proveedor.findByPk(id);
    if (!proveedor) {
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Proveedor no encontrado",
      });
    }

    const datosAnteriores = proveedor.toJSON();

    await proveedor.update({ Estado: false });

    await registrarAuditoria({
      usuario: req.userId,
      accion: "DELETE",
      coleccion: "Proveedor",
      documentoId: id,
      datosAnteriores,
      datosNuevos: { Estado: false },
      ip: req.ip,
    });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Proveedor desactivado",
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al desactivar proveedor",
      error: error.message,
    });
  }
};

// Activar proveedor
export const activarProveedor = async (req, res) => {
  try {
    const { id } = req.params;

    const proveedor = await Proveedor.findByPk(id);
    if (!proveedor) {
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Proveedor no encontrado",
      });
    }

    const datosAnteriores = { ...proveedor.dataValues };

    await proveedor.update({ Estado: true });

    const datosNuevos = { ...proveedor.dataValues };

    await registrarAuditoria({
      usuario: req.userId,
      accion: "ACTIVATE",
      coleccion: "Proveedor",
      documentoId: id,
      datosAnteriores,
      datosNuevos,
      ip: req.ip,
    });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Proveedor activado",
      body: proveedor,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al activar proveedor",
      error: error.message,
    });
  }
};
