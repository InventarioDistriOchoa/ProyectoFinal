import { useState, useEffect, useRef } from "react";
import { useNavigate } from "react-router-dom";
import Swal from "sweetalert2";
import "bootstrap/dist/css/bootstrap.min.css";
import "bootstrap/dist/js/bootstrap.bundle.min.js";
import "bootstrap-icons/font/bootstrap-icons.css";
import "../assets/styles.css";
import { BiHome, BiBox, BiUser, BiCategory, BiLogOut, BiShow, BiHide, BiFile, BiPencil, BiTrash } from "react-icons/bi";

export default function GestionUsuarios() {
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
          setFoto(data.body.Foto.startsWith("http") ? data.body.Foto : `http://localhost:3001${data.body.Foto}`);
        }
      } catch (err) {
        console.error(err);
      }
    };

    fetchProfile();
  }, [token]);

  useEffect(() => {
  if (!token) navigate("/select-role", { replace: true });
}, [token, navigate]);


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
        .then(() => navigate("/select-role", { replace: true }));
    }
  };

  const mostrarModuloUsuarios = rol === "admin" || rol === "superadmin";

  const sidebarItems = [
  { label: "Inicio", icon: <BiHome />, action: () => navigate("/dashboard") },
  { label: "Registrar Producto", icon: <BiFile />, action: () => navigate("/registro-productos") },
  { label: "Registrar Salida", icon: <BiFile />, action: () => navigate("/registro-salidas") },
  { label: "Reportes", icon: <BiFile />, action: () => navigate("/reportes") },
  { label: "Stock", icon: <BiBox />, action: () => navigate("/stock") },
  { label: "Categorías", icon: <BiCategory />, action: () => navigate("/categorias") },
  { label: "Devoluciones", icon: <BiFile />, action: () => navigate("/devoluciones") },

  // Solo mostrar módulo de usuarios si el rol es admin o si mostrarModuloUsuarios es true
  ...(rol === "admin" || mostrarModuloUsuarios ? [{ label: "Usuarios", icon: <BiUser />, action: () => navigate("/usuarios") }] : []),
  ...(rol === "admin" ? [
      { label: "Roles", icon: <BiFile />, action: () => navigate("/roles") },
      { label: "Tipo Documento", icon: <BiFile />, action: () => navigate("/tipo-documento") },
      { label: "Proveedores", icon: <BiUser />, action: () => navigate("/proveedores") },
  ] : []),

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

  // ---------- Gestión de Usuarios ----------
  const [vista, setVista] = useState("registro");
  const [nombre, setNombre] = useState("");
  const [correo, setCorreo] = useState("");
  const [contrasena, setContrasena] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [numeroDocumento, setNumeroDocumento] = useState("");
  const [tipoDocumento, setTipoDocumento] = useState("");
  const [rolUsuario, setRolUsuario] = useState("");
  const [tiposDocumento, setTiposDocumento] = useState([]);
  const [roles, setRoles] = useState([]);
  const [usuarios, setUsuarios] = useState([]);
  const [editUsuario, setEditUsuario] = useState(null);

  // ---------- Cargar datos iniciales ----------
  useEffect(() => {
    const fetchData = async () => {
      try {
        const [resTipos, resRoles, resUsuarios] = await Promise.all([
          fetch("http://localhost:3001/api/tipoDocumento/tipoDocumento", { headers: { Authorization: `Bearer ${token}` } }),
          fetch("http://localhost:3001/api/rol/rol", { headers: { Authorization: `Bearer ${token}` } }),
          fetch("http://localhost:3001/api/persona/persona", { headers: { Authorization: `Bearer ${token}` } }),
        ]);

        const tiposData = await resTipos.json();
        const rolesData = await resRoles.json();
        const usuariosData = await resUsuarios.json();

        setTiposDocumento(tiposData.body || []);
        setRoles(rolesData.body || []);

        const usuariosMap = (usuariosData.body || []).map(u => ({
          ...u,
          Tipo_Documento_id: typeof u.Tipo_Documento_id === "object" ? u.Tipo_Documento_id.idTipo_Documento : u.Tipo_Documento_id,
          Rol_id: typeof u.Rol === "object" ? u.Rol.idRol : u.Rol_id,
        }));

        setUsuarios(usuariosMap);
      } catch (err) {
        console.error(err);
        Swal.fire("Error", "No se pudieron cargar los datos", "error");
      }
    };

    fetchData();
  }, [token]);

  // ---------- Funciones CRUD ----------
  const handleSubmit = async (e) => {
    e.preventDefault();

    if (nombre.trim().length < 3) return Swal.fire("Error", "El nombre debe tener al menos 3 caracteres", "warning");
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(correo)) return Swal.fire("Error", "Correo inválido", "warning");
    if (!/^(?=.*[A-Z])(?=.*\d).{8,}$/.test(contrasena)) return Swal.fire("Error", "Contraseña mínimo 8 caracteres, 1 mayúscula y 1 número", "warning");
    if (!/^\d{5,10}$/.test(numeroDocumento)) return Swal.fire("Error", "Documento entre 5 y 10 dígitos", "warning");
    if (!tipoDocumento || !rolUsuario) return Swal.fire("Error", "Seleccione tipo de documento y rol", "warning");

    const nuevoUsuario = { Nombre: nombre, Correo: correo, Contrasena: contrasena, Numero_Documento: numeroDocumento, Tipo_Documento_id: parseInt(tipoDocumento), Rol_id: parseInt(rolUsuario) };

    try {
      const res = await fetch("http://localhost:3001/api/persona/persona", {
        method: "POST",
        headers: { "Content-Type": "application/json", Authorization: `Bearer ${token}` },
        body: JSON.stringify(nuevoUsuario)
      });
      const data = await res.json();

      if (res.ok) {
        Swal.fire("¡Éxito!", "Usuario registrado correctamente", "success");
        setUsuarios(prev => [...prev, { ...nuevoUsuario, idPersona: data.body.idPersona }]);
        setNombre(""); setCorreo(""); setContrasena(""); setNumeroDocumento(""); setTipoDocumento(""); setRolUsuario("");
      } else Swal.fire("Error", data.message || "No se pudo registrar", "error");
    } catch (err) {
      console.error(err);
      Swal.fire("Error", "No se pudo registrar", "error");
    }
  };

  const handleEditar = async (e) => {
    e.preventDefault();
    if (!editUsuario) return;

    const payload = { 
      Nombre: editUsuario.Nombre, 
      Correo: editUsuario.Correo, 
      Numero_Documento: editUsuario.Numero_Documento, 
      Tipo_Documento_id: parseInt(editUsuario.Tipo_Documento_id), 
      Rol_id: parseInt(editUsuario.Rol_id),
      ...(editUsuario.Contrasena && { Contrasena: editUsuario.Contrasena })
    };

    try {
      const res = await fetch(`http://localhost:3001/api/persona/persona/${editUsuario.idPersona}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json", Authorization: `Bearer ${token}` },
        body: JSON.stringify(payload)
      });
      const data = await res.json();

      if (res.ok) {
        Swal.fire("Éxito", "Usuario actualizado", "success");
        setUsuarios(prev => prev.map(u => u.idPersona === editUsuario.idPersona ? { ...u, ...payload } : u));
        setEditUsuario(null);
      } else Swal.fire("Error", data.Message || data.message || "No se pudo actualizar", "error");
    } catch (err) {
      console.error(err);
      Swal.fire("Error", "No se pudo actualizar", "error");
    }
  };

  const handleEliminar = async (id) => {
    const confirm = await Swal.fire({ title: "¿Eliminar este usuario?", icon: "warning", showCancelButton: true, confirmButtonText: "Sí, eliminar", cancelButtonText: "Cancelar" });
    if (confirm.isConfirmed) {
      try {
        const res = await fetch(`http://localhost:3001/api/persona/persona/${id}`, { method: "DELETE", headers: { Authorization: `Bearer ${token}` } });
        const data = await res.json();

        if (res.ok) {
          setUsuarios(prev => prev.filter(u => u.idPersona !== id));
          Swal.fire("Eliminado", "Usuario eliminado correctamente", "success");
        } else Swal.fire("No se pudo eliminar", data.Message || data.message || "Error desconocido", "error");
      } catch (err) {
        console.error(err);
        Swal.fire("Error", "No se pudo eliminar", "error");
      }
    }
  };

  const abrirModalEditar = (usuario) => setEditUsuario({ ...usuario });

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
          <div className="app-name" style={{ color: "#198754", fontWeight: "bold", fontSize: "1.9rem" }}>
            Gestión de Usuarios
          </div>
        </div>
        <div className="header-right d-flex align-items-center gap-3 ms-auto">
          <div className="dropdown">
            <button className="btn p-0 border-0 bg-transparent dropdown-toggle" type="button" id="perfilDropdown" data-bs-toggle="dropdown" aria-expanded="false">
              <img
                src={foto}
                alt="Perfil"
                className="rounded-circle"
                style={{ width: "40px", height: "40px", objectFit: "cover", border: "2px solid #198754" }}
              />
            </button>
            <ul className="dropdown-menu dropdown-menu-end" aria-labelledby="perfilDropdown">
              <li><button className="dropdown-item" onClick={() => navigate("/my-profile")}>Mi Perfil</button></li>
              <li><button className="dropdown-item" onClick={() => navigate("/dashboard")}>Volver al Inicio</button></li>
              <li><hr className="dropdown-divider" /></li>
              <li><button className="dropdown-item" onClick={cerrarSesion}>
                  Cerrar sesión
                </button></li>
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
            <div className="card shadow-lg p-4 rounded-5" style={{ maxWidth: "700px", width: "100%" }}>
              <h4 className="text-center mb-4" style={{ color: "#198754" }}>Registro de Usuario</h4>
              <form onSubmit={handleSubmit} className="row g-3">
                {/* Campos del formulario */}
                <div className="col-md-6">
                  <label className="form-label">Nombre</label>
                  <input type="text" className="form-control rounded-3 shadow-sm" value={nombre} onChange={e => setNombre(e.target.value)} required />
                </div>
                <div className="col-md-6">
                  <label className="form-label">Correo</label>
                  <input type="email" className="form-control rounded-3 shadow-sm" value={correo} onChange={e => setCorreo(e.target.value)} required />
                </div>
                <div className="col-md-6">
                  <label className="form-label">Contraseña</label>
                  <div className="position-relative">
                    <input type={showPassword ? "text" : "password"} className="form-control rounded-3 shadow-sm pe-5" value={contrasena} onChange={e => setContrasena(e.target.value)} required />
                    <span className="position-absolute top-50 end-0 translate-middle-y me-3" style={{ cursor: "pointer", fontSize: "1.2rem", color: "#6c757d" }} onClick={() => setShowPassword(!showPassword)}>
                      {showPassword ? <BiHide /> : <BiShow />}
                    </span>
                  </div>
                </div>
                <div className="col-md-6">
                  <label className="form-label">Número de Documento</label>
                  <input type="text" className="form-control rounded-3 shadow-sm" value={numeroDocumento} onChange={e => setNumeroDocumento(e.target.value)} required />
                </div>
                <div className="col-md-6">
                  <label className="form-label">Tipo de Documento</label>
                  <select className="form-select rounded-3 shadow-sm" value={tipoDocumento} onChange={e => setTipoDocumento(e.target.value)} required>
                    <option value="">Seleccione...</option>
                    {tiposDocumento.map(td => <option key={td.idTipo_Documento} value={td.idTipo_Documento}>{td.Descripcion}</option>)}
                  </select>
                </div>
                <div className="col-md-6">
                  <label className="form-label">Rol</label>
                  <select className="form-select rounded-3 shadow-sm" value={rolUsuario} onChange={e => setRolUsuario(e.target.value)} required>
                    <option value="">Seleccione...</option>
                    {roles.map(r => <option key={r.idRol} value={r.idRol}>{r.Descripcion_Rol}</option>)}
                  </select>
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
            {usuarios.length === 0 ? (
              <p className="text-center text-muted">No hay usuarios registrados.</p>
            ) : (
              usuarios.map(u => (
                <div className="col-md-6 col-lg-4 mb-3" key={u.idPersona}>
                  <div className="card shadow-sm h-100 text-center">
                    <div className="card-body">
                      <div className="mx-auto mb-2" style={{ width: "60px", height: "60px" }}>
                       <img
  src={u.Foto ? `http://localhost:3001${u.Foto}` : "http://localhost:3001/uploads/default-avatar.png"}
  alt={u.Nombre}
  className="rounded-circle w-100 h-100"
  style={{ objectFit: "cover" }}
  onError={(e) => e.currentTarget.src = "/img/icon-default1.jpg"} // Tu foto por defecto
/>

                      </div>
                      <h6 className="card-title mb-0">{u.Nombre}</h6>
                      <p className="text-muted mb-1">{u.Correo}</p>
                      <p className="text-muted mb-1">{tiposDocumento.find(td => td.idTipo_Documento === u.Tipo_Documento_id)?.Descripcion || u.Tipo_Documento_id}</p>
                      <p className="text-muted mb-2">{roles.find(r => r.idRol === u.Rol_id)?.Descripcion_Rol || u.Rol_id}</p>
                      <div className="d-flex justify-content-center gap-3">
                        <span className="text-primary" style={{ cursor: "pointer", fontSize: "1.2rem" }} title="Editar" onClick={() => abrirModalEditar(u)}><BiPencil /></span>
                        <span className="text-danger" style={{ cursor: "pointer", fontSize: "1.2rem" }} title="Eliminar" onClick={() => handleEliminar(u.idPersona)}><BiTrash /></span>
                      </div>
                    </div>
                  </div>
                </div>
              ))
            )}
          </div>
        )}

        {/* MODAL EDITAR */}
        {editUsuario && (
          <div className="modal fade show d-block" tabIndex="-1" style={{ backgroundColor: "rgba(0,0,0,0.3)" }}>
            <div className="modal-dialog modal-dialog-centered">
              <div className="modal-content">
                <form onSubmit={handleEditar}>
                  <div className="modal-header">
                    <h5 className="modal-title">Editar Usuario</h5>
                    <button type="button" className="btn-close" onClick={() => setEditUsuario(null)}></button>
                  </div>
                  <div className="modal-body">
                    <div className="mb-3">
                      <label className="form-label">Nombre</label>
                      <input type="text" className="form-control" value={editUsuario.Nombre} onChange={e => setEditUsuario(prev => ({ ...prev, Nombre: e.target.value }))} required />
                    </div>
                    <div className="mb-3">
                      <label className="form-label">Correo</label>
                      <input type="email" className="form-control" value={editUsuario.Correo} onChange={e => setEditUsuario(prev => ({ ...prev, Correo: e.target.value }))} required />
                    </div>
                    <div className="mb-3">
                      <label className="form-label">Contraseña (dejar vacío si no desea cambiar)</label>
                      <input type="password" className="form-control" value={editUsuario.Contrasena || ""} onChange={e => setEditUsuario(prev => ({ ...prev, Contrasena: e.target.value }))} />
                    </div>
                    <div className="mb-3">
                      <label className="form-label">Número Documento</label>
                      <input type="text" className="form-control" value={editUsuario.Numero_Documento} onChange={e => setEditUsuario(prev => ({ ...prev, Numero_Documento: e.target.value }))} required />
                    </div>
                    <div className="mb-3">
                      <label className="form-label">Tipo Documento</label>
                      <select className="form-select" value={editUsuario.Tipo_Documento_id} onChange={e => setEditUsuario(prev => ({ ...prev, Tipo_Documento_id: e.target.value }))} required>
                        <option value="">Seleccione...</option>
                        {tiposDocumento.map(td => <option key={td.idTipo_Documento} value={td.idTipo_Documento}>{td.Descripcion}</option>)}
                      </select>
                    </div>
                    <div className="mb-3">
                      <label className="form-label">Rol</label>
                      <select className="form-select" value={editUsuario.Rol_id} onChange={e => setEditUsuario(prev => ({ ...prev, Rol_id: e.target.value }))} required>
                        <option value="">Seleccione...</option>
                        {roles.map(r => <option key={r.idRol} value={r.idRol}>{r.Descripcion_Rol}</option>)}
                      </select>
                    </div>
                  </div>
                  <div className="modal-footer">
                    <button type="button" className="btn btn-secondary" onClick={() => setEditUsuario(null)}>Cancelar</button>
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
