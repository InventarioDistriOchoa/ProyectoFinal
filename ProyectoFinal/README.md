# 📦 Sistema de Gestión de Inventario – DistriOchoa 🧃

![Estado](https://img.shields.io/badge/Estado-Activo-brightgreen)  
![Tecnologías](https://img.shields.io/badge/Tech-Node.js%20%7C%20React%20%7C%20JS%20%7C%20HTML5%20%7C%20CSS3-blue)  
![Licencia](https://img.shields.io/badge/Licencia-MIT-yellow)

---

## 📖 Descripción  

El **Sistema de Gestión de Inventario DistriOchoa** optimiza el control de productos, ventas, devoluciones y usuarios en una distribuidora de alimentos.  
Basado en **Node.js** (backend) y **React** (frontend), automatiza procesos que antes eran verbales y propensos a errores, mejorando la logística y la toma de decisiones.  

---

## 🧭 Contexto y Justificación  

DistriOchoa carecía de un sistema organizado para registrar entradas y salidas de mercancía, lo que generaba errores y retrasos. Con este proyecto:  
- ✅ Se garantiza un manejo organizado y preciso del inventario.  
- ✅ Se minimizan errores manuales.  
- ✅ Se mejora la visibilidad de stock para planificar compras y reabastecimiento.  

---

## 🚀 Características Principales  

- 🔐 **Autenticación Segura:** Uso de **tokens JWT**, **encriptación de contraseñas con hash** (bcrypt) y validaciones estrictas.  
- 👥 **Gestión de Roles:**  
  - **SuperAdmin:** ÚNICO rol que puede eliminar o crear administradores.  
  - **Administrador:** Puede registrar nuevos usuarios (excepto SuperAdmins) y gestionar inventario.  
  - **Auxiliar:** Puede registrar entradas, salidas y devoluciones, pero sin permisos de administración.  
- 📥 **Entradas de Productos:** Registro de abastecimientos con control automático de stock.  
- 📤 **Ventas y Salidas:** Descuento automático del inventario y asignación de responsables.  
- 🔄 **Devoluciones:** Registro de devoluciones de clientes o proveedores con actualización automática del stock.  
- 📦 **Inventario en Tiempo Real:** Alertas por bajo/exceso de stock y productos próximos a caducar.  
- 📈 **Reportes y Métricas:** Generación de informes de productos más vendidos, historial de movimientos y devoluciones.  
- 🧾 **Historial Completo:** Consultas de entradas, salidas y devoluciones por fecha, producto o usuario.  
- 🎨 **Interfaz Moderna y Responsiva:** Construida con React, HTML5 y CSS3.  

---

## 🗄️ Modelo Relacional  

El sistema está organizado en módulos:  
- **Gestión de Inventario:** Tablas `Productos`, `Categorias`, `Proveedores`, `Entradas`.  
- **Gestión de Ventas:** Tablas `Venta`, `DetalleVenta`.  
- **Gestión de Devoluciones:** Tablas `Devoluciones`, `TipoDevolucion`.  
- **Gestión de Usuarios:** Tablas `Persona`, `Roles`, `Tipo_Documento`.  

🔗 Relaciones destacadas:  
- `Productos` pertenece a una `Categoria` y puede tener múltiples `Entradas` y `Devoluciones`.  
- `Entradas` y `Ventas` se asocian a `Persona` para identificar al responsable.  
- `Roles` define los permisos de cada usuario (SuperAdmin, Administrador, Auxiliar).  



