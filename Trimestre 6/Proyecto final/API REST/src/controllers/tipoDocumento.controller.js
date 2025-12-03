// controllers/tipoDocumento.controller.js
import TipoDocumento from "../models/tipoDocumento.model.js";

// Crear TipoDocumento (con lógica de reactivar si existe desactivado)
export const createTipoDocumento = async (req, res) => {
  try {
    const { Descripcion } = req.body;

    // Buscar si ya existe con esa descripción
    const existente = await TipoDocumento.findOne({ where: { Descripcion } });

    if (existente) {
      // Ya existe y está activo
      if (existente.Estado) {
        return res.status(409).json({
          ok: false,
          status: 409,
          Message: "El tipo de documento ya existe",
        });
      }

      // Existe pero está desactivado → permitir reactivación desde el front
      return res.status(409).json({
        ok: false,
        status: 409,
        desactivado: true,
        idTipo_Documento: existente.idTipo_Documento,
        Message:
          "El tipo de documento existe pero está desactivado. ¿Deseas activarlo?",
      });
    }

    // Crear nuevo
    const tipo = await TipoDocumento.create({
      Descripcion,
      Estado: true,
    });

    res.status(201).json({
      ok: true,
      status: 201,
      Message: "Tipo de documento creado",
      body: tipo,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al crear tipo de documento",
      error: error.message,
    });
  }
};

// Mostrar todos los tipos (solo activos)
export const showTipoDocumento = async (req, res) => {
  try {
    const tipos = await TipoDocumento.findAll({
      where: { Estado: true },
    });
    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Listado de tipos de documento",
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

// Mostrar Tipo por ID (da igual si está activo o no)
export const showIdTipoDocumento = async (req, res) => {
  try {
    const { id } = req.params;
    const tipo = await TipoDocumento.findOne({
      where: { idTipo_Documento: id },
    });

    if (!tipo)
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Tipo de documento no encontrado",
      });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Tipo de documento encontrado",
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
export const updateTipoDocumento = async (req, res) => {
  try {
    const { id } = req.params;

    const [updated] = await TipoDocumento.update(req.body, {
      where: { idTipo_Documento: id },
    });

    if (updated === 0) {
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Tipo de documento no encontrado",
      });
    }

    const tipoDocActualizado = await TipoDocumento.findByPk(id);

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Tipo de documento actualizado",
      body: tipoDocActualizado,
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

// ❌ Desactivar Tipo (soft delete: Estado = false)
export const deleteTipoDocumento = async (req, res) => {
  try {
    const { id } = req.params;

    const tipo = await TipoDocumento.findByPk(id);
    if (!tipo) {
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Tipo de documento no encontrado",
      });
    }

    await tipo.update({ Estado: false });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Tipo de documento desactivado",
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al desactivar tipo",
      error: error.message,
    });
  }
};

// ✅ Activar Tipo (Estado = true)
export const activarTipoDocumento = async (req, res) => {
  try {
    const { id } = req.params;

    const tipo = await TipoDocumento.findByPk(id);
    if (!tipo) {
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Tipo de documento no encontrado",
      });
    }

    await tipo.update({ Estado: true });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Tipo de documento activado",
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
