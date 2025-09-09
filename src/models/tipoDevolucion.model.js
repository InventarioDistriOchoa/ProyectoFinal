import { Model, DataTypes } from "sequelize";
import sequelize from "../config/connect.db.js";

class TipoDevolucion extends Model {}

TipoDevolucion.init(
  {
    idTipoDevolucion: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    NombreTipo: {
      type: DataTypes.STRING(45),
      allowNull: false,
    },
  },
  {
    sequelize,
    modelName: "TipoDevolucion",
    tableName: "TipoDevolucion",
    timestamps: false,
  }
);

export default TipoDevolucion;
