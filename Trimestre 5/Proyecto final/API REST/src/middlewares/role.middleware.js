// middlewares/role.middleware.js
import Persona from "../models/persona.model.js";
import Rol from "../models/rol.model.js";

// Permisos por rol (USAMOS CLAVES EN MINÚSCULAS)
const permisos = {
  superadmin: {
    gestionarUsuarios: true,
    eliminar: ["admin", "auxiliar", "superadmin"],
  },
  admin: {
    gestionarUsuarios: true,
    eliminar: ["auxiliar"],
  },
  auxiliar: {
    gestionarUsuarios: false,
    eliminar: [],
  },
};

const checkRole = (rolesOrAccion = null) => {
  return async (req, res, next) => {
    try {
      // 1) Validar que haya userId cargado desde el token
      if (!req.userId) {
        return res.status(401).json({
          ok: false,
          status: 401,
          Message: "Token no encontrado o inválido",
        });
      }

      // 2) Buscar persona y rol
      const persona = await Persona.findOne({
        where: { idPersona: req.userId },
        include: { model: Rol, attributes: ["Descripcion_Rol"] },
      });

      if (!persona) {
        return res.status(404).json({
          ok: false,
          status: 404,
          Message: "Usuario no encontrado",
        });
      }

      // 3) Normalizar nombre de rol a minúsculas
      let rolName = (persona.Rol.Descripcion_Rol || "").trim().toLowerCase();

      // Normalizaciones típicas
      if (rolName.includes("super")) rolName = "superadmin";
      else if (rolName.includes("admin")) rolName = "admin";
      else if (rolName.includes("aux")) rolName = "auxiliar";

      req.userRolName = rolName; // lo guardamos en la request para otros usos

      // 🔍 Logs de depuración
      console.log("🟢 Rol detectado del usuario:", rolName);
      console.log("🟡 Roles permitidos en esta ruta:", rolesOrAccion);

      // 4) Permitir que un usuario edite su propio perfil
      if (req.params.id && Number(req.params.id) === Number(req.userId)) {
        return next();
      }

      // 5) Si la ruta recibe un array de roles permitidos
      if (Array.isArray(rolesOrAccion)) {
        const rolesLower = rolesOrAccion.map((r) => r.toLowerCase());
        if (!rolesLower.includes(rolName)) {
          return res.status(403).json({
            ok: false,
            status: 403,
            Message: "No tienes permisos para esta acción",
          });
        }
      }
      // 6) Si la ruta recibe un string de acción (ej: "gestionarUsuarios")
      else if (typeof rolesOrAccion === "string") {
        const permisosRol = permisos[rolName]; // usamos rol en minúsculas
        if (!permisosRol || !permisosRol[rolesOrAccion]) {
          return res.status(403).json({
            ok: false,
            status: 403,
            Message: "No tienes permisos para esta acción",
          });
        }
      }

      // 7) Todo OK, continuar
      next();
    } catch (err) {
      console.error("❌ Error en checkRole:", err);
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
