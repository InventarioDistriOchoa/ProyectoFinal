import { useState, useEffect, useRef } from "react";
import { BiCamera, BiUser, BiEnvelope, BiIdCard, BiClipboard, BiHome, BiCategory, BiBox, BiLogOut, BiFile } from "react-icons/bi";
import "bootstrap/dist/css/bootstrap.min.css";
import Swal from "sweetalert2";
import { useNavigate } from "react-router-dom";

export default function MyProfile() {
  const navigate = useNavigate();
  const sidebarRef = useRef(null);
  const [sidebarVisible, setSidebarVisible] = useState(false);
  const [profile, setProfile] = useState(null);
  const [tiposDocumento, setTiposDocumento] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [editModal, setEditModal] = useState(false);
  const token = localStorage.getItem("token");
  const mostrarModuloUsuarios = true;


  useEffect(() => {
  if (!token) {
    navigate("/select-role", { replace: true });
  }
}, [token, navigate]);


  // Cerrar sesión
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
    Swal.fire({
      icon: "success",
      title: "Sesión cerrada ✅",
      confirmButtonColor: "#198754",
    }).then(() => {
      navigate("/select-role", { replace: true });
      
      // Bloquear botón atrás
      window.history.pushState(null, "", "/select-role");
      window.onpopstate = () => window.history.pushState(null, "", "/select-role");
    });
  }
};


  const sidebarItems = [
    { label: "Inicio", icon: <BiHome />, action: () => navigate("/dashboard") },
    { label: "Registrar Producto", icon: <BiFile />, action: () => navigate("/registro-productos") },
    { label: "Registrar Salida", icon: <BiFile />, action: () => navigate("/registro-salidas") },
    { label: "Reportes", icon: <BiFile />, action: () => navigate("/reportes") },
    ...(mostrarModuloUsuarios ? [{ label: "Usuarios", icon: <BiUser />, action: () => navigate("/usuarios") }] : []),
    { label: "Categorías", icon: <BiCategory />, action: () => navigate("/categorias") },
    { label: "Stock", icon: <BiBox />, action: () => navigate("/stock") },
    { label: "Devoluciones", icon: <BiFile />, action: () => navigate("/devoluciones") },
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

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [profileRes, tiposRes] = await Promise.all([
          fetch("http://localhost:3001/api/persona/me", { headers: { Authorization: `Bearer ${token}` } }),
          fetch("http://localhost:3001/api/tipoDocumento/tipoDocumento", { headers: { Authorization: `Bearer ${token}` } }),
        ]);
        if (!profileRes.ok || !tiposRes.ok) throw new Error("No se pudo cargar la información");

        const profileData = await profileRes.json();
        const tiposData = await tiposRes.json();

        setProfile(profileData.body);
        setTiposDocumento(tiposData.body || []);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, [token]);

  const tipoDocDescripcion = tiposDocumento.find(td => td.idTipo_Documento === profile?.Tipo_Documento_id)?.Descripcion || profile?.Tipo_Documento_id;

  const handleFotoChange = async (file) => {
    if (!file) return;
    const formData = new FormData();
    formData.append("foto", file);

    try {
      const res = await fetch(`http://localhost:3001/api/persona/persona/${profile.idPersona}/foto`, {
        method: "PUT",
        headers: { Authorization: `Bearer ${token}` },
        body: formData,
      });
      const data = await res.json();
      if (res.ok) {
        Swal.fire("¡Éxito!", "Foto subida correctamente", "success");
        const profileRes = await fetch("http://localhost:3001/api/persona/me", { headers: { Authorization: `Bearer ${token}` } });
        const profileData = await profileRes.json();
        setProfile(profileData.body);
      } else Swal.fire("Error", data.message || "No se pudo subir la foto", "error");
    } catch (err) {
      console.error(err);
      Swal.fire("Error", "No se pudo subir la foto", "error");
    }
  };

  const handleEditar = async (e) => {
    e.preventDefault();

    if (!profile.Nombre || !profile.Correo || !profile.Numero_Documento || !profile.Tipo_Documento_id) {
      Swal.fire("Error", "Todos los campos obligatorios deben estar completos.", "error");
      return;
    }

    const payload = {
      Nombre: profile.Nombre.trim(),
      Correo: profile.Correo.trim(),
      Numero_Documento: profile.Numero_Documento.trim(),
      Tipo_Documento_id: Number(profile.Tipo_Documento_id),
      ...(profile.Contrasena?.trim() ? { Contrasena: profile.Contrasena.trim() } : {}),
    };

    try {
      const res = await fetch(`http://localhost:3001/api/persona/persona/${profile.idPersona}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json", Authorization: `Bearer ${token}` },
        body: JSON.stringify(payload),
      });

      const data = await res.json();

      if (res.ok) {
        Swal.fire("¡Éxito!", "Datos actualizados correctamente", "success");
        setEditModal(false);

        const profileRes = await fetch("http://localhost:3001/api/persona/me", { headers: { Authorization: `Bearer ${token}` } });
        const profileData = await profileRes.json();
        setProfile(profileData.body);
      } else {
        Swal.fire("Error", data.message || "No se pudo actualizar", "error");
      }
    } catch (err) {
      console.error(err);
      Swal.fire("Error", "No se pudo actualizar", "error");
    }
  };

  if (loading) return <p className="text-center mt-5">Cargando...</p>;
  if (error) return <p className="text-center text-danger mt-5">{error}</p>;
  if (!profile) return <p className="text-center mt-5">No se encontró el perfil.</p>;

  return (
    <div className="RegistroUsuarios min-vh-100 position-relative myprofile-background">
      {/* Sidebar Overlay */}
      {sidebarVisible && <div className="position-fixed top-0 start-0 w-100 h-100" style={{ background: "rgba(0,0,0,0.3)", zIndex: 1900 }} />}

      {/* Sidebar */}
      <div ref={sidebarRef} className="position-fixed top-0 start-0 vh-100 bg-white shadow p-3 d-flex flex-column gap-3"
        style={{ width: "240px", transform: sidebarVisible ? "translateX(0)" : "translateX(-100%)", transition: "transform 0.3s ease-in-out", zIndex: 2000 }}
        onMouseLeave={() => setSidebarVisible(false)}
      >
        {sidebarItems.map((item, index) => (
          <button key={index} onClick={() => { item.action(); setSidebarVisible(false); }}
            className="d-flex align-items-center gap-2 p-2 rounded shadow-sm border-0 bg-light text-dark hover-shadow"
            style={{ cursor: "pointer", transition: "all 0.2s", marginTop: index === 0 ? "4rem" : "0" }}
            onMouseEnter={(e) => e.currentTarget.style.backgroundColor = "#e2f0ff"}
            onMouseLeave={(e) => e.currentTarget.style.backgroundColor = "#f8f9fa"}
          >
            {item.icon} <span>{item.label}</span>
          </button>
        ))}
      </div>

      {/* Toggle Sidebar Button */}
      <button id="btn-toggle-sidebar" className="btn btn-light position-fixed top-3 start-3" style={{ zIndex: 2100 }} onClick={() => setSidebarVisible(!sidebarVisible)}>
        &#9776;
      </button>

      {/* Perfil */}
      <div className="container mt-5">
        <div className="row justify-content-center">
          <div className="col-lg-8">
            <div className="card shadow-lg rounded-4 p-4">
              {/* FOTO DE PERFIL */}
              <div className="d-flex flex-column align-items-center text-center position-relative">
                <img
                  src={profile.Foto ? `http://localhost:3001${profile.Foto}` : "http://localhost:3001/uploads/default-avatar.png"}
                  alt="Foto de perfil"
                  className="rounded-circle border border-success"
                  style={{ width: 150, height: 150, objectFit: "cover", borderWidth: "3px" }}
                />
                <label
                  htmlFor="uploadFoto"
                  className="position-absolute bottom-0 end-0 bg-success rounded-circle p-2 text-white"
                  style={{ cursor: "pointer", transform: "translate(25%, 25%)" }}
                  title="Cambiar foto"
                >
                  <BiCamera size={20} />
                </label>
                <input
                  type="file"
                  id="uploadFoto"
                  className="d-none"
                  accept="image/*"
                  onChange={(e) => handleFotoChange(e.target.files[0])}
                />
                <h3 className="mt-3">{profile.Nombre}</h3>
                <p className="text-muted mb-3">{profile.Rol?.Descripcion_Rol || "Empleado"}</p>
              </div>

              {/* TARJETAS DE INFORMACIÓN PERSONAL */}
              <div className="row mt-4">
                <div className="col-md-6 mb-3">
                  <div className="card shadow-sm rounded-4 p-3 text-center ">
                    <BiUser size={30} className="text-success mb-2" />
                    <h6 style={{ marginTop: '-15px' }}>Nombre</h6>
                    <p className="mb-0" style={{ marginTop: '13px' }}>{profile.Nombre}</p>
                  </div>
                </div>
                <div className="col-md-6 mb-3">
                  <div className="card shadow-sm rounded-4 p-3 text-center">
                    <BiEnvelope size={30} className="text-success mb-2" />
                    <h6 style={{ marginTop: '-15px' }}>Correo</h6>
                    <p className="mb-0" style={{ marginTop: '13px' }}>{profile.Correo}</p>
                  </div>
                </div>
                <div className="col-md-6 mb-3">
                  <div className="card shadow-sm rounded-4 p-3 text-center">
                    <BiIdCard size={30} className="text-success mb-2" />
                    <h6 style={{ marginTop: '-15px' }}>Documento</h6>
                    <p className="mb-0" style={{ marginTop: '13px' }}>{profile.Numero_Documento}</p>
                  </div>
                </div>
                <div className="col-md-6 mb-3">
                  <div className="card shadow-sm rounded-4 p-3 text-center">
                    <BiClipboard size={30} className="text-success mb-2" />
                    <h6 style={{ marginTop: '-15px' }}>Tipo Documento</h6>
                    <p className="mb-0" style={{ marginTop: '13px' }}>{tipoDocDescripcion}</p>
                  </div>
                </div>
              </div>

              {/* BOTÓN EDITAR */}
              <div className="d-flex justify-content-center mt-4">
                <button className="btn btn-success w-50" onClick={() => setEditModal(true)}>
                  Editar Perfil
                </button>
              </div>
            </div>
          </div>
        </div>

        {/* MODAL EDITAR */}
        {editModal && (
          <div className="modal fade show d-block" tabIndex="-1" style={{ background: "rgba(0,0,0,0.3)" }}>
            <div className="modal-dialog modal-dialog-centered">
              <div className="modal-content">
                <form onSubmit={handleEditar}>
                  <div className="modal-header">
                    <h5 className="modal-title">Editar Información Personal</h5>
                    <button type="button" className="btn-close" onClick={() => setEditModal(false)}></button>
                  </div>
                  <div className="modal-body">
                    <div className="mb-3">
                      <label className="form-label">Nombre</label>
                      <input type="text" className="form-control" value={profile.Nombre} onChange={e => setProfile(prev => ({ ...prev, Nombre: e.target.value }))} required />
                    </div>
                    <div className="mb-3">
                      <label className="form-label">Correo</label>
                      <input type="email" className="form-control" value={profile.Correo} onChange={e => setProfile(prev => ({ ...prev, Correo: e.target.value }))} required />
                    </div>
                    <div className="mb-3">
                      <label className="form-label">Contraseña</label>
                      <input type="password" className="form-control" value={profile.Contrasena || ""} onChange={e => setProfile(prev => ({ ...prev, Contrasena: e.target.value }))} placeholder="Cambiar contraseña" />
                    </div>
                    <div className="mb-3">
                      <label className="form-label">Número de Documento</label>
                      <input type="text" className="form-control" value={profile.Numero_Documento} onChange={e => setProfile(prev => ({ ...prev, Numero_Documento: e.target.value }))} required />
                    </div>
                    <div className="mb-3">
                      <label className="form-label">Tipo Documento</label>
                      <select className="form-select" value={profile.Tipo_Documento_id} onChange={e => setProfile(prev => ({ ...prev, Tipo_Documento_id: parseInt(e.target.value) }))} required>
                        <option value="">Seleccione...</option>
                        {tiposDocumento.map(td => (
                          <option key={td.idTipo_Documento} value={td.idTipo_Documento}>{td.Descripcion}</option>
                        ))}
                      </select>
                    </div>
                  </div>
                  <div className="modal-footer">
                    <button type="button" className="btn btn-secondary" onClick={() => setEditModal(false)}>Cancelar</button>
                    <button type="submit" className="btn btn-success">Guardar Cambios</button>
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
