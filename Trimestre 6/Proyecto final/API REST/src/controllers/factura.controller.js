// src/controllers/factura.controller.js
import PDFDocument from "pdfkit";

import Venta from "../models/venta.model.js";
import DetalleVenta from "../models/detalleVenta.model.js";
import Producto from "../models/producto.model.js";
import Persona from "../models/persona.model.js";
import TipoDocumento from "../models/tipoDocumento.model.js";
import Rol from "../models/rol.model.js";

// Asegúrate de que las asociaciones estén cargadas en algún punto de tu app:
// Venta.belongsTo(Persona, { foreignKey: "Persona_id", as: "Responsable" });
// Venta.hasMany(DetalleVenta, { foreignKey: "Venta_id", as: "DetalleVentas" });
// DetalleVenta.belongsTo(Producto, { foreignKey: "Producto_id", as: "Producto" });

const formatMoney = (value) =>
  new Intl.NumberFormat("es-CO", {
    style: "currency",
    currency: "COP",
    minimumFractionDigits: 0,
  }).format(Number(value || 0));

export const generarFactura = async (req, res) => {
  try {
    const { idVenta } = req.params;

    const venta = await Venta.findByPk(idVenta, {
      include: [
        {
          model: DetalleVenta,
          as: "DetalleVentas",
          include: [
            {
              model: Producto,
              as: "Producto",
            },
          ],
        },
        {
          model: Persona,
          as: "Responsable",
          attributes: [
            "idPersona",
            "Nombre",
            "Correo",
            "Numero_Documento",
            "Foto",
            "Tipo_Documento_id",
            "Rol_id",
          ],
          include: [
            {
              model: TipoDocumento,
              as: "TipoDocumento",
              attributes: ["Descripcion"],
            },
            {
              model: Rol,
              as: "Rol",
              attributes: ["Descripcion_Rol"],
            },
          ],
        },
      ],
    });

    if (!venta) {
      return res.status(404).json({ message: "La venta no existe." });
    }

    const responsable = venta.Responsable;
    const tipoDoc = responsable?.TipoDocumento?.Descripcion || "";
    const rol = responsable?.Rol?.Descripcion_Rol || "";
    const fechaVenta = new Date(venta.Fecha).toLocaleString("es-CO", {
      dateStyle: "short",
      timeStyle: "short",
    });

    // ==============================
    //   CREACIÓN DEL PDF
    // ==============================
    const doc = new PDFDocument({ size: "A4", margin: 40 });

    res.setHeader("Content-Type", "application/pdf");
    res.setHeader(
      "Content-Disposition",
      `inline; filename=factura_${idVenta}.pdf`
    );

    doc.pipe(res);

    // ------------------------------
    //  ENCABEZADO EMPRESA
    // ------------------------------
    doc
      .fontSize(22)
      .fillColor("#198754")
      .text("DistriOchoa", { align: "left" });

    doc
      .moveDown(0.3)
      .fontSize(10)
      .fillColor("#000000")
      .text("EMPRESA DISTRIOCHOA S.A.S")
      .text("NIT: 123.456.789-0")
      .text("Dirección: Calle 123 #45-67, Bogotá")
      .text("Teléfono: (+57) 300 000 0000")
      .text("Correo: contacto@distriochoa.com");

    // Cuadro de datos de la factura a la derecha
    doc
      .fontSize(12)
      .font("Helvetica-Bold")
      .text(`Factura N°: ${venta.idVenta}`, 350, 50, { align: "left" })
      .font("Helvetica")
      .fontSize(10)
      .text(`Fecha: ${fechaVenta}`, 350, 70)
      .text(`Total: ${formatMoney(venta.Total)}`, 350, 85);

    doc
      .moveTo(40, 120)
      .lineTo(550, 120)
      .strokeColor("#cccccc")
      .stroke();

    // ------------------------------
    //  DATOS DEL RESPONSABLE
    // ------------------------------
    doc.moveDown(1.5);
    doc
      .fontSize(12)
      .font("Helvetica-Bold")
      .text("Datos del responsable", { underline: true });

    doc.moveDown(0.5).fontSize(10).font("Helvetica");

    doc.text(`Nombre: ${responsable?.Nombre || "-"}`);
    doc.text(
      `Documento: ${tipoDoc || ""} ${
        responsable?.Numero_Documento || "No registrado"
      }`
    );
    doc.text(`Correo: ${responsable?.Correo || "-"}`);
    doc.text(`Rol: ${rol || "-"}`);

    doc.moveDown(1);

    // ------------------------------
    //  DETALLE DE PRODUCTOS
    // ------------------------------
    doc
      .fontSize(12)
      .font("Helvetica-Bold")
      .text("Detalle de productos", { underline: true });

    doc.moveDown(0.5);

    const tableTop = doc.y + 5;
    const colX = {
      producto: 40,
      cantidad: 260,
      unitario: 320,
      subtotal: 420,
    };

    // Encabezados de la tabla
    doc.fontSize(10).font("Helvetica-Bold");
    doc.text("Producto", colX.producto, tableTop);
    doc.text("Cant.", colX.cantidad, tableTop, { width: 40, align: "right" });
    doc.text("Vlr Unit.", colX.unitario, tableTop, {
      width: 80,
      align: "right",
    });
    doc.text("Subtotal", colX.subtotal, tableTop, {
      width: 100,
      align: "right",
    });

    doc
      .moveTo(40, tableTop + 12)
      .lineTo(550, tableTop + 12)
      .strokeColor("#198754")
      .stroke();

    // Filas de la tabla
    let y = tableTop + 18;
    doc.font("Helvetica").fontSize(10);

    let totalCalculado = 0;

    venta.DetalleVentas.forEach((detalle) => {
      const producto = detalle.Producto;
      const nombreProd = producto?.Nombre || `Producto ID ${detalle.Producto_id}`;

      totalCalculado += Number(detalle.Subtotal || 0);

      doc.text(nombreProd, colX.producto, y, { width: 210 });
      doc.text(String(detalle.Cantidad), colX.cantidad, y, {
        width: 40,
        align: "right",
      });
      doc.text(formatMoney(detalle.PrecioUnitario), colX.unitario, y, {
        width: 80,
        align: "right",
      });
      doc.text(formatMoney(detalle.Subtotal), colX.subtotal, y, {
        width: 100,
        align: "right",
      });

      y += 18;

      // Nueva página si nos pasamos
      if (y > 720) {
        doc.addPage();
        y = 40;
      }
    });

    // ------------------------------
    //  RESUMEN / TOTALES
    // ------------------------------
    doc.moveTo(40, y + 5).lineTo(550, y + 5).strokeColor("#cccccc").stroke();

    doc
      .font("Helvetica-Bold")
      .fontSize(11)
      .text("Total calculado:", 350, y + 15, { width: 100, align: "left" })
      .text(formatMoney(totalCalculado), 450, y + 15, {
        width: 100,
        align: "right",
      });

    doc
      .fontSize(11)
      .text("Total registrado:", 350, y + 32, { width: 100, align: "left" })
      .text(formatMoney(venta.Total), 450, y + 32, {
        width: 100,
        align: "right",
      });

    // Mensaje final
    doc.moveDown(4);
    doc
      .fontSize(10)
      .font("Helvetica-Oblique")
      .fillColor("#555555")
      .text(
        "Gracias por su compra. Para cambios o devoluciones conserve este comprobante.",
        { align: "center" }
      );

    doc.end();
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Error generando factura." });
  }
};
