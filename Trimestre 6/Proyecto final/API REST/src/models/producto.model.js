import { Model, DataTypes } from "sequelize";
import sequelize from "../config/connect.db.js";
import Categoria from "./categoria.model.js";

class Producto extends Model {}

Producto.init(
  {
    idProducto: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
      unique: true,
    },
    Nombre: {
      type: DataTypes.STRING(100),
      allowNull: false,
      unique: true,
    },
    Precio: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
    },
    Cantidad_Actual: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 0,
    },
    Categoria_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: "categorias",
        key: "idCategoria",
      },
    },
    Estado: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true,
    },
  },
  {
    sequelize,
    modelName: "Producto",
    tableName: "productos",
    timestamps: false,
  }
);

// ❌ AQUÍ YA NO DEFINIMOS RELACIONES
// Producto.belongsTo(...)
// Categoria.hasMany(...)

export default Producto;
