import Persona from "../models/persona.model.js";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { activeTokens, TOKEN_EXPIRATION } from "../middlewares/tokenStore.js";
import Rol from "../models/rol.model.js";
import { Op } from "sequelize";
import { registrarAuditoria } from "../utils/registrarAuditoria.js"; // ✅ AUDITORÍA

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

    // ✅ AUDITORÍA CREATE
    try {
      await registrarAuditoria({
        usuario: req.userId || null, // puede ser null si la crea alguien sin token
        coleccion: "Persona",
        documentoId: persona.idPersona,
        accion: "CREATE",
        datosAnteriores: null,
        datosNuevos: persona.toJSON(),
        ip: req.ip,
      });
    } catch (auditErr) {
      console.error("Error registrando auditoría CREATE Persona:", auditErr.message);
    }

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
        error: error.errors.map((e) => e.message),
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

// ==================== ACTUALIZAR PERSONA ====================
// Actualizar persona
export const updatePersona = async (req, res) => {
  try {
    const { id } = req.params;
    const {
      Contrasena,
      Correo,
      Numero_Documento,
      ...rest
    } = req.body;

    const userRol = Number(req.userRol);   // 1 = Admin, 2 = Aux, 3 = SuperAdmin
    const userId = Number(req.userId);
    const targetId = Number(id);

    console.log("🔐 updatePersona -> userId:", userId, "userRol:", userRol, "targetId:", targetId);
    console.log("📝 Body recibido en updatePersona:", req.body);

    // 👉 REGLA DE PERMISOS:
    // - TODOS los roles pueden editar SU PROPIO perfil (userId === targetId)
    // - SOLO Admin (1) y SuperAdmin (3) pueden editar a otros
    if (userId !== targetId && ![1, 3].includes(userRol)) {
      return res.status(403).json({
        ok: false,
        status: 403,
        Message: "No tienes permisos para actualizar esta persona",
      });
    }

    // Buscar persona a editar
    const persona = await Persona.findByPk(id);

    if (!persona) {
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Persona no encontrada",
      });
    }

    // Guardar datos anteriores para auditoría
    const datosAnteriores = persona.toJSON();

    // ---------- Validar correo duplicado SOLO si lo cambió ----------
    if (Correo && Correo.trim() !== persona.Correo) {
      const existeCorreo = await Persona.findOne({
        where: {
          Correo: Correo.trim(),
          idPersona: { [Op.ne]: id }, // cualquier otro distinto a mí
        },
      });

      if (existeCorreo) {
        return res.status(400).json({
          ok: false,
          status: 400,
          Message: "El correo ya está registrado",
        });
      }

      rest.Correo = Correo.trim();
    }

    // ---------- Validar documento duplicado SOLO si lo cambió ----------
    if (Numero_Documento && Numero_Documento.trim() !== persona.Numero_Documento) {
      const existeDocumento = await Persona.findOne({
        where: {
          Numero_Documento: Numero_Documento.trim(),
          idPersona: { [Op.ne]: id },
        },
      });

      if (existeDocumento) {
        return res.status(400).json({
          ok: false,
          status: 400,
          Message: "El número de documento ya está registrado",
        });
      }

      rest.Numero_Documento = Numero_Documento.trim();
    }

    // ---------- Si viene contraseña, la hasheamos ----------
    if (Contrasena && Contrasena.trim()) {
      rest.Contrasena = await bcrypt.hash(Contrasena.trim(), 10);
    }

    // Limpiar strings (quitar espacios)
    Object.keys(rest).forEach((k) => {
      if (typeof rest[k] === "string") {
        rest[k] = rest[k].trim();
      }
    });

    // Actualizar
    await persona.update(rest);

    const datosNuevos = persona.toJSON();

    // ✅ AUDITORÍA UPDATE
    try {
      await registrarAuditoria({
        usuario: req.userId,
        coleccion: "Persona",
        documentoId: persona.idPersona,
        accion: "UPDATE",
        datosAnteriores,
        datosNuevos,
        ip: req.ip,
      });
    } catch (auditErr) {
      console.error("Error registrando auditoría UPDATE Persona:", auditErr.message);
    }

    return res.status(200).json({
      ok: true,
      status: 200,
      Message: "Persona actualizada correctamente",
    });
  } catch (error) {
    console.error("❌ Error en updatePersona:", error);

    if (error.name === "SequelizeUniqueConstraintError") {
      return res.status(400).json({
        ok: false,
        status: 400,
        Message: "Ya existe un registro con ese valor único",
        error: error.errors?.map((e) => e.message),
      });
    }

    return res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al actualizar persona",
      error: error.message,
    });
  }
};


// ==================== ELIMINAR PERSONA ====================
export const deletePersona = async (req, res) => {
  try {
    const { id } = req.params;

    // Buscar la persona a eliminar con su rol
    const persona = await Persona.findOne({
      where: { idPersona: id },
      include: { model: Rol, attributes: ["idRol", "Descripcion_Rol"] },
    });

    if (!persona) {
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Persona no encontrada",
      });
    }

    // 🚨 Validaciones de seguridad por roles
    // 1 = Admin, 2 = Auxiliar, 3 = SuperAdmin

    // Si soy Admin, no puedo eliminar a otro Admin ni a un SuperAdmin
    if (req.userRol === 1 && (persona.Rol.idRol === 1 || persona.Rol.idRol === 3)) {
      return res.status(403).json({
        ok: false,
        status: 403,
        Message: "Un Admin no puede eliminar a otro Admin ni a un SuperAdmin",
      });
    }

    // Si soy Auxiliar, no puedo eliminar a nadie
    if (req.userRol === 2) {
      return res.status(403).json({
        ok: false,
        status: 403,
        Message: "Un Auxiliar no puede eliminar usuarios",
      });
    }

    // Solo un SuperAdmin puede eliminar a un SuperAdmin
    if (persona.Rol.idRol === 3 && req.userRol !== 3) {
      return res.status(403).json({
        ok: false,
        status: 403,
        Message: "Solo un SuperAdmin puede eliminar a otro SuperAdmin",
      });
    }

    const datosAnteriores = persona.toJSON();

    // Si pasa las validaciones -> eliminar
    await persona.destroy();

    // ✅ AUDITORÍA DELETE
    try {
      await registrarAuditoria({
        usuario: req.userId,
        coleccion: "Persona",
        documentoId: id,
        accion: "DELETE",
        datosAnteriores,
        datosNuevos: null,
        ip: req.ip,
      });
    } catch (auditErr) {
      console.error("Error registrando auditoría DELETE Persona:", auditErr.message);
    }

    return res.status(200).json({
      ok: true,
      status: 200,
      Message: "Persona eliminada con éxito",
    });
  } catch (error) {
    return res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al eliminar persona",
      error: error.message,
    });
  }
};

// ==================== LOGIN ====================
export const login = async (req, res) => {
  try {
    const { Correo, Contrasena } = req.body;

    // Buscar usuario incluyendo su rol
    const persona = await Persona.findOne({
      where: { Correo },
      include: { model: Rol, attributes: ["idRol", "Descripcion_Rol"] },
    });

    const genericError = {
      ok: false,
      status: 401,
      Message: "Credenciales incorrectas",
    };

    if (!persona) {
      return res.status(401).json(genericError);
    }

    const isMatch = await bcrypt.compare(Contrasena, persona.Contrasena);
    if (!isMatch) {
      return res.status(401).json(genericError);
    }

    // Generar token
    const token = jwt.sign(
      { id: persona.idPersona, Correo: persona.Correo, userRol: persona.Rol.idRol },
      process.env.JWK_SECRET,
      { expiresIn: "4h" }
    );

    activeTokens.set(token, {
      lastUsed: Date.now(),
      expiresAt: Date.now() + TOKEN_EXPIRATION,
    });

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
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al iniciar sesión",
      error: error.message,
    });
  }
};

// ==================== LOGOUT ====================
export const logout = async (req, res) => {
  try {
    let token = req.headers.authorization;

    if (!token) {
      return res.status(401).json({
        ok: false,
        status: 401,
        Message: "Debe enviar el token para cerrar sesión",
      });
    }

    token = token.split(" ")[1]; // quitar "Bearer "

    if (activeTokens.has(token)) {
      activeTokens.delete(token);
      return res.status(200).json({
        ok: true,
        status: 200,
        Message: "Logout exitoso. El token ha sido invalidado.",
      });
    }

    return res.status(401).json({
      ok: false,
      status: 401,
      Message: "Token inválido o ya expirado",
    });
  } catch (error) {
    return res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al cerrar sesión",
      error: error.message,
    });
  }
};

// ==================== SUBIR FOTO PERFIL ====================
export const uploadFotoPersona = async (req, res) => {
  try {
    const { id } = req.params;
    const persona = await Persona.findByPk(id);
    if (!persona)
      return res.status(404).json({ ok: false, Message: "Usuario no encontrado" });

    if (!req.file)
      return res.status(400).json({ ok: false, Message: "Archivo no recibido" });

    const fotoPath = `/uploads/fotosUsuarios/${req.file.filename}`;

    persona.Foto = fotoPath;
    await persona.save();

    res
      .status(200)
      .json({ ok: true, path: fotoPath, Message: "Foto subida correctamente" });
  } catch (error) {
    res
      .status(500)
      .json({ ok: false, Message: "Error al subir foto", error: error.message });
  }
};

// ==================== PERFIL DEL USUARIO ACTUAL ====================
export const getMyProfile = async (req, res) => {
  try {
    const persona = await Persona.findOne({
      where: { idPersona: req.userId },
      attributes: { exclude: ["Contrasena", "resetToken", "resetExpires"] },
      include: { model: Rol, attributes: ["Descripcion_Rol"] },
    });

    if (!persona) {
      return res
        .status(404)
        .json({ ok: false, status: 404, Message: "Persona no encontrada" });
    }

    res.json({ ok: true, status: 200, body: persona });
  } catch (err) {
    res.status(500).json({
      ok: false,
      Message: "Error al obtener perfil",
      error: err.message,
    });
  }
};
