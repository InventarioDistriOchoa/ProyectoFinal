import Entrada from "../models/entrada.model.js";

// Crear entrada
export const createEntrada = async (req, res) => {
  try {
    const entrada = await Entrada.create(req.body);
    res.status(201).json({
      ok: true,
      status: 201,
      Message: "Entrada creada",
      body: entrada,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al crear entrada",
      error: error.message,
    });
  }
};

// Mostrar todas las entradas
export const showEntrada = async (req, res) => {
  try {
    const entradas = await Entrada.findAll();
    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Listado de entradas",
      body: entradas,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al obtener entradas",
      error: error.message,
    });
  }
};

// Mostrar entrada por ID
export const showIdEntrada = async (req, res) => {
  try {
    const { id } = req.params;
    const entrada = await Entrada.findOne({ where: { idEntrada: id } });

    if (!entrada)
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Entrada no encontrada",
      });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Entrada encontrada",
      body: entrada,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al obtener entrada",
      error: error.message,
    });
  }
};

// Actualizar entrada
export const updateEntrada = async (req, res) => {
  try {
    const { id } = req.params;
    const updated = await Entrada.update(req.body, { where: { idEntrada: id } });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Entrada actualizada",
      body: updated,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al actualizar entrada",
      error: error.message,
    });
  }
};

// Eliminar entrada
export const deleteEntrada = async (req, res) => {
  try {
    const { id } = req.params;
    await Entrada.destroy({ where: { idEntrada: id } });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Entrada eliminada",
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al eliminar entrada",
      error: error.message,
    });
  }
};
