// Dashboard.jsx
import { useEffect, useState, useRef } from "react";
import { useNavigate } from "react-router-dom";
import Swal from "sweetalert2";
import "bootstrap/dist/css/bootstrap.min.css";
import "bootstrap/dist/js/bootstrap.bundle.min.js";
import "../assets/styles.css";
import {
  BiHome,
  BiBox,
  BiUser,
  BiCategory,
  BiLogOut,
  BiFile,
  BiUndo,
  BiLineChart,
} from "react-icons/bi";

export default function Dashboard() {
  const navigate = useNavigate();
  const sidebarRef = useRef(null);
  const [nombre, setNombre] = useState("");
  const [rol, setRol] = useState("");
  const [sidebarVisible, setSidebarVisible] = useState(false);
  const [foto, setFoto] = useState("/uploads/default-avatar.png");

  // --- Proteger la página contra token inexistente ---
  useEffect(() => {
    const token = localStorage.getItem("token");
    if (!token) {
      navigate("/select-role", { replace: true });
      return;
    }

    const storedNombre = localStorage.getItem("nombre");
    const storedRol = localStorage.getItem("rol");

    if (!storedNombre || !storedRol) {
      navigate("/select-role", { replace: true });
      return;
    }

    setNombre(storedNombre);
    setRol(storedRol.toLowerCase());

    // Traer la foto del usuario
    const fetchProfile = async () => {
      try {
        const res = await fetch("http://localhost:3001/api/persona/me", {
          headers: { Authorization: `Bearer ${token}` },
        });
        if (!res.ok) throw new Error("No se pudo cargar el perfil");
        const data = await res.json();
        if (data.body?.Foto) setFoto(data.body.Foto);
      } catch (err) {
        console.error(err);
      }
    };
    fetchProfile();
  }, [navigate]);

  const cerrarSesion = async () => {
    const token = localStorage.getItem("token");
    try {
      await fetch("http://localhost:3001/api/persona/logout", {
        method: "POST",
        headers: { Authorization: `Bearer ${token}` },
      });
    } catch (err) {
      console.error(err);
    } finally {
      localStorage.clear();
      Swal.fire({
        icon: "success",
        title: "Sesión cerrada ✅",
        confirmButtonColor: "#198754",
      }).then(() => {
        navigate("/select-role", { replace: true });

        // Bloquear el botón atrás
        window.history.pushState(null, "", "/select-role");
        window.onpopstate = () =>
          window.history.pushState(null, "", "/select-role");
      });
    }
  };

  const mostrarModuloUsuarios = rol === "admin" || rol === "superadmin";

  // ✅ Sidebar limpio con solo rutas principales (sin subformularios)
  const sidebarItems = [
    { label: "Inicio", icon: <BiHome />, action: () => navigate("/dashboard") },
    { label: "Productos", icon: <BiFile />, action: () => navigate("/lista-productos") },
    { label: "Entradas", icon: <BiFile />, action: () => navigate("/lista-entradas") },
    { label: "Ventas", icon: <BiFile />, action: () => navigate("/ventas") },
    { label: "Devoluciones", icon: <BiUndo />, action: () => navigate("/devoluciones") },
    { label: "Categorías", icon: <BiCategory />, action: () => navigate("/categorias") },
    { label: "Stock", icon: <BiBox />, action: () => navigate("/stock") },
    { label: "Reportes", icon: <BiLineChart />, action: () => navigate("/reportes") },
    ...(mostrarModuloUsuarios
      ? [{ label: "Usuarios", icon: <BiUser />, action: () => navigate("/usuarios") }]
      : []),
    { label: "Mi Perfil", icon: <BiUser />, action: () => navigate("/my-profile") },
    { label: "Salir", icon: <BiLogOut />, action: cerrarSesion },
  ];

  // --- Cerrar sidebar al hacer clic fuera ---
  useEffect(() => {
    const handleClickOutside = (event) => {
      if (sidebarRef.current && !sidebarRef.current.contains(event.target)) {
        setSidebarVisible(false);
      }
    };
    if (sidebarVisible) {
      document.addEventListener("mousedown", handleClickOutside);
    } else {
      document.removeEventListener("mousedown", handleClickOutside);
    }
    return () =>
      document.removeEventListener("mousedown", handleClickOutside);
  }, [sidebarVisible]);

  return (
    <div className="min-vh-100 d-flex flex-column">
      {sidebarVisible && (
        <div
          className="position-fixed top-0 start-0 w-100 h-100"
          style={{ background: "rgba(0,0,0,0.3)", zIndex: 1900 }}
        />
      )}

      {/* Sidebar flotante */}
      <div
        ref={sidebarRef}
        className="position-fixed top-0 start-0 vh-100 bg-white shadow p-3 d-flex flex-column gap-3"
        style={{
          width: "240px",
          transform: sidebarVisible ? "translateX(0)" : "translateX(-100%)",
          transition: "transform 0.3s ease-in-out",
          zIndex: 2000,
        }}
        onMouseLeave={() => setSidebarVisible(false)}
      >
        {sidebarItems.map((item, index) => (
          <button
            key={index}
            onClick={() => {
              item.action();
              setSidebarVisible(false);
            }}
            className="d-flex align-items-center gap-2 p-2 rounded shadow-sm border-0 bg-light"
            style={{ cursor: "pointer", marginTop: index === 0 ? "4rem" : "0" }}
            onMouseEnter={(e) =>
              (e.currentTarget.style.backgroundColor = "#e2f0ff")
            }
            onMouseLeave={(e) =>
              (e.currentTarget.style.backgroundColor = "#f8f9fa")
            }
          >
            {item.icon} <span>{item.label}</span>
          </button>
        ))}
      </div>

      {/* Botón hamburguesa */}
      <button
        id="btn-toggle-sidebar"
        onClick={() => setSidebarVisible(!sidebarVisible)}
      >
        &#9776;
      </button>

    {/* Header */}
<header className="dashboard-header-top d-flex justify-content-between align-items-center px-4 py-2">
  <div className="header-left d-flex align-items-center">
    <img src="/img/logo.png" className="logo-top me-2" alt="Logo" />
  </div>

  <div className="header-center text-center flex-grow-1 d-flex flex-column align-items-center">
    <div className="app-name">DistriOchoa</div>
    <div className="usuario-header">{nombre} ({rol})</div>
  </div>

  <div className="header-right d-flex align-items-center gap-3">
    <div className="dropdown">
      <button
        className="btn p-0 border-0 bg-transparent dropdown-toggle"
        type="button"
        id="perfilDropdown"
        data-bs-toggle="dropdown"
        aria-expanded="false"
        style={{
          outline: "none",
          boxShadow: "none",
          backgroundColor: "transparent",
        }}
      >
        <img
          src={foto ? `http://localhost:3001${foto}` : "/uploads/default-avatar.png"}
          alt="Perfil"
          className="rounded-circle"
          style={{
            width: "40px",
            height: "40px",
            objectFit: "cover",
            border: "2px solid #198754",
          }}
          onError={(e) => (e.currentTarget.src = "/uploads/default-avatar.png")}
        />
      </button>
      <ul className="dropdown-menu dropdown-menu-end" aria-labelledby="perfilDropdown">
        <li>
          <button
            className="dropdown-item"
            onClick={() => navigate("/my-profile")}
            style={{
              backgroundColor: "transparent",
              color: "inherit",
            }}
            onMouseDown={(e) => (e.currentTarget.style.backgroundColor = "#198754")}
            onMouseUp={(e) => (e.currentTarget.style.backgroundColor = "transparent")}
            onMouseLeave={(e) => (e.currentTarget.style.backgroundColor = "transparent")}
          >
            Mi Perfil
          </button>
        </li>
        <li><hr className="dropdown-divider" /></li>
        <li>
          <button
            className="dropdown-item"
            onClick={cerrarSesion}
            style={{
              backgroundColor: "transparent",
              color: "inherit",
            }}
            onMouseDown={(e) => (e.currentTarget.style.backgroundColor = "#198754")}
            onMouseUp={(e) => (e.currentTarget.style.backgroundColor = "transparent")}
            onMouseLeave={(e) => (e.currentTarget.style.backgroundColor = "transparent")}
          >
            Cerrar sesión
          </button>
        </li>
      </ul>
    </div>
  </div>
</header>


      {/* Opciones del dashboard */}
      <main className="dashboard py-4 flex-grow-1">
       <div className="fila-opciones justify-content-center">
  <div className="opcion tarjeta-dashboard" onClick={() => navigate("/registro-productos")}>
    <img src="/img/icon-productos.png" alt="Registrar productos" />
    <p>Registrar productos</p>
  </div>
  <div className="opcion tarjeta-dashboard" onClick={() => navigate("/lista-productos")}>
    <img src="/img/lista-productos.png" alt="Ver lista de productos" />
    <p>Ver lista de productos</p>
  </div>
  <div className="opcion tarjeta-dashboard" onClick={() => navigate("/registro-entradas")}>
    <img src="/img/icon-entradas.png" alt="Registrar Entradas" />
    <p>Registrar Entradas</p>
  </div>
  <div className="opcion tarjeta-dashboard" onClick={() => navigate("/lista-entradas")}>
    <img src="/img/lista-entradas.png" alt="Ver Entradas" />
    <p>Ver Entradas</p>
  </div>
  <div className="opcion tarjeta-dashboard" onClick={() => navigate("/stock")}>
    <img src="/img/icon-stock.png" alt="Stock" />
    <p>Stock</p>
  </div>
  {/* Si tienes permisos de admin/superadmin */}
  {mostrarModuloUsuarios && (
    <div className="opcion tarjeta-dashboard" onClick={() => navigate("/usuarios")}>
      <img src="/img/icon-usuarios.png" alt="Registrar Usuarios" />
      <p>Registrar Usuarios</p>
    </div>
  )}
  <div className="opcion tarjeta-dashboard" onClick={() => navigate("/reportes")}>
    <img src="/img/icon-reportes.png" alt="Reportes" />
    <p>Reportes</p>
  </div>
  <div className="opcion tarjeta-dashboard" onClick={() => navigate("/ventas")}>
    <img src="/img/icon-salidas.png" alt="Registrar Salidas" />
    <p>Registrar Salidas</p>
  </div>
  <div className="opcion tarjeta-dashboard" onClick={() => navigate("/devoluciones")}>
    <img src="/img/icon-devoluciones.png" alt="Registrar Devoluciones" />
    <p>Registrar Devoluciones</p>
  </div>
  <div className="opcion tarjeta-dashboard" onClick={() => navigate("/categorias")}>
    <img src="/img/icono-categorias.png" alt="Categorías" />
    <p>Categorías</p>
  </div>
</div>
      </main>

      <footer className="footer-dashboard mt-auto py-3 text-center">
        © 2025 <strong>DistriOchoa</strong>. Todos los derechos reservados.
      </footer>
    </div>
  );
}
