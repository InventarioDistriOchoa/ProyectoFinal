import { Router } from "express";
import {
  createPersona,
  showPersona,
  showIdPersona,
  updatePersona,
  deletePersona,
  login,
  logout,
  uploadFotoPersona,
  getMyProfile,
} from "../controllers/persona.controller.js";

import validate from "../middlewares/validate.middleware.js";
import schemaPersona from "../schemes/persona.schema.js";
import Persona from "../models/persona.model.js";
import jwt from "jsonwebtoken";
import authMiddleware from "../middlewares/auth.middleware.js";
import { upload } from "../middlewares/upload.middleware.js";
import sequelize from "../config/connect.db.js";

const router = Router();

// ========================
// CREAR PERSONA
// ========================
router.post("/persona", async (req, res, next) => {
  try {
    const count = await Persona.count();

    // Si no hay personas, se crea la PRIMERA sin token (bootstrap del sistema)
    if (count === 0) {
      await sequelize.query("ALTER TABLE persona AUTO_INCREMENT = 1");
      return createPersona(req, res);
    }

    // A partir de la segunda, se exige token y rol
    let token = req.headers.authorization;
    if (!token) {
      return res
        .status(401)
        .json({ ok: false, status: 401, Message: "Token no encontrado" });
    }

    token = token.split(" ")[1];
    const decoded = jwt.verify(token, process.env.JWK_SECRET);

    // Solo Admin (1) y SuperAdmin (3) pueden crear personas
    if (![1, 3].includes(decoded.userRol)) {
      return res.status(403).json({
        ok: false,
        status: 403,
        Message: "No tienes permisos para crear personas",
      });
    }

    await schemaPersona.createPersona.validateAsync(req.body);
    return createPersona(req, res);
  } catch (error) {
    if (error.name === "JsonWebTokenError") {
      return res
        .status(401)
        .json({ ok: false, status: 401, Message: "Token no válido" });
    }
    next(error);
  }
});

// ========================
// MOSTRAR PERSONAS
// ========================
router.get(
  "/persona",
  authMiddleware,
  async (req, res, next) => {
    if (![1, 2, 3].includes(req.userRol)) {
      return res.status(403).json({
        ok: false,
        status: 403,
        Message: "No tienes permisos para mostrar personas",
      });
    }
    next();
  },
  showPersona
);

router.get(
  "/persona/:id",
  authMiddleware,
  async (req, res, next) => {
    if (![1, 3].includes(req.userRol)) {
      return res.status(403).json({
        ok: false,
        status: 403,
        Message: "No tienes permisos para ver este usuario",
      });
    }
    next();
  },
  showIdPersona
);

// ========================
// ACTUALIZAR PERSONA
// ========================
router.put(
  "/persona/:id",
  authMiddleware,
  async (req, res, next) => {
    const { id } = req.params;
    const persona = await Persona.findByPk(id);
    if (!persona) {
      return res.status(404).json({ ok: false, Message: "Usuario no encontrado" });
    }

    // Permitir si el usuario es Admin/SuperAdmin o si es su propio perfil
    if (![1, 3].includes(req.userRol) && Number(id) !== req.userId) {
      return res.status(403).json({ ok: false, Message: "No tienes permisos para actualizar personas" });
    }

    next();
  },
  updatePersona
);


// ========================
// ELIMINAR PERSONA
// ========================
router.delete(
  "/persona/:id",
  authMiddleware,
  async (req, res, next) => {
    const { id } = req.params;
    const personaAEliminar = await Persona.findByPk(id);

    if (!personaAEliminar)
      return res
        .status(404)
        .json({ ok: false, Message: "Usuario no encontrado" });

    if (req.userRol === 1 && personaAEliminar.Rol_id === 1) {
      return res.status(403).json({
        ok: false,
        Message:
          "Un Admin no puede eliminar a otro Admin. Solo SuperAdmin puede.",
      });
    }

    if (personaAEliminar.Rol_id === 3 && req.userRol !== 3) {
      return res.status(403).json({
        ok: false,
        Message: "Solo un SuperAdmin puede eliminar a un SuperAdmin.",
      });
    }

    if (req.userRol === 2) {
      return res.status(403).json({
        ok: false,
        Message: "Un Auxiliar no puede eliminar usuarios.",
      });
    }

    next();
  },
  deletePersona
);

// ========================
// LOGIN / LOGOUT
// ========================
router.post("/login", login);
router.post("/logout", authMiddleware, logout);

// ========================
// SUBIR FOTO DE USUARIO
// ========================
router.put(
  "/persona/:id/foto",
  authMiddleware,
  upload.single("foto"),
  uploadFotoPersona
);

// ========================
// PERFIL PROPIO (/me)
// ========================
router.get("/me", authMiddleware, getMyProfile);

export default router;
