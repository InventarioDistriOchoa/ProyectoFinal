// routers/reportes.router.js
import { Router } from "express";
import { getDashboardData } from "../controllers/reportes.controller.js";
import authMiddleware from "../middlewares/auth.middleware.js";

const router = Router();
router.get("/dashboard", authMiddleware, getDashboardData);
export default router;
