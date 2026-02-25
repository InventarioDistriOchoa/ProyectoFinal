import { DataTypes } from "sequelize";
import sequelize from "../config/connect.db.js";

const Auditoria = sequelize.define(
  "Auditoria",
  {
    idAuditoria: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },

    // FK hacia Persona.idPersona (ajusta el tipo si tu PK es distinto)
    usuario: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },

    coleccion: {
      type: DataTypes.STRING,
      allowNull: false,
    },

    documentoId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },

    accion: {
      type: DataTypes.ENUM("CREATE", "UPDATE", "DELETE", "ACTIVATE"),
      allowNull: false,
    },

    // ✅ Dejamos que Sequelize guarde JSON (objeto) directamente
    datosAnteriores: {
      type: DataTypes.JSON,
      allowNull: true,
    },

    datosNuevos: {
      type: DataTypes.JSON,
      allowNull: true,
    },

    ip: {
      type: DataTypes.STRING,
      allowNull: true,
    },
  },
  {
    tableName: "Auditoria",
    timestamps: true, // createdAt, updatedAt
  }
);

export default Auditoria;
