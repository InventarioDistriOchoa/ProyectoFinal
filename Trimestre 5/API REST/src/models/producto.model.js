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
    },
    Nombre: {
      type: DataTypes.STRING(100),
      allowNull: false,
    },
    Precio: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
    },
    Cantidad_Actual: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 0,   // ✅ inicia en 0 y no requiere input del usuario
    },
    Categoria_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: "Categorias",
        key: "idCategoria",
      },
    },
  },
  {
    sequelize,
    modelName: "Producto",
    tableName: "Productos",
    timestamps: false,
  }
);

// Relaciones
Producto.belongsTo(Categoria, { foreignKey: "Categoria_id" });
Categoria.hasMany(Producto, { foreignKey: "Categoria_id" });

export default Producto;
