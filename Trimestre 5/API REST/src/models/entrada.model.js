import { Model, DataTypes } from "sequelize";
import sequelize from "../config/connect.db.js";
import Producto from "./producto.model.js";
import Proveedor from "./proveedor.model.js";
import Persona from "./persona.model.js";

class Entrada extends Model {}

Entrada.init(
  {
    idEntrada: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    Fecha: {
      type: DataTypes.DATE,
      allowNull: false,
    },
    Cantidad: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    Producto_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: Producto,
        key: "idProducto",
      },
    },
    Proveedor_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: Proveedor,
        key: "idProveedor",
      },
    },
    Persona_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: Persona,
        key: "idPersona",
      },
    },
  },
  {
    sequelize,
    modelName: "Entrada",
    tableName: "Entradas",
    timestamps: false,
  }
);

export default Entrada;
