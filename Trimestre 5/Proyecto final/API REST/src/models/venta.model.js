// models/venta.model.js
import { Model, DataTypes } from "sequelize";
import sequelize from "../config/connect.db.js";

import Persona from "./persona.model.js";
import DetalleVenta from "./detalleVenta.model.js";

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

    // 👇 NUEVO: para poder hacer DELETE lógico + ACTIVATE
    Estado: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true, // activa por defecto
    },
  },
  {
    sequelize,
    modelName: "Venta",
    tableName: "Venta",
    timestamps: false, // usas Fecha, no createdAt/updatedAt
  }
);

/* ============================
   🔗 RELACIONES
   ============================ */
Venta.belongsTo(Persona, {
  foreignKey: "Persona_id",
  as: "Responsable",
});

Venta.hasMany(DetalleVenta, {
  foreignKey: "Venta_id",
  as: "DetalleVentas",
});

export default Venta;
