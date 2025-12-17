// controllers/categoria.controller.js
import Categoria from "../models/categoria.model.js";
import Producto from "../models/producto.model.js";
import { registrarAuditoria } from "../utils/registrarAuditoria.js";

// ✅ Crear categoría
export const createCategoria = async (req, res) => {
  try {
    const { Nombre_Categoria, Descripcion } = req.body;

    // 1️⃣ Verificar si ya existe una categoría con ese nombre
    const existente = await Categoria.findOne({
      where: { Nombre_Categoria },
    });

    // Existe pero está desactivada -> permitir reactivar desde el front
    if (existente && existente.Estado === false) {
      return res.status(409).json({
        ok: false,
        desactivado: true,
        idCategoria: existente.idCategoria,
        Message: "Esta categoría ya existe pero está desactivada.",
      });
    }

    // Existe activa -> error
    if (existente) {
      return res.status(409).json({
        ok: false,
        Message: "La categoría ya existe y está activa.",
      });
    }

    const nuevaCategoria = await Categoria.create({
      Nombre_Categoria,
      Descripcion,
      Estado: true,
    });

    // Auditoría
    await registrarAuditoria({
      usuario: req.userId,
      accion: "CREATE",
      coleccion: "Categoria",
      documentoId: nuevaCategoria.idCategoria,
      datosAnteriores: null,
      datosNuevos: nuevaCategoria.toJSON(),
      ip: req.ip,
    });

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

// ✅ Listar todas las categorías ACTIVAS
export const showCategoria = async (_req, res) => {
  try {
    const categorias = await Categoria.findAll({
      where: { Estado: true },
    });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Listado de categorías activas",
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

// ✅ Buscar por ID (puedes decidir si permitir ver inactivas o no)
export const showIdCategoria = async (req, res) => {
  try {
    const { id } = req.params;
    const categoria = await Categoria.findOne({
      where: { idCategoria: id },
    });

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
      Message: "Categoría encontrado",
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

// ✅ Actualizar
export const updateCategoria = async (req, res) => {
  try {
    const { id } = req.params;
    const { Nombre_Categoria, Descripcion } = req.body;

    const categoria = await Categoria.findByPk(id);
    if (!categoria) {
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Categoría no encontrada",
      });
    }

    const datosAnteriores = { ...categoria.dataValues };

    await categoria.update({ Nombre_Categoria, Descripcion });

    const datosNuevos = { ...categoria.dataValues };

    await registrarAuditoria({
      usuario: req.userId,
      accion: "UPDATE",
      coleccion: "Categoria",
      documentoId: id,
      datosAnteriores,
      datosNuevos,
      ip: req.ip,
    });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Categoría actualizada exitosamente",
      body: categoria,
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

// ✅ Desactivar categoría (soft delete) + reasignar productos a "No seleccionada"
export const deleteCategoria = async (req, res) => {
  try {
    const { id } = req.params;

    const categoria = await Categoria.findByPk(id);
    if (!categoria) {
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Categoría no encontrada para eliminar",
      });
    }

    const datosAnteriores = categoria.toJSON();

    // 1️⃣ Crear/obtener la categoría "No seleccionada"
    const [noSel] = await Categoria.findOrCreate({
      where: { Nombre_Categoria: "No seleccionada" },
      defaults: {
        Descripcion: "Categoría por defecto al eliminar",
        Estado: true,
      },
    });

    // 2️⃣ Reasignar productos que usen esta categoría
    await Producto.update(
      { Categoria_id: noSel.idCategoria },
      { where: { Categoria_id: id } }
    );

    // 3️⃣ Marcar como inactiva
    await categoria.update({ Estado: false });

    await registrarAuditoria({
      usuario: req.userId,
      accion: "DELETE",
      coleccion: "Categoria",
      documentoId: id,
      datosAnteriores,
      datosNuevos: { ...datosAnteriores, Estado: false },
      ip: req.ip,
    });

    res.status(200).json({
      ok: true,
      status: 200,
      Message:
        "Categoría desactivada. Los productos quedaron en 'No seleccionada'.",
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

// ✅ Activar categoría
export const activarCategoria = async (req, res) => {
  try {
    const { id } = req.params;

    const categoria = await Categoria.findByPk(id);
    if (!categoria) {
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Categoría no encontrada",
      });
    }

    const datosAnteriores = { ...categoria.dataValues };

    await categoria.update({ Estado: true });

    const datosNuevos = { ...categoria.dataValues };

    await registrarAuditoria({
      usuario: req.userId,
      accion: "ACTIVATE",
      coleccion: "Categoria",
      documentoId: id,
      datosAnteriores,
      datosNuevos,
      ip: req.ip,
    });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Categoría activada correctamente",
      body: categoria,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al activar categoría",
      error: error.message,
    });
  }
};
