import { Router } from "express";
import {
  createProducto,
  showProducto,
  showIdProducto,
  updateProducto,
  deleteProducto,
  activarProducto
} from "../controllers/producto.controller.js";

import validate from "../middlewares/validate.middleware.js";
import schemaProducto from "../schemes/producto.schema.js";
import verifyToken from "../middlewares/auth.middleware.js";

const router = Router();

// Crear producto
router.post(
  "/producto",
  verifyToken,
  validate(schemaProducto.createProducto),
  createProducto
);

// Listar productos
router.get("/producto", verifyToken, showProducto);

// Mostrar por ID
router.get("/producto/:id", verifyToken, showIdProducto);

// Actualizar producto
router.put(
  "/producto/:id",
  verifyToken,
  validate(schemaProducto.updateProducto),
  updateProducto
);

// Eliminar producto (desactivar)
router.delete("/producto/:id", verifyToken, deleteProducto);

// ⭐ Reactivar producto
router.put("/producto/activar/:id", verifyToken, activarProducto);

export default router;
