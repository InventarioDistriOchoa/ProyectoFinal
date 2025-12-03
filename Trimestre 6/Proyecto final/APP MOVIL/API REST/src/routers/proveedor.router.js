import { Router } from "express";
import {
  createProveedor,
  showProveedor,
  showIdProveedor,
  updateProveedor,
  deleteProveedor,
} from "../controllers/proveedor.controller.js";

const router = Router();

// 🔓 --- RUTAS PÚBLICAS PARA PRESENTACIÓN / PRUEBAS ----

// Crear proveedor (POST)
router.post("/proveedor", createProveedor);

// Listar todos los proveedores (GET)
router.get("/proveedor", showProveedor);

// Obtener proveedor por ID (GET)
router.get("/proveedor/:id", showIdProveedor);

// Actualizar proveedor (PUT)
router.put("/proveedor/:id", updateProveedor);

// Eliminar proveedor (DELETE)
router.delete("/proveedor/:id", deleteProveedor);

export default router;
