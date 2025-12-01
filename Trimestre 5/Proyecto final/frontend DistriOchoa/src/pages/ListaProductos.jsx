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
  BiUndo,
  BiLineChart,
  BiPencil,
  BiTrash,
} from "react-icons/bi";
import { useTable, useSortBy, useGlobalFilter, usePagination } from "react-table";
import "bootstrap/dist/css/bootstrap.min.css";
import "bootstrap/dist/js/bootstrap.bundle.min.js";
import "../assets/styles.css";

export default function ListaProductos() {
  const [productos, setProductos] = useState([]);
  const [categorias, setCategorias] = useState([]);
  const [mensaje, setMensaje] = useState("");
  const [sidebarVisible, setSidebarVisible] = useState(false);
  const sidebarRef = useRef(null);
  const [filterId, setFilterId] = useState("");
  const [selectedIds, setSelectedIds] = useState([]);
  const [isMobile, setIsMobile] = useState(window.innerWidth < 768);

  const navigate = useNavigate();
  const token = localStorage.getItem("token");
  const rol = (localStorage.getItem("rol") || "").toLowerCase();

  // ==================== RESPONSIVE ====================
  useEffect(() => {
    const handleResize = () => setIsMobile(window.innerWidth < 768);
    window.addEventListener("resize", handleResize);
    return () => window.removeEventListener("resize", handleResize);
  }, []);

  // ==================== AUTH ====================
  useEffect(() => {
    if (!token || !rol) navigate("/select-role", { replace: true });
  }, [navigate, token, rol]);

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

  // ==================== SIDEBAR ====================
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
    { label: "Salir", icon: <BiLogOut />, action: cerrarSesion },
  ];

  useEffect(() => {
    const handleClickOutside = (e) => {
      if (sidebarRef.current && !sidebarRef.current.contains(e.target)) {
        setSidebarVisible(false);
      }
    };
    if (sidebarVisible) document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [sidebarVisible]);

  // ==================== FETCH ====================
  useEffect(() => {
    fetchProductos();
    fetchCategorias();
  }, []);

  const fetchProductos = async () => {
    try {
      const res = await fetch("http://localhost:3001/api/producto/producto", {
        headers: { Authorization: `Bearer ${token}` },
      });
      if (!res.ok) throw new Error();
      const data = await res.json();
      setProductos(data.body || []);
    } catch {
      Swal.fire("Error", "No se pudieron cargar los productos", "error");
    }
  };

  const fetchCategorias = async () => {
    try {
      const res = await fetch("http://localhost:3001/api/categoria/categoria", {
        headers: { Authorization: `Bearer ${token}` },
      });
      if (!res.ok) throw new Error();
      const data = await res.json();
      setCategorias(data.body || []);
    } catch {
      Swal.fire("Error", "No se pudieron cargar las categorías", "error");
    }
  };

  // ==================== ACCIONES INDIVIDUALES ====================
  const eliminarProducto = async (id) => {
    const confirmar = await Swal.fire({
      title: "¿Eliminar este producto?",
      icon: "warning",
      showCancelButton: true,
      confirmButtonText: "Sí, eliminar",
      cancelButtonText: "Cancelar",
      confirmButtonColor: "#d33",
    });
    if (!confirmar.isConfirmed) return;

    try {
      const res = await fetch(`http://localhost:3001/api/producto/producto/${id}`, {
        method: "DELETE",
        headers: { Authorization: `Bearer ${token}` },
      });
      if (!res.ok) throw new Error();
      setMensaje("Producto eliminado correctamente");
      fetchProductos();
    } catch {
      Swal.fire("Error", "No se pudo eliminar el producto", "error");
    }
  };

  const abrirModalEditar = (producto) => {
    Swal.fire({
      title: `Editar producto: ${producto.Nombre}`,
      html: `
        <input id="swal-nombre" class="swal2-input" value="${producto.Nombre}" />
        <input id="swal-precio" class="swal2-input" value="${producto.Precio}" />
        <input id="swal-cantidad" class="swal2-input" value="${producto.Cantidad_Actual}" />
        <select id="swal-categoria" class="swal2-select">
          ${categorias
            .map(
              (c) =>
                `<option value="${c.idCategoria}" ${
                  c.idCategoria === producto.Categoria_id ? "selected" : ""
                }>${c.Nombre_Categoria}</option>`
            )
            .join("")}
        </select>`,
      focusConfirm: false,
      confirmButtonColor: "#198754",
      cancelButtonColor: "#ccc",
      preConfirm: () => ({
        Nombre: document.getElementById("swal-nombre").value,
        Precio: document.getElementById("swal-precio").value,
        Cantidad_Actual: document.getElementById("swal-cantidad").value,
        Categoria_id: document.getElementById("swal-categoria").value,
      }),
    }).then(async (result) => {
      if (!result.isConfirmed) return;
      try {
        const res = await fetch(
          `http://localhost:3001/api/producto/producto/${producto.idProducto}`,
          {
            method: "PUT",
            headers: {
              "Content-Type": "application/json",
              Authorization: `Bearer ${token}`,
            },
            body: JSON.stringify(result.value),
          }
        );
        if (!res.ok) throw new Error();
        Swal.fire("Éxito", "Producto actualizado correctamente", "success");
        fetchProductos();
      } catch {
        Swal.fire("Error", "No se pudo actualizar el producto", "error");
      }
    });
  };

  // ==================== ACCIONES MASIVAS ====================
  const toggleSelectAll = () => {
    if (selectedIds.length === data.length) setSelectedIds([]);
    else setSelectedIds(data.map((p) => p.id));
  };

  const toggleSelectOne = (id) => {
    setSelectedIds((prev) =>
      prev.includes(id) ? prev.filter((x) => x !== id) : [...prev, id]
    );
  };

  const eliminarSeleccionados = async () => {
    const confirm = await Swal.fire({
      title: `¿Eliminar ${selectedIds.length} productos?`,
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#d33",
    });
    if (!confirm.isConfirmed) return;

    try {
      await Promise.all(
        selectedIds.map((id) =>
          fetch(`http://localhost:3001/api/producto/producto/${id}`, {
            method: "DELETE",
            headers: { Authorization: `Bearer ${token}` },
          })
        )
      );
      setSelectedIds([]);
      fetchProductos();
      Swal.fire("Eliminados", "Productos eliminados correctamente", "success");
    } catch {
      Swal.fire("Error", "No se pudieron eliminar algunos productos", "error");
    }
  };

  const cambiarCategoriaSeleccionados = async () => {
    const { value: categoriaId } = await Swal.fire({
      title: "Cambiar categoría",
      input: "select",
      inputOptions: categorias.reduce((acc, c) => {
        acc[c.idCategoria] = c.Nombre_Categoria;
        return acc;
      }, {}),
      inputPlaceholder: "Selecciona una categoría",
      showCancelButton: true,
    });
    if (!categoriaId) return;

    try {
      await Promise.all(
        selectedIds.map((id) =>
          fetch(`http://localhost:3001/api/producto/producto/${id}`, {
            method: "PUT",
            headers: {
              "Content-Type": "application/json",
              Authorization: `Bearer ${token}`,
            },
            body: JSON.stringify({ Categoria_id: categoriaId }),
          })
        )
      );
      setSelectedIds([]);
      fetchProductos();
      Swal.fire("Actualizados", "Categoría cambiada correctamente", "success");
    } catch {
      Swal.fire("Error", "No se pudieron actualizar los productos", "error");
    }
  };

  // ==================== TABLE ====================
  const filteredProductos = useMemo(() => {
    if (!filterId.trim()) return productos;
    return productos.filter((p) => p.idProducto.toString() === filterId.trim());
  }, [productos, filterId]);

  const data = useMemo(() => {
    return filteredProductos.map((prod) => {
      const categoria =
        categorias.find((c) => c.idCategoria === prod.Categoria_id)?.Nombre_Categoria ||
        "—";
      return {
        id: prod.idProducto,
        nombre: prod.Nombre,
        precio: prod.Precio,
        cantidad: prod.Cantidad_Actual,
        categoria,
        acciones: prod,
      };
    });
  }, [filteredProductos, categorias]);

  const columns = useMemo(
    () => [
      {
        Header: (
          <input
            type="checkbox"
            checked={selectedIds.length === data.length && data.length > 0}
            onChange={toggleSelectAll}
          />
        ),
        accessor: "seleccionar",
        disableSortBy: true,
        Cell: ({ row }) => (
          <input
            type="checkbox"
            checked={selectedIds.includes(row.original.id)}
            onChange={() => toggleSelectOne(row.original.id)}
          />
        ),
      },
      { Header: "ID", accessor: "id" },
      { Header: "Nombre", accessor: "nombre" },
      { Header: "Precio", accessor: "precio" },
      { Header: "Cantidad", accessor: "cantidad" },
      { Header: "Categoría", accessor: "categoria" },
      {
        Header: "Acciones",
        accessor: "acciones",
        disableSortBy: true,
        Cell: ({ value }) => (
          <div className="d-flex justify-content-center gap-1">
            <button
              className="btn btn-light p-0 border-0"
              onClick={() => abrirModalEditar(value)}
              title="Editar"
            >
              <BiPencil color="#555" size={20} />
            </button>
            <button
              className="btn btn-light p-0 border-0"
              onClick={() => eliminarProducto(value.idProducto)}
              title="Eliminar"
            >
              <BiTrash color="#ff4d4f" size={20} />
            </button>
          </div>
        ),
      },
    ],
    [categorias, selectedIds, data]
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
  } = useTable({ columns, data, initialState: { pageSize: 10 } }, useGlobalFilter, useSortBy, usePagination);

  const { globalFilter, pageIndex } = state;

  // ==================== RENDER ====================
  return (
    <div className="min-vh-100 position-relative bg-blur">
      {/* Overlay sidebar */}
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
          width: 240,
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
            className="d-flex align-items-center gap-2 p-2 rounded border-0 bg-light text-dark"
            style={{ marginTop: i === 0 ? "4rem" : 0 }}
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

      <div className="container px-3 pt-5">
        <h4 className="mb-3 fw-bold text-center">Listado de Productos</h4>

        {/* Buscadores */}
        <div className="mb-3 d-flex justify-content-center gap-3 flex-wrap">
          <input
            value={globalFilter || ""}
            onChange={(e) => setGlobalFilter(e.target.value)}
            className="form-control w-50"
            placeholder="Buscar producto (nombre, precio, etc.)"
          />
          <input
            type="number"
            value={filterId}
            onChange={(e) => setFilterId(e.target.value)}
            className="form-control w-25"
            placeholder="Buscar por ID exacto"
          />
        </div>

        {/* Acciones masivas */}
        {selectedIds.length > 0 && (
          <div className="alert alert-secondary d-flex justify-content-between align-items-center mt-3 flex-wrap">
            <span>{selectedIds.length} productos seleccionados</span>
            <div className="d-flex gap-2 mt-2 mt-md-0">
              <button className="btn btn-danger btn-sm" onClick={eliminarSeleccionados}>
                Eliminar
              </button>
              <button className="btn btn-success btn-sm" onClick={cambiarCategoriaSeleccionados}>
                Cambiar categoría
              </button>
            </div>
          </div>
        )}

        {/* Lista responsive móvil */}
        {isMobile ? (
          <div className="d-flex flex-column gap-3">
            {data
              .filter((prod) => !globalFilter || prod.nombre.toLowerCase().includes(globalFilter.toLowerCase()) || prod.categoria.toLowerCase().includes(globalFilter.toLowerCase()) || prod.precio.toString().includes(globalFilter))
              .filter((prod) => !filterId.trim() || prod.id.toString() === filterId.trim())
              .map((prod) => (
                <div key={prod.id} className="card shadow-sm" style={{ borderRadius: "12px", padding: "1rem", textAlign: "center" }}>
                  <h5 className="card-title mb-2">{prod.nombre}</h5>
                  <div className="d-flex justify-content-center gap-2 flex-wrap mb-2">
                    <span className="badge bg-success">{prod.precio} $</span>
                    <span className="badge bg-success">{prod.cantidad} uds</span>
                    <span className="badge bg-dark text-white">{prod.categoria}</span>
                  </div>
                  <div className="d-flex justify-content-center gap-2">
                    <button className="btn btn-light p-0 border-0" onClick={() => abrirModalEditar(prod.acciones)}>
                      <BiPencil size={20} />
                    </button>
                    <button className="btn btn-light p-0 border-0" onClick={() => eliminarProducto(prod.id)}>
                      <BiTrash size={20} color="#ff4d4f" />
                    </button>
                  </div>
                </div>
              ))}
          </div>
        ) : (
          // Tabla desktop
          <table {...getTableProps()} className="table table-bordered table-hover shadow-sm">
            <thead className="table-success">
              {headerGroups.map((headerGroup) => (
                <tr {...headerGroup.getHeaderGroupProps()}>
                  {headerGroup.headers.map((column) => (
                    <th {...column.getHeaderProps(column.getSortByToggleProps())} style={{ cursor: column.canSort ? "pointer" : "default" }}>
                      {column.render("Header")}
                      {column.canSort && <span>{column.isSorted ? (column.isSortedDesc ? " 🔽" : " 🔼") : ""}</span>}
                    </th>
                  ))}
                </tr>
              ))}
            </thead>
            <tbody {...getTableBodyProps()}>
              {page.length === 0 ? (
                <tr>
                  <td colSpan={columns.length} className="text-center">
                    No hay productos.
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
        )}

        {/* Paginación desktop */}
        {!isMobile && (
          <div className="d-flex justify-content-between align-items-center mt-3">
            <button className="btn btn-outline-success btn-sm" onClick={() => previousPage()} disabled={!canPreviousPage}>
              ← Anterior
            </button>
            <span>
              Página {pageIndex + 1} de {pageOptions.length}
            </span>
            <button className="btn btn-outline-success btn-sm" onClick={() => nextPage()} disabled={!canNextPage}>
              Siguiente →
            </button>
          </div>
        )}

        <div className="text-center mt-4">
          <button className="btn btn-success" onClick={() => navigate("/registro-productos")}>
            <i className="bi bi-plus-circle me-1"></i> Volver a registrar producto
          </button>
        </div>

        {mensaje && <div className="alert alert-info mt-4 text-center">{mensaje}</div>}
      </div>
    </div>
  );
}
