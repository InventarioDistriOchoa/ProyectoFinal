import Joi from "@hapi/joi";

export default {
  createDetalleVenta: Joi.object({
    Cantidad: Joi.number().integer().min(1).required(),
    PrecioUnitario: Joi.number().precision(2).required(),
    Subtotal: Joi.number().precision(2).required(),
    Venta_id: Joi.number().integer().required(),
    Producto_id: Joi.number().integer().required(),
  }),

  updateDetalleVenta: Joi.object({
    Cantidad: Joi.number().integer().min(1),
    PrecioUnitario: Joi.number().precision(2),
    Subtotal: Joi.number().precision(2),
    Venta_id: Joi.number().integer(),
    Producto_id: Joi.number().integer(),
  }),
};
