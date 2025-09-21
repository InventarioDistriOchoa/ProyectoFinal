import Persona from "../models/persona.model.js";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import crypto from "crypto";
import { Op } from "sequelize";
import { sendMail } from "../utils/sendMail.js";
 // ➜ crea este helper con nodemailer

// ====================== LOGIN ======================
export const login = async (req, res) => {
  try {
    const { Email, Contrasena } = req.body;

    const persona = await Persona.findOne({ where: { Email } });
    if (!persona) {
      return res.status(401).json({
        ok: false,
        status: 401,
        Message: "Email o contraseña incorrectos",
      });
    }

    const isMatch = await bcrypt.compare(Contrasena, persona.Contrasena);
    if (!isMatch) {
      return res.status(401).json({
        ok: false,
        status: 401,
        Message: "Email o contraseña incorrectos",
      });
    }

    const token = jwt.sign(
      { id: persona.idPersona, rol: persona.Rol },
      process.env.JWK_SECRET,
      { expiresIn: "1h" }
    );

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Login exitoso",
      token,
      body: {
        idPersona: persona.idPersona,
        Nombre: persona.Nombre,
        Rol: persona.Rol,
        Email: persona.Email,
      },
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al iniciar sesión",
      error: error.message,
    });
  }
};

// ====================== LOGOUT ======================
export const logout = async (req, res) => {
  res.status(200).json({
    ok: true,
    status: 200,
    Message: "Logout exitoso, el token debe ser eliminado del cliente",
  });
};

// src/controllers/auth.controller.js

export const forgotPassword = async (req, res) => {
  try {
    const { Correo } = req.body;

    // Buscar usuario
    const persona = await Persona.findOne({ where: { Correo } });
    if (!persona) {
      return res.status(404).json({ ok: false, msg: "Correo no encontrado" });
    }

    // Generar token JWT válido por 15 minutos
    const token = jwt.sign(
      { id: persona.idPersona },
      process.env.JWK_SECRET,
      { expiresIn: "15m" }
    );

    // Guardar token y expiración en la base de datos
    persona.resetToken = token;
    persona.resetExpires = Date.now() + 15 * 60 * 1000; // 15 minutos
    await persona.save();

    // Link para resetear contraseña
    const resetLink = `${process.env.FRONTEND_URL}/reset-password?token=${token}`;

    // Enviar correo
    await sendMail(
      Correo,
      "Recuperación de contraseña",
      `<p>Hola ${persona.Nombre},</p>
       <p>Haz clic <a href="${resetLink}">aquí</a> para restablecer tu contraseña. Este enlace es válido por 15 minutos.</p>`
    );

    res.json({ ok: true, msg: "Correo de recuperación enviado" });
  } catch (error) {
    console.error("Error en forgotPassword:", error);
    res.status(500).json({ ok: false, msg: "Error interno" });
  }
};


export const resetPassword = async (req, res) => {
  try {
    const { token } = req.params; // ⚠️ Desde params
    const { nuevaContrasena } = req.body;

    const persona = await Persona.findOne({
      where: {
        resetToken: token,
        resetExpires: { [Op.gt]: Date.now() }
      }
    });

    if (!persona) {
      return res.status(400).json({ ok: false, msg: "Token inválido o vencido" });
    }

    // Guardar nueva contraseña
    persona.Contrasena = await bcrypt.hash(nuevaContrasena, 10);
    persona.resetToken = null;
    persona.resetExpires = null;
    await persona.save();

    res.json({ ok: true, msg: "Contraseña actualizada correctamente" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ ok: false, msg: "Error interno" });
  }
};
