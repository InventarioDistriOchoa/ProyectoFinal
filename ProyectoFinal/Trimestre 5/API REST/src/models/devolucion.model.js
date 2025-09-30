import { Model, DataTypes } from "sequelize";
import sequelize from "../config/connect.db.js";
import Producto from "./producto.model.js";
import Persona from "./persona.model.js";
import TipoDevolucion from "./tipoDevolucion.model.js";

class Devolucion extends Model {}

Devolucion.init(
  {
    idDevolucion: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    Fecha: {
      type: DataTypes.DATE,
      allowNull: false,
    },
    Motivo: {
      type: DataTypes.STRING(200),
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
    Persona_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: Persona,
        key: "idPersona",
      },
    },
    TipoDevolucion_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: TipoDevolucion,
        key: "idTipoDevolucion",
      },
    },
  },
  {
    sequelize,
    modelName: "Devolucion",
    tableName: "Devolucion",
    timestamps: false,
  }
);

export default Devolucion;
