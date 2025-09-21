import { Router } from "express";
import {
  createProveedor,
  showProveedor,
  showIdProveedor,
  updateProveedor,
  deleteProveedor,
} from "../controllers/proveedor.controller.js";

import validate from "../middlewares/validate.middleware.js";
import schemaProveedor from "../schemes/proveedor.schema.js";
import verifyToken from "../middlewares/auth.middleware.js";
import checkRole from "../middlewares/role.middleware.js";

const router = Router();

// Solo Admin puede crear, actualizar y eliminar proveedores
router.post(
  "/proveedor",
  verifyToken,
  checkRole(["Admin"]),
  validate(schemaProveedor.createProveedor),
  createProveedor
);

router.get("/proveedor", verifyToken, showProveedor);
router.get("/proveedor/:id", verifyToken, showIdProveedor);

router.put(
  "/proveedor/:id",
  verifyToken,
  checkRole(["Admin"]),
  validate(schemaProveedor.updateProveedor),
  updateProveedor
);

router.delete(
  "/proveedor/:id",
  verifyToken,
  checkRole(["Admin"]),
  deleteProveedor
);

export default router;
