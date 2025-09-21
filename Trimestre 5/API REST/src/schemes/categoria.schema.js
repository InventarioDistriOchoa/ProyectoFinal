import Joi from '@hapi/joi';

export default {
  createCategoria: Joi.object({
    Nombre_Categoria: Joi.string().required().min(3).max(60),
    Descripcion: Joi.string().required().min(5).max(200),
  }),

  updateCategoria: Joi.object({
    Nombre_Categoria: Joi.string().min(3).max(60),
    Descripcion: Joi.string().min(5).max(200),
  }),
};
