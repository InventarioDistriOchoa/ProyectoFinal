import Persona from "../models/persona.model.js";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { activeTokens, TOKEN_EXPIRATION } from "../middlewares/tokenStore.js";
import Rol from "../models/rol.model.js";

// Crear persona (solo Admin puede crear)
export const createPersona = async (req, res) => {
  try {
    const { Correo, Numero_Documento, Contrasena, ...rest } = req.body;

    // 1) Validar correo duplicado
    const existeCorreo = await Persona.findOne({ where: { Correo } });
    if (existeCorreo) {
      return res.status(400).json({
        ok: false,
        status: 400,
        Message: "El correo ya está registrado",
      });
    }

    // 2) Validar numero de documento duplicado
    const existeDocumento = await Persona.findOne({ where: { Numero_Documento } });
    if (existeDocumento) {
      return res.status(400).json({
        ok: false,
        status: 400,
        Message: "El número de documento ya está registrado",
      });
    }

    // 3) hashear contraseña
    const hashedPassword = await bcrypt.hash(Contrasena, 10);

    // 4) crear persona
    const persona = await Persona.create({
      ...rest,
      Correo,
      Numero_Documento,
      Contrasena: hashedPassword,
    });

    return res.status(201).json({
      ok: true,
      status: 201,
      Message: "Persona creada",
      body: persona,
    });
  } catch (error) {
    // si hubo un error de constraint unique en BD, dar mensaje claro
    if (error.name === "SequelizeUniqueConstraintError") {
      return res.status(400).json({
        ok: false,
        status: 400,
        Message: "Ya existe un registro con ese valor único",
        error: error.errors.map(e => e.message),
      });
    }
    return res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al crear persona",
      error: error.message,
    });
  }
};


// Mostrar todas las personas
export const showPersona = async (req, res) => {
  try {
    const personas = await Persona.findAll();
    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Listado de personas",
      body: personas,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al obtener personas",
      error: error.message,
    });
  }
};

// Mostrar persona por ID
export const showIdPersona = async (req, res) => {
  try {
    const { id } = req.params;
    const persona = await Persona.findOne({ where: { idPersona: id } });

    if (!persona)
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Persona no encontrada",
      });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Persona encontrada",
      body: persona,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al obtener persona",
      error: error.message,
    });
  }
};

// Actualizar persona
export const updatePersona = async (req, res) => {
  try {
    if (req.userRol !== 1) {
      return res.status(403).json({
        ok: false,
        status: 403,
        Message: "No tienes permisos para actualizar personas",
      });
    }

    const { id } = req.params;
    const { Contrasena, ...rest } = req.body;

    if (Contrasena) {
      rest.Contrasena = await bcrypt.hash(Contrasena, 10);
    }

    await Persona.update(rest, { where: { idPersona: id } });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Persona actualizada",
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al actualizar persona",
      error: error.message,
    });
  }
};

// Eliminar persona
export const deletePersona = async (req, res) => {
  try {
    const { id } = req.params;

    // Buscar la persona a eliminar con su rol
    const persona = await Persona.findOne({
      where: { idPersona: id },
      include: { model: Rol, attributes: ["idRol", "Descripcion_Rol"] }
    });

    if (!persona) {
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Persona no encontrada"
      });
    }

    // 🚨 Validaciones de seguridad por roles
    // 1 = Admin, 2 = Auxiliar, 3 = SuperAdmin

    // Si soy Admin, no puedo eliminar a otro Admin ni a un SuperAdmin
    if (req.userRol === 1 && (persona.Rol.idRol === 1 || persona.Rol.idRol === 3)) {
      return res.status(403).json({
        ok: false,
        status: 403,
        Message: "Un Admin no puede eliminar a otro Admin ni a un SuperAdmin"
      });
    }

    // Si soy Auxiliar, no puedo eliminar a nadie
    if (req.userRol === 2) {
      return res.status(403).json({
        ok: false,
        status: 403,
        Message: "Un Auxiliar no puede eliminar usuarios"
      });
    }

    // Solo un SuperAdmin puede eliminar a un SuperAdmin
    if (persona.Rol.idRol === 3 && req.userRol !== 3) {
      return res.status(403).json({
        ok: false,
        status: 403,
        Message: "Solo un SuperAdmin puede eliminar a otro SuperAdmin"
      });
    }

    // Si pasa las validaciones -> eliminar
    await persona.destroy();

    return res.status(200).json({
      ok: true,
      status: 200,
      Message: "Persona eliminada con éxito"
    });

  } catch (error) {
    return res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al eliminar persona",
      error: error.message
    });
  }
};


// LOGIN
export const login = async (req, res) => {
  try {
    const { Correo, Contrasena } = req.body;

    // Buscar usuario incluyendo su rol
    const persona = await Persona.findOne({
      where: { Correo },
      include: { model: Rol, attributes: ["idRol", "Descripcion_Rol"] }
    });

    if (!persona) {
      // Usuario no registrado
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Usuario no registrado"
      });
    }

    const isMatch = await bcrypt.compare(Contrasena, persona.Contrasena);
    if (!isMatch) {
      // Contraseña incorrecta
      return res.status(401).json({
        ok: false,
        status: 401,
        Message: "Contraseña incorrecta"
      });
    }

    // Generar token
    const token = jwt.sign(
      { id: persona.idPersona, Correo: persona.Correo, userRol: persona.Rol.idRol },
      process.env.JWK_SECRET,
      { expiresIn: "20m" }
    );

    // Guardar token activo
    activeTokens.set(token, {
      lastUsed: Date.now(),
      expiresAt: Date.now() + TOKEN_EXPIRATION,
    });

    // Respuesta exitosa
    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Login exitoso",
      token,
      body: {
        idPersona: persona.idPersona,
        Nombre: persona.Nombre,
        Rol: persona.Rol.Descripcion_Rol,
        Correo: persona.Correo,
      },
    });

  } catch (error) {
    // Error del servidor
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al iniciar sesión",
      error: error.message
    });
  }
};

// LOGOUT
export const logout = async (req, res) => {
  try {
    let token = req.headers.authorization;

    if (!token) {
      return res.status(401).json({
        ok: false,
        status: 401,
        Message: "Debe enviar el token para cerrar sesión"
      });
    }

    token = token.split(" ")[1]; // quitar "Bearer "

    // Eliminar token del map de tokens activos
    if (activeTokens.has(token)) {
      activeTokens.delete(token);
      return res.status(200).json({
        ok: true,
        status: 200,
        Message: "Logout exitoso. El token ha sido invalidado."
      });
    }

    return res.status(401).json({
      ok: false,
      status: 401,
      Message: "Token inválido o ya expirado"
    });

  } catch (error) {
    return res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al cerrar sesión",
      error: error.message
    });
  }
};
