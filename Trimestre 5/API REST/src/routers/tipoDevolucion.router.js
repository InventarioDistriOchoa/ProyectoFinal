import { Router } from "express";
import {
  createTipoDevolucion,
  showTipoDevolucion,
  showIdTipoDevolucion,
  updateTipoDevolucion,
  deleteTipoDevolucion,
} from "../controllers/tipoDevolucion.controller.js";

import validate from "../middlewares/validate.middleware.js";
import schema from "../schemes/tipoDevolucion.schema.js";
import verifyToken from "../middlewares/auth.middleware.js";
import checkRole from "../middlewares/role.middleware.js";

const router = Router();

// Solo Admin puede crear, actualizar y eliminar
router.post(
  "/tipoDevolucion",
  verifyToken,
  checkRole(["Admin"]),
  validate(schema.createTipoDevolucion),
  createTipoDevolucion
);

router.get("/tipoDevolucion", verifyToken, showTipoDevolucion);
router.get("/tipoDevolucion/:id", verifyToken, showIdTipoDevolucion);

router.put(
  "/tipoDevolucion/:id",
  verifyToken,
  checkRole(["Admin"]),
  validate(schema.updateTipoDevolucion),
  updateTipoDevolucion
);

router.delete(
  "/tipoDevolucion/:id",
  verifyToken,
  checkRole(["Admin"]),
  deleteTipoDevolucion
);

export default router;
