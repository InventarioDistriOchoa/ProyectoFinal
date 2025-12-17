import Producto from "../models/producto.model.js";
import Categoria from "../models/categoria.model.js";
import { registrarAuditoria } from "../utils/registrarAuditoria.js";


// Crear producto
export const createProducto = async (req, res) => {
  try {
    const { Nombre } = req.body;

    const existente = await Producto.findOne({ where: { Nombre } });

    if (existente && existente.Estado === false) {
      return res.status(409).json({
        ok: false,
        desactivado: true,
        idProducto: existente.idProducto,
        message: "Este producto ya existe pero está desactivado."
      });
    }

    if (existente) {
      return res.status(409).json({
        ok: false,
        message: "El producto ya existe y está activo."
      });
    }

    const data = {
      ...req.body,
      Cantidad_Actual: req.body.Cantidad_Actual ?? 0
    };

    const producto = await Producto.create(data);

   await registrarAuditoria({
  usuario: req.userId,
  coleccion: "Producto",
  documentoId: producto.idProducto,
  accion: "CREATE",
  datosAnteriores: null,
  datosNuevos: producto.toJSON(), // 👈 objeto, sin stringify
  ip: req.ip,
});


    res.status(201).json({
      ok: true,
      message: "Producto creado",
      body: producto,
    });

  } catch (error) {
    res.status(500).json({ message: "Error al crear producto", error: error.message });
  }
};



// Mostrar productos activos
export const showProducto = async (req, res) => {
  try {
    const productos = await Producto.findAll({
      where: { Estado: true },
      include: [
        { 
          model: Categoria, 
          as: "categoria",             // 👈 CORREGIDO
          attributes: ["Nombre_Categoria"]
        }
      ],
    });

    res.json({
      ok: true,
      message: "Listado de productos",
      body: productos,
    });

  } catch (error) {
    res.status(500).json({ message: "Error al obtener productos" });
  }
};



// Mostrar por ID
export const showIdProducto = async (req, res) => {
  try {
    const { id } = req.params;

    const producto = await Producto.findOne({
      where: { idProducto: id },
      include: [
        { 
          model: Categoria, 
          as: "categoria",             // 👈 CORREGIDO
          attributes: ["Nombre_Categoria"]
        }
      ],
    });

    if (!producto) {
      return res.status(404).json({ message: "Producto no encontrado" });
    }

    res.json({
      ok: true,
      body: producto,
    });

  } catch (error) {
    res.status(500).json({ message: "Error al obtener producto" });
  }
};



// Actualizar producto
export const updateProducto = async (req, res) => {
  try {
    const id = req.params.id;

    const producto = await Producto.findByPk(id);
    if (!producto) {
      return res.status(404).json({ message: "Producto no encontrado" });
    }

  const datosAnteriores = { ...producto.dataValues };

await producto.update(req.body);

const datosNuevos = { ...producto.dataValues };

await registrarAuditoria({
  usuario: req.userId,
  accion: "UPDATE",
  coleccion: "Producto",
  documentoId: id,
  datosAnteriores, // 👈 objeto
  datosNuevos,     // 👈 objeto
  ip: req.ip,
});


    return res.json({
      message: "Producto actualizado con éxito",
      body: producto,
    });
  } catch (err) {
    res.status(500).json({ message: "Error al actualizar producto" });
  }
};



// Desactivar producto
export const deleteProducto = async (req, res) => {
  try {
    const { id } = req.params;

    const producto = await Producto.findOne({ where: { idProducto: id } });

    if (!producto) {
      return res.status(404).json({ message: "Producto no encontrado" });
    }

  const datosAnteriores = producto.toJSON();

await producto.update({ Estado: false });

await registrarAuditoria({
  usuario: req.userId,
  accion: "DELETE",
  coleccion: "Producto",
  documentoId: id,
  datosAnteriores,           // objeto
  datosNuevos: { Estado: false }, // objeto
  ip: req.ip,
});

    res.json({ message: "Producto desactivado" });

  } catch (error) {
    res.status(500).json({ message: "Error al desactivar producto" });
  }
};



// Activar producto
export const activarProducto = async (req, res) => {
  try {
    const id = req.params.id;

    const producto = await Producto.findByPk(id);
    if (!producto) {
      return res.status(404).json({ message: "Producto no encontrado" });
    }

   const datosAnteriores = { ...producto.dataValues };

await producto.update({ Estado: true });

const datosNuevos = { ...producto.dataValues };

await registrarAuditoria({
  usuario: req.userId,
  accion: "ACTIVATE",
  coleccion: "Producto",
  documentoId: id,
  datosAnteriores, // objeto
  datosNuevos,     // objeto
  ip: req.ip,
});


    res.json({
      message: "Producto activado correctamente",
      body: producto
    });

  } catch (err) {
    res.status(500).json({ message: "Error al activar producto" });
  }
};
