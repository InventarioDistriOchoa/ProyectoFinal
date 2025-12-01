// src/pages/RegistroVentas.jsx
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
  BiPencil,
  BiTrash,
  BiUndo,
  BiLineChart
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

export default function RegistroVentas() {
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

  const [total, setTotal] = useState("0");
  const [ventas, setVentas] = useState([]);

  const [personaId, setPersonaId] = useState("");
  const [nombreResponsable, setNombreResponsable] = useState("");

  // Modal edición
  const [modalVisible, setModalVisible] = useState(false);
  const [ventaEdit, setVentaEdit] = useState(null);

  // Filtrado por ID y selección múltiple
  const [idFilter, setIdFilter] = useState("");
  const [selectedRows, setSelectedRows] = useState([]);

  const [usuarios, setUsuarios] = useState([]);

  useEffect(() => {
  const fetchUsuarios = async () => {
    try {
      const res = await fetch("http://localhost:3001/api/persona/persona", {
        headers: { Authorization: `Bearer ${token}` },
      });
      if (!res.ok) throw new Error("No se pudieron cargar los usuarios");
      const data = await res.json();
      setUsuarios(data.body || []);
    } catch (err) {
      console.error(err);
      Swal.fire("Error", "No se pudieron cargar los usuarios", "error");
    }
  };
  fetchUsuarios();
}, [token]);


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
    if (sidebarVisible)
      document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [sidebarVisible]);

  // Cargar ventas existentes
  useEffect(() => {
    const fetchVentas = async () => {
      try {
        const res = await fetch("http://localhost:3001/api/venta/venta", {
          headers: { Authorization: `Bearer ${token}` },
        });
        const data = await res.json();
        setVentas(data.body || []);
      } catch (err) {
        console.error(err);
        Swal.fire("Error", "No se pudieron cargar las ventas", "error");
      }
    };
    fetchVentas();
  }, [token]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!fecha || !personaId)
      return Swal.fire("Error", "Todos los campos son obligatorios", "warning");

    const nuevaVenta = {
      Fecha: fecha,
      Total: 0,
      Persona_id: personaId,
    };

    try {
      const res = await fetch("http://localhost:3001/api/venta/venta", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(nuevaVenta),
      });
      const data = await res.json();
      if (res.ok) {
        Swal.fire("¡Éxito!", "Venta registrada correctamente", "success");
        setVentas((prev) => [...prev, { ...nuevaVenta, idVenta: data.body.idVenta }]);
        setFecha(new Date().toISOString().split("T")[0]);
        setTotal("0");
        setVista("listado");
      } else Swal.fire("Error", data.message || "No se pudo registrar", "error");
    } catch (err) {
      console.error(err);
      Swal.fire("Error", "No se pudo registrar", "error");
    }
  };

  const usuariosMap = useMemo(() => {
  const map = {};
  usuarios.forEach(u => {
    map[u.idPersona] = u.Nombre;
  });
  return map;
}, [usuarios]);

  // ---------- Tabla con react-table ----------
  const data = useMemo(() => {
  return ventas.map(v => ({
    id: v.idVenta,
    fecha: new Date(v.Fecha).toISOString().split("T")[0],
    total: v.Total,
    responsable: usuarios.find(u => u.idPersona === v.Persona_id)?.Nombre || "—",
  }));
}, [ventas, usuarios]);


  // Filtrado por ID
  const filteredData = useMemo(() => {
    return data.filter(v => !idFilter || v.id.toString().includes(idFilter));
  }, [data, idFilter]);

  const abrirModalEditar = (venta) => {
    setVentaEdit({ ...venta });
    setModalVisible(true);
  };

  const handleUpdate = async () => {
    if (!ventaEdit.fecha)
      return Swal.fire("Error", "La fecha es obligatoria", "warning");
    try {
      const res = await fetch(`http://localhost:3001/api/venta/venta/${ventaEdit.id}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json", Authorization: `Bearer ${token}` },
        body: JSON.stringify({ Fecha: ventaEdit.fecha }),
      });
      const data = await res.json();
      if (res.ok) {
        Swal.fire("Éxito", "Venta actualizada correctamente", "success");
        setModalVisible(false);
        const res2 = await fetch("http://localhost:3001/api/venta/venta", {
          headers: { Authorization: `Bearer ${token}` },
        });
        const data2 = await res2.json();
        setVentas(data2.body || []);
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
      title: "¿Eliminar venta?",
      showCancelButton: true,
      confirmButtonText: "Sí, eliminar",
      cancelButtonText: "Cancelar",
    });
    if (confirm.isConfirmed) {
      try {
        await fetch(`http://localhost:3001/api/venta/venta/${id}`, {
          method: "DELETE",
          headers: { Authorization: `Bearer ${token}` },
        });
        Swal.fire("Eliminado", "Venta eliminada correctamente", "success");
        setVentas((prev) => prev.filter((v) => v.idVenta !== id));
      } catch {
        Swal.fire("Error", "No se pudo eliminar", "error");
      }
    }
  };

  // Acciones masivas
  const toggleSelectRow = (id) => {
    setSelectedRows(prev =>
      prev.includes(id) ? prev.filter(x => x !== id) : [...prev, id]
    );
  };

  const toggleSelectAll = () => {
    if (selectedRows.length === page.length) setSelectedRows([]);
    else setSelectedRows(page.map(r => r.original.id));
  };

  const handleDeleteMultiple = async () => {
    const confirm = await Swal.fire({
      icon: "warning",
      title: `¿Eliminar ${selectedRows.length} venta(s)?`,
      showCancelButton: true,
      confirmButtonText: "Sí, eliminar",
      cancelButtonText: "Cancelar",
    });
    if (confirm.isConfirmed) {
      try {
        await Promise.all(selectedRows.map(id =>
          fetch(`http://localhost:3001/api/venta/venta/${id}`, {
            method: "DELETE",
            headers: { Authorization: `Bearer ${token}` },
          })
        ));
        Swal.fire("Eliminado", "Ventas eliminadas correctamente", "success");
        setVentas(prev => prev.filter(v => !selectedRows.includes(v.idVenta)));
        setSelectedRows([]);
      } catch {
        Swal.fire("Error", "No se pudieron eliminar todas las ventas", "error");
      }
    }
  };

  const handleUpdateMultiple = async () => {
    const { value: newDate } = await Swal.fire({
      title: "Nueva fecha para ventas seleccionadas",
      input: "date",
      inputLabel: "Seleccione fecha",
      showCancelButton: true,
    });
    if (newDate) {
      try {
        await Promise.all(selectedRows.map(id =>
          fetch(`http://localhost:3001/api/venta/venta/${id}`, {
            method: "PUT",
            headers: { "Content-Type": "application/json", Authorization: `Bearer ${token}` },
            body: JSON.stringify({ Fecha: newDate }),
          })
        ));
        Swal.fire("Éxito", "Fecha actualizada correctamente", "success");
        const res = await fetch("http://localhost:3001/api/venta/venta", {
          headers: { Authorization: `Bearer ${token}` },
        });
        const data = await res.json();
        setVentas(data.body || []);
        setSelectedRows([]);
      } catch {
        Swal.fire("Error", "No se pudo actualizar la fecha", "error");
      }
    }
  };

  const columns = useMemo(
    () => [
      { Header: "ID", accessor: "id" },
      { Header: "Fecha", accessor: "fecha" },
      { Header: "Total", accessor: "total" },
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
    []
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
    { columns, data: filteredData, initialState: { pageSize: 10 } },
    useGlobalFilter,
    useSortBy,
    usePagination
  );

  const { globalFilter, pageIndex } = state;

  return (
    <div className="RegistroUsuarios min-vh-100 position-relative myprofile-background">
      {/* Sidebar overlay */}
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
            Registro de Ventas
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
          <div className="row justify-content-center">
            <div className="col-md-6">
              <form onSubmit={handleSubmit} className="card p-4 shadow-sm">
                <div className="mb-3">
                  <label className="form-label">Fecha</label>
                  <input
                    type="date"
                    className="form-control"
                    value={fecha}
                    onChange={(e) => setFecha(e.target.value)}
                  />
                </div>
                <div className="mb-3">
                  <label className="form-label">Responsable</label>
                  <input
                    type="text"
                    className="form-control"
                    value={nombreResponsable}
                    readOnly
                  />
                </div>
                <button type="submit" className="btn btn-success w-100">Registrar Venta</button>
              </form>
            </div>
          </div>
        )}
{/* Listado */}
{vista === "listado" && (
  <div className="mt-3">
    <div className="mb-3 d-flex justify-content-center gap-2 flex-wrap">
      <input
        value={globalFilter || ""}
        onChange={(e) => setGlobalFilter(e.target.value)}
        className="form-control w-50"
        placeholder="Buscar venta (fecha, responsable, total...)"
      />
      <input
        value={idFilter || ""}
        onChange={(e) => setIdFilter(e.target.value)}
        className="form-control w-25"
        placeholder="Buscar por ID"
      />
    </div>

    {selectedRows.length > 0 && (
      <div className="mb-2 d-flex gap-2 justify-content-center flex-wrap">
        <button className="btn btn-danger btn-sm" onClick={handleDeleteMultiple}>
          Eliminar seleccionadas
        </button>
        <button className="btn btn-warning btn-sm" onClick={handleUpdateMultiple}>
          Cambiar fecha seleccionadas
        </button>
      </div>
    )}

    {/* Tabla para escritorio */}
    <table {...getTableProps()} id="ventas-table" className="table table-bordered table-hover shadow-sm">
      <thead className="table-success">
        {headerGroups.map(headerGroup => (
          <tr {...headerGroup.getHeaderGroupProps()}>
            <th>
              <input
                type="checkbox"
                checked={selectedRows.length === page.length && page.length > 0}
                onChange={toggleSelectAll}
              />
            </th>
            {headerGroup.headers.map(column => (
              <th {...column.getHeaderProps(column.getSortByToggleProps())}>
                {column.render("Header")}
                {column.canSort && (column.isSorted ? (column.isSortedDesc ? " 🔽" : " 🔼") : "")}
              </th>
            ))}
          </tr>
        ))}
      </thead>
      <tbody {...getTableBodyProps()}>
        {page.length === 0 ? (
          <tr><td colSpan={columns.length + 1} className="text-center">No hay ventas.</td></tr>
        ) : (
          page.map(row => {
            prepareRow(row);
            const rowId = row.original.id;
            return (
              <tr {...row.getRowProps()}>
                <td>
                  <input
                    type="checkbox"
                    checked={selectedRows.includes(rowId)}
                    onChange={() => toggleSelectRow(rowId)}
                  />
                </td>
                {row.cells.map(cell => <td {...cell.getCellProps()}>{cell.render("Cell")}</td>)}
              </tr>
            );
          })
        )}
      </tbody>
    </table>

    {/* Cards para móvil */}
    {page.map(row => {
      prepareRow(row);
      const rowId = row.original.id;
      return (
        <div className="venta-card" key={rowId}>
          <div className="d-flex justify-content-between align-items-center mb-2">
            <strong>ID:</strong> {row.original.id}
            <input
              type="checkbox"
              checked={selectedRows.includes(rowId)}
              onChange={() => toggleSelectRow(rowId)}
            />
          </div>
          <div><strong>Fecha:</strong> {row.original.fecha}</div>
          <div><strong>Total:</strong> {row.original.total}</div>
          <div><strong>Responsable:</strong> {row.original.responsable}</div>
          <div className="d-flex gap-2 mt-2">
            <button className="btn btn-warning btn-sm" onClick={() => abrirModalEditar(row.original)}>
              <BiPencil /> Editar
            </button>
            <button className="btn btn-danger btn-sm" onClick={() => handleDelete(row.original.id)}>
              <BiTrash /> Eliminar
            </button>
          </div>
        </div>
      );
    })}

    <div className="d-flex justify-content-between align-items-center mt-3 flex-wrap gap-2">
      <button className="btn btn-outline-success btn-sm" onClick={() => previousPage()} disabled={!canPreviousPage}>← Anterior</button>
      <span>Página {pageIndex + 1} de {pageOptions.length}</span>
      <button className="btn btn-outline-success btn-sm" onClick={() => nextPage()} disabled={!canNextPage}>Siguiente →</button>
    </div>
  </div>
)}

        {/* Modal edición */}
        {modalVisible && (
          <div className="modal d-block" tabIndex="-1">
            <div className="modal-dialog">
              <div className="modal-content">
                <div className="modal-header">
                  <h5 className="modal-title">Editar Venta {ventaEdit.id}</h5>
                  <button type="button" className="btn-close" onClick={() => setModalVisible(false)}></button>
                </div>
                <div className="modal-body">
                  <label className="form-label">Fecha</label>
                  <input
                    type="date"
                    className="form-control"
                    value={ventaEdit.fecha}
                    onChange={(e) => setVentaEdit({...ventaEdit, fecha: e.target.value})}
                  />
                </div>
                <div className="modal-footer">
                  <button className="btn btn-secondary" onClick={() => setModalVisible(false)}>Cancelar</button>
                  <button className="btn btn-success" onClick={handleUpdate}>Guardar</button>
                </div>
              </div>
            </div>
          </div>
        )}

      </div>
    </div>
  );
}
