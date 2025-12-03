// routes/devolucion.router.js
import { Router } from "express";
import {
  createDevolucion,
  showDevolucion,
  showIdDevolucion,
  updateDevolucion,
  deleteDevolucion,
  activarDevolucion,   // 👈 NUEVO
} from "../controllers/devolucion.controller.js";

import validate from "../middlewares/validate.middleware.js";
import schemaDevolucion from "../schemes/devolucion.schema.js";
import verifyToken from "../middlewares/auth.middleware.js";

const router = Router();

/**
 * Rutas de Devolución
 */

// Crear devolución
router.post(
  "/devolucion",
  verifyToken,
  validate(schemaDevolucion.createDevolucion),
  createDevolucion
);

// Listar todas (solo activas si lo pones así en el controller)
router.get("/devolucion", verifyToken, showDevolucion);

// Obtener por id
router.get("/devolucion/:id", verifyToken, showIdDevolucion);

// Actualizar
router.put(
  "/devolucion/:id",
  verifyToken,
  validate(schemaDevolucion.updateDevolucion),
  updateDevolucion
);

// Desactivar (soft delete → Estado = 0)
router.delete("/devolucion/:id", verifyToken, deleteDevolucion);

// ✅ ACTIVAR devolución (Estado = 1)
router.put(
  "/devolucion/activar/:id",
  verifyToken,
  activarDevolucion
);

export default router;
