import Joi from "@hapi/joi";

export default {
  createVenta: Joi.object({
    Fecha: Joi.date().required(),
    Total: Joi.number().precision(2).required(),
    Persona_id: Joi.number().required(),
  }),

  updateVenta: Joi.object({
    Fecha: Joi.date(),
    Total: Joi.number().precision(2),
    Persona_id: Joi.number(),
  }),
};
