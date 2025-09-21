import { Router } from "express";
import {
  createVenta,
  showVenta,
  showIdVenta,
  updateVenta,
  deleteVenta,
} from "../controllers/venta.controller.js";

import validate from "../middlewares/validate.middleware.js";
import schema from "../schemes/venta.schema.js";
import verifyToken from "../middlewares/auth.middleware.js";
import checkRole from "../middlewares/role.middleware.js";

const router = Router();

// Solo Admin puede crear, actualizar y eliminar ventas
router.post(
  "/venta",
  verifyToken,
  checkRole(["Admin"]),
  validate(schema.createVenta),
  createVenta
);

router.get("/venta", verifyToken, showVenta);
router.get("/venta/:id", verifyToken, showIdVenta);

router.put(
  "/venta/:id",
  verifyToken,
  checkRole(["Admin"]),
  validate(schema.updateVenta),
  updateVenta
);

router.delete(
  "/venta/:id",
  verifyToken,
  checkRole(["Admin"]),
  deleteVenta
);

export default router;
