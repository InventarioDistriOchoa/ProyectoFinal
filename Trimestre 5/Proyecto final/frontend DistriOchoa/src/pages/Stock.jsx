// src/pages/Stock.jsx
import { useEffect, useState, useRef, useMemo } from "react";
import { useNavigate } from "react-router-dom";
import Swal from "sweetalert2";
import "bootstrap/dist/css/bootstrap.min.css";
import "bootstrap/dist/js/bootstrap.bundle.min.js";
import "../assets/styles.css";
import { 
  BiHome, BiBox, BiUser, BiCategory, BiLogOut, BiFile, BiUndo, BiLineChart 
} from "react-icons/bi";

export default function Stock() {
  const navigate = useNavigate();
  const sidebarRef = useRef(null);
  const [nombre, setNombre] = useState("");
  const [rol, setRol] = useState("");
  const [sidebarVisible, setSidebarVisible] = useState(false);
  const [foto, setFoto] = useState("/uploads/default-avatar.png");
  const [stockData, setStockData] = useState([]);

  // --- Buscadores y paginación ---
  const [searchNombre, setSearchNombre] = useState("");
  const [searchId, setSearchId] = useState("");
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 10;

  // --- Traer datos de perfil ---
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

  // --- Traer stock ---
  useEffect(() => {
    const fetchStock = async () => {
      try {
        const token = localStorage.getItem("token");
        const res = await fetch("http://localhost:3001/api/stock", {
          headers: { Authorization: `Bearer ${token}` },
        });
        if (!res.ok) throw new Error("Error al cargar el stock");
        const data = await res.json();
        setStockData(data.body || []);
      } catch (err) {
        console.error(err);
        Swal.fire("Error", "No se pudo cargar el stock", "error");
      }
    };
    fetchStock();
  }, []);

  const cerrarSesion = async () => {
    try {
      const token = localStorage.getItem("token");
      await fetch("http://localhost:3001/api/persona/logout", {
        method: "POST",
        headers: { Authorization: `Bearer ${token}` },
      });
    } catch {}
    localStorage.clear();
    Swal.fire({ icon: "success", title: "Sesión cerrada ✅", confirmButtonColor: "#198754" })
      .then(() => navigate("/select-role", { replace: true }));
  };

  const mostrarModuloUsuarios = rol === "admin" || rol === "superadmin";

  // --- Sidebar completo ---
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

  // --- Cerrar sidebar al clic fuera ---
  useEffect(() => {
    const handleClickOutside = (e) => {
      if (sidebarRef.current && !sidebarRef.current.contains(e.target)) {
        setSidebarVisible(false);
      }
    };
    if (sidebarVisible) document.addEventListener("mousedown", handleClickOutside);
    else document.removeEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [sidebarVisible]);

  const getEstadoColor = (estado) => {
    if (estado === "verde") return "#28a745";
    if (estado === "amarillo") return "#ffc107";
    if (estado === "rojo") return "#dc3545";
    return "#6c757d";
  };

  // --- Filtrar datos ---
  const filteredStock = useMemo(() => {
    return stockData.filter(item => 
      item.producto.toLowerCase().includes(searchNombre.toLowerCase()) &&
      item.id.toString().includes(searchId)
    );
  }, [stockData, searchNombre, searchId]);

  // --- Paginación ---
  const totalPages = Math.ceil(filteredStock.length / itemsPerPage);
  const paginatedStock = filteredStock.slice(
    (currentPage - 1) * itemsPerPage,
    currentPage * itemsPerPage
  );

  return (
    <div className="min-vh-100 d-flex flex-column usuarios-background">
      {sidebarVisible && <div className="position-fixed top-0 start-0 w-100 h-100" style={{ background: "rgba(0,0,0,0.3)", zIndex: 1900 }} />}

      {/* Sidebar */}
      <div
        ref={sidebarRef}
        className="position-fixed top-0 start-0 vh-100 bg-white shadow p-3 d-flex flex-column gap-3"
        style={{ width: "240px", transform: sidebarVisible ? "translateX(0)" : "translateX(-100%)", transition: "transform 0.3s ease-in-out", zIndex: 2000 }}
        onMouseLeave={() => setSidebarVisible(false)}
      >
        {sidebarItems.map((item, i) => (
          <button
            key={i}
            onClick={() => { item.action(); setSidebarVisible(false); }}
            className="d-flex align-items-center gap-2 p-2 rounded shadow-sm border-0 bg-light text-dark"
            style={{ cursor: "pointer", transition: "all 0.2s", marginTop: i === 0 ? "4rem" : "0" }}
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
        <div></div>
        <div className="text-center flex-grow-1">
          <div className="fw-bold" style={{ fontSize: "2rem", color: "#198754" }}>👋 Hola {nombre}</div>
          <div style={{ fontSize: "1.1rem" }}>
            {rol === "admin" && <>Eres <strong>Admin</strong> 🛠️</>}
            {rol === "superadmin" && <>Eres <strong>Superadmin</strong> 👑</>}
            {rol !== "admin" && rol !== "superadmin" && <>Rol: {rol}</>}
          </div>
        </div>
        <div className="header-right d-flex align-items-center gap-3">
          <div className="dropdown">
            <button className="btn p-0 border-0 bg-transparent dropdown-toggle" type="button" data-bs-toggle="dropdown">
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

      {/* Contenido stock */}
      <main className="dashboard stock-screen flex-grow-1 py-4 px-3">
        <div className="card-tabla mx-auto" style={{ maxWidth: 1200 }}>
          <h2 className="text-center mb-3">📦 Stock de Productos</h2>

          {/* Buscadores */}
          <div className="d-flex justify-content-between mb-3 gap-2">
            <input
              type="text"
              className="form-control"
              placeholder="Buscar por nombre"
              value={searchNombre}
              onChange={(e) => { setCurrentPage(1); setSearchNombre(e.target.value); }}
            />
            <input
              type="text"
              className="form-control"
              placeholder="Buscar por ID"
              value={searchId}
              onChange={(e) => { setCurrentPage(1); setSearchId(e.target.value); }}
            />
          </div>

          <div className="tabla-responsive">
            <table className="table table-bordered table-striped">
              <thead className="table-success text-center">
                <tr>
                  <th>ID</th>
                  <th>Producto</th>
                  <th>Estado</th>
                  <th>Categoría</th>
                  <th>Disponible</th>
                  <th>Entradas</th>
                  <th>Salidas</th>
                  <th>Devoluciones Proveedor</th>
                  <th>Devoluciones Cliente</th>
                </tr>
              </thead>
              <tbody>
                {paginatedStock.length === 0 ? (
                  <tr>
                    <td colSpan={9} className="text-center">No hay productos en stock</td>
                  </tr>
                ) : (
                  paginatedStock.map((item) => (
                    <tr key={item.id}>
                      <td>{item.id}</td>
                      <td>{item.producto}</td>
                      <td className="text-center">
                        <span style={{
                          display: "inline-block",
                          width: "15px",
                          height: "15px",
                          borderRadius: "50%",
                          backgroundColor: getEstadoColor(item.estado)
                        }}></span>
                      </td>
                      <td>{item.categoria || "Sin categoría"}</td>
                      <td>{item.disponible}</td>
                      <td>{item.entradas}</td>
                      <td>{item.salidas}</td>
                      <td>{item.devolucionesProveedor || 0}</td>
                      <td>{item.devolucionesCliente || 0}</td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>

    {/* Paginación */}
{totalPages > 1 && (
  <nav className="mt-3">
    <ul className="pagination justify-content-center">
      <li className={`page-item ${currentPage === 1 ? "disabled" : ""}`}>
        <button 
          className="page-link" 
          style={{ color: "#198754", borderColor: "#198754" }}
          onClick={() => setCurrentPage(currentPage - 1)}
        >
          Anterior
        </button>
      </li>
      {Array.from({ length: totalPages }, (_, i) => (
        <li key={i} className={`page-item ${currentPage === i + 1 ? "active" : ""}`}>
          <button 
            className="page-link" 
            style={{ 
              color: currentPage === i + 1 ? "white" : "#198754",
              backgroundColor: currentPage === i + 1 ? "#198754" : "white",
              borderColor: "#198754"
            }}
            onClick={() => setCurrentPage(i + 1)}
          >
            {i + 1}
          </button>
        </li>
      ))}
      <li className={`page-item ${currentPage === totalPages ? "disabled" : ""}`}>
        <button 
          className="page-link" 
          style={{ color: "#198754", borderColor: "#198754" }}
          onClick={() => setCurrentPage(currentPage + 1)}
        >
          Siguiente
        </button>
      </li>
    </ul>
  </nav>
)}

        </div>
      </main>

      {/* Footer */}
      <footer className="footer-dashboard mt-auto py-3 text-center" style={{ backgroundColor: "transparent" }}>
        © 2025 <strong>DistriOchoa</strong>. Todos los derechos reservados.
      </footer>
    </div>
  );
}
