import { Router } from "express";
import {
  createDetalleVenta,
  showDetalleVenta,
  showIdDetalleVenta,
  updateDetalleVenta,
  deleteDetalleVenta,
} from "../controllers/detalleVenta.controller.js";

import validate from "../middlewares/validate.middleware.js";
import schemaDetalleVenta from "../schemes/detalleVenta.schema.js";
import verifyToken from "../middlewares/auth.middleware.js";
import checkRole from "../middlewares/role.middleware.js";

const router = Router();

// Solo Admin puede crear, actualizar y eliminar detalles de venta
router.post(
  "/detalleVenta",
  verifyToken,
  checkRole(["Admin"]),
  validate(schemaDetalleVenta.createDetalleVenta),
  createDetalleVenta
);

router.get("/detalleVenta", verifyToken, showDetalleVenta);
router.get("/detalleVenta/:id", verifyToken, showIdDetalleVenta);

router.put(
  "/detalleVenta/:id",
  verifyToken,
  checkRole(["Admin"]),
  validate(schemaDetalleVenta.updateDetalleVenta),
  updateDetalleVenta
);

router.delete(
  "/detalleVenta/:id",
  verifyToken,
  checkRole(["Admin"]),
  deleteDetalleVenta
);

export default router;
