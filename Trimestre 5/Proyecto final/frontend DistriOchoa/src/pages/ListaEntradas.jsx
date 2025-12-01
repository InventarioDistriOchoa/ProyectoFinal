import { useEffect, useState, useRef, useMemo } from "react";
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
  BiLineChart,
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

export default function ListaEntradas() {
  const [entradas, setEntradas] = useState([]);
  const [productos, setProductos] = useState([]);
  const [proveedores, setProveedores] = useState([]);
  const [usuarios, setUsuarios] = useState([]);
  const [filterId, setFilterId] = useState("");
  const [sidebarVisible, setSidebarVisible] = useState(false);
  const [selectedRows, setSelectedRows] = useState({});
  const sidebarRef = useRef(null);
  const navigate = useNavigate();
  const token = localStorage.getItem("token");
  const rol = (localStorage.getItem("rol") || "").toLowerCase();

  // --- Validar login ---
  useEffect(() => {
    if (!token || !rol) navigate("/select-role", { replace: true });
  }, [navigate, token, rol]);

  // --- Cerrar sesión ---
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

  // --- Sidebar limpio con rutas principales ---
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

  // --- Ocultar sidebar al hacer click fuera ---
  useEffect(() => {
    const handleClickOutside = (e) => {
      if (sidebarRef.current && !sidebarRef.current.contains(e.target)) {
        setSidebarVisible(false);
      }
    };
    if (sidebarVisible) document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [sidebarVisible]);

  // --- Cargar datos ---
  const fetchEntradas = async () => {
    try {
      const resE = await fetch("http://localhost:3001/api/entrada/entrada", { headers: { Authorization: `Bearer ${token}` } });
      const dataE = await resE.json();
      setEntradas(dataE.body || []);
    } catch {
      Swal.fire("Error", "No se pudieron cargar las entradas", "error");
    }
  };

  useEffect(() => {
    if (!token) return;
    const fetchAll = async () => {
      try {
        const [resE, resP, resPr, resU] = await Promise.all([
          fetch("http://localhost:3001/api/entrada/entrada", { headers: { Authorization: `Bearer ${token}` } }),
          fetch("http://localhost:3001/api/producto/producto", { headers: { Authorization: `Bearer ${token}` } }),
          fetch("http://localhost:3001/api/proveedor/proveedor", { headers: { Authorization: `Bearer ${token}` } }),
          fetch("http://localhost:3001/api/persona/persona", { headers: { Authorization: `Bearer ${token}` } }),
        ]);

        const [dataE, dataP, dataPr, dataU] = await Promise.all([resE.json(), resP.json(), resPr.json(), resU.json()]);
        setEntradas(dataE.body || []);
        setProductos(dataP.body || []);
        setProveedores(dataPr.body || []);
        setUsuarios(dataU.body || []);
      } catch {
        Swal.fire("Error", "No se pudieron cargar los datos", "error");
      }
    };
    fetchAll();
  }, [token]);

  // --- Editar entrada con modal ---
  const abrirModalEditar = (entrada) => {
    Swal.fire({
      title: `Editar proveedor de la entrada #${entrada.id}`,
      html: `
      <div style="text-align:left; font-size:14px; line-height:1.5;">
        <p style="color:#e67e22; font-weight:bold;">
          ⚠️ Solo puedes modificar el proveedor de esta entrada
        </p>
        <div style="margin-bottom:10px;">
          <label>Fecha:</label>
          <input id="swal-fecha" type="date" class="swal2-input" value="${entrada.fecha}" disabled />
        </div>
        <div style="margin-bottom:10px;">
          <label>Producto:</label>
          <input id="swal-producto" class="swal2-input" value="${entrada.producto}" disabled />
        </div>
        <div style="margin-bottom:10px;">
          <label>Cantidad:</label>
          <input id="swal-cantidad" type="number" class="swal2-input" value="${entrada.cantidad}" disabled />
        </div>
        <div style="margin-bottom:10px;">
          <label>Proveedor:</label>
          <select id="swal-proveedor" class="swal2-input">
            ${proveedores.map(pr => {
              const selected = pr.idProveedor === entrada.Proveedor_id;
              return `<option value="${pr.idProveedor}" ${selected ? "selected" : ""}>${pr.Nombre_Empresa}</option>`;
            }).join("")}
          </select>
        </div>
        <div style="margin-bottom:10px;">
          <label>Responsable:</label>
          <input id="swal-responsable" class="swal2-input" value="${entrada.responsable}" disabled />
        </div>
      </div>`,
      focusConfirm: false,
      showCancelButton: true,
      confirmButtonText: "Guardar cambios",
      cancelButtonText: "Cancelar",
      confirmButtonColor: "#198754",
      cancelButtonColor: "#ccc",
      preConfirm: () => ({
        Proveedor_id: parseInt(document.getElementById("swal-proveedor").value, 10),
      }),
    }).then(async (result) => {
      if (!result.isConfirmed) return;
      try {
        const res = await fetch(`http://localhost:3001/api/entrada/entrada/${entrada.id}`, {
          method: "PUT",
          headers: { "Content-Type": "application/json", Authorization: `Bearer ${token}` },
          body: JSON.stringify(result.value),
        });
        if (!res.ok) throw new Error();
        Swal.fire("Éxito", "Proveedor actualizado correctamente ✅", "success");
        fetchEntradas();
      } catch {
        Swal.fire("Error", "No se pudo actualizar el proveedor ❌", "error");
      }
    });
  };

  // --- Eliminar entrada ---
  const handleDelete = async (id) => {
    const confirm = await Swal.fire({
      title: "¿Seguro?",
      text: "Esta acción no se puede deshacer",
      icon: "warning",
      showCancelButton: true,
      confirmButtonText: "Sí, eliminar",
      cancelButtonText: "Cancelar",
      confirmButtonColor: "#d33",
      cancelButtonColor: "#3085d6",
    });

    if (confirm.isConfirmed) {
      try {
        await fetch(`http://localhost:3001/api/entrada/entrada/${id}`, {
          method: "DELETE",
          headers: { Authorization: `Bearer ${token}` },
        });
        setEntradas((prev) => prev.filter((e) => e.idEntrada !== id));
        Swal.fire("Eliminado", "La entrada fue eliminada ✅", "success");
      } catch {
        Swal.fire("Error", "No se pudo eliminar la entrada ❌", "error");
      }
    }
  };

  // --- Selección múltiple ---
  const toggleRowSelection = (id) => {
    setSelectedRows(prev => ({ ...prev, [id]: !prev[id] }));
  };
  const toggleAllRows = () => {
    if (Object.keys(selectedRows).length === data.length) {
      setSelectedRows({});
    } else {
      const allSelected = {};
      data.forEach(row => allSelected[row.id] = true);
      setSelectedRows(allSelected);
    }
  };
  const selectedCount = Object.values(selectedRows).filter(Boolean).length;

  // --- Preparar datos para tabla ---
  const filteredEntradas = useMemo(() => {
    if (!filterId.trim()) return entradas;
    return entradas.filter(e => e.idEntrada.toString() === filterId.trim());
  }, [entradas, filterId]);

  const data = useMemo(() => {
    return filteredEntradas.map(e => {
      const producto = productos.find(p => p.idProducto === e.Producto_id)?.Nombre || "—";
      const proveedor = proveedores.find(p => p.idProveedor === e.Proveedor_id)?.Nombre_Empresa || "—";
      const responsable = usuarios.find(u => u.idPersona === e.Persona_id)?.Nombre || "—";
      const fechaFormateada = new Date(e.Fecha).toISOString().split("T")[0];
      return {
        id: e.idEntrada,
        fecha: fechaFormateada,
        producto,
        cantidad: e.Cantidad,
        proveedor,
        Proveedor_id: e.Proveedor_id,
        responsable,
      };
    });
  }, [filteredEntradas, productos, proveedores, usuarios]);

  // --- Columnas con checkbox ---
  const columns = useMemo(() => [
    {
      Header: (
        <input
          type="checkbox"
          checked={selectedCount === data.length && data.length > 0}
          onChange={toggleAllRows}
        />
      ),
      id: "selection",
      Cell: ({ row }) => (
        <input
          type="checkbox"
          checked={!!selectedRows[row.original.id]}
          onChange={() => toggleRowSelection(row.original.id)}
        />
      ),
      disableSortBy: true,
    },
    { Header: "ID", accessor: "id" },
    { Header: "Fecha", accessor: "fecha" },
    { Header: "Producto", accessor: "producto" },
    { Header: "Cantidad", accessor: "cantidad" },
    { Header: "Proveedor", accessor: "proveedor" },
    { Header: "Responsable", accessor: "responsable" },
    {
      Header: "Acciones",
      accessor: "acciones",
      disableSortBy: true,
      Cell: ({ row }) => (
        <div className="d-flex gap-2 justify-content-center">
          <button className="btn btn-light p-0 border-0" onClick={() => abrirModalEditar(row.original)} title="Editar">
            <BiPencil size={20} color="#555" />
          </button>
          <button className="btn btn-light p-0 border-0" onClick={() => handleDelete(row.original.id)} title="Eliminar">
            <BiTrash size={20} color="#ff4d4f" />
          </button>
        </div>
      ),
    },
  ], [selectedRows, data, selectedCount]);

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
  } = useTable({ columns, data, initialState: { pageSize: 10 } }, useGlobalFilter, useSortBy, usePagination);

  const { globalFilter, pageIndex } = state;

  // --- Detectar si es móvil ---
  const [isMobile, setIsMobile] = useState(window.innerWidth < 768);
  useEffect(() => {
    const handleResize = () => setIsMobile(window.innerWidth < 768);
    window.addEventListener("resize", handleResize);
    return () => window.removeEventListener("resize", handleResize);
  }, []);

  // --- Render ---
  return (
    <div className="min-vh-100 position-relative bg-blur">
      {sidebarVisible && <div className="position-fixed top-0 start-0 w-100 h-100" style={{ background: "rgba(0,0,0,0.3)", zIndex: 1900 }} />}

      {/* Sidebar */}
      <div
        ref={sidebarRef}
        className="position-fixed top-0 start-0 vh-100 bg-white shadow p-3 d-flex flex-column gap-3"
        style={{ width: 240, transform: sidebarVisible ? "translateX(0)" : "translateX(-100%)", transition: "transform 0.3s ease-in-out", zIndex: 2000 }}
        onMouseLeave={() => setSidebarVisible(false)}
      >
        {sidebarItems.map((item, i) => (
          <button key={i} onClick={() => { item.action(); setSidebarVisible(false); }} className="d-flex align-items-center gap-2 p-2 rounded border-0 bg-light text-dark" style={{ marginTop: i === 0 ? "4rem" : 0 }}>
            {item.icon} <span>{item.label}</span>
          </button>
        ))}
      </div>

      {/* Botón hamburguesa */}
      <button id="btn-toggle-sidebar" className="btn btn-light position-fixed top-3 start-3" style={{ zIndex: 2100 }} onClick={() => setSidebarVisible(!sidebarVisible)}>
        &#9776;
      </button>

      {/* Contenido principal */}
      <div className="container px-3 pt-5">
        <h4 className="mb-3 fw-bold text-center">Listado de Entradas</h4>

        {/* Botones selección múltiple */}
        {selectedCount > 0 && (
          <div className="mb-3 d-flex gap-2 justify-content-center flex-wrap">
            <button className="btn btn-warning" onClick={() => {
              const ids = Object.keys(selectedRows).filter(id => selectedRows[id]);
              ids.forEach(id => {
                const entrada = data.find(d => d.id === parseInt(id));
                if (entrada) abrirModalEditar(entrada);
              });
            }}>
              Editar proveedor ({selectedCount})
            </button>
            <button className="btn btn-danger" onClick={() => {
              const ids = Object.keys(selectedRows).filter(id => selectedRows[id]);
              Swal.fire({
                title: `Eliminar ${ids.length} entradas?`,
                icon: "warning",
                showCancelButton: true,
                confirmButtonText: "Sí, eliminar",
                cancelButtonText: "Cancelar",
              }).then(async (result) => {
                if (!result.isConfirmed) return;
                try {
                  await Promise.all(ids.map(id => fetch(`http://localhost:3001/api/entrada/entrada/${id}`, { method: "DELETE", headers: { Authorization: `Bearer ${token}` } })));
                  Swal.fire("Eliminadas", `${ids.length} entradas eliminadas`, "success");
                  fetchEntradas();
                  setSelectedRows({});
                } catch {
                  Swal.fire("Error", "No se pudieron eliminar todas las entradas ❌", "error");
                }
              });
            }}>
              Eliminar ({selectedCount})
            </button>
          </div>
        )}

        {/* Buscadores */}
        <div className="mb-3 d-flex justify-content-center gap-3 flex-wrap">
          <input value={globalFilter || ""} onChange={(e) => setGlobalFilter(e.target.value)} className="form-control w-50" placeholder="Buscar entrada (producto, proveedor, etc.)" />
          <input type="number" value={filterId} onChange={(e) => setFilterId(e.target.value)} className="form-control w-25" placeholder="Buscar por ID exacto" />
        </div>

        {/* Tabla o Cards según tamaño */}
        {isMobile ? (
          <div className="d-flex flex-column gap-3">
            {data.length === 0 ? (
              <p className="text-center">No hay entradas.</p>
            ) : data.map(row => (
              <div key={row.id} className="card shadow-sm p-3">
                <div className="d-flex justify-content-between align-items-start">
                  <div>
                    <h6>ID: {row.id}</h6>
                    <p className="mb-1"><strong>Fecha:</strong> {row.fecha}</p>
                    <p className="mb-1"><strong>Producto:</strong> {row.producto}</p>
                    <p className="mb-1"><strong>Cantidad:</strong> {row.cantidad}</p>
                    <p className="mb-1"><strong>Proveedor:</strong> {row.proveedor}</p>
                    <p className="mb-1"><strong>Responsable:</strong> {row.responsable}</p>
                  </div>
                  <div className="d-flex flex-column gap-2">
                    <button className="btn btn-light p-1 border-0" onClick={() => abrirModalEditar(row)} title="Editar">
                      <BiPencil size={20} color="#555" />
                    </button>
                    <button className="btn btn-light p-1 border-0" onClick={() => handleDelete(row.id)} title="Eliminar">
                      <BiTrash size={20} color="#ff4d4f" />
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <table {...getTableProps()} className="table table-bordered table-hover shadow-sm">
            <thead className="table-success">
              {headerGroups.map(headerGroup => (
                <tr {...headerGroup.getHeaderGroupProps()}>
                  {headerGroup.headers.map(column => (
                    <th {...column.getHeaderProps(column.getSortByToggleProps())} style={{ cursor: column.canSort ? "pointer" : "default" }}>
                      {column.render("Header")}
                      {column.canSort && (
                        <span>{column.isSorted ? (column.isSortedDesc ? " 🔽" : " 🔼") : ""}</span>
                      )}
                    </th>
                  ))}
                </tr>
              ))}
            </thead>
            <tbody {...getTableBodyProps()}>
              {page.length === 0 ? (
                <tr>
                  <td colSpan={columns.length} className="text-center">No hay entradas.</td>
                </tr>
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
        )}

        {/* Paginación solo en tabla */}
        {!isMobile && (
          <div className="d-flex justify-content-between align-items-center mt-3">
            <button className="btn btn-outline-success btn-sm" onClick={() => previousPage()} disabled={!canPreviousPage}>← Anterior</button>
            <span>Página {pageIndex + 1} de {pageOptions.length}</span>
            <button className="btn btn-outline-success btn-sm" onClick={() => nextPage()} disabled={!canNextPage}>Siguiente →</button>
          </div>
        )}

        {/* Botón extra */}
        <div className="text-center mt-4">
          <button className="btn btn-success" onClick={() => navigate("/registro-entradas")}>
            <i className="bi bi-plus-circle me-1"></i> Registrar nueva entrada
          </button>
        </div>
      </div>
    </div>
  );
}
