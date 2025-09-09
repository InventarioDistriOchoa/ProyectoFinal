import { Router } from "express";
import { createPersona, showPersona, showIdPersona, updatePersona, deletePersona, login, logout } from "../controllers/persona.controller.js";
import validate from "../middlewares/validate.middleware.js";
import schemaPersona from "../schemes/persona.schema.js";
import Persona from "../models/persona.model.js";
import jwt from "jsonwebtoken";
import verifyToken from "../middlewares/auth.middleware.js"; // <-- IMPORTAR VERIFYTOKEN

const router = Router();



// Crear persona
router.post("/persona", async (req, res, next) => {
  try {
    const count = await Persona.count();

    if (count === 0) {
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
router.delete("/persona/:id", verifyToken, (req, res, next) => {
  if (req.userRol !== 1) {
    return res.status(403).json({
      ok: false,
      status: 403,
      Message: "No tienes permisos para eliminar personas",
    });
  }
  next();
}, deletePersona);

// ========================
// LOGIN / LOGOUT
// ========================
router.post("/login", login);
router.post("/logout", logout);

export default router;
