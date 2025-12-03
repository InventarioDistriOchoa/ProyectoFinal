// src/pages/RegistroDevoluciones.jsx
import { useState, useEffect, useRef, useMemo } from "react";
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
  BiPencil,
  BiTrash,
} from "react-icons/bi";
import {
  useTable,
  useSortBy,
  useGlobalFilter,
  usePagination,
} from "react-table";

import "bootstrap/dist/css/bootstrap.min.css";
import "bootstrap/dist/js/bootstrap.bundle.min.js";
import "bootstrap-icons/font/bootstrap-icons.css";
import "../assets/styles.css";

export default function RegistroDevoluciones() {
  const navigate = useNavigate();
  const sidebarRef = useRef(null);
  const token = localStorage.getItem("token");

  const [sidebarVisible, setSidebarVisible] = useState(false);
  const [usuario, setUsuario] = useState("");
  const [rol, setRol] = useState("");
  const [foto, setFoto] = useState("/uploads/default-avatar.png");

  const [vista, setVista] = useState("registro");

  const [fecha, setFecha] = useState(() => {
    const hoy = new Date();
    const yyyy = hoy.getFullYear();
    const mm = String(hoy.getMonth() + 1).padStart(2, "0");
    const dd = String(hoy.getDate()).padStart(2, "0");
    return `${yyyy}-${mm}-${dd}`;
  });

  const [motivo, setMotivo] = useState("");
  const [cantidad, setCantidad] = useState("");
  const [productoId, setProductoId] = useState("");
  const [tipoDevolucionId, setTipoDevolucionId] = useState("");
  const [personaId, setPersonaId] = useState("");
  const [nombreResponsable, setNombreResponsable] = useState("");

  const [productos, setProductos] = useState([]);
  const [tiposDevolucion, setTiposDevolucion] = useState([]);
  const [devoluciones, setDevoluciones] = useState([]);

  // Modal edición
  const [modalVisible, setModalVisible] = useState(false);
  const [devolucionEdit, setDevolucionEdit] = useState(null);

  // ----- Perfil -----
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
        if (data.body) {
          setPersonaId(data.body.idPersona);
          setNombreResponsable(data.body.Nombre);
          if (data.body.Foto) {
            setFoto(
              data.body.Foto.startsWith("http")
                ? data.body.Foto
                : `http://localhost:3001${data.body.Foto}`
            );
          }
        }
      } catch (err) {
        console.error(err);
      }
    };
    fetchProfile();
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

  const sidebarItems = useMemo(() => {
    const mostrarModuloUsuarios = rol === "admin" || rol === "superadmin";
    return [
      { label: "Inicio", icon: <BiHome />, action: () => navigate("/dashboard") },
      { label: "Productos", icon: <BiFile />, action: () => navigate("/lista-productos") },
      { label: "Entradas", icon: <BiFile />, action: () => navigate("/lista-entradas") },
      { label: "Ventas", icon: <BiFile />, action: () => navigate("/ventas") },
      { label: "Devoluciones", icon: <BiUndo />, action: () => navigate("/devoluciones") },
      { label: "Tipo Devolución", icon: <BiFile />, action: () => navigate("/registro-tipo-devolucion") },
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

  // Sidebar click afuera
  useEffect(() => {
    const handleClickOutside = (e) => {
      if (sidebarRef.current && !sidebarRef.current.contains(e.target)) {
        setSidebarVisible(false);
      }
    };
    if (sidebarVisible)
      document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [sidebarVisible]);

  // ----- Cargar datos -----
  useEffect(() => {
    const fetchData = async () => {
      try {
        const [devRes, prodRes, tipoRes] = await Promise.all([
          fetch("http://localhost:3001/api/devolucion/devolucion", { headers: { Authorization: `Bearer ${token}` } }),
          fetch("http://localhost:3001/api/producto/producto", { headers: { Authorization: `Bearer ${token}` } }),
          fetch("http://localhost:3001/api/tipoDevolucion/tipoDevolucion", { headers: { Authorization: `Bearer ${token}` } }),
        ]);

        const devData = await devRes.json();
        const prodData = await prodRes.json();
        const tipoData = await tipoRes.json();

        setDevoluciones(devData.body || []);
        setProductos(prodData.body || []);
        setTiposDevolucion(tipoData.body || []);
      } catch (err) {
        console.error(err);
        Swal.fire("Error", "No se pudieron cargar los datos", "error");
      }
    };
    fetchData();
  }, [token]);

  // ----- Crear -----
  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!fecha || !motivo || !cantidad || !productoId || !personaId || !tipoDevolucionId)
      return Swal.fire("Error", "Todos los campos son obligatorios", "warning");

    const nuevaDevolucion = {
      Fecha: fecha,
      Motivo: motivo,
      Cantidad: parseInt(cantidad, 10),
      Producto_id: parseInt(productoId, 10),
      Persona_id: personaId,
      TipoDevolucion_id: parseInt(tipoDevolucionId, 10),
    };

    try {
      const res = await fetch("http://localhost:3001/api/devolucion/devolucion", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(nuevaDevolucion),
      });
      const data = await res.json();
      if (res.ok) {
        Swal.fire("¡Éxito!", "Devolución registrada correctamente", "success");
        setDevoluciones((prev) => [...prev, data.body]);
        setFecha(new Date().toISOString().split("T")[0]);
        setMotivo("");
        setCantidad("");
        setProductoId("");
        setTipoDevolucionId("");
        setVista("listado");
      } else Swal.fire("Error", data.Message || "No se pudo registrar", "error");
    } catch (err) {
      console.error(err);
      Swal.fire("Error", "No se pudo registrar", "error");
    }
  };

  // ---------- Tabla ----------
  const data = useMemo(() => {
    return devoluciones.map((d) => ({
      id: d.idDevolucion,
      fecha: new Date(d.Fecha).toISOString().split("T")[0],
      motivo: d.Motivo,
      cantidad: d.Cantidad,
      producto: productos.find((p) => p.idProducto === d.Producto_id)?.Nombre || d.Producto_id,
      responsable: nombreResponsable && Number(d.Persona_id) === Number(personaId) ? nombreResponsable : d.Persona_id,
      tipo: tiposDevolucion.find((t) => t.idTipoDevolucion === d.TipoDevolucion_id)?.NombreTipo || d.TipoDevolucion_id,
    }));
  }, [devoluciones, productos, tiposDevolucion, nombreResponsable, personaId]);

  const abrirModalEditar = (devolucion) => {
    setDevolucionEdit({ ...devolucion });
    setModalVisible(true);
  };

  const handleUpdate = async () => {
    if (!devolucionEdit.fecha || !devolucionEdit.motivo)
      return Swal.fire("Error", "La fecha y motivo son obligatorios", "warning");
    try {
      const res = await fetch(`http://localhost:3001/api/devolucion/devolucion/${devolucionEdit.id}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json", Authorization: `Bearer ${token}` },
        body: JSON.stringify({
          Fecha: devolucionEdit.fecha,
          Motivo: devolucionEdit.motivo,
          Cantidad: devolucionEdit.cantidad,
        }),
      });
      const data = await res.json();
      if (res.ok) {
        Swal.fire("Éxito", "Devolución actualizada correctamente", "success");
        setModalVisible(false);
        const res2 = await fetch("http://localhost:3001/api/devolucion/devolucion", {
          headers: { Authorization: `Bearer ${token}` },
        });
        const data2 = await res2.json();
        setDevoluciones(data2.body || []);
      } else {
        Swal.fire("Error", data.Message || "No se pudo actualizar", "error");
      }
    } catch {
      Swal.fire("Error", "No se pudo actualizar", "error");
    }
  };

  const handleDelete = async (id) => {
    const confirm = await Swal.fire({
      icon: "warning",
      title: "¿Eliminar devolución?",
      showCancelButton: true,
      confirmButtonText: "Sí, eliminar",
      cancelButtonText: "Cancelar",
    });
    if (confirm.isConfirmed) {
      try {
        const res = await fetch(`http://localhost:3001/api/devolucion/devolucion/${id}`, {
          method: "DELETE",
          headers: { Authorization: `Bearer ${token}` },
        });
        const data = await res.json();
        if (res.ok) {
          Swal.fire("Eliminado", "Devolución eliminada correctamente", "success");
          setDevoluciones((prev) => prev.filter((d) => d.idDevolucion !== id));
        } else Swal.fire("Error", data.Message || "No se pudo eliminar", "error");
      } catch {
        Swal.fire("Error", "No se pudo eliminar", "error");
      }
    }
  };

  const columns = useMemo(
    () => [
      { Header: "ID", accessor: "id" },
      { Header: "Fecha", accessor: "fecha" },
      { Header: "Motivo", accessor: "motivo" },
      { Header: "Cantidad", accessor: "cantidad" },
      { Header: "Producto", accessor: "producto" },
      { Header: "Tipo", accessor: "tipo" },
      { Header: "Responsable", accessor: "responsable" },
      {
        Header: "Acciones",
        accessor: "acciones",
        Cell: ({ row }) => (
          <div className="d-flex gap-2 justify-content-center">
            <button
              className="btn btn-sm btn-warning action-btn"
              onClick={() => abrirModalEditar(row.original)}
              title="Editar"
            >
              <BiPencil />
            </button>
            <button
              className="btn btn-sm btn-danger action-btn"
              onClick={() => handleDelete(row.original.id)}
              title="Eliminar"
            >
              <BiTrash />
            </button>
          </div>
        ),
      },
    ],
    [productos, tiposDevolucion]
  );

  const {
    getTableProps,
    getTableBodyProps,
    headerGroups,
    prepareRow,
    page,
    canPreviousPage,
    canNextPage,
    pageOptions,
    nextPage,
    previousPage,
    state,
    setGlobalFilter,
  } = useTable(
    { columns, data, initialState: { pageSize: 10 } },
    useGlobalFilter,
    useSortBy,
    usePagination
  );

  const { globalFilter, pageIndex } = state;

  return (
    <div className="RegistroUsuarios min-vh-100 position-relative myprofile-background">
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

      {/* Botón hamburguesa */}
      <button
        id="btn-toggle-sidebar"
        className="btn btn-light position-fixed top-3 start-3"
        style={{ zIndex: 2100 }}
        onClick={() => setSidebarVisible(!sidebarVisible)}
      >
        &#9776;
      </button>

      {/* Header */}
      <header className="dashboard-header-top d-flex align-items-center px-4 py-2 position-relative" style={{ background: "transparent" }}>
        <div className="header-center position-absolute top-50 start-50 translate-middle text-center">
          <div className="app-name" style={{ color: "#198754", fontWeight: "bold", fontSize: "1.9rem" }}>
            Registro de Devoluciones
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
        </div>
      </header>

      {/* Contenido principal */}
      <div className="container mt-4 px-3 pt-5">
        {/* Selector de vista */}
        <div className="d-flex justify-content-center gap-2 mb-4">
          <button
            className={`btn ${vista === "registro" ? "btn-success" : "btn-outline-success"}`}
            onClick={() => setVista("registro")}
          >
            Registro
          </button>
          <button
            className={`btn ${vista === "listado" ? "btn-success" : "btn-outline-success"}`}
            onClick={() => setVista("listado")}
          >
            Listado
          </button>
        </div>

        {/* Registro */}
        {vista === "registro" && (
          <div className="d-flex justify-content-center">
            <div className="card shadow-lg p-4 rounded-5" style={{ maxWidth: "700px", width: "100%" }}>
              <h4 className="text-center mb-4" style={{ color: "#198754" }}>Registrar Devolución</h4>
              <form onSubmit={handleSubmit} className="row g-3">
                <div className="col-md-4">
                  <label className="form-label">Fecha</label>
                  <input type="date" className="form-control rounded-3 shadow-sm" value={fecha} onChange={(e) => setFecha(e.target.value)} required />
                </div>
                <div className="col-md-8">
                  <label className="form-label">Motivo</label>
                  <input type="text" className="form-control rounded-3 shadow-sm" value={motivo} onChange={(e) => setMotivo(e.target.value)} required />
                </div>
                <div className="col-md-4">
                  <label className="form-label">Cantidad</label>
                  <input type="number" className="form-control rounded-3 shadow-sm" value={cantidad} onChange={(e) => setCantidad(e.target.value)} required />
                </div>
                <div className="col-md-4">
                  <label className="form-label">Producto</label>
                  <select className="form-select rounded-3 shadow-sm" value={productoId} onChange={(e) => setProductoId(e.target.value)} required>
                    <option value="">Seleccione</option>
                    {productos.map((p) => (
                      <option key={p.idProducto} value={p.idProducto}>{p.Nombre}</option>
                    ))}
                  </select>
                </div>
                <div className="col-md-4">
                  <label className="form-label">Tipo Devolución</label>
                  <select className="form-select rounded-3 shadow-sm" value={tipoDevolucionId} onChange={(e) => setTipoDevolucionId(e.target.value)} required>
                    <option value="">Seleccione</option>
                    {tiposDevolucion.map((t) => (
                      <option key={t.idTipoDevolucion} value={t.idTipoDevolucion}>{t.NombreTipo}</option>
                    ))}
                  </select>
                </div>
                <div className="col-md-12">
                  <label className="form-label">Responsable</label>
                  <input type="text" className="form-control rounded-3 shadow-sm" value={nombreResponsable} disabled />
                </div>
                <div className="col-12 d-flex justify-content-center mt-3">
                  <button type="submit" className="btn btn-success btn-lg rounded-4 px-5 shadow-sm">Registrar</button>
                </div>
              </form>
            </div>
          </div>
        )}

        {/* Listado */}
        {vista === "listado" && (
          <div className="mt-3">
            <div className="mb-3 d-flex justify-content-center">
              <input
                value={globalFilter || ""}
                onChange={(e) => setGlobalFilter(e.target.value)}
                className="form-control w-50"
                placeholder="Buscar devolución (motivo, producto, etc.)"
              />
            </div>
            <table {...getTableProps()} className="table table-bordered table-hover shadow-sm">
              <thead className="table-success">
                {headerGroups.map(headerGroup => (
                  <tr {...headerGroup.getHeaderGroupProps()}>
                    {headerGroup.headers.map(column => (
                      <th {...column.getHeaderProps(column.getSortByToggleProps())} style={{ cursor: column.canSort ? "pointer" : "default" }}>
                        {column.render("Header")}
                        {column.canSort && (column.isSorted ? (column.isSortedDesc ? " 🔽" : " 🔼") : "")}
                      </th>
                    ))}
                  </tr>
                ))}
              </thead>
              <tbody {...getTableBodyProps()}>
                {page.length === 0 ? (
                  <tr><td colSpan={columns.length} className="text-center">No hay devoluciones.</td></tr>
                ) : (
                  page.map(row => {
                    prepareRow(row);
                    return (
                      <tr {...row.getRowProps()}>
                        {row.cells.map(cell => <td {...cell.getCellProps()}>{cell.render("Cell")}</td>)}
                      </tr>
                    );
                  })
                )}
              </tbody>
            </table>
            <div className="d-flex justify-content-between align-items-center mt-3">
              <button className="btn btn-outline-success btn-sm" onClick={() => previousPage()} disabled={!canPreviousPage}>← Anterior</button>
              <span>Página {pageIndex + 1} de {pageOptions.length}</span>
              <button className="btn btn-outline-success btn-sm" onClick={() => nextPage()} disabled={!canNextPage}>Siguiente →</button>
            </div>
          </div>
        )}
      </div>

      {/* Modal flotante para editar devolución */}
      {modalVisible && devolucionEdit && (
        <div
          className="position-fixed top-0 start-0 w-100 h-100 d-flex align-items-center justify-content-center"
          style={{ backgroundColor: "rgba(0,0,0,0.35)", zIndex: 3000 }}
        >
          <div
            className="bg-white shadow-lg rounded-4 p-4 position-relative"
            style={{
              width: "420px",
              maxWidth: "90%",
              animation: "fadeIn 0.25s ease-in-out",
            }}
          >
            <button
              type="button"
              className="btn-close position-absolute top-2 end-2"
              onClick={() => setModalVisible(false)}
            ></button>

            <h5 className="text-success mb-3 text-center">Editar Devolución #{devolucionEdit.id}</h5>

            <div className="mb-3">
              <label className="form-label">Fecha</label>
              <input
                type="date"
                className="form-control"
                value={devolucionEdit.fecha}
                onChange={(e) => setDevolucionEdit({ ...devolucionEdit, fecha: e.target.value })}
              />
            </div>
            <div className="mb-3">
              <label className="form-label">Motivo</label>
              <input
                type="text"
                className="form-control"
                value={devolucionEdit.motivo}
                onChange={(e) => setDevolucionEdit({ ...devolucionEdit, motivo: e.target.value })}
              />
            </div>
            <div className="mb-3">
              <label className="form-label">Cantidad</label>
              <input
                type="number"
                className="form-control"
                value={devolucionEdit.cantidad}
                onChange={(e) => setDevolucionEdit({ ...devolucionEdit, cantidad: e.target.value })}
              />
            </div>

            <div className="d-flex justify-content-end gap-2">
              <button className="btn btn-secondary" onClick={() => setModalVisible(false)}>
                Cancelar
              </button>
              <button className="btn btn-success" onClick={handleUpdate}>
                Guardar cambios
              </button>
            </div>
          </div>

          <style>
            {`
              @keyframes fadeIn {
                0% { opacity: 0; transform: translateY(-20px); }
                100% { opacity: 1; transform: translateY(0); }
              }
              .action-btn:hover {
                transform: scale(1.1);
                transition: transform 0.2s;
              }
            `}
          </style>
        </div>
      )}
    </div>
  );
}
