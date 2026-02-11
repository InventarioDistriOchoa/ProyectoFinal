// utils/registrarAuditoria.js
import Auditoria from "../models/auditoria.model.js";

export const registrarAuditoria = async ({
  usuario,
  accion,
  coleccion,
  documentoId,
  datosAnteriores,
  datosNuevos,
  ip,
}) => {
  console.log("🔎 ACCION RECIBIDA:", accion);

  await Auditoria.create({
    usuario,
    accion,
    coleccion,
    documentoId,
    datosAnteriores, // 👈 ya es un objeto
    datosNuevos,     // 👈 ya es un objeto
    ip,
  });
};
