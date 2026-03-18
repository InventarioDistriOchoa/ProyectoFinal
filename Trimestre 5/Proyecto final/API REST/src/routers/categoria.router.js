// routes/categoria.router.js
import { Router } from "express";
import {
  createCategoria,
  showCategoria,
  showIdCategoria,
  updateCategoria,
  deleteCategoria,
} from "../controllers/categoria.controller.js";

import validate from "../middlewares/validate.middleware.js";
import schemaCategoria from "../schemes/categoria.schema.js";
import verifyToken from "../middlewares/auth.middleware.js";
import checkRole from "../middlewares/role.middleware.js"; // Si lo usas para restringir a Admin/Auxiliar

const router = Router();

/**
 * Rutas de Categoría
 * Protegidas con token; agrega checkRole(['Admin','Auxiliar']) si necesitas roles.
 */
router.post(
  "/categoria",
  verifyToken,
  validate(schemaCategoria.createCategoria),
  createCategoria
);

router.get("/categoria", verifyToken, showCategoria);

router.get("/categoria/:id", verifyToken, showIdCategoria);

router.put(
  "/categoria/:id",
  verifyToken,
  validate(schemaCategoria.updateCategoria),
  updateCategoria
);

// 🔴 Eliminar categoría (con reasignación de productos a “No seleccionada”)
router.delete("/categoria/:id", verifyToken, deleteCategoria);

export default router;
