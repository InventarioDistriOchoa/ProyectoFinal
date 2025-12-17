// src/models/persona.model.js
import { Model, DataTypes } from "sequelize";
import sequelize from "../config/connect.db.js";
import TipoDocumento from "./tipoDocumento.model.js";
import Rol from "./rol.model.js";

class Persona extends Model {}

Persona.init(
  {
    idPersona: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    Nombre: {
      type: DataTypes.STRING(100),
      allowNull: false,
    },
    Correo: {
      type: DataTypes.STRING(100),
      allowNull: false,
      unique: true,
      validate: { isEmail: true },
    },
    Contrasena: {
      type: DataTypes.STRING(100),
      allowNull: false,
    },
    Numero_Documento: {
      type: DataTypes.STRING(50),
      allowNull: false,
      unique: true,
    },
    Tipo_Documento_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: TipoDocumento,
        key: "idTipo_Documento",
      },
    },
    Rol_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: Rol,
        key: "idRol",
      },
    },

    Foto: {
      type: DataTypes.STRING,
      allowNull: true,
    },

    resetToken: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    resetExpires: {
      type: DataTypes.DATE,
      allowNull: true,
    },
  },
  {
    sequelize,
    modelName: "Persona",
    tableName: "Persona",
    timestamps: false,
  }
);

/* 🔥 ASOCIACIONES (muy útil para las auditorías y consultas) */
Persona.belongsTo(TipoDocumento, {
  foreignKey: "Tipo_Documento_id",
  as: "TipoDocumento"
});

Persona.belongsTo(Rol, {
  foreignKey: "Rol_id",
  as: "Rol"
});

export default Persona;
