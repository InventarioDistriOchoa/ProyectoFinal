import Rol from "../models/rol.model.js";

// Crear Rol
export const createRol = async (req, res) => {
  try {
    const rol = await Rol.create(req.body);
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

// Mostrar todos los Roles
export const showRol = async (req, res) => {
  try {
    const roles = await Rol.findAll();
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
    await Rol.update(req.body, { where: { idRol: id } });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Rol actualizado",
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

// Eliminar Rol
export const deleteRol = async (req, res) => {
  try {
    const { id } = req.params;
    await Rol.destroy({ where: { idRol: id } });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Rol eliminado",
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
