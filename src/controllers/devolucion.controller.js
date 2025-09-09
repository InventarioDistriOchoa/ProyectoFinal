import Devolucion from "../models/devolucion.model.js";

// Crear devolución
export const createDevolucion = async (req, res) => {
  try {
    const devolucion = await Devolucion.create(req.body);
    res.status(201).json({
      ok: true,
      status: 201,
      Message: "Devolución creada",
      body: devolucion,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al crear devolución",
      error: error.message,
    });
  }
};

// Mostrar todas las devoluciones
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

// Mostrar devolución por ID
export const showIdDevolucion = async (req, res) => {
  try {
    const { id } = req.params;
    const devolucion = await Devolucion.findOne({ where: { idDevolucion: id } });

    if (!devolucion)
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Devolución no encontrada",
      });

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
    const updated = await Devolucion.update(req.body, { where: { idDevolucion: id } });

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

    res.status(204).json({
      ok: true,
      status: 204,
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
