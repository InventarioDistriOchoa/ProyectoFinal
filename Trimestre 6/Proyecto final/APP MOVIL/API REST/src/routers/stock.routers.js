// src/app/routes/stock.routers.js
import { Router } from "express";
import { getStock } from "../controllers/stock.controller.js";
import authMiddleware from "../middlewares/auth.middleware.js";

const router = Router();

// GET /api/stock -> Devuelve stock completo
router.get("/", authMiddleware, getStock);

export default router;
