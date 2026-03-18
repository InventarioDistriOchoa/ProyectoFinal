import Proveedor from "../models/proveedor.model.js";

// Crear proveedor
export const createProveedor = async (req, res) => {
  try {
    const proveedor = await Proveedor.create(req.body);
    res.status(201).json({
      ok: true,
      status: 201,
      Message: "Proveedor creado",
      body: proveedor,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al crear proveedor",
      error: error.message,
    });
  }
};

// Mostrar todos los proveedores
export const showProveedor = async (req, res) => {
  try {
    const proveedores = await Proveedor.findAll();
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

// Mostrar proveedor por ID
export const showIdProveedor = async (req, res) => {
  try {
    const { id } = req.params;
    const proveedor = await Proveedor.findOne({ where: { idProveedor: id } });

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
    await Proveedor.update(req.body, { where: { idProveedor: id } });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Proveedor actualizado",
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

// Eliminar proveedor
export const deleteProveedor = async (req, res) => {
  try {
    const { id } = req.params;
    await Proveedor.destroy({ where: { idProveedor: id } });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Proveedor eliminado",
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al eliminar proveedor",
      error: error.message,
    });
  }
};
