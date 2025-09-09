import Producto from "../models/producto.model.js";

// Crear producto
export const createProducto = async (req, res) => {
  try {
    const producto = await Producto.create(req.body);
    res.status(201).json({
      ok: true,
      status: 201,
      Message: "Producto creado",
      body: producto,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al crear producto",
      error: error.message,
    });
  }
};

// Mostrar todos los productos
export const showProducto = async (req, res) => {
  try {
    const productos = await Producto.findAll();
    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Listado de productos",
      body: productos,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al obtener productos",
      error: error.message,
    });
  }
};

// Mostrar producto por ID
export const showIdProducto = async (req, res) => {
  try {
    const { id } = req.params;
    const producto = await Producto.findOne({ where: { idProducto: id } });

    if (!producto)
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Producto no encontrado",
      });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Producto encontrado",
      body: producto,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al obtener producto",
      error: error.message,
    });
  }
};

// Actualizar producto
export const updateProducto = async (req, res) => {
  try {
    const { id } = req.params;
    await Producto.update(req.body, { where: { idProducto: id } });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Producto actualizado",
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al actualizar producto",
      error: error.message,
    });
  }
};

// Eliminar producto
export const deleteProducto = async (req, res) => {
  try {
    const { id } = req.params;
    await Producto.destroy({ where: { idProducto: id } });

    res.status(204).json({
      ok: true,
      status: 204,
      Message: "Producto eliminado",
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al eliminar producto",
      error: error.message,
    });
  }
};
