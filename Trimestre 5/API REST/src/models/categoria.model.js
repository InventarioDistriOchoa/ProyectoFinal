import { Model, DataTypes } from "sequelize";
import sequelize from "../config/connect.db.js";

class Categoria extends Model {}

Categoria.init(
  {
    idCategoria: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    Nombre_Categoria: {
      type: DataTypes.STRING(60),
      allowNull: false,
    },
    Descripcion: {
      type: DataTypes.STRING(200),
      allowNull: false,
    },
  },
  {
    sequelize,
    modelName: "Categoria",
    tableName: "Categorias",
    timestamps: false,
  }
);

export default Categoria;
