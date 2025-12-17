// controllers/auditoria.controller.js
import Auditoria from "../models/auditoria.model.js";
import Persona from "../models/persona.model.js";
import Categoria from "../models/categoria.model.js";

export const obtenerHistorial = async (req, res) => {
  try {
    const historial = await Auditoria.findAll({
      include: [
        {
          model: Persona,
          as: "persona",
          attributes: ["Nombre", "Correo"],
        },
      ],
      order: [["createdAt", "DESC"]],
    });

    const categorias = await Categoria.findAll();

    const mapCategorias = Object.fromEntries(
      categorias.map((c) => [c.idCategoria, c.Nombre_Categoria])
    );

    const mapEstado = (v) => (v ? "Activo" : "Inactivo");

    const resultado = historial.map((item) => {
      // ✅ Ya vienen como objeto o null
      const prev = item.datosAnteriores || {};
      const next = item.datosNuevos || {};

      const getValue = (obj, keys) => {
        for (const k of keys) {
          if (obj[k] != null) return obj[k];
        }
        return null;
      };

      // ====== Categoria
      const prevIdCat = getValue(prev, [
        "Categoria_id",
        "idCategoria",
        "id_categoria",
        "id_Categoria",
        "idcategoria",
      ]);
      const nextIdCat = getValue(next, [
        "Categoria_id",
        "idCategoria",
        "id_categoria",
        "id_Categoria",
        "idcategoria",
      ]);

      if (prevIdCat !== null)
        prev.Categoria = mapCategorias[Number(prevIdCat)] || prevIdCat;
      if (nextIdCat !== null)
        next.Categoria = mapCategorias[Number(nextIdCat)] || nextIdCat;

      // ====== Estado (ojo mayúscula como en modelo Producto)
      if (prev.Estado !== undefined) prev.Estado = mapEstado(prev.Estado);
      if (next.Estado !== undefined) next.Estado = mapEstado(next.Estado);

      return {
        ...item.toJSON(),
        datosAnteriores: prev,
        datosNuevos: next,
      };
    });

    res.json({
      ok: true,
      body: resultado,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      ok: false,
      msg: "Error cargando historial",
    });
  }
};
