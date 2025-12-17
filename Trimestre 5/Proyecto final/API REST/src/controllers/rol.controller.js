// controllers/rol.controller.js
import Rol from "../models/rol.model.js";

// Crear Rol
export const createRol = async (req, res) => {
  try {
    const { Descripcion_Rol } = req.body;

    // Verificar si ya existe un rol con ese nombre
    const existente = await Rol.findOne({ where: { Descripcion_Rol } });

    if (existente) {
      // Existe pero está desactivado → ofrecer reactivar
      if (existente.Estado === false) {
        return res.status(409).json({
          ok: false,
          status: 409,
          Message: "Este rol ya existe pero está desactivado. ¿Deseas activarlo?",
          desactivado: true,
          idRol: existente.idRol,
        });
      }

      // Existe y está activo
      return res.status(409).json({
        ok: false,
        status: 409,
        Message: "Ya existe un rol con esa descripción",
      });
    }

    const rol = await Rol.create({ Descripcion_Rol, Estado: true });

    res.status(201).json({
      ok: true,
      status: 201,
      Message: "Rol creado",
      body: rol,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al crear rol",
      error: error.message,
    });
  }
};

// Mostrar todos los Roles (solo activos)
export const showRol = async (req, res) => {
  try {
    const roles = await Rol.findAll({
      where: { Estado: true }, // 👈 solo los activos
    });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Listado de roles",
      body: roles,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al obtener roles",
      error: error.message,
    });
  }
};

// Mostrar Rol por ID
export const showIdRol = async (req, res) => {
  try {
    const { id } = req.params;
    const rol = await Rol.findOne({ where: { idRol: id } });

    if (!rol)
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Rol no encontrado",
      });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Rol encontrado",
      body: rol,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al obtener rol",
      error: error.message,
    });
  }
};

// Actualizar Rol
export const updateRol = async (req, res) => {
  try {
    const { id } = req.params;

    const [updated] = await Rol.update(req.body, { where: { idRol: id } });

    if (updated === 0) {
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Rol no encontrado",
      });
    }

    const rolActualizado = await Rol.findByPk(id);

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Rol actualizado",
      body: rolActualizado,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al actualizar rol",
      error: error.message,
    });
  }
};

// "Eliminar" Rol (soft delete → Estado = false)
export const deleteRol = async (req, res) => {
  try {
    const { id } = req.params;

    const rol = await Rol.findByPk(id);
    if (!rol) {
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Rol no encontrado",
      });
    }

    await rol.update({ Estado: false });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Rol desactivado",
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al eliminar rol",
      error: error.message,
    });
  }
};

// ✅ Activar Rol (Estado = true)
export const activarRol = async (req, res) => {
  try {
    const { id } = req.params;

    const rol = await Rol.findByPk(id);
    if (!rol) {
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Rol no encontrado",
      });
    }

    await rol.update({ Estado: true });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Rol activado",
      body: rol,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al activar rol",
      error: error.message,
    });
  }
};
