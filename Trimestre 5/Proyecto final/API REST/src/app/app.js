// Dependencias principales 
import dotenv from "dotenv";
import express from "express";
import morgan from "morgan";
import cors from "cors";
import path from "path";
import multer from "multer";
import { fileURLToPath } from "url";
import fs from "fs";

// Routers 
import authRouter from "../routers/auth.router.js";
import proveedorRouter from "../routers/proveedor.router.js";
import categoriaRouter from "../routers/categoria.router.js";
import tipoDocumentoRouter from "../routers/tipoDocumento.router.js";
import rolRouter from "../routers/rol.router.js";
import personaRouter from "../routers/persona.router.js";
import productoRouter from "../routers/producto.router.js";
import entradaRouter from "../routers/entrada.router.js";
import ventaRouter from "../routers/venta.router.js";
import detalleVentaRouter from "../routers/detalleVenta.router.js";
import tipoDevolucionRouter from "../routers/tipoDevolucion.router.js";
import devolucionRouter from "../routers/devolucion.router.js";
import stockRouter from "../routers/stock.routers.js";
import reportesRouter from "../routers/reportes.router.js";
import auditoriaRoutes from "../routers/auditoria.routes.js";
import facturaRoutes from "../routers/factura.router.js";
import authMiddleware from "../middlewares/auth.middleware.js";
import Auditoria from "../models/auditoria.model.js";
import Persona from "../models/persona.model.js";
// Configuración inicial
dotenv.config(); // Carga las variables de entorno

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();

// Middlewares globales
app.use(cors({
  origin: "http://localhost:5173"
}));

app.use(express.json());
app.use(morgan("dev"));

// Configuración de Multer
const uploadDir = path.join(__dirname, "../uploads/fotosUsuarios");

if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadDir),
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  },
});

export const upload = multer({ storage });

// Carpeta pública para las fotos
app.use("/uploads", express.static(path.join(__dirname, "../uploads")));

// Rutas
// Públicas
app.use("/api/auth", authRouter);

// Protegidas
app.use("/api/proveedor", authMiddleware, proveedorRouter);
app.use("/api/categoria", authMiddleware, categoriaRouter);
app.use("/api/tipoDocumento", tipoDocumentoRouter);
app.use("/api/rol", rolRouter);
app.use("/api/persona", personaRouter);
app.use("/api/producto", authMiddleware, productoRouter);
app.use("/api/entrada", authMiddleware, entradaRouter);
app.use("/api/venta", authMiddleware, ventaRouter);
app.use("/api/detalleVenta", authMiddleware, detalleVentaRouter);
app.use("/api/tipoDevolucion", authMiddleware, tipoDevolucionRouter);
app.use("/api/devolucion", authMiddleware, devolucionRouter);
app.use("/api/stock", stockRouter);
app.use("/api/reportes", authMiddleware, reportesRouter);
app.use("/api/historial", auditoriaRoutes);
app.use("/api", facturaRoutes);
// Manejo de errores
app.use((req, res) => {
  res.status(404).json({ ok: false, message: "Ruta no encontrada" });
});

app.use((err, req, res, next) => {
  console.error(err.stack);
  res
    .status(500)
    .json({ ok: false, message: "Error en el servidor", error: err.message });
});
// RELACIONES sin ciclo de imports
Auditoria.belongsTo(Persona, {
  foreignKey: "usuario",
  as: "persona"
});

Persona.hasMany(Auditoria, {
  foreignKey: "usuario",
  as: "auditorias"
});

export default app;
