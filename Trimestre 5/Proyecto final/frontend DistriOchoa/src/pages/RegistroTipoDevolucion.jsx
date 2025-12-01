import { useState, useEffect, useRef, useMemo } from "react";
import { useNavigate } from "react-router-dom";
import Swal from "sweetalert2";
import {
  BiHome,
  BiBox,
  BiCategory,
  BiLogOut,
  BiFile,
  BiPencil,
  BiTrash,
  BiUndo,
  BiLineChart,
  BiUser
} from "react-icons/bi";
import {
  useTable,
  useSortBy,
  useGlobalFilter,
  usePagination,
} from "react-table";
import "bootstrap/dist/css/bootstrap.min.css";
import "bootstrap/dist/js/bootstrap.bundle.min.js";
import "../assets/styles.css";

export default function RegistroTipoDevolucion() {
  const navigate = useNavigate();
  const sidebarRef = useRef(null);
  const token = localStorage.getItem("token");

  const [sidebarVisible, setSidebarVisible] = useState(false);
  const [vista, setVista] = useState("registro");

  // Datos
  const [tipos, setTipos] = useState([]);

  // Formulario
  const [nombreTipo, setNombreTipo] = useState("");

  // Modal edición
  const [modalVisible, setModalVisible] = useState(false);
  const [tipoEdit, setTipoEdit] = useState(null);

  // ---- Cerrar sesión ----
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


  const [rol, setRol] = useState("");

useEffect(() => {
  setRol((localStorage.getItem("rol") || "").toLowerCase());
}, []);


  const sidebarItems = useMemo(() => {
   const mostrarModuloUsuarios = rol === "admin" || rol === "superadmin";
   return [
     { label: "Inicio", icon: <BiHome />, action: () => navigate("/dashboard") },
     { label: "Productos", icon: <BiFile />, action: () => navigate("/lista-productos") },
     { label: "Entradas", icon: <BiFile />, action: () => navigate("/lista-entradas") },
     { label: "Ventas", icon: <BiFile />, action: () => navigate("/ventas") },
     { label: "Devoluciones", icon: <BiUndo />, action: () => navigate("/devoluciones") },
     { label: "Devolución", icon: <BiFile />, action: () => navigate("/registro-devolucion") }, // <-- Nuevo
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


  // ---- Sidebar toggle ----
  useEffect(() => {
    const handleClickOutside = (e) => {
      if (sidebarRef.current && !sidebarRef.current.contains(e.target)) {
        setSidebarVisible(false);
      }
    };
    if (sidebarVisible) document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [sidebarVisible]);

  // ---- Cargar datos ----
  const fetchTipos = async () => {
    try {
      const res = await fetch("http://localhost:3001/api/tipoDevolucion/tipoDevolucion", {
        headers: { Authorization: `Bearer ${token}` },
      });
      const data = await res.json();
      setTipos(data.body || []);
    } catch {
      Swal.fire("Error", "No se pudieron cargar los tipos de devolución", "error");
    }
  };

  useEffect(() => {
    if (token) fetchTipos();
  }, [token]);

  useEffect(() => {
    if (vista === "listado") fetchTipos();
  }, [vista]);

  // ---- Registrar TipoDevolucion ----
  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!nombreTipo.trim()) {
      return Swal.fire("Error", "El nombre es obligatorio", "warning");
    }

    try {
      const res = await fetch("http://localhost:3001/api/tipoDevolucion/tipoDevolucion", {
        method: "POST",
        headers: { "Content-Type": "application/json", Authorization: `Bearer ${token}` },
        body: JSON.stringify({ NombreTipo: nombreTipo.trim() }),
      });
      const data = await res.json();
      if (res.ok) {
        Swal.fire("Éxito", "Tipo de devolución creado", "success");
        setNombreTipo("");
        fetchTipos();
      } else {
        Swal.fire("Error", data.Message || "No se pudo registrar", "error");
      }
    } catch {
      Swal.fire("Error", "No se pudo registrar", "error");
    }
  };

  // ---- Abrir modal edición ----
  const abrirModalEditar = (tipo) => {
    setTipoEdit({ id: tipo.idTipoDevolucion, nombre: tipo.NombreTipo });
    setModalVisible(true);
  };

  // ---- Guardar edición ----
  const handleUpdate = async () => {
    if (!tipoEdit.nombre.trim()) {
      return Swal.fire("Error", "El nombre es obligatorio", "warning");
    }
    try {
      const res = await fetch(
        `http://localhost:3001/api/tipoDevolucion/tipoDevolucion/${tipoEdit.id}`,
        {
          method: "PUT",
          headers: { "Content-Type": "application/json", Authorization: `Bearer ${token}` },
          body: JSON.stringify({ NombreTipo: tipoEdit.nombre.trim() }),
        }
      );
      const data = await res.json();
      if (res.ok) {
        Swal.fire("Éxito", "Tipo de devolución actualizado", "success");
        setModalVisible(false);
        fetchTipos();
      } else {
        Swal.fire("Error", data.Message || "No se pudo actualizar", "error");
      }
    } catch {
      Swal.fire("Error", "No se pudo actualizar", "error");
    }
  };

  // ---- Eliminar ----
  const handleDelete = async (id) => {
    const confirm = await Swal.fire({
      icon: "warning",
      title: "¿Eliminar tipo de devolución?",
      showCancelButton: true,
      confirmButtonText: "Sí, eliminar",
      cancelButtonText: "Cancelar",
    });
    if (confirm.isConfirmed) {
      try {
        const res = await fetch(
          `http://localhost:3001/api/tipoDevolucion/tipoDevolucion/${id}`,
          { method: "DELETE", headers: { Authorization: `Bearer ${token}` } }
        );
        const data = await res.json();
        if (res.ok) {
          Swal.fire("Eliminado", "Tipo de devolución eliminado", "success");
          fetchTipos();
        } else {
          Swal.fire("Error", data.Message || "No se pudo eliminar", "error");
        }
      } catch {
        Swal.fire("Error", "No se pudo eliminar", "error");
      }
    }
  };

  // ---- Tabla ----
  const data = useMemo(
    () =>
      tipos.map((t) => ({
        id: t.idTipoDevolucion,
        nombre: t.NombreTipo,
      })),
    [tipos]
  );

  const columns = useMemo(
    () => [
      { Header: "ID", accessor: "id" },
      { Header: "Nombre del Tipo", accessor: "nombre" },
      {
        Header: "Acciones",
        accessor: "acciones",
        Cell: ({ row }) => (
          <div className="d-flex gap-2 justify-content-center">
            <button
              className="btn btn-sm btn-warning action-btn"
              title="Editar"
              onClick={() => abrirModalEditar(row.original)}
            >
              <BiPencil />
            </button>
            <button
              className="btn btn-sm btn-danger action-btn"
              title="Eliminar"
              onClick={() => handleDelete(row.original.id)}
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
    { columns, data, initialState: { pageSize: 10 } },
    useGlobalFilter,
    useSortBy,
    usePagination
  );
  const { globalFilter, pageIndex } = state;

  return (
    <div className="min-vh-100 position-relative bg-blur">
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

      <button
        id="btn-toggle-sidebar"
        className="btn btn-light position-fixed top-3 start-3"
        style={{ zIndex: 2100 }}
        onClick={() => setSidebarVisible(!sidebarVisible)}
      >
        &#9776;
      </button>

      {/* Contenido principal */}
      <div className="container px-3 pt-5">
        <h4 className="text-center mb-4 fw-bold text-success">Tipo de Devolución</h4>

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

        {/* ---------- VISTA REGISTRO ---------- */}
        {vista === "registro" && (
          <div className="d-flex justify-content-center">
            <div className="card shadow-lg p-4 rounded-5" style={{ maxWidth: "500px", width: "100%" }}>
              <form onSubmit={handleSubmit} className="row g-3">
                <div className="col-12">
                  <label className="form-label">Nombre del Tipo</label>
                  <input
                    type="text"
                    className="form-control rounded-3 shadow-sm"
                    value={nombreTipo}
                    onChange={(e) => setNombreTipo(e.target.value)}
                    required
                  />
                </div>

                <div className="col-12 d-flex justify-content-center mt-3">
                  <button type="submit" className="btn btn-success btn-lg rounded-4 px-5 shadow-sm">
                    Registrar
                  </button>
                </div>
              </form>
            </div>
          </div>
        )}

        {/* ---------- VISTA LISTADO ---------- */}
        {vista === "listado" && (
          <div>
            <div className="mb-3 d-flex justify-content-center">
              <input
                value={globalFilter || ""}
                onChange={(e) => setGlobalFilter(e.target.value)}
                className="form-control w-50"
                placeholder="Buscar tipo de devolución"
              />
            </div>
            <table {...getTableProps()} className="table table-bordered table-hover shadow-sm">
              <thead className="table-success">
                {headerGroups.map((headerGroup) => (
                  <tr {...headerGroup.getHeaderGroupProps()}>
                    {headerGroup.headers.map((column) => (
                      <th
                        {...column.getHeaderProps(column.getSortByToggleProps())}
                        style={{ cursor: column.canSort ? "pointer" : "default" }}
                      >
                        {column.render("Header")}
                        {column.canSort && (
                          <span>
                            {column.isSorted
                              ? column.isSortedDesc
                                ? " 🔽"
                                : " 🔼"
                              : ""}
                          </span>
                        )}
                      </th>
                    ))}
                  </tr>
                ))}
              </thead>
              <tbody {...getTableBodyProps()}>
                {page.length === 0 ? (
                  <tr>
                    <td colSpan={columns.length} className="text-center">
                      No hay tipos de devolución.
                    </td>
                  </tr>
                ) : (
                  page.map((row) => {
                    prepareRow(row);
                    return (
                      <tr {...row.getRowProps()}>
                        {row.cells.map((cell) => (
                          <td {...cell.getCellProps()}>{cell.render("Cell")}</td>
                        ))}
                      </tr>
                    );
                  })
                )}
              </tbody>
            </table>
            <div className="d-flex justify-content-between align-items-center mt-3">
              <button
                className="btn btn-outline-success btn-sm"
                onClick={() => previousPage()}
                disabled={!canPreviousPage}
              >
                ← Anterior
              </button>
              <span>
                Página {pageIndex + 1} de {pageOptions.length}
              </span>
              <button
                className="btn btn-outline-success btn-sm"
                onClick={() => nextPage()}
                disabled={!canNextPage}
              >
                Siguiente →
              </button>
            </div>
          </div>
        )}
      </div>

      {/* Modal Editar TipoDevolucion */}
      {modalVisible && tipoEdit && (
        <div
          className="position-fixed top-0 start-0 w-100 h-100 d-flex align-items-center justify-content-center"
          style={{ backgroundColor: "rgba(0,0,0,0.35)", zIndex: 3000 }}
        >
          <div
            className="bg-white shadow-lg rounded-4 p-4 position-relative"
            style={{ width: "380px", maxWidth: "90%" }}
          >
            <button
              type="button"
              className="btn-close position-absolute top-2 end-2"
              onClick={() => setModalVisible(false)}
            ></button>

            <h5 className="text-success mb-3 text-center">
              Editar Tipo #{tipoEdit.id}
            </h5>

            <div className="mb-3">
              <label className="form-label">Nombre</label>
              <input
                type="text"
                className="form-control"
                value={tipoEdit.nombre}
                onChange={(e) =>
                  setTipoEdit({ ...tipoEdit, nombre: e.target.value })
                }
              />
            </div>

            <div className="d-flex justify-content-end gap-2">
              <button
                className="btn btn-secondary"
                onClick={() => setModalVisible(false)}
              >
                Cancelar
              </button>
              <button className="btn btn-success" onClick={handleUpdate}>
                Guardar cambios
              </button>
            </div>
          </div>

          <style>
            {`
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
