// routes/devolucion.router.js
import { Router } from "express";
import {
  createDevolucion,
  showDevolucion,
  showIdDevolucion,
  updateDevolucion,
  deleteDevolucion,
} from "../controllers/devolucion.controller.js";

import validate from "../middlewares/validate.middleware.js";
import schemaDevolucion from "../schemes/devolucion.schema.js";
import verifyToken from "../middlewares/auth.middleware.js";

const router = Router();

/**
 * Rutas de Devolución
 * - POST: crea la devolución y, si es al proveedor,
 *         descuenta stock o elimina el producto (lógica en createDevolucion)
 * - GET:  lista o muestra por id
 * - PUT:  actualiza
 * - DELETE: elimina
 */

// Crear devolución
router.post(
  "/devolucion",
  verifyToken,
  validate(schemaDevolucion.createDevolucion),
  createDevolucion       // <── aquí dentro va la lógica de stock
);

// Listar todas
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

// Eliminar
router.delete("/devolucion/:id", verifyToken, deleteDevolucion);

export default router;
