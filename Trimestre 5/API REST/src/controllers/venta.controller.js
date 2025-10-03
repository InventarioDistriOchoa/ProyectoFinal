import Venta from "../models/venta.model.js";

// Crear Venta
export const createVenta = async (req, res) => {
  try {
    const venta = await Venta.create(req.body);
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

// Mostrar todas las Ventas
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

// Mostrar Venta por ID
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

// Actualizar Venta
export const updateVenta = async (req, res) => {
  try {
    const { id } = req.params;
    await Venta.update(req.body, { where: { idVenta: id } });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Venta actualizada",
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

// Eliminar Venta
export const deleteVenta = async (req, res) => {
  try {
    const { id } = req.params;
    await Venta.destroy({ where: { idVenta: id } });

    res.status(204).json({
      ok: true,
      status: 204,
      Message: "Venta eliminada",
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al eliminar venta",
      error: error.message,
    });
  }
};
