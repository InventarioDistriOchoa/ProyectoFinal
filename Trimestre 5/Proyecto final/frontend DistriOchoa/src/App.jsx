// App.jsx
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import SelectRole from "./pages/SelectRole";
import Login from "./pages/Login";
import Dashboard from "./pages/dashboard";
import ResetPassword from "./pages/ResetPassword";

// Productos
import RegistroProducto from "./pages/RegistroProducto";
import ListaProductos from "./pages/ListaProductos";

// Entradas
import RegistroEntrada from "./pages/RegistroEntrada";
import ListaEntradas from "./pages/ListaEntradas";

// Categorías
import RegistroCategoria from "./pages/RegistroCategoria";

// Usuarios
import UsuariosHome from "./pages/UsuariosHome";
import RegistroUsuarios from "./pages/RegistroUsuarios";

// Proveedores / Roles / Tipo Documento
import GestionProveedores from "./pages/GestionProveedores";
import GestionRoles from "./pages/GestionRoles";
import GestionTipoDoc from "./pages/GestionTipoDoc";

// Perfil
import MyProfile from "./pages/MyProfile";
import AuthWatcher from "./pages/AuthWatcher";

// 🟢 Ventas
import VentasHome from "./pages/VentasHome";
import RegistroVenta from "./pages/RegistroVentas";
import RegistroDetalleVenta from "./pages/RegistroDetalleVenta";

// 🟣 Devoluciones
import DevolucionesHome from "./pages/DevolucionesHome";
import RegistroDevolucion from "./pages/RegistroDevolucion";
import RegistroTipoDevolucion from "./pages/RegistroTipoDevolucion";

// 📊 Reportes (nuevo)
import Reportes from "./pages/Reportes";

// 📦 Stock (nuevo) 
import Stock from "./pages/Stock";

export default function App() {
  return (
    <Router>
      <AuthWatcher timeoutInMinutes={45} />

      <Routes>
        {/* Rutas públicas */}
        <Route path="/" element={<SelectRole />} />
        <Route path="/select-role" element={<SelectRole />} />
        <Route path="/login" element={<Login />} />

        {/* Rutas privadas */}
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/reset-password" element={<ResetPassword />} />

        {/* Productos */}
        <Route path="/registro-productos" element={<RegistroProducto />} />
        <Route path="/lista-productos" element={<ListaProductos />} />

        {/* Entradas */}
        <Route path="/registro-entradas" element={<RegistroEntrada />} />
        <Route path="/lista-entradas" element={<ListaEntradas />} />

        {/* Categorías */}
        <Route path="/categorias" element={<RegistroCategoria />} />

        {/* Usuarios */}
        <Route path="/usuarios" element={<UsuariosHome />} />
        <Route path="/registro-usuarios" element={<RegistroUsuarios />} />

        {/* Proveedores / Roles / Tipo Documento */}
        <Route path="/proveedores" element={<GestionProveedores />} />
        <Route path="/roles" element={<GestionRoles />} />
        <Route path="/tipo-documento" element={<GestionTipoDoc />} />

        {/* Perfil */}
        <Route path="/my-profile" element={<MyProfile />} />

        {/* 🟢 Ventas */}
        <Route path="/ventas" element={<VentasHome />} />
        <Route path="/registro-venta" element={<RegistroVenta />} />
        <Route path="/registro-detalle-venta" element={<RegistroDetalleVenta />} />

        {/* 🟣 Devoluciones */}
        <Route path="/devoluciones" element={<DevolucionesHome />} />
        <Route path="/registro-devolucion" element={<RegistroDevolucion />} />
        <Route path="/registro-tipo-devolucion" element={<RegistroTipoDevolucion />} />

        {/* 📊 Reportes */}
        <Route path="/reportes" element={<Reportes />} />

        {/* 📦 Stock */}
        <Route path="/stock" element={<Stock />} />



      </Routes>
    </Router>
  );
};



