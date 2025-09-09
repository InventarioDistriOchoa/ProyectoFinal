import Persona from "../models/persona.model.js";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";

// Login
export const login = async (req, res) => {
  try {
    const { Email, Contrasena } = req.body;

    // Buscar persona por email este es la uncione eh
    const persona = await Persona.findOne({ where: { Email } });
    if (!persona) {
      return res.status(401).json({
        ok: false,
        status: 401,
        Message: "Email o contraseña incorrectos",
      });
    }

    // Comparar contraseñas
    const isMatch = await bcrypt.compare(Contrasena, persona.Contrasena);
    if (!isMatch) {
      return res.status(401).json({
        ok: false,
        status: 401,
        Message: "Email o contraseña incorrectos",
      });
    }

    // Crear token JWK
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

// Logout (solo para el cliente, borrando token)
export const logout = async (req, res) => {
  res.status(200).json({
    ok: true,
    status: 200,
    Message: "Logout exitoso, el token debe ser eliminado del cliente",
  });
};
