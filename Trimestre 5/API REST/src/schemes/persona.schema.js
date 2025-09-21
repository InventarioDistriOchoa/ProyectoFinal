// src/schemas/persona.schema.js
import Joi from "@hapi/joi";

export default {
  createPersona: Joi.object({
    Nombre: Joi.string().required().min(3),
    Correo: Joi.string().email().required(),
    Contrasena: Joi.string().required().min(6),
    Numero_Documento: Joi.string().required().min(3).max(50),
    Tipo_Documento_id: Joi.number().required(),
    Rol_id: Joi.number().required(),
  }),

  updatePersona: Joi.object({
    Nombre: Joi.string().min(3),
    Correo: Joi.string().email(),
    Contrasena: Joi.string().min(6),
    Numero_Documento: Joi.string().min(3).max(50),
    Tipo_Documento_id: Joi.number(),
    Rol_id: Joi.number(),
  }),
};
