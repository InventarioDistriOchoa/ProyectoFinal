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

export default function RegistroDetalleVenta() {
  const navigate = useNavigate();
  const sidebarRef = useRef(null);
  const token = localStorage.getItem("token");

  const [sidebarVisible, setSidebarVisible] = useState(false);
  const [vista, setVista] = useState("registro");

  // Datos
  const [ventas, setVentas] = useState([]);
  const [productos, setProductos] = useState([]);
  const [detalles, setDetalles] = useState([]);

  // Formulario
  const [ventaId, setVentaId] = useState("");
  const [productoId, setProductoId] = useState("");
  const [cantidad, setCantidad] = useState("");
  const [precioUnitario, setPrecioUnitario] = useState("");
  const [subtotal, setSubtotal] = useState("");

  // Modal edición
  const [modalVisible, setModalVisible] = useState(false);
  const [detalleEdit, setDetalleEdit] = useState(null);

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

  const rol = (localStorage.getItem("rol") || "").toLowerCase();
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
  useEffect(() => {
    if (!token) return;
    fetchAll();
  }, [token]);

  const fetchAll = async () => {
    try {
      const [resV, resP, resD] = await Promise.all([
        fetch("http://localhost:3001/api/venta/venta", {
          headers: { Authorization: `Bearer ${token}` },
        }),
        fetch("http://localhost:3001/api/producto/producto", {
          headers: { Authorization: `Bearer ${token}` },
        }),
        fetch("http://localhost:3001/api/detalleVenta/detalleVenta", {
          headers: { Authorization: `Bearer ${token}` },
        }),
      ]);
      const [dataV, dataP, dataD] = await Promise.all([resV.json(), resP.json(), resD.json()]);
      setVentas(dataV.body || []);
      setProductos(dataP.body || []);
      setDetalles(dataD.body || []);
    } catch {
      Swal.fire("Error", "No se pudieron cargar los datos", "error");
    }
  };

  useEffect(() => {
    if (vista === "listado") fetchAll();
  }, [vista]);

  // ---- Registrar DetalleVenta ----
  const handleSubmit = async (e) => {
    e.preventDefault();
    const cantidadNum = parseInt(cantidad, 10);
    const precioNum = parseFloat(precioUnitario);

    if (!ventaId || !productoId || !cantidadNum || !precioNum) {
      return Swal.fire("Error", "Todos los campos son obligatorios", "warning");
    }

    const productoSel = productos.find((p) => p.idProducto === parseInt(productoId, 10));
    if (!productoSel) {
      return Swal.fire("Error", "Producto no encontrado", "error");
    }
    const stock = productoSel.Cantidad_Actual ?? 0;
    if (cantidadNum > stock) {
      return Swal.fire("Error", `Stock insuficiente. Disponible: ${stock}`, "warning");
    }

    const nuevoDetalle = {
      Cantidad: cantidadNum,
      PrecioUnitario: precioNum,
      Subtotal: parseFloat(subtotal) || cantidadNum * precioNum,
      Venta_id: parseInt(ventaId, 10),
      Producto_id: parseInt(productoId, 10),
    };

    try {
      const res = await fetch("http://localhost:3001/api/detalleVenta/detalleVenta", {
        method: "POST",
        headers: { "Content-Type": "application/json", Authorization: `Bearer ${token}` },
        body: JSON.stringify(nuevoDetalle),
      });
      const data = await res.json();
      if (res.ok) {
        Swal.fire("Éxito", "Detalle de venta registrado", "success");
        await fetchAll();
        setVentaId(""); setProductoId(""); setCantidad(""); setPrecioUnitario(""); setSubtotal("");
      } else {
        Swal.fire("Error", data.Message || "No se pudo registrar", "error");
      }
    } catch {
      Swal.fire("Error", "No se pudo registrar", "error");
    }
  };

  // ---- Abrir modal edición ----
  const abrirModalEditar = (detalle) => {
    setDetalleEdit({
      id: detalle.id,
      ventaId: detalle.Venta_id || detalle.ventaId,
      productoId: detalle.Producto_id || detalle.productoId,
      cantidad: detalle.Cantidad || detalle.cantidad,
      precioUnitario: detalle.PrecioUnitario || detalle.precioUnitario,
      subtotal: detalle.Subtotal || detalle.subtotal,
    });
    setModalVisible(true);
  };

  // ---- Guardar edición ----
  const handleUpdate = async () => {
    if (!detalleEdit.ventaId || !detalleEdit.productoId || !detalleEdit.cantidad || !detalleEdit.precioUnitario) {
      return Swal.fire("Error", "Todos los campos son obligatorios", "warning");
    }
    try {
      const res = await fetch(`http://localhost:3001/api/detalleVenta/detalleVenta/${detalleEdit.id}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json", Authorization: `Bearer ${token}` },
        body: JSON.stringify({
          Cantidad: parseInt(detalleEdit.cantidad, 10),
          PrecioUnitario: parseFloat(detalleEdit.precioUnitario),
          Subtotal: parseFloat(detalleEdit.subtotal),
          Venta_id: parseInt(detalleEdit.ventaId, 10),
          Producto_id: parseInt(detalleEdit.productoId, 10),
        }),
      });
      const data = await res.json();
      if (res.ok) {
        Swal.fire("Éxito", "Detalle de venta actualizado", "success");
        setModalVisible(false);
        fetchAll();
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
      title: "¿Eliminar detalle de venta?",
      showCancelButton: true,
      confirmButtonText: "Sí, eliminar",
      cancelButtonText: "Cancelar",
    });
    if (confirm.isConfirmed) {
      try {
        const res = await fetch(`http://localhost:3001/api/detalleVenta/detalleVenta/${id}`, {
          method: "DELETE",
          headers: { Authorization: `Bearer ${token}` },
        });
        const data = await res.json();
        if (res.ok) {
          Swal.fire("Eliminado", "Detalle eliminado correctamente", "success");
          fetchAll();
        } else {
          Swal.fire("Error", data.Message || "No se pudo eliminar", "error");
        }
      } catch {
        Swal.fire("Error", "No se pudo eliminar", "error");
      }
    }
  };

  // ---- Tabla ----
  const data = useMemo(() =>
    detalles.map((d) => {
      const venta = ventas.find((v) => v.idVenta === d.Venta_id);
      const producto = productos.find((p) => p.idProducto === d.Producto_id);
      const fechaVenta = venta ? new Date(venta.Fecha).toISOString().split("T")[0] : "—";
      return {
        id: d.idDetalleVenta,
        venta: venta ? `#${venta.idVenta}` : "—",
        fecha: fechaVenta,
        producto: producto?.Nombre || "—",
        cantidad: d.Cantidad,
        precioUnitario: d.PrecioUnitario,
        subtotal: d.Subtotal,
        Venta_id: d.Venta_id,
        Producto_id: d.Producto_id,
      };
    }), [detalles, ventas, productos]
  );

  const columns = useMemo(() => [
    { Header: "ID", accessor: "id" },
    { Header: "Venta", accessor: "venta" },
    { Header: "Fecha Venta", accessor: "fecha" },
    { Header: "Producto", accessor: "producto" },
    { Header: "Cantidad", accessor: "cantidad" },
    { Header: "Precio Unitario", accessor: "precioUnitario" },
    { Header: "Subtotal", accessor: "subtotal" },
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
  ], []);

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
        <h4 className="text-center mb-4 fw-bold text-success">Detalle de Venta</h4>

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
            <div className="card shadow-lg p-4 rounded-5" style={{ maxWidth: "700px", width: "100%" }}>
              <form onSubmit={handleSubmit} className="row g-3">
                <div className="col-md-6">
                  <label className="form-label">Venta</label>
                  <select
                    className="form-control rounded-3 shadow-sm"
                    value={ventaId}
                    onChange={(e) => setVentaId(e.target.value)}
                    required
                  >
                    <option value="">Seleccione</option>
                    {ventas.map((v) => (
                      <option key={v.idVenta} value={v.idVenta}>
                        #{v.idVenta} - {new Date(v.Fecha).toISOString().split("T")[0]}
                      </option>
                    ))}
                  </select>
                </div>

                <div className="col-md-6">
                  <label className="form-label">Producto</label>
                  <select
                    className="form-control rounded-3 shadow-sm"
                    value={productoId}
                    onChange={(e) => {
                      const id = e.target.value;
                      setProductoId(id);
                      const prod = productos.find(p => p.idProducto === parseInt(id, 10));
                      setPrecioUnitario(prod ? prod.Precio : "");
                    }}
                    required
                  >
                    <option value="">Seleccione</option>
                    {productos.map((p) => (
                      <option key={p.idProducto} value={p.idProducto}>
                        {p.Nombre}
                      </option>
                    ))}
                  </select>
                </div>

                <div className="col-md-4">
                  <label className="form-label">Cantidad</label>
                  <input
                    type="number"
                    className="form-control rounded-3 shadow-sm"
                    value={cantidad}
                    onChange={(e) => setCantidad(e.target.value)}
                    required
                  />
                </div>

                <div className="col-md-4">
                  <label className="form-label">Precio Unitario</label>
                  <input
                    type="number"
                    className="form-control rounded-3 shadow-sm"
                    value={precioUnitario}
                    onChange={(e) => setPrecioUnitario(e.target.value)}
                    required
                  />
                </div>

                <div className="col-md-4">
                  <label className="form-label">Subtotal</label>
                  <input
                    type="number"
                    className="form-control rounded-3 shadow-sm"
                    value={
                      subtotal ||
                      (cantidad && precioUnitario
                        ? parseFloat(cantidad) * parseFloat(precioUnitario)
                        : "")
                    }
                    onChange={(e) => setSubtotal(e.target.value)}
                    placeholder="Calculado automáticamente"
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
                placeholder="Buscar detalle (producto, venta, etc.)"
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
                      No hay detalles de venta.
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

      {/* Modal Editar Detalle */}
      {modalVisible && detalleEdit && (
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

            <h5 className="text-success mb-3 text-center">
              Editar Detalle #{detalleEdit.id}
            </h5>

            <div className="mb-3">
              <label className="form-label">Cantidad</label>
              <input
                type="number"
                className="form-control"
                value={detalleEdit.cantidad}
                onChange={(e) =>
                  setDetalleEdit({ ...detalleEdit, cantidad: e.target.value })
                }
              />
            </div>
            <div className="mb-3">
              <label className="form-label">Precio Unitario</label>
              <input
                type="number"
                className="form-control"
                value={detalleEdit.precioUnitario}
                onChange={(e) =>
                  setDetalleEdit({
                    ...detalleEdit,
                    precioUnitario: e.target.value,
                  })
                }
              />
            </div>
            <div className="mb-3">
              <label className="form-label">Subtotal</label>
              <input
                type="number"
                className="form-control"
                value={detalleEdit.subtotal}
                onChange={(e) =>
                  setDetalleEdit({ ...detalleEdit, subtotal: e.target.value })
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
