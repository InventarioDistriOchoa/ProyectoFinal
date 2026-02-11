// models/categoria.model.js
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
    Estado: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
      field: "Estado",
    },
  },
  {
    sequelize,
    modelName: "Categoria",
    tableName: "categorias", // como la tienes en la BD
    timestamps: false,
  }
);

export default Categoria;
