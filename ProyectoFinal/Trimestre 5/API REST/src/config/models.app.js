import sequelize from "./connect.db.js";

// Importamos todos los modelos
import Proveedor from "../models/proveedor.model.js";
import Categoria from "../models/categoria.model.js";
import TipoDocumento from "../models/tipoDocumento.model.js";
import Rol from "../models/rol.model.js";
import Persona from "../models/persona.model.js";
import Producto from "../models/producto.model.js";
import Entrada from "../models/entrada.model.js";
import Venta from "../models/venta.model.js";
import DetalleVenta from "../models/detalleVenta.model.js";
import TipoDevolucion from "../models/tipoDevolucion.model.js";
import Devolucion from "../models/devolucion.model.js";

// Definimos relaciones pos de las llaves foraneas

// 📌 Persona con TipoDocumento y Rol
TipoDocumento.hasMany(Persona, { foreignKey: "Tipo_Documento_id" });
Persona.belongsTo(TipoDocumento, { foreignKey: "Tipo_Documento_id" });

Rol.hasMany(Persona, { foreignKey: "Rol_id" });
Persona.belongsTo(Rol, { foreignKey: "Rol_id" });

// 📌 Producto con Categoria
Categoria.hasMany(Producto, { foreignKey: "Categoria_id" });
Producto.belongsTo(Categoria, { foreignKey: "Categoria_id" });

// 📌 Entrada con Producto, Proveedor y Persona
Producto.hasMany(Entrada, { foreignKey: "Producto_id" });
Entrada.belongsTo(Producto, { foreignKey: "Producto_id" });

Proveedor.hasMany(Entrada, { foreignKey: "Proveedor_id" });
Entrada.belongsTo(Proveedor, { foreignKey: "Proveedor_id" });

Persona.hasMany(Entrada, { foreignKey: "Persona_id" });
Entrada.belongsTo(Persona, { foreignKey: "Persona_id" });

// 📌 Venta con Persona
Persona.hasMany(Venta, { foreignKey: "Persona_id" });
Venta.belongsTo(Persona, { foreignKey: "Persona_id" });

// 📌 DetalleVenta con Venta y Producto
Venta.hasMany(DetalleVenta, { foreignKey: "Venta_id" });
DetalleVenta.belongsTo(Venta, { foreignKey: "Venta_id" });

Producto.hasMany(DetalleVenta, { foreignKey: "Producto_id" });
DetalleVenta.belongsTo(Producto, { foreignKey: "Producto_id" });

// 📌 Devolución con Producto, Persona y TipoDevolucion
Producto.hasMany(Devolucion, { foreignKey: "Producto_id" });
Devolucion.belongsTo(Producto, { foreignKey: "Producto_id" });

Persona.hasMany(Devolucion, { foreignKey: "Persona_id" });
Devolucion.belongsTo(Persona, { foreignKey: "Persona_id" });

TipoDevolucion.hasMany(Devolucion, { foreignKey: "TipoDevolucion_id" });
Devolucion.belongsTo(TipoDevolucion, { foreignKey: "TipoDevolucion_id" });

// Función para inicializar modelos
export const modelsApp = async (sync = false) => {
  try {
    if (sync) {
      await sequelize.sync({ force: false }); 
      console.log("✅ Tablas sincronizadas con la BD");
    }
  } catch (error) {
    console.error("❌ Error al sincronizar modelos:", error);
  }
};

export {
  Proveedor,
  Categoria,
  TipoDocumento,
  Rol,
  Persona,
  Producto,
  Entrada,
  Venta,
  DetalleVenta,
  TipoDevolucion,
  Devolucion
};


