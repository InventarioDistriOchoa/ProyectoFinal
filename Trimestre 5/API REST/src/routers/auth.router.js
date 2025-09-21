// src/routes/auth.router.js
import { Router } from "express";
import {
  login,
  logout,
  forgotPassword,   // ✅ Nuevo
  resetPassword    // ✅ Nuevo
} from "../controllers/auth.controller.js";

const router = Router();

// Rutas existentes
router.post("/login", login);
router.post("/logout", logout);

// 🔑 Nuevas rutas para recuperación de contraseña
router.post("/forgot-password", forgotPassword);        // Enviar correo con token
router.post("/reset-password/:token", resetPassword);   // Cambiar contraseña

export default router;
