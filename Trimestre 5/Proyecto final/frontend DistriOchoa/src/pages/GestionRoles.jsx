import { useState, useEffect, useRef } from "react";
import { useNavigate } from "react-router-dom";
import Swal from "sweetalert2";
import "bootstrap/dist/css/bootstrap.min.css";
import "bootstrap/dist/js/bootstrap.bundle.min.js";
import "bootstrap-icons/font/bootstrap-icons.css";
import "../assets/styles.css";
import { BiHome, BiUser, BiLogOut, BiPencil, BiTrash, BiFile, BiCategory, BiBox } from "react-icons/bi";

export default function GestionRoles() {
  const navigate = useNavigate();
  const sidebarRef = useRef(null);
  const token = localStorage.getItem("token");

  // ---------- Sidebar ----------
  const [sidebarVisible, setSidebarVisible] = useState(false);
  const [usuario, setUsuario] = useState("");
  const [rolUsuario, setRolUsuario] = useState("");
  const [foto, setFoto] = useState("/uploads/default-avatar.png");
  const mostrarModuloUsuarios = true;

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

    setUsuario(storedNombre);
    setRolUsuario(storedRol.toLowerCase());

    const fetchProfile = async () => {
      try {
        const res = await fetch("http://localhost:3001/api/persona/me", {
          headers: { Authorization: `Bearer ${token}` },
        });
        if (!res.ok) throw new Error("No se pudo cargar el perfil");
        const data = await res.json();
        if (data.body?.Foto) {
          setFoto(data.body.Foto.startsWith("http") ? data.body.Foto : `http://localhost:3001${data.body.Foto}`);
        }
      } catch (err) {
        console.error(err);
      }
    };
    fetchProfile();
  }, [navigate, token]);

  const cerrarSesion = async () => {
    try {
      await fetch("http://localhost:3001/api/persona/logout", {
        method: "POST",
        headers: { Authorization: `Bearer ${token}` },
      });
    } catch (err) {
      console.error(err);
    } finally {
      localStorage.clear();
      Swal.fire({ icon: "success", title: "Sesión cerrada ✅", confirmButtonColor: "#198754" })
        .then(() => {
          navigate("/select-role", { replace: true });
          window.history.pushState(null, "", "/select-role");
          window.onpopstate = () => window.history.pushState(null, "", "/select-role");
        });
    }
  };

  // ---------- Sidebar items completos ----------
  const sidebarItems = [
    { label: "Inicio", icon: <BiHome />, action: () => navigate("/dashboard") },
    { label: "Registrar Producto", icon: <BiFile />, action: () => navigate("/registro-productos") },
    { label: "Registrar Salida", icon: <BiFile />, action: () => navigate("/registro-salidas") },
    { label: "Reportes", icon: <BiFile />, action: () => navigate("/reportes") },
    { label: "Stock", icon: <BiBox />, action: () => navigate("/stock") },
    { label: "Categorías", icon: <BiCategory />, action: () => navigate("/categorias") },
    { label: "Devoluciones", icon: <BiFile />, action: () => navigate("/devoluciones") },

    ...(mostrarModuloUsuarios ? [{ label: "Usuarios", icon: <BiUser />, action: () => navigate("/usuarios") }] : []),
    { label: "Proveedores", icon: <BiFile />, action: () => navigate("/proveedores") },
    { label: "Tipo Documento", icon: <BiFile />, action: () => navigate("/tipo-documento") },
    { label: "Crear Usuarios", icon: <BiUser />, action: () => navigate("/registro-usuarios") },

    { label: "Mi Perfil", icon: <BiUser />, action: () => navigate("/my-profile") },
    { label: "Salir", icon: <BiLogOut />, action: cerrarSesion },
  ];

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (sidebarRef.current && !sidebarRef.current.contains(event.target)) setSidebarVisible(false);
    };
    if (sidebarVisible) document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [sidebarVisible]);

  // ---------- Gestión de Roles ----------
  const [vista, setVista] = useState("registro");
  const [descripcionRol, setDescripcionRol] = useState("");
  const [roles, setRoles] = useState([]);
  const [editRol, setEditRol] = useState(null);

  const getIconoRol = (descripcionRol) => {
    switch (descripcionRol.toLowerCase()) {
      case "admin": return "/img/icon-admin.png";
      case "superadmin": return "/img/icon-superadmin.png";
      case "auxiliar": return "/img/icon-usuario.png";
      default: return "/img/icon-default.png";
    }
  };

  useEffect(() => {
    const fetchRoles = async () => {
      try {
        const res = await fetch("http://localhost:3001/api/rol/rol", {
          headers: { Authorization: `Bearer ${token}` },
        });
        const data = await res.json();
        setRoles(data.body || []);
      } catch (err) {
        console.error(err);
        Swal.fire("Error", "No se pudieron cargar los roles", "error");
      }
    };
    fetchRoles();
  }, [token]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (descripcionRol.trim().length < 3) return Swal.fire("Error", "La descripción debe tener al menos 3 caracteres", "warning");

    const nuevoRol = { Descripcion_Rol: descripcionRol };
    try {
      const res = await fetch("http://localhost:3001/api/rol/rol", {
        method: "POST",
        headers: { "Content-Type": "application/json", Authorization: `Bearer ${token}` },
        body: JSON.stringify(nuevoRol),
      });
      const data = await res.json();
      if (res.ok) {
        Swal.fire("¡Éxito!", "Rol creado correctamente", "success");
        setRoles(prev => [...prev, { ...nuevoRol, idRol: data.body.idRol }]);
        setDescripcionRol("");
      } else Swal.fire("Error", data.message || "No se pudo crear", "error");
    } catch (err) {
      console.error(err);
      Swal.fire("Error", "No se pudo crear", "error");
    }
  };

  const handleEliminar = async (id) => {
    const confirm = await Swal.fire({ title: "¿Eliminar este rol?", icon: "warning", showCancelButton: true, confirmButtonText: "Sí, eliminar", cancelButtonText: "Cancelar" });
    if (confirm.isConfirmed) {
      try {
        const res = await fetch(`http://localhost:3001/api/rol/rol/${id}`, { method: "DELETE", headers: { Authorization: `Bearer ${token}` } });
        const data = await res.json();
        if (res.ok) {
          setRoles(prev => prev.filter(r => r.idRol !== id));
          Swal.fire("Eliminado", "Rol eliminado correctamente", "success");
        } else Swal.fire("No se pudo eliminar", data.message || "Error desconocido", "error");
      } catch (err) {
        console.error(err);
        Swal.fire("Error", "No se pudo eliminar", "error");
      }
    }
  };

  const abrirModalEditar = (rol) => setEditRol({ ...rol });

  return (
    <div className="RegistroUsuarios min-vh-100 position-relative myprofile-background">
      {sidebarVisible && <div className="position-fixed top-0 start-0 w-100 h-100" style={{ background: "rgba(0,0,0,0.3)", zIndex: 1900 }} />}

     {/* Sidebar */}
<div
  ref={sidebarRef}
  className="position-fixed top-0 start-0 vh-100 bg-white shadow p-3 d-flex flex-column"
  style={{
    width: "240px",
    transform: sidebarVisible ? "translateX(0)" : "translateX(-100%)",
    transition: "transform 0.3s ease-in-out",
    zIndex: 2000,
  }}
  onMouseLeave={() => setSidebarVisible(false)}
>
 {/* Contenedor scrollable */}
<div
  className="d-flex flex-column gap-3 sidebar-scroll"
  style={{
    flexGrow: 1,
    overflowY: "auto",
    paddingRight: "5px",
  }}
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

</div>

      <button id="btn-toggle-sidebar" className="btn btn-light position-fixed top-3 start-3" style={{ zIndex: 2100 }} onClick={() => setSidebarVisible(!sidebarVisible)}>
        &#9776;
      </button>

      {/* Header */}
      <header className="dashboard-header-top d-flex align-items-center px-4 py-2 position-relative" style={{ backgroundColor: "transparent" }}>
        <div className="header-left">
          <img src="/img/logo.png" className="logo-top me-2" alt="Logo" />
        </div>
        <div className="header-center position-absolute top-50 start-50 translate-middle text-center">
          <div className="app-name" style={{ color: "#198754", fontWeight: "bold", fontSize: "1.9rem" }}>Gestión de Roles</div>
        </div>
        <div className="header-right d-flex align-items-center gap-3 ms-auto">
          <div className="dropdown">
            <button className="btn p-0 border-0 bg-transparent dropdown-toggle" type="button" id="perfilDropdown" data-bs-toggle="dropdown" aria-expanded="false">
              <img src={foto} alt="Perfil" className="rounded-circle" style={{ width: "40px", height: "40px", objectFit: "cover", border: "2px solid #198754" }} />
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

      {/* Contenido principal */}
      <div className="container mt-4 px-3 pt-5">
        {/* Selector de vista */}
        <div className="d-flex justify-content-center gap-2 mb-4" style={{ marginTop: "-10px" }}>
          <button className={`btn ${vista === "registro" ? "btn-success" : "btn-outline-success"}`} onClick={() => setVista("registro")}>Registro</button>
          <button className={`btn ${vista === "listado" ? "btn-success" : "btn-outline-success"}`} onClick={() => setVista("listado")}>Listado</button>
        </div>

        {/* VISTA REGISTRO */}
        {vista === "registro" && (
          <div className="d-flex justify-content-center">
            <div className="card shadow-lg p-4 rounded-5" style={{ maxWidth: "500px", width: "100%" }}>
              <h4 className="text-center mb-4" style={{ color: "#198754" }}>Registro de Rol</h4>
              <form onSubmit={handleSubmit} className="row g-3">
                <div className="col-12">
                  <label className="form-label">Descripción del Rol</label>
                  <input type="text" className="form-control rounded-3 shadow-sm" value={descripcionRol} onChange={e => setDescripcionRol(e.target.value)} required />
                </div>
                <div className="col-12 d-flex justify-content-center mt-3">
                  <button type="submit" className="btn btn-success btn-lg rounded-4 px-5 shadow-sm">Registrar</button>
                </div>
              </form>
            </div>
          </div>
        )}

        {/* VISTA LISTADO */}
        {vista === "listado" && (
          <div className="row">
            {roles.length === 0 ? (
              <p className="text-center text-muted">No hay roles registrados.</p>
            ) : (
              roles.map((r, index) => (
                <div className="col-md-6 col-lg-4 mb-3" key={index}>
                  <div className="card shadow-sm h-100 text-center">
                    <div className="card-body d-flex flex-column align-items-center">
                      <img 
                        src={getIconoRol(r.Descripcion_Rol)} 
                        alt={r.Descripcion_Rol} 
                        style={{ width: "60px", height: "60px", marginBottom: "10px" }}
                      />
                      <h6 className="card-title mb-2">{r.Descripcion_Rol}</h6>
                      <div className="d-flex justify-content-center gap-3 mt-auto">
                        <span className="text-primary" style={{ cursor: "pointer", fontSize: "1.2rem" }} title="Editar" onClick={() => abrirModalEditar(r)}><BiPencil /></span>
                        <span className="text-danger" style={{ cursor: "pointer", fontSize: "1.2rem" }} title="Eliminar" onClick={() => handleEliminar(r.idRol)}><BiTrash /></span>
                      </div>
                    </div>
                  </div>
                </div>
              ))
            )}
          </div>
        )}

        {/* MODAL EDITAR */}
        {editRol && (
          <div className="modal fade show d-block" tabIndex="-1" style={{ backgroundColor: "rgba(0,0,0,0.3)" }}>
            <div className="modal-dialog modal-dialog-centered">
              <div className="modal-content">
                <form
                  onSubmit={async (e) => {
                    e.preventDefault();
                    try {
                      const res = await fetch(`http://localhost:3001/api/rol/rol/${editRol.idRol}`, {
                        method: "PUT",
                        headers: { "Content-Type": "application/json", Authorization: `Bearer ${token}` },
                        body: JSON.stringify({ Descripcion_Rol: editRol.Descripcion_Rol }),
                      });
                      const data = await res.json();
                      if (res.ok) {
                        Swal.fire("Éxito", "Rol actualizado", "success");
                        setRoles(prev => prev.map(r => r.idRol === editRol.idRol ? editRol : r));
                        setEditRol(null);
                      } else Swal.fire("Error", data.message || "No se pudo actualizar", "error");
                    } catch (err) {
                      console.error(err);
                      Swal.fire("Error", "No se pudo actualizar", "error");
                    }
                  }}
                >
                  <div className="modal-header">
                    <h5 className="modal-title">Editar Rol</h5>
                    <button type="button" className="btn-close" onClick={() => setEditRol(null)}></button>
                  </div>
                  <div className="modal-body">
                    <div className="mb-3">
                      <label className="form-label">Descripción del Rol</label>
                      <input type="text" className="form-control" value={editRol.Descripcion_Rol} onChange={e => setEditRol(prev => ({ ...prev, Descripcion_Rol: e.target.value }))} required />
                    </div>
                  </div>
                  <div className="modal-footer">
                    <button type="button" className="btn btn-secondary" onClick={() => setEditRol(null)}>Cancelar</button>
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
