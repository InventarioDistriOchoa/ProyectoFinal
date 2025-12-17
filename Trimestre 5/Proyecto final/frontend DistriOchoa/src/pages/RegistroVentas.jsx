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
  BiLineChart,
  BiCart,
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

  const [ventas, setVentas] = useState([]);

  const [personaId, setPersonaId] = useState("");
  const [nombreResponsable, setNombreResponsable] = useState("");

  // ---- productos y carrito (SIN clientes) ----
  const [productos, setProductos] = useState([]);
  const [productoId, setProductoId] = useState("");
  const [cantidad, setCantidad] = useState(1);
  const [carrito, setCarrito] = useState(() => {
    try {
      const saved = localStorage.getItem("carrito_venta");
      return saved ? JSON.parse(saved) : [];
    } catch (e) {
      console.error("Error leyendo carrito_venta de localStorage", e);
      return [];
    }
  });

  // Modal edición
  const [modalVisible, setModalVisible] = useState(false);
  const [ventaEdit, setVentaEdit] = useState(null);

  // Filtrado por ID y selección múltiple
  const [idFilter, setIdFilter] = useState("");
  const [selectedRows, setSelectedRows] = useState([]);

  const [usuarios, setUsuarios] = useState([]);

  // =======================
  //   CARGA DE DATOS BASE
  // =======================

  // Guardar carrito en localStorage cuando cambie
  useEffect(() => {
    try {
      localStorage.setItem("carrito_venta", JSON.stringify(carrito));
    } catch (e) {
      console.error("Error guardando carrito_venta en localStorage", e);
    }
  }, [carrito]);

  // Usuarios (para mostrar responsable en listado)
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
    if (token) fetchUsuarios();
  }, [token]);

  // Perfil (responsable)
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
    if (token) fetchProfile();
  }, [token]);

  // Productos para combos
  useEffect(() => {
    const fetchProductos = async () => {
      try {
        const res = await fetch("http://localhost:3001/api/producto/producto", {
          headers: { Authorization: `Bearer ${token}` },
        });
        if (!res.ok) throw new Error("No se pudieron cargar los productos");
        const data = await res.json();
        setProductos(data.body || []);
      } catch (err) {
        console.error(err);
        Swal.fire("Error", "No se pudieron cargar los productos", "error");
      }
    };

    if (token) fetchProductos();
  }, [token]);

  // Ventas existentes (listado)
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

  useEffect(() => {
    if (token) fetchVentas();
  }, [token]);

  // =======================
  //   SESIÓN / SIDEBAR
  // =======================

  const cerrarSesion = async () => {
    // 🔹 Si hay productos en el carrito, preguntar primero
    if (carrito.length > 0) {
      const result = await Swal.fire({
        icon: "warning",
        title: "Tienes productos en tu carrito",
        text: "Si cierras sesión, los productos del carrito se perderán. ¿Quieres continuar?",
        showCancelButton: true,
        confirmButtonText: "Sí, cerrar sesión",
        cancelButtonText: "Cancelar",
        confirmButtonColor: "#d33",
        cancelButtonColor: "#198754",
      });

      if (!result.isConfirmed) {
        // El usuario se arrepintió, no cerramos sesión
        return;
      }
    }

    // Si no hay carrito o aceptó perderlo, cerramos sesión normal
    try {
      await fetch("http://localhost:3001/api/persona/logout", {
        method: "POST",
        headers: { Authorization: `Bearer ${token}` },
      });
    } catch (err) {
      console.error(err);
    } finally {
      // Limpio todo, incluido carrito_venta
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
      label: "Productos",
      icon: <BiFile />,
      action: () => navigate("/lista-productos"),
    },
    {
      label: "Entradas",
      icon: <BiFile />,
      action: () => navigate("/lista-entradas"),
    },
    { label: "Ventas", icon: <BiFile />, action: () => navigate("/ventas") },
    {
      label: "Devoluciones",
      icon: <BiUndo />,
      action: () => navigate("/devoluciones"),
    },
    {
      label: "Categorías",
      icon: <BiCategory />,
      action: () => navigate("/categorias"),
    },
    { label: "Stock", icon: <BiBox />, action: () => navigate("/stock") },
    {
      label: "Reportes",
      icon: <BiLineChart />,
      action: () => navigate("/reportes"),
    },
    // puedes dejar o quitar "Detalle Venta" según tu router
    {
      label: "Detalle Venta",
      icon: <BiBox />,
      action: () => navigate("/registro-detalle-venta"),
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
    {
      label: "Mi Perfil",
      icon: <BiUser />,
      action: () => navigate("/my-profile"),
    },
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

  // =======================
  //   CARRITO / REGISTRO
  // =======================

  const totalVenta = useMemo(
    () =>
      carrito.reduce(
        (acc, item) => acc + item.cantidad * (item.precio || 0),
        0
      ),
    [carrito]
  );

  const totalItemsCarrito = useMemo(
    () => carrito.reduce((acc, item) => acc + (item.cantidad || 0), 0),
    [carrito]
  );

 const handleAgregarAlCarrito = () => {
  if (!productoId) {
    return Swal.fire("Error", "Selecciona un producto", "warning");
  }
  if (!cantidad || cantidad <= 0) {
    return Swal.fire("Error", "La cantidad debe ser mayor a 0", "warning");
  }

  const idNum = parseInt(productoId, 10);
  const prod = productos.find((p) => p.idProducto === idNum);
  if (!prod) {
    return Swal.fire("Error", "Producto no encontrado", "error");
  }

  // 🟢 STOCK DISPONIBLE (usa el campo que tienes en la BD)
  const stockDisponible =
    prod.Cantidad_Actual ??
    prod.cantidad_actual ??
    prod.stock ??
    prod.disponible ??
    0;

  // 🔎 Ver cuánto ya hay en el carrito de ese producto
  const existenteEnCarrito = carrito.find((item) => item.id === idNum);
  const cantidadEnCarrito = existenteEnCarrito ? existenteEnCarrito.cantidad : 0;

  const cantidadSolicitada = Number(cantidad);
  const nuevaCantidadTotal = cantidadEnCarrito + cantidadSolicitada;

  // 🚫 Validar contra stock
  if (nuevaCantidadTotal > stockDisponible) {
    return Swal.fire(
      "Stock insuficiente",
      `Solo quedan ${stockDisponible} unidad(es) de "${prod.Nombre || prod.nombre}". 
Ya tienes ${cantidadEnCarrito} en el carrito y estás intentando agregar ${cantidadSolicitada} más.`,
      "warning"
    );
  }

  const precioProd =
    prod.Precio ||
    prod.PrecioVenta ||
    prod.precio ||
    prod.precioVenta ||
    0;

  setCarrito((prev) => {
    const existe = prev.find((item) => item.id === idNum);
    if (existe) {
      // Si ya está en el carrito, sumamos cantidad
      return prev.map((item) =>
        item.id === idNum
          ? { ...item, cantidad: item.cantidad + cantidadSolicitada }
          : item
      );
    }
    // Si no estaba, lo agregamos nuevo
    return [
      ...prev,
      {
        id: idNum,
        nombre: prod.Nombre || prod.nombre || "Producto",
        precio: precioProd,
        cantidad: cantidadSolicitada,
      },
    ];
  });

  // 🧮 Stock restante después de agregar
  const stockRestante = stockDisponible - nuevaCantidadTotal;

  Swal.fire(
    "Producto agregado",
    `Añadiste ${cantidadSolicitada} unidad(es) de "${
      prod.Nombre || prod.nombre
    }".\nStock restante en inventario: ${stockRestante} unidad(es).`,
    "success"
  );

  setCantidad(1);
  setProductoId("");
};


  const handleQuitarDelCarrito = (id) => {
    setCarrito((prev) => prev.filter((item) => item.id !== id));
  };

  // Usar tu backend tal cual
  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!fecha || !personaId) {
      return Swal.fire(
        "Error",
        "La fecha y el responsable son obligatorios",
        "warning"
      );
    }

    if (carrito.length === 0) {
      return Swal.fire(
        "Error",
        "Debes agregar al menos un producto al carrito",
        "warning"
      );
    }

    try {
      // 1) Crear la venta
      const ventaPayload = {
        Fecha: fecha,
        Total: 0, // el total real lo recalcula el backend con los detalles
        Persona_id: personaId,
      };

      const resVenta = await fetch("http://localhost:3001/api/venta/venta", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(ventaPayload),
      });

      const dataVenta = await resVenta.json();
      if (!resVenta.ok) {
        return Swal.fire(
          "Error",
          dataVenta.message || dataVenta.Message || "No se pudo crear la venta",
          "error"
        );
      }

      const idVenta = dataVenta.body.idVenta;

      // 2) Crear cada detalle usando tu endpoint /detalleVenta/detalleVenta
      for (const item of carrito) {
        const detallePayload = {
          Cantidad: item.cantidad,
          PrecioUnitario: item.precio,
          Subtotal: item.cantidad * item.precio,
          Venta_id: idVenta,
          Producto_id: item.id,
        };

        const resDet = await fetch(
          "http://localhost:3001/api/detalleVenta/detalleVenta",
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              Authorization: `Bearer ${token}`,
            },
            body: JSON.stringify(detallePayload),
          }
        );

        const dataDet = await resDet.json();
        if (!resDet.ok) {
          return Swal.fire(
            "Error",
            dataDet.Message || "Error al registrar un detalle de venta",
            "error"
          );
        }
      }

      Swal.fire("¡Éxito!", "Venta registrado correctamente", "success");

      // Recargar listado de ventas
      await fetchVentas();

      // Limpiar formulario y carrito
      setCarrito([]);
      setFecha(new Date().toISOString().split("T")[0]);
      setVista("listado");
    } catch (err) {
      console.error(err);
      Swal.fire("Error", "No se pudo registrar la venta completa", "error");
    }
  };

  // =======================
  //   LISTADO / TABLA
  // =======================

  const dataTabla = useMemo(() => {
    return ventas.map((v) => ({
      id: v.idVenta,
      fecha: new Date(v.Fecha).toISOString().split("T")[0],
      total: v.Total,
      responsable:
        usuarios.find((u) => u.idPersona === v.Persona_id)?.Nombre || "—",
    }));
  }, [ventas, usuarios]);

  // Filtrado por ID
  const filteredData = useMemo(() => {
    return dataTabla.filter(
      (v) => !idFilter || v.id.toString().includes(idFilter)
    );
  }, [dataTabla, idFilter]);

  const abrirModalEditar = (venta) => {
    setVentaEdit({ ...venta });
    setModalVisible(true);
  };

  const handleUpdate = async () => {
    if (!ventaEdit.fecha)
      return Swal.fire("Error", "La fecha es obligatoria", "warning");
    try {
      const res = await fetch(
        `http://localhost:3001/api/venta/venta/${ventaEdit.id}`,
        {
          method: "PUT",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${token}`,
          },
          body: JSON.stringify({ Fecha: ventaEdit.fecha }),
        }
      );
      const data = await res.json();
      if (res.ok) {
        Swal.fire("Éxito", "Venta actualizada correctamente", "success");
        setModalVisible(false);
        await fetchVentas();
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
    setSelectedRows((prev) =>
      prev.includes(id) ? prev.filter((x) => x !== id) : [...prev, id]
    );
  };

  const toggleSelectAll = (page) => {
    if (selectedRows.length === page.length) setSelectedRows([]);
    else setSelectedRows(page.map((r) => r.original.id));
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
        await Promise.all(
          selectedRows.map((id) =>
            fetch(`http://localhost:3001/api/venta/venta/${id}`, {
              method: "DELETE",
              headers: { Authorization: `Bearer ${token}` },
            })
          )
        );
        Swal.fire("Eliminado", "Ventas eliminadas correctamente", "success");
        setVentas((prev) => prev.filter((v) => !selectedRows.includes(v.idVenta)));
        setSelectedRows([]);
      } catch {
        Swal.fire(
          "Error",
          "No se pudieron eliminar todas las ventas",
          "error"
        );
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
        await Promise.all(
          selectedRows.map((id) =>
            fetch(`http://localhost:3001/api/venta/venta/${id}`, {
              method: "PUT",
              headers: {
                "Content-Type": "application/json",
                Authorization: `Bearer ${token}`,
              },
              body: JSON.stringify({ Fecha: newDate }),
            })
          )
        );
        Swal.fire("Éxito", "Fecha actualizada correctamente", "success");
        await fetchVentas();
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
     <div
  className="container px-3 pt-3"
  style={{ marginTop: "0.5rem" }}
>

        {/* Selector de vista */}
        <div className="d-flex justify-content-center gap-2 mb-4">
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

        {/* REGISTRO CON CARRITO (SIN CLIENTES) */}
        {vista === "registro" && (
          // Un solo form que envuelve ambas tarjetas
          <form onSubmit={handleSubmit}>
            <div className="row justify-content-center g-3">
              {/* Tarjeta izquierda: datos básicos + agregar al carrito */}
              <div className="col-lg-5">
                <div className="card p-4 shadow-sm h-100">
                  <h5 className="mb-3 text-success fw-bold">Datos de la venta</h5>

                  <div className="row g-3 mb-3">
                    <div className="col-12">
                      <label className="form-label">Fecha</label>
                      <input
                        type="date"
                        className="form-control"
                        value={fecha}
                        onChange={(e) => setFecha(e.target.value)}
                      />
                    </div>
                    <div className="col-12">
                      <label className="form-label">Responsable</label>
                      <input
                        type="text"
                        className="form-control"
                        value={nombreResponsable}
                        readOnly
                      />
                    </div>
                  </div>

                  <hr />

                  {/* Selector de producto y cantidad */}
                  <h6 className="mb-3 fw-semibold">Agregar producto al carrito</h6>
                  <div className="row g-3 align-items-end">
                    <div className="col-12">
                      <label className="form-label">Producto</label>
                      <select
                        className="form-select"
                        value={productoId}
                        onChange={(e) => setProductoId(e.target.value)}
                      >
                        <option value="">Seleccione un producto</option>
                        {productos.map((p) => (
                          <option key={p.idProducto} value={p.idProducto}>
                            {p.Nombre || p.nombre} - $
                            {p.Precio || p.PrecioVenta || p.precio}
                          </option>
                        ))}
                      </select>
                    </div>
                    <div className="col-6">
                      <label className="form-label">Cantidad</label>
                      <input
                        type="number"
                        className="form-control"
                        min="1"
                        value={cantidad}
                        onChange={(e) => setCantidad(Number(e.target.value))}
                      />
                    </div>
                    <div className="col-6 d-grid">
                      <button
                        type="button"
                        className="btn btn-outline-success"
                        onClick={handleAgregarAlCarrito}
                      >
                        Agregar al carrito
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              {/* Tarjeta derecha: resumen del carrito + tabla + total */}
              <div className="col-lg-7">
                <div className="card p-4 shadow-sm h-100 d-flex flex-column">
                  {/* Header carrito con ícono y numerito dentro */}
                  <div className="d-flex justify-content-between align-items-center mb-3">
                    <div className="d-flex align-items-center gap-2">
                      <div
                        className="position-relative d-inline-flex align-items-center justify-content-center rounded-circle"
                        style={{
                          width: "46px",
                          height: "46px",
                          border: "2px solid #198754",
                        }}
                      >
                        <BiCart
                          style={{ color: "#198754", fontSize: "1.6rem" }}
                        />
                        {totalItemsCarrito > 0 && (
                          <span
                            className="position-absolute d-flex align-items-center justify-content-center"
                            style={{
                              top: "-4px",
                              right: "-4px",
                              width: "20px",
                              height: "20px",
                              borderRadius: "50%",
                              backgroundColor: "#dc3545",
                              color: "#fff",
                              fontSize: "0.75rem",
                              fontWeight: "bold",
                            }}
                          >
                            {totalItemsCarrito}
                          </span>
                        )}
                      </div>
                      <div>
                        <h5 className="mb-0 fw-bold text-success">Carrito</h5>
                        <small className="text-muted">
                          Productos agregados a esta venta
                        </small>
                      </div>
                    </div>
                  </div>

                  {/* Tabla carrito */}
                  <div className="table-responsive mb-3 flex-grow-1">
                    <table className="table table-bordered table-striped mb-0">
                      <thead className="table-success">
                        <tr>
                          <th>Producto</th>
                          <th>Cantidad</th>
                          <th>Precio unitario</th>
                          <th>Subtotal</th>
                          <th>Acciones</th>
                        </tr>
                      </thead>
                      <tbody>
                        {carrito.length === 0 ? (
                          <tr>
                            <td colSpan={5} className="text-center">
                              No hay productos en el carrito
                            </td>
                          </tr>
                        ) : (
                          carrito.map((item) => (
                            <tr key={item.id}>
                              <td>{item.nombre}</td>
                              <td>{item.cantidad}</td>
                              <td>${item.precio}</td>
                              <td>${item.cantidad * item.precio}</td>
                              <td>
                                <button
                                  type="button"
                                  className="btn btn-sm btn-danger"
                                  onClick={() => handleQuitarDelCarrito(item.id)}
                                >
                                  <BiTrash /> Quitar
                                </button>
                              </td>
                            </tr>
                          ))
                        )}
                      </tbody>
                    </table>
                  </div>

                  {/* Total y botón registrar */}
                  <div className="d-flex justify-content-between align-items-center mt-2">
                    <h5 className="mb-0">
                      Total:{" "}
                      <span className="text-success fw-bold">
                        ${totalVenta}
                      </span>
                    </h5>
                    <button type="submit" className="btn btn-success">
                      Registrar Venta
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </form>
        )}

        {/* LISTADO */}
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
                <button
                  className="btn btn-danger btn-sm"
                  onClick={handleDeleteMultiple}
                >
                  Eliminar seleccionadas
                </button>
                <button
                  className="btn btn-warning btn-sm"
                  onClick={handleUpdateMultiple}
                >
                  Cambiar fecha seleccionadas
                </button>
              </div>
            )}

            {/* Tabla para escritorio */}
            <table
              {...getTableProps()}
              id="ventas-table"
              className="table table-bordered table-hover shadow-sm"
            >
              <thead className="table-success">
                {headerGroups.map((headerGroup) => (
                  <tr {...headerGroup.getHeaderGroupProps()}>
                    <th>
                      <input
                        type="checkbox"
                        checked={
                          selectedRows.length === page.length && page.length > 0
                        }
                        onChange={() => toggleSelectAll(page)}
                      />
                    </th>
                    {headerGroup.headers.map((column) => (
                      <th
                        {...column.getHeaderProps(
                          column.getSortByToggleProps()
                        )}
                      >
                        {column.render("Header")}
                        {column.canSort &&
                          (column.isSorted
                            ? column.isSortedDesc
                              ? " 🔽"
                              : " 🔼"
                            : "")}
                      </th>
                    ))}
                  </tr>
                ))}
              </thead>
              <tbody {...getTableBodyProps()}>
                {page.length === 0 ? (
                  <tr>
                    <td colSpan={columns.length + 1} className="text-center">
                      No hay ventas.
                    </td>
                  </tr>
                ) : (
                  page.map((row) => {
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
                        {row.cells.map((cell) => (
                          <td {...cell.getCellProps()}>
                            {cell.render("Cell")}
                          </td>
                        ))}
                      </tr>
                    );
                  })
                )}
              </tbody>
            </table>

            {/* Cards para móvil */}
            {page.map((row) => {
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
                  <div>
                    <strong>Fecha:</strong> {row.original.fecha}
                  </div>
                  <div>
                    <strong>Total:</strong> {row.original.total}
                  </div>
                  <div>
                    <strong>Responsable:</strong> {row.original.responsable}
                  </div>
                  <div className="d-flex gap-2 mt-2">
                    <button
                      className="btn btn-warning btn-sm"
                      onClick={() => abrirModalEditar(row.original)}
                    >
                      <BiPencil /> Editar
                    </button>
                    <button
                      className="btn btn-danger btn-sm"
                      onClick={() => handleDelete(row.original.id)}
                    >
                      <BiTrash /> Eliminar
                    </button>
                  </div>
                </div>
              );
            })}

            <div className="d-flex justify-content-between align-items-center mt-3 flex-wrap gap-2">
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

        {/* Modal edición */}
        {modalVisible && ventaEdit && (
          <div className="modal d-block" tabIndex="-1">
            <div className="modal-dialog">
              <div className="modal-content">
                <div className="modal-header">
                  <h5 className="modal-title">Editar Venta {ventaEdit.id}</h5>
                  <button
                    type="button"
                    className="btn-close"
                    onClick={() => setModalVisible(false)}
                  ></button>
                </div>
                <div className="modal-body">
                  <label className="form-label">Fecha</label>
                  <input
                    type="date"
                    className="form-control"
                    value={ventaEdit.fecha}
                    onChange={(e) =>
                      setVentaEdit({
                        ...ventaEdit,
                        fecha: e.target.value,
                      })
                    }
                  />
                </div>
                <div className="modal-footer">
                  <button
                    className="btn btn-secondary"
                    onClick={() => setModalVisible(false)}
                  >
                    Cancelar
                  </button>
                  <button className="btn btn-success" onClick={handleUpdate}>
                    Guardar
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
          <footer className="footer-dashboard mt-auto py-3 text-center">
        © 2025 <strong>DistriOchoa</strong>. Todos los derechos reservados.
      </footer>
    </div>
  );
}
