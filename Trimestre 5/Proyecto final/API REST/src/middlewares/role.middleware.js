// middlewares/role.middleware.js
import Persona from '../models/persona.model.js';
import Rol from '../models/rol.model.js';

// Definimos permisos por rol (acciones de negocio)
const permisos = {
  SuperAdmin: {
    gestionarUsuarios: true,
    eliminar: ["Admin", "Auxiliar", "SuperAdmin"], // puede eliminar cualquiera
  },
  Admin: {
    gestionarUsuarios: true,
    eliminar: ["Auxiliar"], // no puede eliminar otro Admin ni SuperAdmin
  },
  Auxiliar: {
    gestionarUsuarios: false, // no puede gestionar usuarios
    eliminar: [], // no puede eliminar
  },
};

const checkRole = (rolesOrAccion = null) => {
  return async (req, res, next) => {
    try {
      // Validar que el usuario esté logueado
      if (!req.userId) {
        return res.status(401).json({ ok: false, status: 401, Message: "Token no encontrado o inválido" });
      }

      // Obtener usuario y rol desde la base de datos
      const persona = await Persona.findOne({
        where: { idPersona: req.userId },
        include: { model: Rol, attributes: ["Descripcion_Rol"] },
      });

      if (!persona) {
        return res.status(404).json({ ok: false, status: 404, Message: "Usuario no encontrado" });
      }

      const rolName = persona.Rol.Descripcion_Rol;
      req.userRolName = rolName;

      // PERMISO ESPECIAL: permitir que un usuario edite su propio perfil
   if (req.params.id && Number(req.params.id) === Number(req.userId)) {
  return next();
}



      // Validación de roles (Array de roles permitidos)
      if (Array.isArray(rolesOrAccion)) {
        if (!rolesOrAccion.includes(rolName)) {
          return res.status(403).json({ ok: false, status: 403, Message: "No tienes permisos para esta acción" });
        }
      } 
      // Validación de acción específica (string)
      else if (typeof rolesOrAccion === "string") {
        const rolPermisos = permisos[rolName];
        if (!rolPermisos || !rolPermisos[rolesOrAccion]) {
          return res.status(403).json({ ok: false, status: 403, Message: "No tienes permisos para esta acción" });
        }
      }

      // Pasar al siguiente middleware / controlador
      next();
    } catch (err) {
      return res.status(500).json({
        ok: false,
        status: 500,
        Message: "Error en la verificación de rol",
        error: err.message,
      });
    }
  };
};

export default checkRole;
