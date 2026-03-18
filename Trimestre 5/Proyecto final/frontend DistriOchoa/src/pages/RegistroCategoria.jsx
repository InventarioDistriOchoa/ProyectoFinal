// src/pages/GestionCategorias.jsx
import { useState, useEffect, useRef } from "react";
import { useNavigate } from "react-router-dom";
import Swal from "sweetalert2";
import "bootstrap/dist/css/bootstrap.min.css";
import "bootstrap/dist/js/bootstrap.bundle.min.js";
import "bootstrap-icons/font/bootstrap-icons.css";
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
  BiPencil,
  BiTrash,
} from "react-icons/bi";


export default function GestionCategorias() {
  const navigate = useNavigate();
  const sidebarRef = useRef(null);
  const token = localStorage.getItem("token");

  // ---------- Sidebar ----------
  const [sidebarVisible, setSidebarVisible] = useState(false);
  const [usuario, setUsuario] = useState("");
  const [rol, setRol] = useState("");
  const [foto, setFoto] = useState("/uploads/default-avatar.png");

  useEffect(() => {
    setUsuario(localStorage.getItem("nombre") || "");
    setRol((localStorage.getItem("rol") || "").toLowerCase());

    const fetchProfile = async () => {
      try {
        const res = await fetch("http://localhost:3001/api/persona/me", {
          headers: { Authorization: `Bearer ${token}` },
        });
        if (!res.ok) throw new Error("No se pudo cargar el perfil");
        const data = await res.json();
        if (data.body?.Foto) {
          setFoto(
            data.body.Foto.startsWith("http")
              ? data.body.Foto
              : `http://localhost:3001${data.body.Foto}`
          );
        }
      } catch (err) { console.error(err); }
    };
    fetchProfile();
  }, [token]);

  const cerrarSesion = async () => {
    try {
      await fetch("http://localhost:3001/api/persona/logout", {
        method: "POST",
        headers: { Authorization: `Bearer ${token}` },
      });
    } catch (err) { console.error(err); }
    finally {
      localStorage.clear();
      Swal.fire({
        icon: "success",
        title: "Sesión cerrada ✅",
        confirmButtonColor: "#198754",
      }).then(() => navigate("/select-role", { replace: true }));
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
 

  useEffect(() => {
    const handleClickOutside = (e) => {
      if (sidebarRef.current && !sidebarRef.current.contains(e.target))
        setSidebarVisible(false);
    };
    if (sidebarVisible) document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [sidebarVisible]);

  // ---------- Gestión de Categorías ----------
  const [vista, setVista] = useState("registro");
  const [nombreCategoria, setNombreCategoria] = useState("");
  const [descripcion, setDescripcion] = useState("");
  const [categorias, setCategorias] = useState([]);
  const [editCategoria, setEditCategoria] = useState(null);

  // Filtros
  const [filtroNombre, setFiltroNombre] = useState("");
  const [filtroId, setFiltroId] = useState("");

  const fetchCategorias = async () => {
    try {
      const res = await fetch("http://localhost:3001/api/categoria/categoria", {
        headers: { Authorization: `Bearer ${token}` },
      });
      const data = await res.json();
      setCategorias(data.body || []);
    } catch (err) {
      console.error(err);
      Swal.fire("Error", "No se pudieron cargar las categorías", "error");
    }
  };
  useEffect(() => { fetchCategorias(); }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (nombreCategoria.trim().length < 3)
      return Swal.fire("Error", "El nombre debe tener al menos 3 caracteres", "warning");

    const nuevaCategoria = { Nombre_Categoria: nombreCategoria, Descripcion: descripcion };
    try {
      const res = await fetch("http://localhost:3001/api/categoria/categoria", {
        method: "POST",
        headers: { "Content-Type": "application/json", Authorization: `Bearer ${token}` },
        body: JSON.stringify(nuevaCategoria),
      });
      const data = await res.json();
      if (res.ok) {
        Swal.fire("¡Éxito!", "Categoría registrada correctamente", "success");
        fetchCategorias();
        setNombreCategoria(""); setDescripcion("");
      } else Swal.fire("Error", data.Message || "No se pudo registrar", "error");
    } catch { Swal.fire("Error", "No se pudo registrar", "error"); }
  };

  const handleEliminar = async (id) => {
    const cat = categorias.find(c => c.idCategoria === id);
    const { isConfirmed } = await Swal.fire({
      title: "¿Eliminar categoría?",
      html: `
        La categoría <b>${cat?.Nombre_Categoria || ""}</b> podría tener productos relacionados.<br/>
        Si continúas, esos productos quedarán con la categoría <b>"No seleccionada"</b>.
      `,
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#d33",
      cancelButtonColor: "#6c757d",
      confirmButtonText: "Sí, eliminar",
      cancelButtonText: "Cancelar",
    });

    if (!isConfirmed) return;

    try {
      await fetch(`http://localhost:3001/api/categoria/categoria/${id}`, {
        method: "DELETE",
        headers: { Authorization: `Bearer ${token}` },
      });
      Swal.fire("Eliminado", "Categoría eliminada correctamente", "success");
      fetchCategorias();
    } catch {
      Swal.fire("Error", "No se pudo eliminar la categoría", "error");
    }
  };


  const abrirModalEditar = (cat) => setEditCategoria({ ...cat });

  // Filtro doble
const categoriasFiltradas = (categorias || []).filter(c =>
  (c.Nombre_Categoria || "").toLowerCase().includes(filtroNombre.toLowerCase()) &&
  (filtroId === "" || String(c.idCategoria) === filtroId)
);


  // Función para imagen según categoría
  const iconoCategoria = (nombre) => {
    const n = nombre.toLowerCase();
    if (n.includes("frutas")) return "/img/frutas.png";
    if (n.includes("verduras")) return "/img/verduras.png";
    if (n.includes("hierbas")) return "/img/hierbas.png";
    if (n.includes("legumbres")) return "/img/legumbres.png";
    return "/img/default.png";
  };

  // Carrusel refs
  const carruselRef = useRef(null);
 const scrollLeft = () => { carruselRef.current?.scrollBy({ left: -300, behavior: "smooth" }); };
const scrollRight = () => { carruselRef.current?.scrollBy({ left: 300, behavior: "smooth" }); };

  return (
    <div className="RegistroUsuarios min-vh-100 position-relative myprofile-background">
      {sidebarVisible && <div className="position-fixed top-0 start-0 w-100 h-100"
        style={{ background: "rgba(0,0,0,0.3)", zIndex: 1900 }} />}

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
          <button key={i}
            onClick={() => { item.action(); setSidebarVisible(false); }}
            className="d-flex align-items-center gap-2 p-2 rounded shadow-sm border-0 bg-light text-dark"
            style={{ cursor: "pointer", marginTop: i === 0 ? "4rem" : "0" }}
          >
            {item.icon} <span>{item.label}</span>
          </button>
        ))}
      </div>

      <button
        id="btn-toggle-sidebar"
        className="btn btn-light position-fixed top-3 start-3"
        style={{ zIndex: 2100 }}
        onClick={() => setSidebarVisible(!sidebarVisible)}
      >
        &#9776;
      </button>

      {/* Header transparente */}
      <header
        className="dashboard-header-top d-flex align-items-center px-4 py-2 position-relative"
        style={{ backgroundColor: "transparent" }}
      >
        <div className="header-left">
          <img src="/img/logo.png" className="logo-top me-2" alt="Logo" />
        </div>
        <div className="header-center position-absolute top-50 start-50 translate-middle text-center">
          <div className="app-name" style={{ color: "#198754", fontWeight: "bold", fontSize: "1.9rem" }}>
            Gestión de Categorías
          </div>
        </div>
        <div className="header-right d-flex align-items-center gap-3 ms-auto">
          <div className="dropdown">
            <button className="btn p-0 border-0 bg-transparent dropdown-toggle" type="button"
              id="perfilDropdown" data-bs-toggle="dropdown" aria-expanded="false">
              <img src={foto} alt="Perfil" className="rounded-circle"
                style={{ width: 40, height: 40, objectFit: "cover", border: "2px solid #198754" }} />
            </button>
            <ul className="dropdown-menu dropdown-menu-end" aria-labelledby="perfilDropdown">
              <li><button className="dropdown-item" onClick={() => navigate("/my-profile")}>Mi Perfil</button></li>
              <li><button className="dropdown-item" onClick={() => navigate("/dashboard")}>Volver al Inicio</button></li>
              <li><hr className="dropdown-divider" /></li>
              <li><button className="dropdown-item" onClick={cerrarSesion}>Cerrar sesión</button></li>
            </ul>
          </div>
        </div>
      </header>

      {/* Contenido */}
      <div className="container mt-4 px-3 pt-5">
        {/* Selector de vista */}
        <div className="d-flex justify-content-center gap-2 mb-4" style={{ marginTop: "-10px" }}>
          <button className={`btn ${vista === "registro" ? "btn-success" : "btn-outline-success"}`} onClick={() => setVista("registro")}>Registro</button>
          <button className={`btn ${vista === "listado" ? "btn-success" : "btn-outline-success"}`} onClick={() => setVista("listado")}>Listado</button>
        </div>

        {/* REGISTRO */}
        {vista === "registro" && (
          <div className="d-flex justify-content-center">
            <div className="card shadow-lg p-4 rounded-5" style={{ maxWidth: "700px", width: "100%" }}>
              <h4 className="text-center mb-4" style={{ color: "#198754" }}>Registro de Categoría</h4>
              <form onSubmit={handleSubmit} className="row g-3">
                <div className="col-md-6">
                  <label className="form-label">Nombre Categoría</label>
                  <input type="text" className="form-control rounded-3 shadow-sm"
                    value={nombreCategoria} onChange={e => setNombreCategoria(e.target.value)} required />
                </div>
                <div className="col-md-6">
                  <label className="form-label">Descripción</label>
                  <input type="text" className="form-control rounded-3 shadow-sm"
                    value={descripcion} onChange={e => setDescripcion(e.target.value)} />
                </div>
                <div className="col-12 d-flex justify-content-center mt-3">
                  <button type="submit" className="btn btn-success btn-lg rounded-4 px-5 shadow-sm">Registrar</button>
                </div>
              </form>
            </div>
          </div>
        )}

      {/* LISTADO con carrusel y doble filtro */}
{vista === "listado" && (
  <>
    {/* Filtros */}
    <div className="row mb-3">
      <div className="col-md-6 mb-2">
        <input
          type="text"
          className="form-control"
          placeholder="Buscar por nombre de categoría..."
          value={filtroNombre}
          onChange={e => setFiltroNombre(e.target.value)}
        />
      </div>
      <div className="col-md-6">
        <input
          type="text"
          className="form-control"
          placeholder="Buscar por ID..."
          value={filtroId}
          onChange={e => setFiltroId(e.target.value)}
        />
      </div>
    </div>

    {/* Carrusel */}
    <div className="position-relative">
      <button
        className="btn btn-light position-absolute top-50 start-0 translate-middle-y"
        onClick={scrollLeft}
        style={{ zIndex: 5 }}
      >
        ‹
      </button>

      <div
        ref={carruselRef}
        className="d-flex overflow-auto gap-3 pb-3 px-4"
        style={{ scrollBehavior: "smooth" }}
      >
        {categoriasFiltradas.length === 0 && (
          <p className="text-muted">No hay categorías que coincidan.</p>
        )}

        {categoriasFiltradas.map((c) => (
          <div
            key={c.idCategoria}
            className="card shadow-sm text-center p-3"
            style={{
              minWidth: "220px",
              maxWidth: "220px",      // ancho fijo
              borderRadius: "20px",
              flex: "0 0 auto",
              display: "flex",
              flexDirection: "column",
              justifyContent: "space-between"
            }}
          >
            <img
              src={iconoCategoria(c.Nombre_Categoria)}
              alt="icono"
              style={{
                width: "80px",
                height: "80px",
                objectFit: "contain",
                margin: "0 auto 10px"
              }}
            />
            <h6 className="mb-1">{c.Nombre_Categoria}</h6>
            <p
              className="text-muted small mb-2"
              style={{
                whiteSpace: "pre-line", // respeta saltos de línea
                wordBreak: "break-word",
                textAlign: "justify",
                overflowY: "auto",      // scroll si es muy largo
                maxHeight: "60px",      // altura máxima
                marginBottom: "0.5rem"
              }}
            >
              {c.Descripcion || "Sin descripción"}
            </p>
            <div className="d-flex justify-content-center gap-3 mt-auto">
              <span
                className="text-primary"
                style={{ cursor: "pointer", fontSize: "1.3rem" }}
                title="Editar"
                onClick={() => abrirModalEditar(c)}
              >
                <BiPencil />
              </span>
              <span
                className="text-danger"
                style={{ cursor: "pointer", fontSize: "1.3rem" }}
                title="Eliminar"
                onClick={() => handleEliminar(c.idCategoria)}
              >
                <BiTrash />
              </span>
            </div>
          </div>
        ))}
      </div>

      <button
        className="btn btn-light position-absolute top-50 end-0 translate-middle-y"
        onClick={scrollRight}
        style={{ zIndex: 5 }}
      >
        ›
      </button>
    </div>
  </>
)}



        {/* MODAL EDITAR */}
        {editCategoria && (
          <div className="modal fade show d-block" tabIndex="-1" style={{ backgroundColor: "rgba(0,0,0,0.3)" }}>
            <div className="modal-dialog modal-dialog-centered">
              <div className="modal-content">
                <form
                  onSubmit={async (e) => {
                    e.preventDefault();
                    try {
                      const res = await fetch(
                        `http://localhost:3001/api/categoria/categoria/${editCategoria.idCategoria}`,
                        {
                          method: "PUT",
                          headers: {
                            "Content-Type": "application/json",
                            Authorization: `Bearer ${token}`,
                          },
                          body: JSON.stringify({
                            Nombre_Categoria: editCategoria.Nombre_Categoria,
                            Descripcion: editCategoria.Descripcion,
                          }),
                        }
                      );
                      const data = await res.json();
                      if (res.ok) {
                        Swal.fire("Éxito", "Categoría actualizada", "success");
                        fetchCategorias();
                        setEditCategoria(null);
                      } else Swal.fire("Error", data.Message || "No se pudo actualizar", "error");
                    } catch {
                      Swal.fire("Error", "No se pudo actualizar", "error");
                    }
                  }}
                >
                  <div className="modal-header">
                    <h5 className="modal-title">Editar Categoría</h5>
                    <button type="button" className="btn-close" onClick={() => setEditCategoria(null)}></button>
                  </div>
                  <div className="modal-body">
                    <div className="mb-3">
                      <label className="form-label">Nombre Categoría</label>
                      <input type="text" className="form-control"
                        value={editCategoria.Nombre_Categoria}
                        onChange={e => setEditCategoria(prev => ({ ...prev, Nombre_Categoria: e.target.value }))}
                        required />
                    </div>
                    <div className="mb-3">
                      <label className="form-label">Descripción</label>
                      <input type="text" className="form-control"
                        value={editCategoria.Descripcion}
                        onChange={e => setEditCategoria(prev => ({ ...prev, Descripcion: e.target.value }))} />
                    </div>
                  </div>
                  <div className="modal-footer">
                    <button type="button" className="btn btn-secondary" onClick={() => setEditCategoria(null)}>Cancelar</button>
                    <button type="submit" className="btn btn-primary">Guardar Cambios</button>
                  </div>
                </form>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
