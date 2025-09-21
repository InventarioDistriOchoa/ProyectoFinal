import Joi from "@hapi/joi";

export default {
  createDevolucion: Joi.object({
    Fecha: Joi.date().required(),
    Motivo: Joi.string().max(200).required(),
    Cantidad: Joi.number().integer().min(1).required(),
    Producto_id: Joi.number().integer().required(),
    Persona_id: Joi.number().integer().required(),
    TipoDevolucion_id: Joi.number().integer().required(),
  }),

  updateDevolucion: Joi.object({
    Fecha: Joi.date(),
    Motivo: Joi.string().max(200),
    Cantidad: Joi.number().integer().min(1),
    Producto_id: Joi.number().integer(),
    Persona_id: Joi.number().integer(),
    TipoDevolucion_id: Joi.number().integer(),
  }),
};
