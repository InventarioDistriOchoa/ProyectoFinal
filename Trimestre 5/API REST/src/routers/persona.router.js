import { Router } from "express";
import { createPersona, showPersona, showIdPersona, updatePersona, deletePersona, login, logout } from "../controllers/persona.controller.js";
import validate from "../middlewares/validate.middleware.js";
import schemaPersona from "../schemes/persona.schema.js";
import Persona from "../models/persona.model.js";
import jwt from "jsonwebtoken";
import verifyToken from "../middlewares/auth.middleware.js"; // <-- IMPORTAR VERIFYTOKEN
import checkRole from "../middlewares/role.middleware.js";
import sequelize from "../config/connect.db.js";

const router = Router();



// Crear persona
router.post("/persona", async (req, res, next) => {
  try {
    const count = await Persona.count();

     if (count === 0) {
      sequelize.query("ALTER TABLE persona AUTO_INCREMENT = 1");
      // Primera persona: permitir crear sin token
      return createPersona(req, res);
    }

    // Ya hay usuarios: se requiere token
    let token = req.headers.authorization;
    if (!token) {
      return res.status(401).json({
        ok: false,
        status: 401,
        Message: "Token no encontrado",
      });
    }

    token = token.split(" ")[1];
    const decoded = jwt.verify(token, process.env.JWK_SECRET);

    // Solo Admin puede crear más usuarios
    if (decoded.userRol !== 1) {
      return res.status(403).json({
        ok: false,
        status: 403,
        Message: "No tienes permisos para crear personas",
      });
    }

    // Validar datos
    await schemaPersona.createPersona.validateAsync(req.body);

    // Crear persona
    return createPersona(req, res);

  } catch (error) {
    if (error.name === "JsonWebTokenError") {
      return res.status(401).json({
        ok: false,
        status: 401,
        Message: "Token no válido",
      });
    }
    next(error);
  }
});

// ========================
// MOSTRAR TODAS LAS PERSONAS
// ========================
router.get("/persona", verifyToken, async (req, res, next) => {
  try {
    if (req.userRol !== 1 && req.userRol !== 2) {
      return res.status(403).json({
        ok: false,
        status: 403,
        Message: "No tienes permisos para mostrar personas",
      });
    }

    const personas = await Persona.findAll();
    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Listado de personas",
      body: personas,
    });
  } catch (error) {
    next(error);
  }
});

// ========================
// MOSTRAR PERSONA POR ID
// ========================
router.get("/persona/:id", verifyToken, (req, res, next) => {
  if (req.userRol !== 1) {
    return res.status(403).json({
      ok: false,
      status: 403,
      Message: "No tienes permisos para mostrar personas",
    });
  }
  next();
}, showIdPersona);

// ========================
// ACTUALIZAR PERSONA
// ========================
router.put("/persona/:id", verifyToken, (req, res, next) => {
  if (req.userRol !== 1) {
    return res.status(403).json({
      ok: false,
      status: 403,
      Message: "No tienes permisos para actualizar personas",
    });
  }
  next();
}, validate(schemaPersona.updatePersona), updatePersona);

// ========================
// ELIMINAR PERSONA
// ========================
router.delete(
  "/persona/:id",
  verifyToken,
  async (req, res, next) => {
    try {
      const { id } = req.params;
      const personaAEliminar = await Persona.findByPk(id);

      if (!personaAEliminar) {
        return res.status(404).json({ error: "Usuario no encontrado" });
      }

      // 🚫 Un Admin NO puede eliminar a otro Admin
      if (req.userRol === 1 && personaAEliminar.Rol_id === 1) {
        return res.status(403).json({
          error: "Un Admin no puede eliminar a otro Admin. Solo un SuperAdmin puede hacerlo."
        });
      }

      // 🚫 Un Admin o Auxiliar NO pueden eliminar a un SuperAdmin
      if (personaAEliminar.Rol_id === 3 && req.userRol !== 3) {
        return res.status(403).json({
          error: "Solo un SuperAdmin puede eliminar a otro SuperAdmin."
        });
      }

      // 🚫 Un Auxiliar no puede eliminar a nadie
      if (req.userRol === 2) {
        return res.status(403).json({
          error: "Un Auxiliar no puede eliminar usuarios."
        });
      }

      next(); // pasa al controlador deletePersona
    } catch (err) {
      return res.status(500).json({ error: "Error en la validación: " + err.message });
    }
  },
  deletePersona
);

// ========================
// LOGIN / LOGOUT
// ========================
router.post("/login", login);
router.post("/logout", logout);

export default router;
