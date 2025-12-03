import { useState, useEffect, useRef } from "react";
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
  BiListCheck,
} from "react-icons/bi";

export default function RegistroEntrada() {
  const navigate = useNavigate();
  const sidebarRef = useRef(null);
  const token = localStorage.getItem("token");

  // ---------------------------------------------------------------------------
  // Fecha por defecto
  // ---------------------------------------------------------------------------
  const [fecha, setFecha] = useState(() => {
    const hoy = new Date();
    const yyyy = hoy.getFullYear();
    const mm = String(hoy.getMonth() + 1).padStart(2, "0");
    const dd = String(hoy.getDate()).padStart(2, "0");
    return `${yyyy}-${mm}-${dd}`;
  });

  const [cantidad, setCantidad] = useState("");
  const [producto, setProducto] = useState("");
  const [proveedor, setProveedor] = useState("");
  const [productos, setProductos] = useState([]);
  const [proveedores, setProveedores] = useState([]);
  const [usuario, setUsuario] = useState("");
  const [rol, setRol] = useState("");
  const [sidebarVisible, setSidebarVisible] = useState(false);

  // ---------------------------------------------------------------------------
  // Traer perfil actual desde la API
  // ---------------------------------------------------------------------------
  useEffect(() => {
    if (!token) return;

    const fetchProfile = async () => {
      try {
        const res = await fetch("http://localhost:3001/api/persona/me", {
          headers: { Authorization: `Bearer ${token}` },
        });
        const data = await res.json();
        if (res.ok) {
          setUsuario(data.body.Nombre || "");
          setRol((data.body.Rol || "").toLowerCase());
        }
      } catch (err) {
        console.error("No se pudo cargar el perfil", err);
      }
    };

    fetchProfile();
  }, [token]);

  // ---------------------------------------------------------------------------
  // Productos y proveedores
  // ---------------------------------------------------------------------------
  useEffect(() => {
    if (!token) return;

    const fetchProductos = async () => {
      try {
        const res = await fetch("http://localhost:3001/api/producto/producto", {
          headers: { Authorization: `Bearer ${token}` },
        });
        const data = await res.json();
        setProductos(data.body || []);
      } catch {
        Swal.fire("Error", "No se pudieron cargar los productos", "error");
      }
    };

    const fetchProveedores = async () => {
      try {
        const res = await fetch("http://localhost:3001/api/proveedor/proveedor", {
          headers: { Authorization: `Bearer ${token}` },
        });
        const data = await res.json();
        setProveedores(data.body || []);
      } catch {
        Swal.fire("Error", "No se pudieron cargar los proveedores", "error");
      }
    };

    fetchProductos();
    fetchProveedores();
  }, [token]);

  // ---------------------------------------------------------------------------
  // Redirigir si no hay token
  // ---------------------------------------------------------------------------
  useEffect(() => {
    if (!token) navigate("/select-role", { replace: true });
  }, [token, navigate]);

  // ---------------------------------------------------------------------------
  // Cerrar sesión
  // ---------------------------------------------------------------------------
  const cerrarSesion = async () => {
    try {
      await fetch("http://localhost:3001/api/persona/logout", {
        method: "POST",
        headers: { Authorization: `Bearer ${token}` },
      });
    } catch {}
    finally {
      localStorage.clear();
      Swal.fire({
        icon: "success",
        title: "Sesión cerrada ✅",
        confirmButtonColor: "#198754",
      }).then(() => navigate("/select-role", { replace: true }));
    }
  };

  // ---------------------------------------------------------------------------
  // Sidebar limpio (solo rutas principales)
  // ---------------------------------------------------------------------------
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

  // ---------------------------------------------------------------------------
  // Registrar entrada
  // ---------------------------------------------------------------------------
  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!fecha || !cantidad || !producto || !proveedor) {
      Swal.fire("Error", "Todos los campos son obligatorios", "error");
      return;
    }

    const nuevaEntrada = {
      Fecha: fecha,
      Cantidad: parseInt(cantidad, 10),
      Producto_id: parseInt(producto, 10),
      Proveedor_id: parseInt(proveedor, 10),
    };

    try {
      const res = await fetch("http://localhost:3001/api/entrada/entrada", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(nuevaEntrada),
      });
      const data = await res.json();
      if (res.ok) {
        Swal.fire({
          title: "¡Entrada Registrada!",
          html: `
            <strong>Fecha:</strong> ${fecha}<br/>
            <strong>Producto:</strong> ${productos.find(p => p.idProducto == producto)?.Nombre || ""}<br/>
            <strong>Cantidad:</strong> ${cantidad}<br/>
            <strong>Proveedor:</strong> ${proveedores.find(pr => pr.idProveedor == proveedor)?.Nombre_Empresa || ""}<br/>
            <strong>Responsable:</strong> ${usuario}
          `,
          icon: "success",
          confirmButtonColor: "#198754",
        });
        setFecha("");
        setCantidad("");
        setProducto("");
        setProveedor("");
      } else {
        Swal.fire("Error", data.message || "No se pudo registrar la entrada", "error");
      }
    } catch (err) {
      console.error(err);
      Swal.fire("Error", "No se pudo registrar la entrada", "error");
    }
  };

  return (
    <div className="min-vh-100 position-relative">
      {/* Fondo oscuro cuando el sidebar está visible */}
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
        onMouseLeave={() => setSidebarVisible(false)}
      >
        {sidebarItems.map((item, i) => (
          <button
            key={i}
            onClick={() => { item.action(); setSidebarVisible(false); }}
            className="d-flex align-items-center gap-2 p-2 rounded shadow-sm border-0 bg-light text-dark"
            style={{
              cursor: "pointer",
              transition: "all 0.2s",
              marginTop: i === 0 ? "4rem" : "0",
            }}
            onMouseEnter={(e) => (e.currentTarget.style.backgroundColor = "#e2f0ff")}
            onMouseLeave={(e) => (e.currentTarget.style.backgroundColor = "#f8f9fa")}
          >
            {item.icon} <span>{item.label}</span>
          </button>
        ))}
      </div>

      {/* Botón toggle sidebar */}
      <button
        id="btn-toggle-sidebar"
        className="btn btn-success position-fixed top-3 start-3"
        style={{ zIndex: 2100 }}
        onClick={() => setSidebarVisible(!sidebarVisible)}
      >
        &#9776;
      </button>

      {/* Contenido principal */}
      <div className="container-fluid px-3 pt-5">
        <div className="row">
          <div className="col-12 col-md-6 d-flex justify-content-center align-items-start mb-4">
            <form onSubmit={handleSubmit} className="w-100" style={{ maxWidth: "500px" }}>
              <img
                src="/img/logo.png"
                alt="Logo"
                className="logo mb-4 d-block mx-auto"
                style={{ height: "80px" }}
              />
              <h1 className="mb-4 text-center fw-bold">Registrar Entrada</h1>

              <div className="mb-3">
                <label className="form-label fw-bold">Fecha</label>
                <input
                  type="date"
                  className="form-control"
                  value={fecha}
                  onChange={(e) => setFecha(e.target.value)}
                  required
                />
              </div>

              <div className="mb-3">
                <label className="form-label fw-bold">Cantidad</label>
                <input
                  type="number"
                  className="form-control"
                  value={cantidad}
                  onChange={(e) => setCantidad(e.target.value)}
                  required
                />
              </div>

              <div className="mb-3">
                <label className="form-label fw-bold">Producto</label>
                <select
                  className="form-select"
                  value={producto}
                  onChange={(e) => setProducto(e.target.value)}
                  required
                >
                  <option value="">Selecciona un producto</option>
                  {productos.map((p) => (
                    <option key={p.idProducto} value={p.idProducto}>
                      {p.Nombre}
                    </option>
                  ))}
                </select>
              </div>

              <div className="mb-3">
                <label className="form-label fw-bold">Proveedor</label>
                <select
                  className="form-select"
                  value={proveedor}
                  onChange={(e) => setProveedor(e.target.value)}
                  required
                >
                  <option value="">Selecciona un proveedor</option>
                  {proveedores.map((pr) => (
                    <option key={pr.idProveedor} value={pr.idProveedor}>
                      {pr.Nombre_Empresa}
                    </option>
                  ))}
                </select>
              </div>

              {/* Responsable autocompletado */}
              <div className="mb-3">
                <label className="form-label fw-bold">Responsable</label>
                <input
                  type="text"
                  className="form-control"
                  value={usuario}
                  readOnly
                />
              </div>

              <button type="submit" className="btn btn-success w-100 mb-3">
                Registrar Entrada
              </button>

              <button
                type="button"
                className="btn btn-success w-100"
                onClick={() => navigate("/lista-entradas")}
              >
                <BiListCheck className="me-2" />
                Ver Lista de Entradas
              </button>
            </form>
          </div>

          <div className="d-none d-md-flex col-md-6 justify-content-center align-items-center">
            <div
              className="card shadow-lg border-0"
              style={{ overflow: "hidden", borderRadius: "20px", maxWidth: "950px" }}
            >
              <img
                src="/img/banner-distriochoa.png"
                alt="Banner"
                className="img-fluid efecto-hover"
                style={{
                  width: "100%",
                  maxHeight: "800px",
                  objectFit: "contain",
                  transition: "transform 0.3s ease-in-out",
                }}
              />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
