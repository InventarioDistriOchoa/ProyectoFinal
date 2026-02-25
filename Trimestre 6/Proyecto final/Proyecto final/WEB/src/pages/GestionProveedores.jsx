import { useState, useEffect, useRef, useCallback } from "react";
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
  BiPencil,
  BiTrash,
} from "react-icons/bi";

export default function GestionProveedores() {
  const navigate = useNavigate();
  const sidebarRef = useRef(null);
  const token = localStorage.getItem("token");

  // ---------- Sidebar / usuario ----------
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
      } catch (err) {
        console.error(err);
      }
    };
    if (token) fetchProfile();
  }, [token]);

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
      }).then(() => navigate("/select-role", { replace: true }));
    }
  };

  const mostrarModuloUsuarios = rol === "admin" || rol === "superadmin";
  const sidebarItems = [
    { label: "Inicio", icon: <BiHome />, action: () => navigate("/dashboard") },
    {
      label: "Registrar Producto",
      icon: <BiFile />,
      action: () => navigate("/registro-productos"),
    },
    { label: "Venta", icon: <BiFile />, action: () => navigate("/ventas") },
    { label: "Reportes", icon: <BiFile />, action: () => navigate("/reportes") },
    { label: "Stock", icon: <BiBox />, action: () => navigate("/stock") },
    {
      label: "Categorías",
      icon: <BiCategory />,
      action: () => navigate("/categorias"),
    },
    {
      label: "Devoluciones",
      icon: <BiFile />,
      action: () => navigate("/devoluciones"),
    },
    ...(mostrarModuloUsuarios
      ? [
          {
            label: "Usuarios",
            icon: <BiUser />,
            action: () => navigate("/usuarios"),
          },
        ]
      : []),
    ...(rol === "admin"
      ? [
          {
            label: "Roles",
            icon: <BiFile />,
            action: () => navigate("/roles"),
          },
          {
            label: "Tipo Documento",
            icon: <BiFile />,
            action: () => navigate("/tipo-documento"),
          },
          {
            label: "Crear Usuarios",
            icon: <BiUser />,
            action: () => navigate("/registro-usuarios"),
          },
        ]
      : []),
    { label: "Mi Perfil", icon: <BiUser />, action: () => navigate("/my-profile") },
    { label: "Salir", icon: <BiLogOut />, action: cerrarSesion },
  ];

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (sidebarRef.current && !sidebarRef.current.contains(event.target)) {
        setSidebarVisible(false);
      }
    };
    if (sidebarVisible) {
      document.addEventListener("mousedown", handleClickOutside);
    }
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [sidebarVisible]);

  // ---------- Gestión de Proveedores ----------
  const [vista, setVista] = useState("registro");
  const [nombreEmpresa, setNombreEmpresa] = useState("");
  const [direccion, setDireccion] = useState("");
  const [proveedores, setProveedores] = useState([]);
  const [editProveedor, setEditProveedor] = useState(null);

  // ---- Cargar proveedores (solo activos si back filtra por Estado) ----
  const fetchProveedores = useCallback(async () => {
    try {
      const res = await fetch("http://localhost:3001/api/proveedor/proveedor", {
        headers: { Authorization: `Bearer ${token}` },
      });
      const data = await res.json();
      setProveedores(data.body || []);
    } catch (err) {
      console.error(err);
      Swal.fire("Error", "No se pudieron cargar los proveedores", "error");
    }
  }, [token]);

  useEffect(() => {
    if (token) fetchProveedores();
  }, [token, fetchProveedores]);

  // ---------- Crear proveedor (con reactivar si existe desactivado) ----------
  const handleSubmit = async (e) => {
    e.preventDefault();

    if (nombreEmpresa.trim().length < 3) {
      return Swal.fire(
        "Error",
        "El nombre debe tener al menos 3 caracteres",
        "warning"
      );
    }

    const nuevoProveedor = {
      Nombre_Empresa: nombreEmpresa.trim(),
      Direccion: direccion.trim(),
    };

    try {
      const res = await fetch(
        "http://localhost:3001/api/proveedor/proveedor",
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${token}`,
          },
          body: JSON.stringify(nuevoProveedor),
        }
      );

      const data = await res.json();

      // 🔴 CASO ESPECIAL: el proveedor existe pero está desactivado
      if (res.status === 409 && data.desactivado) {
        const result = await Swal.fire({
          icon: "warning",
          title: "Proveedor desactivado",
          text:
            data.message ||
            data.Message ||
            "Este proveedor ya existe pero está desactivado.",
          showCancelButton: true,
          confirmButtonText: "Reactivar",
          cancelButtonText: "Cancelar",
        });

        if (!result.isConfirmed) return;

        // 🟢 Reactivar proveedor
        const activarRes = await fetch(
          `http://localhost:3001/api/proveedor/proveedor/activar/${data.idProveedor}`,
          {
            method: "PUT",
            headers: { Authorization: `Bearer ${token}` },
          }
        );

        const activarData = await activarRes.json();

        if (activarRes.ok) {
          await Swal.fire(
            "Activado",
            "Proveedor reactivado correctamente",
            "success"
          );
          setNombreEmpresa("");
          setDireccion("");
          fetchProveedores();
        } else {
          Swal.fire(
            "Error",
            activarData.message || activarData.Message || "No se pudo activar",
            "error"
          );
        }

        return;
      }

      // ⛔ Existe y está activo
      if (res.status === 409) {
        return Swal.fire(
          "Error",
          data.message || data.Message || "El proveedor ya existe",
          "error"
        );
      }

      // ✅ Caso normal: creado
      if (res.ok) {
        await Swal.fire(
          "¡Éxito!",
          "Proveedor registrado correctamente",
          "success"
        );
        setNombreEmpresa("");
        setDireccion("");
        fetchProveedores();
        return;
      }

      // Otros errores
      Swal.fire(
        "Error",
        data.message || data.Message || "No se pudo registrar",
        "error"
      );
    } catch (err) {
      console.error(err);
      Swal.fire("Error", "No se pudo registrar", "error");
    }
  };

  // ---------- Desactivar proveedor (soft delete en el back) ----------
  const handleEliminar = async (id) => {
    const confirm = await Swal.fire({
      title: "¿Desactivar este proveedor?",
      text: "Podrás reactivarlo más tarde si lo necesitas.",
      icon: "warning",
      showCancelButton: true,
      confirmButtonText: "Sí, desactivar",
      cancelButtonText: "Cancelar",
    });

    if (!confirm.isConfirmed) return;

    try {
      const res = await fetch(
        `http://localhost:3001/api/proveedor/proveedor/${id}`,
        {
          method: "DELETE",
          headers: { Authorization: `Bearer ${token}` },
        }
      );
      const data = await res.json();

      if (res.ok) {
        Swal.fire("Desactivado", "Proveedor desactivado correctamente", "success");
        // Recargar lista (back ya solo devuelve activos)
        fetchProveedores();
      } else {
        Swal.fire(
          "No se pudo desactivar",
          data.message || data.Message || "Error desconocido",
          "error"
        );
      }
    } catch (err) {
      console.error(err);
      Swal.fire("Error", "No se pudo desactivar", "error");
    }
  };

  const abrirModalEditar = (proveedor) => setEditProveedor({ ...proveedor });

  return (
    <div className="RegistroUsuarios min-vh-100 position-relative myprofile-background">
      {sidebarVisible && (
        <div
          className="position-fixed top-0 start-0 w-100 h-100"
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
          transition: "transform 0.3s ease-in-out",
          zIndex: 2000,
        }}
        onMouseLeave={() => setSidebarVisible(false)}
      >
        <div
          className="d-flex flex-column gap-3 sidebar-scroll"
          style={{ flexGrow: 1, overflowY: "auto", paddingRight: "5px" }}
        >
          {sidebarItems.map((item, index) => (
            <button
              key={index}
              onClick={() => {
                item.action();
                setSidebarVisible(false);
              }}
              className="d-flex align-items-center gap-2 p-2 rounded shadow-sm border-0 bg-light text-dark"
              style={{
                cursor: "pointer",
                transition: "all 0.2s",
                marginTop: index === 0 ? "4rem" : "0",
              }}
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
      </div>

      <button
        id="btn-toggle-sidebar"
        className="btn btn-light position-fixed top-3 start-3"
        style={{ zIndex: 2100 }}
        onClick={() => setSidebarVisible(!sidebarVisible)}
      >
        &#9776;
      </button>

      {/* Header */}
      <header
        className="dashboard-header-top d-flex align-items-center px-4 py-2 position-relative"
        style={{ backgroundColor: "transparent" }}
      >
        <div className="header-left">
          <img src="/img/logo.png" className="logo-top me-2" alt="Logo" />
        </div>
        <div className="header-center position-absolute top-50 start-50 translate-middle text-center">
          <div
            className="app-name"
            style={{
              color: "#198754",
              fontWeight: "bold",
              fontSize: "1.9rem",
            }}
          >
            Gestión de Proveedores
          </div>
        </div>
        <div className="header-right d-flex align-items-center gap-3 ms-auto">
          <div className="dropdown">
            <button
              className="btn p-0 border-0 bg-transparent dropdown-toggle"
              type="button"
              id="perfilDropdown"
              data-bs-toggle="dropdown"
              aria-expanded="false"
            >
              <img
                src={foto}
                alt="Perfil"
                className="rounded-circle"
                style={{
                  width: "40px",
                  height: "40px",
                  objectFit: "cover",
                  border: "2px solid #198754",
                }}
              />
            </button>
            <ul
              className="dropdown-menu dropdown-menu-end"
              aria-labelledby="perfilDropdown"
            >
              <li>
                <button
                  className="dropdown-item"
                  onClick={() => navigate("/my-profile")}
                >
                  Mi Perfil
                </button>
              </li>
              <li>
                <button
                  className="dropdown-item"
                  onClick={() => navigate("/dashboard")}
                >
                  Volver al Inicio
                </button>
              </li>
              <li>
                <hr className="dropdown-divider" />
              </li>
              <li>
                <button className="dropdown-item" onClick={cerrarSesion}>
                  Cerrar sesión
                </button>
              </li>
            </ul>
          </div>
        </div>
      </header>

      {/* Contenido principal */}
      <div className="container mt-4 px-3 pt-5">
        {/* Selector de vista */}
        <div
          className="d-flex justify-content-center gap-2 mb-4"
          style={{ marginTop: "-10px" }}
        >
          <button
            className={`btn ${
              vista === "registro" ? "btn-success" : "btn-outline-success"
            }`}
            onClick={() => setVista("registro")}
          >
            Registro
          </button>
          <button
            className={`btn ${
              vista === "listado" ? "btn-success" : "btn-outline-success"
            }`}
            onClick={() => setVista("listado")}
          >
            Listado
          </button>
        </div>

        {/* ---------- VISTA REGISTRO ---------- */}
        {vista === "registro" && (
          <div className="d-flex justify-content-center">
            <div
              className="card shadow-lg p-4 rounded-5"
              style={{ maxWidth: "700px", width: "100%" }}
            >
              <h4
                className="text-center mb-4"
                style={{ color: "#198754" }}
              >
                Registro de Proveedor
              </h4>
              <form onSubmit={handleSubmit} className="row g-3">
                <div className="col-md-6">
                  <label className="form-label">Nombre Empresa</label>
                  <input
                    type="text"
                    className="form-control rounded-3 shadow-sm"
                    value={nombreEmpresa}
                    onChange={(e) => setNombreEmpresa(e.target.value)}
                    required
                  />
                </div>
                <div className="col-md-6">
                  <label className="form-label">Dirección</label>
                  <input
                    type="text"
                    className="form-control rounded-3 shadow-sm"
                    value={direccion}
                    onChange={(e) => setDireccion(e.target.value)}
                  />
                </div>
                <div className="col-12 d-flex justify-content-center mt-3">
                  <button
                    type="submit"
                    className="btn btn-success btn-lg rounded-4 px-5 shadow-sm"
                  >
                    Registrar
                  </button>
                </div>
              </form>
            </div>
          </div>
        )}

        {/* ---------- VISTA LISTADO ---------- */}
        {vista === "listado" && (
          <div className="row">
            {proveedores.length === 0 ? (
              <p className="text-center text-muted">
                No hay proveedores registrados.
              </p>
            ) : (
              proveedores.map((p) => (
                <div className="col-md-6 col-lg-4 mb-3" key={p.idProveedor}>
                  <div className="card shadow-sm h-100 text-center">
                    <div className="card-body">
                      <h6 className="card-title mb-1">{p.Nombre_Empresa}</h6>
                      <p className="text-muted mb-2">{p.Direccion}</p>
                      <div className="d-flex justify-content-center gap-3">
                        <span
                          className="text-primary"
                          style={{
                            cursor: "pointer",
                            fontSize: "1.2rem",
                          }}
                          title="Editar"
                          onClick={() => abrirModalEditar(p)}
                        >
                          <BiPencil />
                        </span>
                        <span
                          className="text-danger"
                          style={{
                            cursor: "pointer",
                            fontSize: "1.2rem",
                          }}
                          title="Desactivar"
                          onClick={() => handleEliminar(p.idProveedor)}
                        >
                          <BiTrash />
                        </span>
                      </div>
                    </div>
                  </div>
                </div>
              ))
            )}
          </div>
        )}

        {/* ---------- MODAL EDITAR ---------- */}
        {editProveedor && (
          <div
            className="modal fade show d-block"
            tabIndex="-1"
            style={{ backgroundColor: "rgba(0,0,0,0.3)" }}
          >
            <div className="modal-dialog modal-dialog-centered">
              <div className="modal-content">
                <form
                  onSubmit={async (e) => {
                    e.preventDefault();
                    try {
                      const res = await fetch(
                        `http://localhost:3001/api/proveedor/proveedor/${editProveedor.idProveedor}`,
                        {
                          method: "PUT",
                          headers: {
                            "Content-Type": "application/json",
                            Authorization: `Bearer ${token}`,
                          },
                          body: JSON.stringify({
                            Nombre_Empresa: editProveedor.Nombre_Empresa,
                            Direccion: editProveedor.Direccion,
                          }),
                        }
                      );
                      const data = await res.json();
                      if (res.ok) {
                        Swal.fire(
                          "Éxito",
                          "Proveedor actualizado",
                          "success"
                        );
                        fetchProveedores();
                        setEditProveedor(null);
                      } else {
                        Swal.fire(
                          "Error",
                          data.message ||
                            data.Message ||
                            "No se pudo actualizar",
                          "error"
                        );
                      }
                    } catch (err) {
                      console.error(err);
                      Swal.fire("Error", "No se pudo actualizar", "error");
                    }
                  }}
                >
                  <div className="modal-header">
                    <h5 className="modal-title">Editar Proveedor</h5>
                    <button
                      type="button"
                      className="btn-close"
                      onClick={() => setEditProveedor(null)}
                    ></button>
                  </div>
                  <div className="modal-body">
                    <div className="mb-3">
                      <label className="form-label">Nombre Empresa</label>
                      <input
                        type="text"
                        className="form-control"
                        value={editProveedor.Nombre_Empresa}
                        onChange={(e) =>
                          setEditProveedor((prev) => ({
                            ...prev,
                            Nombre_Empresa: e.target.value,
                          }))
                        }
                        required
                      />
                    </div>
                    <div className="mb-3">
                      <label className="form-label">Dirección</label>
                      <input
                        type="text"
                        className="form-control"
                        value={editProveedor.Direccion}
                        onChange={(e) =>
                          setEditProveedor((prev) => ({
                            ...prev,
                            Direccion: e.target.value,
                          }))
                        }
                      />
                    </div>
                  </div>
                  <div className="modal-footer">
                    <button
                      type="button"
                      className="btn btn-secondary"
                      onClick={() => setEditProveedor(null)}
                    >
                      Cancelar
                    </button>
                    <button type="submit" className="btn btn-primary">
                      Guardar Cambios
                    </button>
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
