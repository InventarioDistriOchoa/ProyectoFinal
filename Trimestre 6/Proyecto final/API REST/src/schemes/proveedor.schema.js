import Joi from "@hapi/joi";

export default {
  createProveedor: Joi.object({
    Nombre_Empresa: Joi.string().min(3).max(60).required(),
    Direccion: Joi.string().min(5).max(100).required(),
  }),

  updateProveedor: Joi.object({
    Nombre_Empresa: Joi.string().min(3).max(60),
    Direccion: Joi.string().min(5).max(100),
  }),
};
