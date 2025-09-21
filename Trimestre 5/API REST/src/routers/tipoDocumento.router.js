import { Router } from "express";
import {
  createTipoDocumento,
  showTipoDocumento,
  showIdTipoDocumento,
  updateTipoDocumento,
  deleteTipoDocumento,
} from "../controllers/tipoDocumento.controller.js";

import validate from "../middlewares/validate.middleware.js";
import schema from "../schemes/tipoDocumento.schema.js";
import verifyToken from "../middlewares/auth.middleware.js";
import checkRole from "../middlewares/role.middleware.js";
import TipoDocumento from "../models/tipoDocumento.model.js"; // 👈 IMPORTANTE

import jwt from "jsonwebtoken";

const router = Router();

// ============================
// CREAR TIPO DOCUMENTO
// ============================
router.post("/tipoDocumento", async (req, res, next) => {
  try {
    const count = await TipoDocumento.count();
    console.log("Cantidad de tipos de documento:", count);

    // Caso 1: Primer tipoDocumento → sin token
    if (count === 0) {
      console.log("Creando primer tipoDocumento SIN TOKEN...");
      await schema.createTipoDocumento.validateAsync(req.body);
      return createTipoDocumento(req, res);
    }

    // Caso 2: Ya existen → se requiere token
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

    // Solo Admin puede crear más tipos de documento
    if (decoded.userRol !== 1) {
      return res.status(403).json({
        ok: false,
        status: 403,
        Message: "No tienes permisos para crear tipos de documento",
      });
    }

    await schema.createTipoDocumento.validateAsync(req.body);
    return createTipoDocumento(req, res);

  } catch (error) {
    console.error("Error en POST /tipoDocumento:", error);
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
router.get("/tipoDocumento", verifyToken, showTipoDocumento);
router.get("/tipoDocumento/:id", verifyToken, showIdTipoDocumento);
router.put("/tipoDocumento/:id", verifyToken,  updateTipoDocumento);
router.delete("/tipoDocumento/:id", verifyToken, deleteTipoDocumento);
export default router;
