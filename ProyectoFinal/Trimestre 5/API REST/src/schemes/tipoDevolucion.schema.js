import Joi from "@hapi/joi";

export default {
  createTipoDevolucion: Joi.object({
    NombreTipo: Joi.string().min(3).max(45).required(),
  }),

  updateTipoDevolucion: Joi.object({
    NombreTipo: Joi.string().min(3).max(45),
  }),
};
