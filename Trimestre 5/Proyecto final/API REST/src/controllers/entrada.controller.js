import Entrada from "../models/entrada.model.js";
import Producto from "../models/producto.model.js";
import { registrarAuditoria } from "../utils/registrarAuditoria.js";

// =======================
// Crear entrada
// =======================
export const createEntrada = async (req, res) => {
  try {
    const { Fecha, Cantidad, Producto_id, Proveedor_id } = req.body;
    const Persona_id = req.userId; // viene del token (verifyToken)

    // 1) Crear la entrada
    const nuevaEntrada = await Entrada.create({
      Fecha,
      Cantidad,
      Producto_id,
      Proveedor_id,
      Persona_id,
      Estado: true, // por si acaso
    });

    // 2) Actualizar la cantidad del producto
    const producto = await Producto.findByPk(Producto_id);
    if (!producto) {
      return res.status(404).json({ ok: false, Message: "Producto no encontrado" });
    }

    producto.Cantidad_Actual += Cantidad; // suma la entrada
    await producto.save();

    // 3) Registrar auditoría
    await registrarAuditoria({
      usuario: req.userId,
      coleccion: "Entrada",
      documentoId: nuevaEntrada.idEntrada,
      accion: "CREATE",
      datosAnteriores: null,
      datosNuevos: nuevaEntrada.toJSON(),
      ip: req.ip,
    });

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

// =======================
// Mostrar todas las entradas ACTIVAS
// =======================
export const showEntrada = async (req, res) => {
  try {
    const entradas = await Entrada.findAll({
      where: { Estado: true }, // solo activas
    });

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

// =======================
// Mostrar entrada por ID
// =======================
export const showIdEntrada = async (req, res) => {
  try {
    const { id } = req.params;
    const entrada = await Entrada.findOne({ where: { idEntrada: id } });

    if (!entrada) {
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Entrada no encontrada",
      });
    }

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

// =======================
// Actualizar entrada
// (NO tocamos stock, igual que tu versión original)
// =======================
export const updateEntrada = async (req, res) => {
  try {
    const { id } = req.params;

    const entrada = await Entrada.findOne({ where: { idEntrada: id } });
    if (!entrada) {
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Entrada no encontrada",
      });
    }

    const datosAnteriores = { ...entrada.dataValues };

    await entrada.update(req.body);

    const datosNuevos = { ...entrada.dataValues };

    await registrarAuditoria({
      usuario: req.userId,
      coleccion: "Entrada",
      documentoId: id,
      accion: "UPDATE",
      datosAnteriores,
      datosNuevos,
      ip: req.ip,
    });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Entrada actualizada",
      body: entrada,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al actualizar entrada",
      error: error.message,
    });
  }
};

// =======================
// DESACTIVAR entrada (soft delete) + actualizar stock
// =======================
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
      // Restar la cantidad de la entrada desactivada
      producto.Cantidad_Actual -= entrada.Cantidad;
      if (producto.Cantidad_Actual < 0) producto.Cantidad_Actual = 0; // evitar negativos
      await producto.save();
    }

    const datosAnteriores = entrada.toJSON();

    // 3️⃣ Soft delete: marcar Estado = false
    await entrada.update({ Estado: false });

    // 4️⃣ Auditoría
    await registrarAuditoria({
      usuario: req.userId,
      coleccion: "Entrada",
      documentoId: id,
      accion: "DELETE", // o "DEACTIVATE" si luego quieres diferenciar
      datosAnteriores,
      datosNuevos: { Estado: false },
      ip: req.ip,
    });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Entrada desactivada y stock actualizado ✅",
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al desactivar entrada",
      error: error.message,
    });
  }
};

// =======================
// ACTIVAR entrada (revertir soft delete) + actualizar stock
// =======================
export const activarEntrada = async (req, res) => {
  try {
    const { id } = req.params;

    const entrada = await Entrada.findOne({ where: { idEntrada: id } });
    if (!entrada) {
      return res.status(404).json({
        ok: false,
        status: 404,
        Message: "Entrada no encontrada",
      });
    }

    const datosAnteriores = { ...entrada.dataValues };

    // 1️⃣ Actualizar stock del producto (sumar de nuevo la cantidad)
    const producto = await Producto.findByPk(entrada.Producto_id);
    if (producto) {
      producto.Cantidad_Actual += entrada.Cantidad;
      await producto.save();
    }

    // 2️⃣ Marcar Estado = true
    await entrada.update({ Estado: true });

    const datosNuevos = { ...entrada.dataValues };

    // 3️⃣ Registrar auditoría
    await registrarAuditoria({
      usuario: req.userId,
      coleccion: "Entrada",
      documentoId: id,
      accion: "ACTIVATE",
      datosAnteriores,
      datosNuevos,
      ip: req.ip,
    });

    res.status(200).json({
      ok: true,
      status: 200,
      Message: "Entrada activada y stock actualizado ✅",
      body: entrada,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      ok: false,
      status: 500,
      Message: "Error al activar entrada",
      error: error.message,
    });
  }
};
