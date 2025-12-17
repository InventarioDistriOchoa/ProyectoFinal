// routes/tipoDevolucion.router.js
import { Router } from "express";
import {
  createTipoDevolucion,
  showTipoDevolucion,
  showIdTipoDevolucion,
  updateTipoDevolucion,
  deleteTipoDevolucion,
  activarTipoDevolucion,     // 👈 NUEVO
} from "../controllers/tipoDevolucion.controller.js";

import validate from "../middlewares/validate.middleware.js";
import schema from "../schemes/tipoDevolucion.schema.js";
import verifyToken from "../middlewares/auth.middleware.js";
import checkRole from "../middlewares/role.middleware.js";

const router = Router();

// Solo Admin/SuperAdmin puede crear, actualizar, eliminar, activar
router.post(
  "/tipoDevolucion",
  verifyToken,
  checkRole(["admin", "superadmin"]),   // 👈 si quieres restringir
  validate(schema.createTipoDevolucion),
  createTipoDevolucion
);

router.get("/tipoDevolucion", verifyToken, showTipoDevolucion);
router.get("/tipoDevolucion/:id", verifyToken, showIdTipoDevolucion);

router.put(
  "/tipoDevolucion/:id",
  verifyToken,
  checkRole(["admin", "superadmin"]),   // opcional
  validate(schema.updateTipoDevolucion),
  updateTipoDevolucion
);

// Desactivar (soft delete → Estado = 0)
router.delete(
  "/tipoDevolucion/:id",
  verifyToken,
  checkRole(["admin", "superadmin"]),   // opcional
  deleteTipoDevolucion
);

// ✅ ACTIVAR nuevamente (Estado = 1)
router.put(
  "/activar/:id",
  verifyToken,
  checkRole(["admin", "superadmin"]),
  activarTipoDevolucion
);


export default router;
