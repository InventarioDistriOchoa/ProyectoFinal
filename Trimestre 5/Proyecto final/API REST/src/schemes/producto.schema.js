import Joi from "@hapi/joi";

export default {
  createProducto: Joi.object({
    Nombre: Joi.string().min(3).max(100).required(),
    Precio: Joi.number().precision(2).required(),
    Cantidad_Actual: Joi.number().integer().required(),
    Categoria_id: Joi.number().integer().required(),
  }),

  updateProducto: Joi.object({
    Nombre: Joi.string().min(3).max(100),
    Precio: Joi.number().precision(2),
    Cantidad_Actual: Joi.number().integer(),
    Categoria_id: Joi.number().integer(),
  }),
};
