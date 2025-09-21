import Persona from '../models/persona.model.js';
import Rol from '../models/rol.model.js';

const checkRole = (allowedRoles = []) => {
  return async (req, res, next) => {
    try {
      if (!req.userId) return res.status(401).json({ error: "Token no encontrado o inválido" });

      const persona = await Persona.findOne({
        where: { idPersona: req.userId },
        include: { model: Rol, attributes: ["Descripcion_Rol"] }
      });

      if (!persona) return res.status(404).json({ error: "Usuario no encontrado" });

      const userRole = persona.Rol.Descripcion_Rol;

      if (!allowedRoles.includes(userRole)) {
        return res.status(403).json({ error: "No tienes permisos para esta acción" });
      }

      next();
    } catch (err) {
      return res.status(400).json({ error: "Error en la verificación de rol: " + err.message });
    }
  };
};

export default checkRole;
