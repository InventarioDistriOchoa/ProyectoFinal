import { Model, DataTypes } from "sequelize";
import sequelize from "../config/connect.db.js";

class Rol extends Model {}

Rol.init(
  {
    idRol: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    Descripcion_Rol: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
    },
  },
  {
    sequelize,
    modelName: "Rol",
    tableName: "rol",
    timestamps: false,
  }
);

export default Rol;
