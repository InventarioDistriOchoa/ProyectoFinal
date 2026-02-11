import Joi from "@hapi/joi";

export default {
  createRol: Joi.object({
    Descripcion_Rol: Joi.string().min(3).max(70).required(),
  }),

  updateRol: Joi.object({
    Descripcion_Rol: Joi.string().min(3).max(70),
  }),
};
