// routes/categoria.router.js
import { Router } from "express";
import {
  createCategoria,
  showCategoria,
  showIdCategoria,
  updateCategoria,
  deleteCategoria,
  activarCategoria,
} from "../controllers/categoria.controller.js";

import validate from "../middlewares/validate.middleware.js";
import schemaCategoria from "../schemes/categoria.schema.js";
import verifyToken from "../middlewares/auth.middleware.js";
import checkRole from "../middlewares/role.middleware.js";

const router = Router();

// Crear categoría (solo Admin / SuperAdmin)
router.post(
  "/categoria",
  verifyToken,
  checkRole(["Admin", "SuperAdmin"]),
  validate(schemaCategoria.createCategoria),
  createCategoria
);

// Listar categorías (cualquiera con token)
router.get("/categoria", verifyToken, showCategoria);

// Ver detalle
router.get("/categoria/:id", verifyToken, showIdCategoria);

// Actualizar (solo Admin / SuperAdmin)
router.put(
  "/categoria/:id",
  verifyToken,
  checkRole(["Admin", "SuperAdmin"]),
  validate(schemaCategoria.updateCategoria),
  updateCategoria
);

// Desactivar (soft delete)
router.delete(
  "/categoria/:id",
  verifyToken,
  checkRole(["Admin", "SuperAdmin"]),
  deleteCategoria
);

// ✅ Activar de nuevo
router.put(
  "/categoria/activar/:id",
  verifyToken,
  checkRole(["Admin", "SuperAdmin"]),
  activarCategoria
);

export default router;
