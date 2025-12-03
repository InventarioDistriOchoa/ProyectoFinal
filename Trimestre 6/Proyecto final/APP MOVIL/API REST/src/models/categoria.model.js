import { Model, DataTypes } from "sequelize";
import sequelize from "../config/connect.db.js";

class Categoria extends Model {}

Categoria.init(
  {
    idCategoria: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
      field: "idCategoria",
    },
    Nombre_Categoria: {
      type: DataTypes.STRING(60),
      allowNull: false,
      field: "Nombre_Categoria",
    },
    Descripcion: {
      type: DataTypes.STRING(200),
      allowNull: false,
      field: "Descripcion",
    },
  },
  {
    sequelize,
    modelName: "Categoria",
    tableName: "categorias",   // 👈 en minúsculas, como está en MariaDB
    timestamps: false,
  }
);

export default Categoria;
