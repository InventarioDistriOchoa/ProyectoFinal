import { Router } from "express";
import {
  createEntrada,
  showEntrada,
  showIdEntrada,
  updateEntrada,
  deleteEntrada,
  activarEntrada,   // 👈 NUEVO
} from "../controllers/entrada.controller.js";

import validate from "../middlewares/validate.middleware.js";
import schemaEntrada from "../schemes/entrada.schema.js";
import verifyToken from "../middlewares/auth.middleware.js";
import checkRole from "../middlewares/role.middleware.js";

const router = Router();

// Solo Admin puede crear, actualizar y eliminar entradas (comentario tuyo)
// Si quisieras forzar eso, aquí podrías meter checkRole([1,3])

router.post(
  "/entrada",
  verifyToken,
  validate(schemaEntrada.createEntrada),
  createEntrada
);

router.get("/entrada", verifyToken, showEntrada);
router.get("/entrada/:id", verifyToken, showIdEntrada);

router.put(
  "/entrada/:id",
  verifyToken,
  validate(schemaEntrada.updateEntrada),
  updateEntrada
);

// Soft delete (Estado = false + actualiza stock)
router.delete(
  "/entrada/:id",
  verifyToken,
  deleteEntrada
);

// 👇 NUEVO: activar entrada (Estado = true + vuelve a sumar stock)
router.put(
  "/entrada/:id/activar",
  verifyToken,
  activarEntrada
);

export default router;
