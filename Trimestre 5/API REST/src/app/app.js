import express from 'express';
import morgan from 'morgan';
import cors from 'cors';

// Importamos routers
import proveedorRouter from '../routers/proveedor.router.js';
import categoriaRouter from '../routers/categoria.router.js';
import tipoDocumentoRouter from '../routers/tipoDocumento.router.js';
import rolRouter from '../routers/rol.router.js';
import personaRouter from '../routers/persona.router.js';
import productoRouter from '../routers/producto.router.js';
import entradaRouter from '../routers/entrada.router.js';
import ventaRouter from '../routers/venta.router.js';
import detalleVentaRouter from '../routers/detalleVenta.router.js';
import tipoDevolucionRouter from '../routers/tipoDevolucion.router.js';
import devolucionRouter from '../routers/devolucion.router.js';
import authRouter from '../routers/auth.router.js'; // <-- Router de login/logout

// Middlewares
import authMiddleware from '../middlewares/auth.middleware.js';

const app = express();

// Middlewares globales
app.use(cors());                // Permite solicitudes desde cualquier origen
app.use(express.json());        // Para recibir JSON
app.use(morgan('dev'));         // Logs de peticiones

// Rutas públicas (no requieren token)
app.use('/api/auth', authRouter);

// Rutas protegidas por token
app.use('/api/proveedor', authMiddleware, proveedorRouter);
app.use('/api/categoria', authMiddleware, categoriaRouter);
app.use('/api/tipoDocumento',  tipoDocumentoRouter);
app.use('/api/rol', rolRouter);
app.use('/api/persona', personaRouter);
app.use('/api/producto', authMiddleware, productoRouter);
app.use('/api/entrada', authMiddleware, entradaRouter);
app.use('/api/venta', authMiddleware, ventaRouter);
app.use('/api/detalleVenta', authMiddleware, detalleVentaRouter);
app.use('/api/tipoDevolucion', authMiddleware, tipoDevolucionRouter);
app.use('/api/devolucion', authMiddleware, devolucionRouter);

// Manejo de rutas no encontradas
app.use((req, res, next) => {
    res.status(404).json({ ok: false, message: 'Ruta no encontrada' });
});

// Manejo de errores global
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ ok: false, message: 'Error en el servidor', error: err.message });
});

export default app;
