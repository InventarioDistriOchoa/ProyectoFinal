import { Router } from "express";
import {
  createProducto,
  showProducto,
  showIdProducto,
  updateProducto,
  deleteProducto,
} from "../controllers/producto.controller.js";

import validate from "../middlewares/validate.middleware.js";
import schemaProducto from "../schemes/producto.schema.js";
import verifyToken from "../middlewares/auth.middleware.js";
import checkRole from "../middlewares/role.middleware.js";

const router = Router();

// Solo Admin puede crear, actualizar y eliminar productos
router.post(
  "/producto",
  verifyToken,
  validate(schemaProducto.createProducto),
  createProducto
);

router.get("/producto", verifyToken, showProducto);
router.get("/producto/:id", verifyToken, showIdProducto);

router.put(
  "/producto/:id",
  verifyToken,
  validate(schemaProducto.updateProducto),
  updateProducto
);

router.delete(
  "/producto/:id",
  verifyToken,
  deleteProducto
);

export default router;
