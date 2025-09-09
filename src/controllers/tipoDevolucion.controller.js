import TipoDevolucion from "../models/tipoDevolucion.model.js";

// Crear TipoDevolucion
export const createTipoDevolucion = async (req, res) => {
  try {
    const tipo = await TipoDevolucion.create(req.body);
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

// Mostrar todos los tipos
export const showTipoDevolucion = async (req, res) => {
  try {
    const tipos = await TipoDevolucion.findAll();
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
    const tipo = await TipoDevolucion.findOne({ where: { idTipoDevolucion: id } });

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
    await TipoDevolucion.update(req.body, { where: { idTipoDevolucion: id } });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Tipo de devolución actualizado",
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

// Eliminar Tipo
export const deleteTipoDevolucion = async (req, res) => {
  try {
    const { id } = req.params;
    await TipoDevolucion.destroy({ where: { idTipoDevolucion: id } });

    res.status(204).json({
      ok: true,
      status: 204,
      Message: "Tipo de devolución eliminado",
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
