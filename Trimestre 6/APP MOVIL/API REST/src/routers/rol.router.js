import { Router } from "express";
import {
  createRol,
  showRol,
  showIdRol,
  updateRol,
  deleteRol,
} from "../controllers/rol.controller.js";

import validate from "../middlewares/validate.middleware.js";
import schemaRol from "../schemes/rol.schema.js";
import verifyToken from "../middlewares/auth.middleware.js";
import checkRole from "../middlewares/role.middleware.js";
import Rol from "../models/rol.model.js";
import jwt from "jsonwebtoken";

const router = Router();

// ============================
// CREAR ROL
// ============================
router.post("/rol", async (req, res, next) => {
  try {
    const count = await Rol.count();
    console.log("Cantidad de roles en BD:", count);

    // Caso 1: Primer rol → sin token
    if (count === 0) {
      console.log("Creando primer rol SIN TOKEN...");
      await schemaRol.createRol.validateAsync(req.body);
      return createRol(req, res);
    }

    // Caso 2: Ya existen roles → validar token
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

    if (decoded.userRol !== 1) {
      return res.status(403).json({
        ok: false,
        status: 403,
        Message: "No tienes permisos para crear roles",
      });
    }

    await schemaRol.createRol.validateAsync(req.body);
    return createRol(req, res);

  } catch (error) {
    console.error("Error en POST /rol:", error);
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

// ============================
// RESTO DE RUTAS
// ============================
router.get("/rol", verifyToken, showRol);
router.get("/rol/:id", verifyToken, showIdRol);

router.put(
  "/rol/:id",
  verifyToken,
  checkRole(["Admin"]),
  validate(schemaRol.updateRol),
  updateRol
);

router.delete(
  "/rol/:id",
  verifyToken,
  checkRole(["Admin"]),
  deleteRol
);

export default router;
