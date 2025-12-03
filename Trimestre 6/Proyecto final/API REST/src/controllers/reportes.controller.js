// controllers/reportes.controller.js
import { Sequelize } from "sequelize";
import Producto from "../models/producto.model.js";
import Categoria from "../models/categoria.model.js";
import DetalleVenta from "../models/detalleVenta.model.js";
import Entrada from "../models/entrada.model.js";

export const getDashboardData = async (req, res) => {
  try {
    // 🥇 Productos más vendidos (por cantidad vendida)
    const masVendidos = await DetalleVenta.findAll({
      attributes: [
        [Sequelize.col("Producto.Nombre"), "producto"],
        [Sequelize.fn("SUM", Sequelize.col("Cantidad")), "unidades"]
      ],
      include: [{ model: Producto, attributes: [] }],
      group: ["Producto.Nombre"],
      order: [[Sequelize.fn("SUM", Sequelize.col("Cantidad")), "DESC"]],
      limit: 5
    });

    // 📦 Entradas por mes (últimos 6 meses)
    const entradasPorMes = await Entrada.findAll({
      attributes: [
        [Sequelize.fn("DATE_FORMAT", Sequelize.col("Fecha"), "%b"), "mes"],
        [Sequelize.fn("SUM", Sequelize.col("Cantidad")), "total"]
      ],
      group: [Sequelize.fn("MONTH", Sequelize.col("Fecha"))],
      order: [Sequelize.literal("MIN(Fecha)")],
      limit: 6
    });

    // 🍏 Distribución por categoría
    const distribucion = await Producto.findAll({
      attributes: [
        [Sequelize.col("Categoria.Nombre_Categoria"), "categoria"],
        [Sequelize.fn("SUM", Sequelize.col("Cantidad_Actual")), "stock"]
      ],
      include: [{ model: Categoria, as: "Categoria", attributes: [] }],
      group: ["Categoria.Nombre_Categoria"]
    });

    // Totales generales
    const totalProductos = await Producto.count();
    const totalCategorias = await Categoria.count();
    const stockTotal = await Producto.sum("Cantidad_Actual");

    res.json({
      masVendidos,
      entradasPorMes,
      distribucion,
      totalProductos,
      totalCategorias,
      stockTotal
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
