import Joi from "@hapi/joi";

export default {
  createEntrada: Joi.object({
    Fecha: Joi.date().required(),
    Cantidad: Joi.number().integer().min(1).required(),
    Producto_id: Joi.number().integer().required(),
    Proveedor_id: Joi.number().integer().required(),
    Persona_id: Joi.number().integer().required(),
  }),

  updateEntrada: Joi.object({
    Fecha: Joi.date(),
    Cantidad: Joi.number().integer().min(1),
    Producto_id: Joi.number().integer(),
    Proveedor_id: Joi.number().integer(),
    Persona_id: Joi.number().integer(),
  }),
};
