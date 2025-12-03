import { Router } from "express";
import { obtenerHistorial } from "../controllers/auditoria.controller.js";
import authMiddleware from "../middlewares/auth.middleware.js";

const router = Router();

// Ruta protegida
router.get("/", authMiddleware, obtenerHistorial);

export default router;
