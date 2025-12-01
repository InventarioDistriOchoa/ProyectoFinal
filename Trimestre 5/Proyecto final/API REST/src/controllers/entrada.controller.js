import Entrada from "../models/entrada.model.js";
import Producto from "../models/producto.model.js";
// Crear entrada

export const createEntrada = async (req, res) => {
  try {
    const { Fecha, Cantidad, Producto_id, Proveedor_id } = req.body;
    const Persona_id = req.userId; // del token

    // Crear la entrada
    const nuevaEntrada = await Entrada.create({
      Fecha,
      Cantidad,
      Producto_id,
      Proveedor_id,
      Persona_id,
    });

    // Actualizar la cantidad del producto
    const producto = await Producto.findByPk(Producto_id);
    if (!producto) {
      return res.status(404).json({ ok: false, Message: "Producto no encontrado" });
    }

    producto.Cantidad_Actual += Cantidad; // suma la entrada
    await producto.save();

    return res.status(201).json({
      ok: true,
      Message: "Entrada registrada correctamente",
      body: nuevaEntrada,
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({
      ok: false,
      Message: "Error al crear entrada",
      error: error.message,
    });
  }
};

// Mostrar todas las entradas
export const showEntrada = async (req, res) => {
  try {
    const entradas = await Entrada.findAll();
    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Listado de entradas",
      body: entradas,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al obtener entradas",
      error: error.message,
    });
  }
};

// Mostrar entrada por ID
export const showIdEntrada = async (req, res) => {
  try {
    const { id } = req.params;
    const entrada = await Entrada.findOne({ where: { idEntrada: id } });

    if (!entrada)
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Entrada no encontrada",
      });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Entrada encontrada",
      body: entrada,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al obtener entrada",
      error: error.message,
    });
  }
};

// Actualizar entrada
export const updateEntrada = async (req, res) => {
  try {
    const { id } = req.params;
    const updated = await Entrada.update(req.body, { where: { idEntrada: id } });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Entrada actualizada",
      body: updated,
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al actualizar entrada",
      error: error.message,
    });
  }
};

// Eliminar entrada y actualizar stock del producto
export const deleteEntrada = async (req, res) => {
  try {
    const { id } = req.params;

    // 1️⃣ Buscar la entrada
    const entrada = await Entrada.findOne({ where: { idEntrada: id } });
    if (!entrada) {
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Entrada no encontrada",
      });
    }

    // 2️⃣ Buscar el producto asociado
    const producto = await Producto.findByPk(entrada.Producto_id);
    if (producto) {
      // Restar la cantidad de la entrada eliminada
      producto.Cantidad_Actual -= entrada.Cantidad;
      if (producto.Cantidad_Actual < 0) producto.Cantidad_Actual = 0; // evitar negativos
      await producto.save();
    }

    // 3️⃣ Eliminar la entrada
    await Entrada.destroy({ where: { idEntrada: id } });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Entrada eliminada y stock actualizado ✅",
    });
  } catch (error) {
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al eliminar entrada",
      error: error.message,
    });
  }
};
