// src/pages/UsuariosHome.jsx
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

export default function UsuariosHome() {
  const navigate = useNavigate();
  const sidebarRef = useRef(null);
  const [nombre, setNombre] = useState("");
  const [rol, setRol] = useState("");
  const [sidebarVisible, setSidebarVisible] = useState(false);
  const [foto, setFoto] = useState("/uploads/default-avatar.png");

  // --- Obtener datos de usuario y foto ---
  useEffect(() => {
    const storedNombre = localStorage.getItem("nombre");
    const storedRol = localStorage.getItem("rol");

    if (!storedNombre || !storedRol) {
      navigate("/select-role");
      return;
    }
    setNombre(storedNombre);
    setRol(storedRol.toLowerCase());

    const fetchProfile = async () => {
      try {
        const token = localStorage.getItem("token");
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

  // --- Cerrar sesión ---
  const cerrarSesion = async () => {
    try {
      const token = localStorage.getItem("token");
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
      }).then(() => navigate("/select-role", { replace: true }));
    }
  };

  const mostrarModuloUsuarios = rol === "admin" || rol === "superadmin";

  // --- Sidebar items ---
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
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [sidebarVisible]);

  return (
    <div className="min-vh-100 d-flex flex-column usuarios-background">
      {/* Fondo semitransparente */}
      {sidebarVisible && <div className="position-fixed top-0 start-0 w-100 h-100" style={{ background: "rgba(0,0,0,0.3)", zIndex: 1900 }} />}

      {/* Sidebar */}
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
            onClick={() => { item.action(); setSidebarVisible(false); }}
            className="d-flex align-items-center gap-2 p-2 rounded shadow-sm border-0 bg-light text-dark"
            style={{ cursor: "pointer", transition: "all 0.2s", marginTop: index === 0 ? "4rem" : "0" }}
            onMouseEnter={(e) => (e.currentTarget.style.backgroundColor = "#e2f0ff")}
            onMouseLeave={(e) => (e.currentTarget.style.backgroundColor = "#f8f9fa")}
          >
            {item.icon} <span>{item.label}</span>
          </button>
        ))}
      </div>

      {/* Botón hamburguesa */}
      <button
        className="position-fixed m-3 btn btn-success rounded-circle shadow"
        style={{ zIndex: 2100 }}
        onClick={() => setSidebarVisible(!sidebarVisible)}
      >
        &#9776;
      </button>

      {/* Header */}
      <header className="dashboard-header-top d-flex justify-content-between align-items-center px-4 py-2" style={{ backgroundColor: "transparent" }}>
        <div className="header-left"></div>

        <div className="text-center flex-grow-1">
          <div className="fw-bold" style={{ fontSize: "2rem", color: "#198754" }}>👋 Hola {nombre}</div>
          <div className="usuario-header" style={{ fontSize: "1.1rem", marginTop: "0.25rem" }}>
            {rol === "admin" && <>Eres <strong>Admin</strong> 🛠️</>}
            {rol === "superadmin" && <>Eres <strong>Superadmin</strong> 👑</>}
            {rol !== "admin" && rol !== "superadmin" && <>Rol: {rol}</>}
          </div>
        </div>

        {/* Dropdown de perfil */}
        <div className="header-right d-flex align-items-center gap-3">
          <div className="dropdown">
            <button className="btn p-0 border-0 bg-transparent dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
              <img src={`http://localhost:3001${foto}`} alt="Perfil" className="rounded-circle" style={{ width: 40, height: 40, objectFit: "cover", border: "2px solid #198754" }} />
            </button>
            <ul className="dropdown-menu dropdown-menu-end">
              <li><button className="dropdown-item" onClick={() => navigate("/my-profile")}>Mi Perfil</button></li>
              <li><button className="dropdown-item" onClick={() => navigate("/dashboard")}>Volver al Inicio</button></li>
              <li><hr className="dropdown-divider" /></li>
              <li><button className="dropdown-item" onClick={cerrarSesion}>Cerrar sesión</button></li>
            </ul>
          </div>
        </div>
      </header>

      {/* Contenido principal */}
      <main className="dashboard py-4 flex-grow-1">
        <div className="fila-opciones justify-content-center">
          <div className="opcion tarjeta-dashboard" onClick={() => navigate("/roles")}>
            <img src="/img/roles-icono.png" alt="Roles" style={{ width: 80, height: 80 }} />
            <p>Roles</p>
          </div>
          <div className="opcion tarjeta-dashboard" onClick={() => navigate("/proveedores")}>
            <img src="/img/icon-proveedores.png" alt="Proveedores" style={{ width: 80, height: 80 }} />
            <p>Proveedores</p>
          </div>
          <div className="opcion tarjeta-dashboard" onClick={() => navigate("/registro-usuarios")}>
            <img src="/img/icon-usuarios.png" alt="Crear Usuarios" style={{ width: 80, height: 80 }} />
            <p>Crear Usuarios</p>
          </div>
          <div className="opcion tarjeta-dashboard" onClick={() => navigate("/tipo-documento")}>
            <img src="/img/icon-documentos.png" alt="Tipos de Documento" style={{ width: 80, height: 80 }} />
            <p>Tipos de Documento</p>
          </div>
        </div>
      </main>

      <footer className="footer-dashboard mt-auto py-3 text-center"style={{ backgroundColor: "transparent" }}>
        © 2025 <strong>DistriOchoa</strong>. Todos los derechos reservados.
      </footer>
    </div>
  );
}
