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
  BiUser,
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

  // Datos base
  const [ventas, setVentas] = useState([]);
  const [productos, setProductos] = useState([]);
  const [detalles, setDetalles] = useState([]);

  // Filtro
  const [ventaSeleccionada, setVentaSeleccionada] = useState("");
  const [idFilter, setIdFilter] = useState("");

  // Modal edición
  const [modalVisible, setModalVisible] = useState(false);
  const [detalleEdit, setDetalleEdit] = useState(null);

  const rol = (localStorage.getItem("rol") || "").toLowerCase();

  // =======================
  //  Sidebar / Sesión
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
    if (sidebarVisible) document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [sidebarVisible]);

  // =======================
  //   CARGA DE DATOS
  // =======================

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

      const [dataV, dataP, dataD] = await Promise.all([
        resV.json(),
        resP.json(),
        resD.json(),
      ]);

      setVentas(dataV.body || []);
      setProductos(dataP.body || []);
      setDetalles(dataD.body || []);
    } catch (err) {
      console.error(err);
      Swal.fire("Error", "No se pudieron cargar los datos", "error");
    }
  };

  // =======================
  //   EDITAR DETALLE
  // =======================

  const abrirModalEditar = (detalle) => {
    setDetalleEdit({
      id: detalle.id,
      cantidad: detalle.Cantidad || detalle.cantidad,
      precioUnitario: detalle.PrecioUnitario || detalle.precioUnitario,
      subtotal: detalle.Subtotal || detalle.subtotal,
      Venta_id: detalle.Venta_id,
      Producto_id: detalle.Producto_id,
    });
    setModalVisible(true);
  };

  const handleUpdate = async () => {
    if (!detalleEdit || !detalleEdit.cantidad || !detalleEdit.precioUnitario) {
      return Swal.fire("Error", "Cantidad y precio son obligatorios", "warning");
    }

    try {
      const res = await fetch(
        `http://localhost:3001/api/detalleVenta/detalleVenta/${detalleEdit.id}`,
        {
          method: "PUT",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${token}`,
          },
          body: JSON.stringify({
            Cantidad: parseInt(detalleEdit.cantidad, 10),
            PrecioUnitario: parseFloat(detalleEdit.precioUnitario),
            Subtotal: parseFloat(detalleEdit.subtotal),
            Venta_id: detalleEdit.Venta_id,
            Producto_id: detalleEdit.Producto_id,
          }),
        }
      );
      const data = await res.json();
      if (res.ok) {
        Swal.fire("Éxito", "Detalle de venta actualizado", "success");
        setModalVisible(false);
        fetchAll();
      } else {
        Swal.fire("Error", data.Message || "No se pudo actualizar", "error");
      }
    } catch (err) {
      console.error(err);
      Swal.fire("Error", "No se pudo actualizar", "error");
    }
  };

  // =======================
  //   ELIMINAR DETALLE
  // =======================

  const handleDelete = async (id) => {
    const confirm = await Swal.fire({
      icon: "warning",
      title: "¿Eliminar detalle de venta?",
      showCancelButton: true,
      confirmButtonText: "Sí, eliminar",
      cancelButtonText: "Cancelar",
    });
    if (!confirm.isConfirmed) return;

    try {
      const res = await fetch(
        `http://localhost:3001/api/detalleVenta/detalleVenta/${id}`,
        {
          method: "DELETE",
          headers: { Authorization: `Bearer ${token}` },
        }
      );
      const data = await res.json();
      if (res.ok) {
        Swal.fire("Eliminado", "Detalle eliminado correctamente", "success");
        fetchAll();
      } else {
        Swal.fire("Error", data.Message || "No se pudo eliminar", "error");
      }
    } catch (err) {
      console.error(err);
      Swal.fire("Error", "No se pudo eliminar", "error");
    }
  };
  

  // =======================
  //   TABLA (LISTADO)
  // =======================

  const dataTabla = useMemo(
    () =>
      detalles.map((d) => {
        const venta = ventas.find((v) => v.idVenta === d.Venta_id);
        const producto = productos.find((p) => p.idProducto === d.Producto_id);

        const fechaVenta = venta
          ? new Date(venta.Fecha).toISOString().split("T")[0]
          : "—";

        return {
          id: d.idDetalleVenta,
          Venta_id: d.Venta_id,
          ventaLabel: venta ? `#${venta.idVenta}` : "—",
          fecha: fechaVenta,
          producto: producto ? producto.Nombre || producto.nombre : "—",
          cantidad: d.Cantidad,
          precioUnitario: d.PrecioUnitario,
          subtotal: d.Subtotal,
          Producto_id: d.Producto_id,
        };
      }),
    [detalles, ventas, productos]
  );

  const filtradoPorVenta = useMemo(
    () =>
      dataTabla.filter((d) =>
        ventaSeleccionada
          ? d.Venta_id === parseInt(ventaSeleccionada, 10)
          : true
      ),
    [dataTabla, ventaSeleccionada]
  );

  const filteredData = useMemo(
    () =>
      filtradoPorVenta.filter(
        (d) =>
          !idFilter ||
          d.id.toString().includes(idFilter) ||
          d.Venta_id.toString().includes(idFilter)
      ),
    [filtradoPorVenta, idFilter]
  );

   const columns = useMemo(
    () => [
      { Header: "ID Detalle", accessor: "id" },
      { Header: "Venta", accessor: "ventaLabel" },
      { Header: "Fecha Venta", accessor: "fecha" },
      { Header: "Producto", accessor: "producto" },
      { Header: "Cantidad", accessor: "cantidad" },
      { Header: "Precio Unitario", accessor: "precioUnitario" },
      { Header: "Subtotal", accessor: "subtotal" },
      {
        Header: "Acciones",
        accessor: "acciones",
        Cell: ({ row }) => (
          <div className="d-flex gap-2 justify-content-center flex-wrap">
           <button
  className="btn btn-sm btn-primary"
  title="Editar"
  onClick={() => abrirModalEditar(row.original)}
>
  <BiPencil />
</button>

<button
  className="btn btn-sm btn-danger"
  title="Eliminar"
  onClick={() => handleDelete(row.original.id)}
>
  <BiTrash />
</button>

<button
  type="button"
  className="btn btn-sm btn-success"
  title="Ver factura PDF"
  onClick={() =>
    window.open(
      `http://localhost:3001/api/factura/${row.original.Venta_id}/${token}`,
      "_blank"
    )
  }
>
  Ver factura
</button>



          </div>
        ),
      },
    ],
    [] // eslint-disable-line react-hooks/exhaustive-deps
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

  // =======================
  //   RENDER
  // =======================

  return (
    <div className="min-vh-100 position-relative myprofile-background">
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
                (e.currentTarget.style.backgroundColor = "#f8f9fa")}
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
      <header
        className="dashboard-header-top d-flex align-items-center px-4 py-2 position-relative"
        style={{ background: "transparent" }}
      >
        <div className="header-center position-absolute top-50 start-50 translate-middle text-center">
          <div
            className="app-name"
            style={{
              color: "#198754",
              fontWeight: "bold",
              fontSize: "1.9rem",
            }}
          >
            Detalle de Venta
          </div>
        </div>
      </header>

      {/* Contenido */}
      {/* Contenido */}
<div
  className="container px-2"
  style={{
    marginTop: "-10px",
    paddingTop: "0px",
  }}
>


        {/* Filtro por venta */}
        <div className="row mb-3 justify-content-center">
          <div className="col-md-6">
            <label className="form-label">Filtrar por Venta</label>
            <select
              className="form-select"
              value={ventaSeleccionada}
              onChange={(e) => setVentaSeleccionada(e.target.value)}
            >
              <option value="">Todas las ventas</option>
              {ventas.map((v) => (
                <option key={v.idVenta} value={v.idVenta}>
                  #{v.idVenta} - {new Date(v.Fecha).toISOString().split("T")[0]}
                </option>
              ))}
            </select>
          </div>
        </div>

        {/* Buscadores */}
        <div className="mb-3 d-flex justify-content-center gap-2 flex-wrap">
          <input
            value={globalFilter || ""}
            onChange={(e) => setGlobalFilter(e.target.value)}
            className="form-control w-50"
            placeholder="Buscar (producto, etc.)"
          />
          <input
            value={idFilter || ""}
            onChange={(e) => setIdFilter(e.target.value)}
            className="form-control w-25"
            placeholder="Filtrar por ID o Venta"
          />
        </div>

        {/* Tabla */}
        <table
          {...getTableProps()}
          className="table table-bordered table-hover shadow-sm"
        >
          <thead className="table-success">
            {headerGroups.map((headerGroup) => (
              <tr {...headerGroup.getHeaderGroupProps()}>
                {headerGroup.headers.map((column) => (
                  <th
                    {...column.getHeaderProps(
                      column.getSortByToggleProps()
                    )}
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

      {/* Modal edición */}
      {modalVisible && detalleEdit && (
        <div
          className="position-fixed top-0 start-0 w-100 h-100 d-flex align-items-center justify-content-center"
          style={{ backgroundColor: "rgba(0,0,0,0.35)", zIndex: 3000 }}
        >
          <div
            className="bg-white shadow-lg rounded-4 p-4 position-relative"
            style={{ width: "420px", maxWidth: "90%" }}
          >
            <button
              type="button"
              className="btn-close position-absolute top-0 end-0 m-2"
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
                  setDetalleEdit({
                    ...detalleEdit,
                    cantidad: e.target.value,
                  })
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
                  setDetalleEdit({
                    ...detalleEdit,
                    subtotal: e.target.value,
                  })
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
        </div>
      )}
          <footer className="footer-dashboard mt-auto py-3 text-center">
        © 2025 <strong>DistriOchoa</strong>. Todos los derechos reservados.
      </footer>
    </div>
  );
}
