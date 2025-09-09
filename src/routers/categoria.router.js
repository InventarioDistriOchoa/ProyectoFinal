import { Router } from "express";
import {
  createCategoria,
  showCategoria,
  showIdCategoria,
  updateCategoria,
  deleteCategoria
} from "../controllers/categoria.controller.js";

import validate from "../middlewares/validate.middleware.js";
import schemaCategoria from "../schemes/categoria.schema.js";
import verifyToken from "../middlewares/auth.middleware.js";
import checkRole from "../middlewares/role.middleware.js"; // Middleware que controlará Admin/Auxiliar

const router = Router();

// Rutas protegidas con token y roles
router.post(
  "/categoria",
  verifyToken,
  checkRole(["Admin"]),       // Solo Admin puede crear
  validate(schemaCategoria.createCategoria),
  createCategoria
);

router.get("/categoria", verifyToken, showCategoria);
router.get("/categoria/:id", verifyToken, showIdCategoria);

router.put(
  "/categoria/:id",
  verifyToken,
  checkRole(["Admin"]),
  validate(schemaCategoria.updateCategoria),
  updateCategoria
);

router.delete(
  "/categoria/:id",
  verifyToken,
  checkRole(["Admin"]),
  deleteCategoria
);

export default router;
