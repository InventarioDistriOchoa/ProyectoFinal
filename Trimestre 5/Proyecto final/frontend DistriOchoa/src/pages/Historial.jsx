import { useEffect, useMemo, useRef, useState } from "react";
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
} from "react-icons/bi";

export default function Historial() {
  const [data, setData] = useState([]);

  // Nuevas listas para traducciones
  const [categorias, setCategorias] = useState([]);
  const [roles, setRoles] = useState([]);
  const [tiposDocumento, setTiposDocumento] = useState([]);

  const [selected, setSelected] = useState(null);

  const [sidebarVisible, setSidebarVisible] = useState(false);
  const sidebarRef = useRef(null);
  const navigate = useNavigate();

  const token = localStorage.getItem("token");
  const rol = (localStorage.getItem("rol") || "").toLowerCase();

  // =======================
  // Validar login
  // =======================
  useEffect(() => {
    if (!token || !rol) navigate("/select-role", { replace: true });
  }, [navigate, token, rol]);

  // =======================
  // Cerrar sesión
  // =======================
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
        title: "Sesión cerrada ✅",
        confirmButtonColor: "#198754",
      }).then(() => navigate("/select-role", { replace: true }));
    }
  };

  const mostrarModuloUsuarios = rol === "admin" || rol === "superadmin";

  // Sidebar
  const sidebarItems = [
    { label: "Inicio", icon: <BiHome />, action: () => navigate("/dashboard") },
    { label: "Productos", icon: <BiFile />, action: () => navigate("/lista-productos") },
    { label: "Entradas", icon: <BiFile />, action: () => navigate("/lista-entradas") },
    { label: "Ventas", icon: <BiFile />, action: () => navigate("/ventas") },
    { label: "Devoluciones", icon: <BiUndo />, action: () => navigate("/devoluciones") },
    { label: "Categorías", icon: <BiCategory />, action: () => navigate("/categorias") },
    { label: "Stock", icon: <BiBox />, action: () => navigate("/stock") },
    { label: "Reportes", icon: <BiLineChart />, action: () => navigate("/reportes") },
    { label: "Historial", icon: <BiFile />, action: () => navigate("/historial") },
    ...(mostrarModuloUsuarios
      ? [{ label: "Usuarios", icon: <BiUser />, action: () => navigate("/usuarios") }]
      : []),
    { label: "Mi Perfil", icon: <BiUser />, action: () => navigate("/my-profile") },
    { label: "Salir", icon: <BiLogOut />, action: cerrarSesion },
  ];

  // Ocultar sidebar
  useEffect(() => {
    const handleClickOutside = (e) => {
      if (sidebarRef.current && !sidebarRef.current.contains(e.target)) {
        setSidebarVisible(false);
      }
    };
    if (sidebarVisible) document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [sidebarVisible]);

  // =======================
  // 1. Cargar historial
  // =======================
  const getHistorial = async () => {
    try {
      const res = await fetch("http://localhost:3001/api/historial", {
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
      });

      if (!res.ok) return;

      const json = await res.json();
      setData(json.body || []);
    } catch (err) {
      console.error(err);
      Swal.fire("Error", "No se pudo cargar el historial", "error");
    }
  };

  // =======================
  // 2. Cargar categorías
  // =======================
  const getCategorias = async () => {
    try {
      const res = await fetch("http://localhost:3001/api/categoria/categoria", {
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
      });

      const json = await res.json();
      setCategorias(json.body || json);
    } catch (err) {
      console.error(err);
    }
  };

  const getCategoriaNombre = (id) => {
    const cat = categorias.find((c) => c.idCategoria == id);
    return cat ? cat.Nombre_Categoria : "Desconocida";
  };

  // =======================
  // 3. Cargar Roles
  // =======================
  const getRoles = async () => {
    try {
      const res = await fetch("http://localhost:3001/api/rol/rol", {
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
      });

      const json = await res.json();
      setRoles(json.body || json);
    } catch (err) {
      console.error(err);
    }
  };

  const getRolNombre = (id) => {
    const r = roles.find((x) => x.idRol == id);
    return r ? r.Descripcion_Rol : "Desconocido";
  };

  // =======================
  // 4. Cargar Tipo Documento
  // =======================
  const getTiposDocumento = async () => {
    try {
      const res = await fetch("http://localhost:3001/api/tipoDocumento/tipoDocumento", {
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
      });

      const json = await res.json();
      setTiposDocumento(json.body || json);
    } catch (err) {
      console.error(err);
    }
  };

  const getTipoDocumentoNombre = (id) => {
    const td = tiposDocumento.find((t) => t.idTipo_Documento == id);
    return td ? td.Descripcion : "Desconocido";
  };

  // =======================
  // Cargar todo
  // =======================
  useEffect(() => {
    if (!token) return;
    getHistorial();
    getCategorias();
    getRoles();
    getTiposDocumento();
  }, [token]);

  // =======================
  // Texto de acción
  // =======================
  const getColor = (accion) => {
    switch (accion) {
      case "CREATE":
        return "text-success fw-bold";
      case "UPDATE":
        return "text-warning fw-bold";
      case "DELETE":
        return "text-danger fw-bold";
      case "ACTIVATE":
        return "text-primary fw-bold";
      default:
        return "";
    }
  };

  const getAccionTexto = (item) => {
    const nombre = item.persona?.Nombre || "Se";
    const modulo = item.coleccion || "el sistema";

    switch (item.accion) {
      case "CREATE":
        return `${nombre === "Se" ? "Se creó" : `${nombre} creó`} un registro en ${modulo}`;
      case "UPDATE":
        return `${nombre === "Se" ? "Se realizó" : `${nombre} realizó`} una actualización en ${modulo}`;
      case "DELETE":
        return `${nombre === "Se" ? "Se desactivó" : `${nombre} desactivó`} un registro en ${modulo}`;
      case "ACTIVATE":
        return `${nombre === "Se" ? "Se reactivó" : `${nombre} reactivó`} un registro en ${modulo}`;
      default:
        return item.accion;
    }
  };

  // =======================
  // Filtros
  // =======================
  const [search, setSearch] = useState("");
  const [accionFilter, setAccionFilter] = useState("");
  const [usuarioFilter, setUsuarioFilter] = useState("");
  const [accionTextoFilter, setAccionTextoFilter] = useState("");
  const [fechaDesde, setFechaDesde] = useState("");
  const [fechaHasta, setFechaHasta] = useState("");

  const [currentPage, setCurrentPage] = useState(1);
  const PAGE_SIZE = 12;

  // Dropdown usuarios
  const usuariosDisponibles = useMemo(() => {
    const set = new Set();
    (data || []).forEach((item) => {
      if (item.persona?.Nombre) set.add(item.persona.Nombre);
    });
    return Array.from(set).sort();
  }, [data]);

  useEffect(() => {
    setCurrentPage(1);
  }, [search, accionFilter, usuarioFilter, accionTextoFilter, fechaDesde, fechaHasta, data.length]);

  // Filtrado
  const filteredData = useMemo(() => {
    let result = data || [];

    const term = search.trim().toLowerCase();
    const accionTextoTerm = accionTextoFilter.trim().toLowerCase();

    result = result.filter((item) => {
      const usuario = item.persona?.Nombre || "";
      const modulo = item.coleccion || "";
      const accion = item.accion || "";
      const accionDescripcion = getAccionTexto(item) || "";

      // Filtro general
      if (term) {
        const combined = `${usuario} ${modulo} ${accion} ${accionDescripcion}`.toLowerCase();
        if (!combined.includes(term)) return false;
      }

      if (accionFilter && accion !== accionFilter) return false;
      if (usuarioFilter && usuario !== usuarioFilter) return false;
      if (accionTextoTerm && !accionDescripcion.toLowerCase().includes(accionTextoTerm)) return false;

      // Fechas
      if (fechaDesde || fechaHasta) {
        const fechaItem = new Date(item.createdAt);
        if (fechaDesde) {
          const desde = new Date(fechaDesde);
          if (fechaItem < desde) return false;
        }
        if (fechaHasta) {
          const hasta = new Date(fechaHasta);
          hasta.setDate(hasta.getDate() + 1);
          if (fechaItem >= hasta) return false;
        }
      }
      return true;
    });

    return result;
  }, [data, search, accionFilter, usuarioFilter, accionTextoFilter, fechaDesde, fechaHasta]);

  // Paginación
  const totalPages = Math.max(1, Math.ceil(filteredData.length / PAGE_SIZE));
  const paginatedData = useMemo(() => {
    const start = (currentPage - 1) * PAGE_SIZE;
    return filteredData.slice(start, start + PAGE_SIZE);
  }, [filteredData, currentPage]);

  // Detección móvil
  const [isMobile, setIsMobile] = useState(window.innerWidth < 768);
  useEffect(() => {
    const handleResize = () => setIsMobile(window.innerWidth < 768);
    window.addEventListener("resize", handleResize);
    return () => window.removeEventListener("resize", handleResize);
  }, []);

  // =======================
  // Helper para parsear JSON
  // =======================
  const parseMaybeJSON = (data) => {
    if (!data) return {};
    if (typeof data === "object") return data;

    if (typeof data === "string") {
      try {
        let parsed = JSON.parse(data);
        if (typeof parsed === "object" && parsed !== null) return parsed;

        if (typeof parsed === "string") {
          const trimmed = parsed.trim();
          if (trimmed.startsWith("{") || trimmed.startsWith("[")) {
            try {
              const parsed2 = JSON.parse(trimmed);
              if (typeof parsed2 === "object" && parsed2 !== null) return parsed2;
            } catch {}
          }
        }
        return { texto: String(parsed) };
      } catch {
        const trimmed = data.trim();
        if (trimmed.startsWith("{") || trimmed.startsWith("[")) {
          try {
            const parsed2 = JSON.parse(trimmed);
            if (typeof parsed2 === "object" && parsed2 !== null) return parsed2;
          } catch {}
        }
        return { texto: data };
      }
    }

    return { texto: String(data) };
  };

  // =======================
  // Diccionario de etiquetas bonitas (Opción A)
  // =======================
  const LABEL_MAP = {
    idPersona: "ID de persona",
    Nombre: "Nombre",
    Correo: "Correo electrónico",
    Contrasena: "Contraseña",
    Numero_Documento: "Número de documento",
    Tipo_Documento_id: "Tipo de documento",
    Rol_id: "Rol",
    Foto: "Fotografía",
    ResetToken: "Token de recuperación",
    ResetExpires: "Expira recuperación",
    Categoria_id: "Categoría",
  };

  // =======================
  // Render bonito por valor
  // =======================
  const renderValue = (key, value) => {
    if (value === null || value === undefined) return "—";

    // Traducciones bonitas
    if (key === "Categoria_id") return getCategoriaNombre(value);
    if (key === "Tipo_Documento_id") return getTipoDocumentoNombre(value);
    if (key === "Rol_id") return getRolNombre(value);

    if (typeof value === "boolean") return value ? "Sí" : "No";
    if (typeof value === "object") return JSON.stringify(value);

    return String(value);
  };

  // =======================
  // RENDER UI
  // =======================
  return (
    <div className="min-vh-100 position-relative bg-blur">
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
        onMouseLeave={() => setSidebarVisible(false)}
      >
        {sidebarItems.map((item, i) => (
          <button
            key={i}
            onClick={() => {
              item.action();
              setSidebarVisible(false);
            }}
            className="d-flex align-items-center gap-2 p-2 rounded shadow-sm border-0 bg-light text-dark"
            style={{ cursor: "pointer", marginTop: i === 0 ? "4rem" : "0" }}
          >
            {item.icon} <span>{item.label}</span>
          </button>
        ))}
      </div>

      {/* Botón hamburguesa */}
      <button
        id="btn-toggle-sidebar"
        className="btn btn-light position-fixed top-3 start-3"
        style={{ zIndex: 2100 }}
        onClick={() => setSidebarVisible(!sidebarVisible)}
      >
        &#9776;
      </button>

      {/* Contenido */}
      <div className="container px-3 pt-5">
        <h4 className="mb-3 fw-bold text-center">Historial de Auditoría</h4>

        {/* FILTROS */}
        <div className="card mb-3 p-3 shadow-sm">
          <div className="row g-2">
            <div className="col-md-3">
              <label className="form-label small mb-1">Buscar en todo</label>
              <input
                type="text"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="form-control"
                placeholder="Usuario, módulo, acción..."
              />
            </div>

            <div className="col-md-3">
              <label className="form-label small mb-1">Tipo de acción</label>
              <select
                className="form-select"
                value={accionFilter}
                onChange={(e) => setAccionFilter(e.target.value)}
              >
                <option value="">Todas</option>
                <option value="CREATE">Crear</option>
                <option value="UPDATE">Actualizar</option>
                <option value="DELETE">Eliminar</option>
                <option value="ACTIVATE">Activar</option>
              </select>
            </div>

            <div className="col-md-3">
              <label className="form-label small mb-1">Usuario</label>
              <select
                className="form-select"
                value={usuarioFilter}
                onChange={(e) => setUsuarioFilter(e.target.value)}
              >
                <option value="">Todos</option>
                {usuariosDisponibles.map((u) => (
                  <option key={u} value={u}>
                    {u}
                  </option>
                ))}
              </select>
            </div>

            <div className="col-md-3">
              <label className="form-label small mb-1">Palabra en acción</label>
              <input
                type="text"
                className="form-control"
                value={accionTextoFilter}
                onChange={(e) => setAccionTextoFilter(e.target.value)}
                placeholder='Ej: "reactivó", "desactivó"...'
              />
            </div>
          </div>

          <div className="row g-2 mt-2">
            <div className="col-md-3">
              <label className="form-label small mb-1">Fecha desde</label>
              <input
                type="date"
                className="form-control"
                value={fechaDesde}
                onChange={(e) => setFechaDesde(e.target.value)}
              />
            </div>

            <div className="col-md-3">
              <label className="form-label small mb-1">Fecha hasta</label>
              <input
                type="date"
                className="form-control"
                value={fechaHasta}
                onChange={(e) => setFechaHasta(e.target.value)}
              />
            </div>

            <div className="col-md-3 d-flex align-items-end">
              <button
                className="btn btn-outline-secondary w-100"
                onClick={() => {
                  setSearch("");
                  setAccionFilter("");
                  setUsuarioFilter("");
                  setAccionTextoFilter("");
                  setFechaDesde("");
                  setFechaHasta("");
                }}
              >
                Limpiar filtros
              </button>
            </div>

            <div className="col-md-3 d-flex align-items-end justify-content-end">
              <span className="text-muted small">
                {filteredData.length} registros encontrados
              </span>
            </div>
          </div>
        </div>

        {/* TABLA / CARDS */}
        <div className="card-tabla animate-fadeIn">
          {!isMobile ? (
            <>
              <table className="table table-bordered table-hover mb-0">
                <thead className="table-success">
                  <tr>
                    <th>Usuario</th>
                    <th>Acción</th>
                    <th>Módulo</th>
                    <th>Fecha</th>
                    <th>Detalles</th>
                  </tr>
                </thead>
                <tbody>
                  {paginatedData.length === 0 ? (
                    <tr>
                      <td colSpan={5} className="text-center">
                        No hay registros que coincidan con los filtros.
                      </td>
                    </tr>
                  ) : (
                    paginatedData.map((item) => (
                      <tr key={item.idAuditoria}>
                        <td>{item.persona?.Nombre || "—"}</td>
                        <td className={getColor(item.accion)}>{getAccionTexto(item)}</td>
                        <td>{item.coleccion}</td>
                        <td>{new Date(item.createdAt).toLocaleString()}</td>
                        <td>
                          <button
                            className="btn btn-success btn-sm"
                            onClick={() => setSelected(item)}
                          >
                            Ver
                          </button>
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>

              <div className="d-flex justify-content-between align-items-center mt-2">
                <button
                  className="btn btn-outline-secondary btn-sm"
                  disabled={currentPage === 1}
                  onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
                >
                  ⟵ Anterior
                </button>
                <span className="small">
                  Página {currentPage} de {totalPages}
                </span>
                <button
                  className="btn btn-outline-secondary btn-sm"
                  disabled={currentPage === totalPages}
                  onClick={() =>
                    setCurrentPage((p) => Math.min(totalPages, p + 1))
                  }
                >
                  Siguiente ⟶
                </button>
              </div>
            </>
          ) : (
            <>
              <div className="d-flex flex-column gap-3">
                {paginatedData.length === 0 ? (
                  <p className="text-center">No hay registros que coincidan con los filtros.</p>
                ) : (
                  paginatedData.map((item) => (
                    <div key={item.idAuditoria} className="card venta-card">
                      <div className="card-header fw-bold">
                        {item.persona?.Nombre || "Usuario desconocido"}
                      </div>
                      <div className="card-body">
                        <p className={getColor(item.accion)}>{getAccionTexto(item)}</p>
                        <p className="mb-1">
                          <strong>Módulo:</strong> {item.coleccion}
                        </p>
                        <p className="mb-1">
                          <strong>Fecha:</strong> {new Date(item.createdAt).toLocaleString()}
                        </p>
                        <button
                          className="btn btn-success btn-sm mt-2"
                          onClick={() => setSelected(item)}
                        >
                          Ver detalles
                        </button>
                      </div>
                    </div>
                  ))
                )}
              </div>

              <div className="d-flex justify-content-between align-items-center mt-2">
                <button
                  className="btn btn-outline-secondary btn-sm"
                  disabled={currentPage === 1}
                  onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
                >
                  ⟵
                </button>
                <span className="small">
                  {currentPage} / {totalPages}
                </span>
                <button
                  className="btn btn-outline-secondary btn-sm"
                  disabled={currentPage === totalPages}
                  onClick={() => setCurrentPage((p) => Math.min(totalPages, p + 1))}
                >
                  ⟶
                </button>
              </div>
            </>
          )}
        </div>
      </div>

      {/* =============================== */}
      {/* MODAL DETALLES DE AUDITORÍA    */}
      {/* =============================== */}
      {selected && (
        <div
          className="position-fixed top-0 start-0 w-100 h-100 d-flex align-items-center justify-content-center animate-fadeIn"
          style={{ background: "rgba(0,0,0,0.45)", zIndex: 3000 }}
          onClick={() => setSelected(null)}
        >
          <div
            className="bg-white rounded-3 shadow-lg p-4 w-100 animate-slideUp"
            style={{ maxWidth: 700, maxHeight: "80vh", overflowY: "auto" }}
            onClick={(e) => e.stopPropagation()}
          >
            <button
              type="button"
              className="btn btn-light btn-sm position-absolute"
              style={{ top: 10, right: 10, borderRadius: "50%" }}
              onClick={() => setSelected(null)}
            >
              ×
            </button>

            <h5 className="fw-bold mb-3">
              Detalles de Auditoría #{selected.idAuditoria}
            </h5>

            <div className="mb-3 small">
              <p>
                <strong>Usuario:</strong> {selected.persona?.Nombre}
              </p>
              <p>
                <strong>Correo:</strong> {selected.persona?.Correo}
              </p>
              <p>
                <strong>Acción:</strong> {getAccionTexto(selected)}
              </p>
              <p>
                <strong>Módulo:</strong> {selected.coleccion}
              </p>
              <p>
                <strong>Fecha:</strong> {new Date(selected.createdAt).toLocaleString()}
              </p>
            </div>

            {(() => {
              const accion = selected.accion;

              const prevRaw = parseMaybeJSON(selected.datosAnteriores);
              const nextRaw = parseMaybeJSON(selected.datosNuevos);

              const allKeys = Array.from(
                new Set([...Object.keys(prevRaw), ...Object.keys(nextRaw)])
              );

              const prev = {};
              const next = {};
              allKeys.forEach((k) => {
                if (prevRaw[k] !== undefined) prev[k] = prevRaw[k];
                if (nextRaw[k] !== undefined) next[k] = nextRaw[k];
              });

              let tituloPrev = "Datos anteriores";
              let tituloNext = "Datos nuevos";

              if (accion === "CREATE") {
                tituloPrev = "Antes de la creación";
                tituloNext = "Registro creado";
              } else if (accion === "UPDATE") {
                tituloPrev = "Valores antes de la actualización";
                tituloNext = "Valores después de la actualización";
              } else if (accion === "DELETE") {
                tituloPrev = "Registro antes de desactivarse";
                tituloNext = "Estado final tras la desactivación";
              } else if (accion === "ACTIVATE") {
                tituloPrev = "Registro antes de la activación";
                tituloNext = "Estado después de la activación";
              }

              return (
                <div className="row small">
                  {/* Datos Anteriores */}
                  <div className="col-md-6 mb-3">
                    <h6 className="fw-bold">{tituloPrev}</h6>
                    {Object.keys(prev).length > 0 ? (
                      <div className="bg-light p-3 rounded-3 mt-2">
                      {Object.entries(prev).map(([key, value]) => {
  if (key === "Contrasena") return null; // OCULTAR CONTRASEÑA
  const label = LABEL_MAP[key] || key;
  return (
    <div key={key} className="mb-1">
      <strong>{label}:</strong> {renderValue(key, value)}
    </div>
  );
})}

                      </div>
                    ) : (
                      <p className="fst-italic text-muted">
                        No se registraron datos anteriores.
                      </p>
                    )}
                  </div>

                  {/* Datos Nuevos */}
                  <div className="col-md-6 mb-3">
                    <h6 className="fw-bold">{tituloNext}</h6>
                    {Object.keys(next).length > 0 ? (
                      <div className="bg-light p-3 rounded-3 mt-2">
                      {Object.entries(next).map(([key, value]) => {
  if (key === "Contrasena") return null; // OCULTAR CONTRASEÑA
  const label = LABEL_MAP[key] || key;
  return (
    <div key={key} className="mb-1">
      <strong>{label}:</strong> {renderValue(key, value)}
    </div>
  );
})}

                      </div>
                    ) : (
                      <p className="fst-italic text-muted">
                        No se registraron datos nuevos.
                      </p>
                    )}
                  </div>
                </div>
              );
            })()}

            <button
              className="btn btn-danger w-100 mt-3"
              onClick={() => setSelected(null)}
            >
              Cerrar
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
