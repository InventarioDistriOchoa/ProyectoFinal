import { Model, DataTypes } from "sequelize";
import sequelize from "../config/connect.db.js";

class TipoDocumento extends Model {}

TipoDocumento.init(
  {
    idTipo_Documento: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    Descripcion: {
      type: DataTypes.STRING(25),
      allowNull: false,
      unique: true,
    },
  },
  {
    sequelize,
    modelName: "TipoDocumento",
    tableName: "Tipo_Documento",
    timestamps: false,
  }
);

export default TipoDocumento;
