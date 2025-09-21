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
import checkRole from "../middlewares/role.middleware.js";

const router = Router();

// Solo Admin puede crear, actualizar y eliminar devoluciones
router.post(
  "/devolucion",
  verifyToken,
  checkRole(["Admin"]),
  validate(schemaDevolucion.createDevolucion),
  createDevolucion
);

router.get("/devolucion", verifyToken, showDevolucion);
router.get("/devolucion/:id", verifyToken, showIdDevolucion);

router.put(
  "/devolucion/:id",
  verifyToken,
  checkRole(["Admin"]),
  validate(schemaDevolucion.updateDevolucion),
  updateDevolucion
);

router.delete(
  "/devolucion/:id",
  verifyToken,
  checkRole(["Admin"]),
  deleteDevolucion
);

export default router;
