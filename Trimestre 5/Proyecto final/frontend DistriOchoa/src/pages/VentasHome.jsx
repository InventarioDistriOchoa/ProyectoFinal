// src/pages/VentasHome.jsx
import { useEffect, useState, useRef, useMemo } from "react";
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

export default function VentasHome() {
  const navigate = useNavigate();
  const sidebarRef = useRef(null);
  const [sidebarVisible, setSidebarVisible] = useState(false);
  const [nombre, setNombre] = useState("");
  const [rol, setRol] = useState("");
  const [foto, setFoto] = useState("/uploads/default-avatar.png");

  // ----- Cargar usuario -----
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

  // ----- Cerrar sesión -----
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

  // ----- Sidebar dinámico -----
  const sidebarItems = useMemo(() => {
    const mostrarModuloUsuarios = rol === "admin" || rol === "superadmin";
    return [
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
  }, [rol, navigate]);

  // ----- Cerrar sidebar al click fuera -----
  useEffect(() => {
    const handleClickOutside = (event) => {
      if (sidebarRef.current && !sidebarRef.current.contains(event.target)) {
        setSidebarVisible(false);
      }
    };
    if (sidebarVisible) document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [sidebarVisible]);

  return (
    <div className="min-vh-100 d-flex flex-column usuarios-background">
      {/* Overlay */}
      {sidebarVisible && (
        <div
          className="position-fixed top-0 start-0 w-100 h-100"
          style={{ background: "rgba(0,0,0,0.3)", zIndex: 1900 }}
        />
      )}

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
      >
        {sidebarItems.map((item, index) => (
          <button
            key={index}
            onClick={() => {
              item.action();
              setSidebarVisible(false);
            }}
            className="d-flex align-items-center gap-2 p-2 rounded shadow-sm border-0 bg-light text-dark"
            style={{ cursor: "pointer", marginTop: index === 0 ? "4rem" : 0 }}
          >
            {item.icon} <span>{item.label}</span>
          </button>
        ))}
      </div>

      {/* Botón hamburguesa */}
      <button
        id="btn-toggle-sidebar"
        onClick={() => setSidebarVisible(!sidebarVisible)}
        className="btn btn-light position-fixed top-3 start-3"
        style={{ zIndex: 2100 }}
      >
        &#9776;
      </button>

      {/* Header */}
      <header className="dashboard-header-top d-flex justify-content-between align-items-center px-4 py-2" style={{ background: "transparent" }}>
        <div className="text-center flex-grow-1">
          <div className="fw-bold" style={{ fontSize: "2rem", color: "#198754" }}>
            🛒 Módulo Ventas
          </div>
          <div className="usuario-header mt-1">
            Hola <strong>{nombre}</strong> ({rol})
          </div>
        </div>
        <div className="dropdown">
          <button
            className="btn p-0 border-0 bg-transparent dropdown-toggle"
            type="button"
            id="perfilDropdown"
            data-bs-toggle="dropdown"
            aria-expanded="false"
          >
            <img
              src={`http://localhost:3001${foto}`}
              alt="Perfil"
              className="rounded-circle"
              style={{ width: "40px", height: "40px", objectFit: "cover", border: "2px solid #198754" }}
            />
          </button>
          <ul className="dropdown-menu dropdown-menu-end" aria-labelledby="perfilDropdown">
            <li>
              <button className="dropdown-item" onClick={() => navigate("/my-profile")}>
                Mi Perfil
              </button>
            </li>
            <li>
              <button className="dropdown-item" onClick={() => navigate("/dashboard")}>
                Volver al Inicio
              </button>
            </li>
            <li><hr className="dropdown-divider" /></li>
            <li>
              <button className="dropdown-item" onClick={cerrarSesion}>
                Cerrar sesión
              </button>
            </li>
          </ul>
        </div>
      </header>

      {/* Contenido principal */}
      <main className="dashboard py-4 flex-grow-1">
        <div className="fila-opciones justify-content-center">
          <div
            className="opcion tarjeta-dashboard"
            onClick={() => navigate("/registro-venta")}
          >
            <img
              src="/img/icon-venta.png"
              alt="Registrar Venta"
              style={{ width: "80px", height: "80px" }}
            />
            <p>Registrar Venta</p>
          </div>

          <div
            className="opcion tarjeta-dashboard"
            onClick={() => navigate("/registro-detalle-venta")}
          >
            <img
              src="/img/icon-detalle-venta.png"
              alt="Registrar Detalle Venta"
              style={{ width: "80px", height: "80px" }}
            />
            <p>Registrar Detalle Venta</p>
          </div>
        </div>
      </main>

      <footer className="footer-dashboard mt-auto py-3 text-center">
        © 2025 <strong>DistriOchoa</strong>. Todos los derechos reservados.
      </footer>
    </div>
  );
}
