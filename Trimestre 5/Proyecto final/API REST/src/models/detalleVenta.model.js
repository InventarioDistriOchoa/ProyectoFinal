import { Model, DataTypes } from "sequelize";
import sequelize from "../config/connect.db.js";
import Venta from "./venta.model.js";
import Producto from "./producto.model.js";

class DetalleVenta extends Model {}

DetalleVenta.init(
  {
    idDetalleVenta: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    Cantidad: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    PrecioUnitario: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
    },
    Subtotal: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
    },
    Venta_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: Venta,
        key: "idVenta",
      },
    },
    Producto_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: Producto,
        key: "idProducto",
      },
    },
  },
  {
    sequelize,
    modelName: "DetalleVenta",
    tableName: "DetalleVenta",
    timestamps: false,
  }
);

export default DetalleVenta;
