import Joi from "@hapi/joi";

export default {
  createTipoDocumento: Joi.object({
    Descripcion: Joi.string().min(3).max(20).required(),
  }),

  updateTipoDocumento: Joi.object({
    Descripcion: Joi.string().min(3).max(20),
  }),
};
