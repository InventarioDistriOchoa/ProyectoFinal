import { Model, DataTypes } from "sequelize";
import sequelize from "../config/connect.db.js";

class Proveedor extends Model {}

Proveedor.init(
  {
    idProveedor: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    Nombre_Empresa: {
      type: DataTypes.STRING(60),
      allowNull: false,
    },
    Direccion: {
      type: DataTypes.STRING(100),
      allowNull: false,
    },
  },
  {
    sequelize,
    modelName: "Proveedor",
    tableName: "Proveedores",
    timestamps: false,
  }
);

export default Proveedor;
