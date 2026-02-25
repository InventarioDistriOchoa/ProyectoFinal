import { useEffect, useState, useRef, useMemo } from "react";
import { useNavigate } from "react-router-dom";
import Swal from "sweetalert2";
import {
  BiHome,
  BiBox,
  BiUser,
  BiCategory,
  BiLogOut,
  BiFile,
  BiUndo,
  BiLineChart,
  BiReceipt,
} from "react-icons/bi";
import "bootstrap/dist/css/bootstrap.min.css";
import "../assets/styles.css";

export default function Facturas() {
  const navigate = useNavigate();
  const sidebarRef = useRef(null);

  const [sidebarVisible, setSidebarVisible] = useState(false);
  const [ventas, setVentas] = useState([]);
  const [usuarios, setUsuarios] = useState([]);
  const [filtro, setFiltro] = useState("");
  const token = localStorage.getItem("token");

  const rol = (localStorage.getItem("rol") || "").toLowerCase();

  // --------------------------
  //   Sidebar - Sesión
  // --------------------------

  const cerrarSesion = async () => {
    try {
      await fetch("http://localhost:3001/api/persona/logout", {
        method: "POST",
        headers: { Authorization: `Bearer ${token}` },
      });
    } finally {
      localStorage.clear();
      Swal.fire({
        icon: "success",
        title: "Sesión cerrada",
        confirmButtonColor: "#198754",
      }).then(() => navigate("/select-role", { replace: true }));
    }
  };

  const mostrarModuloUsuarios = rol === "admin" || rol === "superadmin";

  const sidebarItems = [
    { label: "Inicio", icon: <BiHome />, action: () => navigate("/dashboard") },
    { label: "Productos", icon: <BiFile />, action: () => navigate("/lista-productos") },
    { label: "Entradas", icon: <BiFile />, action: () => navigate("/lista-entradas") },
    { label: "Ventas", icon: <BiFile />, action: () => navigate("/ventas") },
    { label: "Devoluciones", icon: <BiUndo />, action: () => navigate("/devoluciones") },
    { label: "Categorías", icon: <BiCategory />, action: () => navigate("/categorias") },
    { label: "Stock", icon: <BiBox />, action: () => navigate("/stock") },
    { label: "Reportes", icon: <BiLineChart />, action: () => navigate("/reportes") },
    { label: "Detalle Venta", icon: <BiBox />, action: () => navigate("/registro-detalle-venta") },
    ...(mostrarModuloUsuarios
      ? [{ label: "Usuarios", icon: <BiUser />, action: () => navigate("/usuarios") }]
      : []),
    { label: "Mi Perfil", icon: <BiUser />, action: () => navigate("/my-profile") },
    { label: "Salir", icon: <BiLogOut />, action: cerrarSesion },
  ];

  useEffect(() => {
    const handleClickOutside = (e) => {
      if (sidebarRef.current && !sidebarRef.current.contains(e.target)) {
        setSidebarVisible(false);
      }
    };
    if (sidebarVisible) document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [sidebarVisible]);

  // --------------------------
  //   Cargar Ventas & Usuarios
  // --------------------------

  useEffect(() => {
    if (token) {
      fetchVentas();
      fetchUsuarios();
    }
  }, [token]);

  const fetchVentas = async () => {
    try {
      const res = await fetch("http://localhost:3001/api/venta/venta", {
        headers: { Authorization: `Bearer ${token}` },
      });
      const data = await res.json();
      setVentas(data.body || []);
    } catch {
      Swal.fire("Error", "No se pudieron cargar las ventas", "error");
    }
  };

  const fetchUsuarios = async () => {
    try {
      const res = await fetch("http://localhost:3001/api/persona/persona", {
        headers: { Authorization: `Bearer ${token}` },
      });
      const data = await res.json();
      setUsuarios(data.body || []);
    } catch {
      Swal.fire("Error", "No se pudieron cargar los usuarios", "error");
    }
  };

  // --------------------------
  //   Abrir PDF con token
  // --------------------------

  const handleVerFacturaPdf = async (idVenta) => {
    try {
      if (!token) {
        return Swal.fire(
          "Sesión expirada",
          "Debes iniciar sesión nuevamente para ver la factura.",
          "warning"
        );
      }

      const res = await fetch(`http://localhost:3001/api/factura/${idVenta}`, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });

      if (!res.ok) {
        return Swal.fire(
          "Error",
          "No se pudo generar la factura. Intenta de nuevo.",
          "error"
        );
      }

      const blob = await res.blob();
      const url = window.URL.createObjectURL(blob);
      window.open(url, "_blank");
    } catch (err) {
      console.error(err);
      Swal.fire("Error", "Hubo un problema al abrir la factura", "error");
    }
  };

  // --------------------------
  //   Filtrar ventas
  // --------------------------

  const ventasFiltradas = useMemo(
    () =>
      ventas.filter((v) => {
        const fecha = new Date(v.Fecha).toISOString().split("T")[0];
        const responsable =
          usuarios.find((u) => u.idPersona === v.Persona_id)?.Nombre || "";

        return (
          fecha.includes(filtro) ||
          responsable.toLowerCase().includes(filtro.toLowerCase()) ||
          v.idVenta.toString().includes(filtro)
        );
      }),
    [ventas, usuarios, filtro]
  );

  // --------------------------
  //   Render
  // --------------------------

  return (
    <div className="min-vh-100 position-relative usuarios-background">
      {/* Overlay */}
      {sidebarVisible && (
        <div
          className="position-fixed w-100 h-100 top-0 start-0"
          style={{ background: "rgba(0,0,0,0.3)", zIndex: 1900 }}
        />
      )}

      {/* Sidebar */}
      <div
        ref={sidebarRef}
        className="position-fixed top-0 start-0 vh-100 bg-white shadow p-3 d-flex flex-column"
        style={{
          width: "240px",
          transform: sidebarVisible ? "translateX(0)" : "translateX(-100%)",
          transition: "0.3s",
          zIndex: 2000,
        }}
      >
        <div className="d-flex flex-column gap-3 sidebar-scroll">
          {sidebarItems.map((item, i) => (
            <button
              key={i}
              onClick={() => {
                item.action();
                setSidebarVisible(false);
              }}
              className="d-flex align-items-center gap-2 p-2 rounded shadow-sm border-0 bg-light text-dark"
              style={{ cursor: "pointer", marginTop: i === 0 ? "4rem" : 0 }}
            >
              {item.icon} <span>{item.label}</span>
            </button>
          ))}
        </div>
      </div>

      {/* Hamburguesa */}
      <button
        className="btn btn-light position-fixed top-3 start-3"
        style={{ zIndex: 2100 }}
        onClick={() => setSidebarVisible(!sidebarVisible)}
      >
        ☰
      </button>

      {/* Header */}
      <header className="text-center py-3">
        <h2 className="fw-bold" style={{ color: "#198754" }}>
          📑 Facturas Registradas
        </h2>
      </header>

      {/* Filtro */}
      <div className="container mb-4">
        <input
          type="text"
          className="form-control mx-auto"
          placeholder="Buscar por fecha, venta o responsable"
          style={{ maxWidth: "500px" }}
          value={filtro}
          onChange={(e) => setFiltro(e.target.value)}
        />
      </div>

      {/* Cards */}
      <div className="container">
        <div className="row g-4">
          {ventasFiltradas.length === 0 ? (
            <p className="text-center">No hay facturas disponibles.</p>
          ) : (
            ventasFiltradas.map((v) => {
              const fecha = new Date(v.Fecha).toISOString().split("T")[0];
              const responsable =
                usuarios.find((u) => u.idPersona === v.Persona_id)?.Nombre ||
                "—";

              return (
                <div key={v.idVenta} className="col-md-4">
                  <div
                    className="shadow-lg p-4 rounded-4"
                    style={{
                      background: "white",
                      borderLeft: "6px solid #198754",
                    }}
                  >
                    <div className="d-flex align-items-center gap-3 mb-3">
                      <BiReceipt
                        style={{ fontSize: "2.5rem", color: "#198754" }}
                      />
                      <h5 className="fw-bold mb-0">Factura #{v.idVenta}</h5>
                    </div>

                    <p>
                      <strong>Fecha:</strong> {fecha}
                    </p>
                    <p>
                      <strong>Total:</strong> ${v.Total}
                    </p>
                    <p>
                      <strong>Responsable:</strong> {responsable}
                    </p>

                    <div className="d-flex justify-content-between mt-3">
                      <button
                        className="btn btn-success"
                        onClick={() => handleVerFacturaPdf(v.idVenta)}
                      >
                        Ver PDF
                      </button>

                      <button
                        className="btn btn-outline-success"
                        onClick={() =>
                          navigate(`/registro-detalle-venta?id=${v.idVenta}`)
                        }
                      >
                        Ver Detalles
                      </button>
                    </div>
                  </div>
                </div>
              );
            })
          )}
        </div>
      </div>

      <footer className="footer-dashboard mt-auto py-3 text-center">
        © 2025 <strong>DistriOchoa</strong>. Todos los derechos reservados.
      </footer>
    </div>
  );
}
