// controllers/tipoDevolucion.controller.js
import TipoDevolucion from "../models/tipoDevolucion.model.js";
import { registrarAuditoria } from "../utils/registrarAuditoria.js";

// Crear TipoDevolucion
export const createTipoDevolucion = async (req, res) => {
  try {
    const { NombreTipo } = req.body;

    // 1️⃣ Buscar si ya existe un tipo con ese mismo nombre
    const existente = await TipoDevolucion.findOne({ where: { NombreTipo } });

    // 2️⃣ Si existe pero está DESACTIVADO → mandar bandera para que el front pregunte si desea reactivarlo
    if (existente && existente.Estado === false) {
      return res.status(409).json({
        ok: false,
        desactivado: true,
        idTipoDevolucion: existente.idTipoDevolucion,
        message: "Este tipo de devolución ya existe pero está desactivado.",
      });
    }

    // 3️⃣ Si existe y está activo → error normal
    if (existente) {
      return res.status(409).json({
        ok: false,
        message: "El tipo de devolución ya existe.",
      });
    }

    // 4️⃣ Crear normalmente
    const tipo = await TipoDevolucion.create({
      ...req.body,
      Estado: true,
    });

    await registrarAuditoria({
      usuario: req.userId,
      accion: "CREATE",
      coleccion: "TipoDevolucion",
      documentoId: tipo.idTipoDevolucion,
      datosAnteriores: null,
      datosNuevos: tipo.toJSON(),
      ip: req.ip,
    });

    res.status(201).json({
      ok: true,
      status: 201,
      Message: "Tipo de devolución creado",
      body: tipo,
    });

  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al crear tipo de devolución",
      error: error.message,
    });
  }
};

// Mostrar todos los tipos (solo activos)
export const showTipoDevolucion = async (req, res) => {
  try {
    const tipos = await TipoDevolucion.findAll({
      where: { Estado: true },
    });
    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Listado de tipos de devolución",
      body: tipos,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al obtener tipos",
      error: error.message,
    });
  }
};

// Mostrar Tipo por ID
export const showIdTipoDevolucion = async (req, res) => {
  try {
    const { id } = req.params;
    const tipo = await TipoDevolucion.findOne({
      where: { idTipoDevolucion: id },
    });

    if (!tipo)
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Tipo de devolución no encontrado",
      });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Tipo de devolución encontrado",
      body: tipo,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al obtener tipo",
      error: error.message,
    });
  }
};

// Actualizar Tipo
export const updateTipoDevolucion = async (req, res) => {
  try {
    const { id } = req.params;

    const tipo = await TipoDevolucion.findByPk(id);
    if (!tipo) {
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Tipo de devolución no encontrado",
      });
    }

    const datosAnteriores = { ...tipo.dataValues };

    await tipo.update(req.body);

    const datosNuevos = { ...tipo.dataValues };

    await registrarAuditoria({
      usuario: req.userId,
      accion: "UPDATE",
      coleccion: "TipoDevolucion",
      documentoId: id,
      datosAnteriores,
      datosNuevos,
      ip: req.ip,
    });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Tipo de devolución actualizado",
      body: tipo,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al actualizar tipo",
      error: error.message,
    });
  }
};

// Desactivar Tipo (soft delete)
export const deleteTipoDevolucion = async (req, res) => {
  try {
    const { id } = req.params;

    const tipo = await TipoDevolucion.findByPk(id);
    if (!tipo) {
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Tipo de devolución no encontrado",
      });
    }

    const datosAnteriores = tipo.toJSON();

    await tipo.update({ Estado: false });

    await registrarAuditoria({
      usuario: req.userId,
      accion: "DELETE",
      coleccion: "TipoDevolucion",
      documentoId: id,
      datosAnteriores,
      datosNuevos: { Estado: false },
      ip: req.ip,
    });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Tipo de devolución desactivado",
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al eliminar tipo",
      error: error.message,
    });
  }
};

// Activar Tipo
export const activarTipoDevolucion = async (req, res) => {
  try {
    const { id } = req.params;

    const tipo = await TipoDevolucion.findByPk(id);
    if (!tipo) {
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Tipo de devolución no encontrado",
      });
    }

    const datosAnteriores = { ...tipo.dataValues };

    await tipo.update({ Estado: true });

    const datosNuevos = { ...tipo.dataValues };

    await registrarAuditoria({
      usuario: req.userId,
      accion: "ACTIVATE",
      coleccion: "TipoDevolucion",
      documentoId: id,
      datosAnteriores,
      datosNuevos,
      ip: req.ip,
    });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Tipo de devolución activado",
      body: tipo,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al activar tipo",
      error: error.message,
    });
  }
};
