// models/rol.model.js
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
    Estado: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,   // 👈 activo por defecto
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
