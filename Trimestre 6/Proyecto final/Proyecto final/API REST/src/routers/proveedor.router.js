// routers/proveedor.router.js
import { Router } from "express";
import {
  createProveedor,
  showProveedor,
  showIdProveedor,
  updateProveedor,
  deleteProveedor,
  activarProveedor,        // 👈 NUEVO
} from "../controllers/proveedor.controller.js";

import validate from "../middlewares/validate.middleware.js";
import schemaProveedor from "../schemes/proveedor.schema.js";
import verifyToken from "../middlewares/auth.middleware.js";
import checkRole from "../middlewares/role.middleware.js";

const router = Router();

// Solo Admin y SuperAdmin pueden crear, actualizar y eliminar proveedores
router.post(
  "/proveedor",
  verifyToken,
  checkRole(["Admin", "SuperAdmin"]),
  validate(schemaProveedor.createProveedor),
  createProveedor
);

router.get("/proveedor", verifyToken, showProveedor);
router.get("/proveedor/:id", verifyToken, showIdProveedor);

router.put(
  "/proveedor/:id",
  verifyToken,
  checkRole(["Admin", "SuperAdmin"]),
  validate(schemaProveedor.updateProveedor),
  updateProveedor
);

// Desactivar (soft delete)
router.delete(
  "/proveedor/:id",
  verifyToken,
  checkRole(["Admin", "SuperAdmin"]),
  deleteProveedor
);

// ✅ Activar proveedor nuevamente
router.put(
  "/proveedor/activar/:id",
  verifyToken,
  checkRole(["Admin", "SuperAdmin"]),
  activarProveedor
);

export default router;
