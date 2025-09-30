import Categoria from "../models/categoria.model.js";

// Crear categoría
export const createCategoria = async (req, res) => {
  try {
    const { Nombre_Categoria, Descripcion } = req.body;
    const nuevaCategoria = await Categoria.create({ Nombre_Categoria, Descripcion });

    res.status(201).json({
      ok: true,
      status: 201,
      Message: "Categoría creada exitosamente",
      body: nuevaCategoria,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al crear la categoría",
      error: error.message,
    });
  }
};

// Mostrar todas las categorías
export const showCategoria = async (req, res) => {
  try {
    const categorias = await Categoria.findAll();
    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Listado de categorías",
      body: categorias,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al obtener categorías",
      error: error.message,
    });
  }
};

// Mostrar categoría por ID
export const showIdCategoria = async (req, res) => {
  try {
    const { id } = req.params;
    const categoria = await Categoria.findOne({ where: { idCategoria: id } });

    if (!categoria) {
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Categoría no encontrada",
      });
    }

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Categoría encontrada",
      body: categoria,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al obtener categoría",
      error: error.message,
    });
  }
};

// Actualizar categoría
export const updateCategoria = async (req, res) => {
  try {
    const { id } = req.params;
    const { Nombre_Categoria, Descripcion } = req.body;

    const updated = await Categoria.update(
      { Nombre_Categoria, Descripcion },
      { where: { idCategoria: id } }
    );

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Categoría actualizada exitosamente",
      body: updated,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al actualizar categoría",
      error: error.message,
    });
  }
};

// Eliminar categoría
export const deleteCategoria = async (req, res) => {
  try {
    const { id } = req.params;
    await Categoria.destroy({ where: { idCategoria: id } });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Categoría eliminada exitosamente",
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al eliminar categoría",
      error: error.message,
    });
  }
};
