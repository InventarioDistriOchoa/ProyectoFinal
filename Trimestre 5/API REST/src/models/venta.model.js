import { Model, DataTypes } from "sequelize";
import sequelize from "../config/connect.db.js";
import Persona from "./persona.model.js";

class Venta extends Model {}

Venta.init(
  {
    idVenta: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    Fecha: {
      type: DataTypes.DATE,
      allowNull: false,
    },
    Total: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
    },
    Persona_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: Persona,
        key: "idPersona",
      },
    },
  },
  {
    sequelize,
    modelName: "Venta",
    tableName: "Venta",
    timestamps: false,
  }
);

export default Venta;
