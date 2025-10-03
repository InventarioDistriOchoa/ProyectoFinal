import { Router } from "express";
import {
  createEntrada,
  showEntrada,
  showIdEntrada,
  updateEntrada,
  deleteEntrada,
} from "../controllers/entrada.controller.js";

import validate from "../middlewares/validate.middleware.js";
import schemaEntrada from "../schemes/entrada.schema.js";
import verifyToken from "../middlewares/auth.middleware.js";
import checkRole from "../middlewares/role.middleware.js";

const router = Router();

// Solo Admin puede crear, actualizar y eliminar entradas
router.post(
  "/entrada",
  verifyToken,
  checkRole(["Admin"]),
  validate(schemaEntrada.createEntrada),
  createEntrada
);

router.get("/entrada", verifyToken, showEntrada);
router.get("/entrada/:id", verifyToken, showIdEntrada);

router.put(
  "/entrada/:id",
  verifyToken,
  checkRole(["Admin"]),
  validate(schemaEntrada.updateEntrada),
  updateEntrada
);

router.delete(
  "/entrada/:id",
  verifyToken,
  checkRole(["Admin"]),
  deleteEntrada
);

export default router;
