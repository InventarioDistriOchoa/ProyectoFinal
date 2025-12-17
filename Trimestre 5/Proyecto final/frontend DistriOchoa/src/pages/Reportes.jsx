// src/pages/Reportes.jsx
import { useState, useEffect, useRef, useMemo } from "react";
import { useNavigate } from "react-router-dom";
import Swal from "sweetalert2";
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  BarElement,
  ArcElement,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
} from "chart.js";
import { Bar, Doughnut, Line } from "react-chartjs-2";
import "bootstrap/dist/css/bootstrap.min.css";
import "bootstrap/dist/js/bootstrap.bundle.min.js";
import "../assets/styles.css";
import {
  BiHome,
  BiBox,
  BiUser,
  BiCategory,
  BiLogOut,
  BiFile,
  BiUndo,
  BiLineChart,
  BiReceipt,           // 👈 IMPORTAMOS EL ICONO DE FACTURA
} from "react-icons/bi";

ChartJS.register(
  CategoryScale,
  LinearScale,
  BarElement,
  ArcElement,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend
);

export default function Reportes() {
  const navigate = useNavigate();
  const sidebarRef = useRef(null);
  const [nombre, setNombre] = useState("");
  const [rol, setRol] = useState("");
  const [sidebarVisible, setSidebarVisible] = useState(false);
  const [foto, setFoto] = useState("/uploads/default-avatar.png");

  // 👉 helper: es admin o superadmin
  const esAdmin = rol === "admin" || rol === "superadmin";

  // Estados de gráficos
  const [productosMasVendidos, setProductosMasVendidos] = useState(null);
  const [entradasPorMes, setEntradasPorMes] = useState(null);
  const [distribucionCategoria, setDistribucionCategoria] = useState(null);
  const [stockActual, setStockActual] = useState(null);
  const [resumen, setResumen] = useState({
    productos: 0,
    categorias: 0,
    stockTotal: 0,
  });
  const [alertasStock, setAlertasStock] = useState([]);

  // Paginación interna para alertas
  const [paginaActual, setPaginaActual] = useState(1);
  const ITEMS_POR_PAGINA = 10;
  const [busqueda, setBusqueda] = useState("");

  useEffect(() => {
    const storedNombre = localStorage.getItem("nombre");
    const storedRol = localStorage.getItem("rol");
    if (!storedNombre || !storedRol) navigate("/select-role");

    setNombre(storedNombre || "");
    setRol((storedRol || "").toLowerCase());

    const fetchProfile = async () => {
      try {
        const token = localStorage.getItem("token");
        const res = await fetch("http://localhost:3001/api/persona/me", {
          headers: { Authorization: `Bearer ${token}` },
        });
        if (!res.ok) throw new Error();
        const data = await res.json();
        if (data.body?.Foto) setFoto(data.body.Foto);
      } catch (err) {
        console.error(err);
      }
    };
    fetchProfile();
  }, [navigate]);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const token = localStorage.getItem("token");

        // Stock
        const stockRes = await fetch("http://localhost:3001/api/stock", {
          headers: { Authorization: `Bearer ${token}` },
        });
        const stockJson = await stockRes.json();
        const stockData = stockJson.body || [];

        setStockActual({
          labels: stockData.map((p) => p.producto),
          datasets: [
            {
              label: "Stock",
              data: stockData.map((p) => p.disponible),
              backgroundColor: "#20c997",
            },
          ],
        });

        setAlertasStock(
          stockData.map((p) => ({ producto: p.producto, estado: p.estado }))
        );
        setPaginaActual(1); // Resetear página cuando cambian los datos

        // Distribución por categoría
        const categoriasCount = {};
        stockData.forEach((p) => {
          categoriasCount[p.categoria] = (categoriasCount[p.categoria] || 0) + 1;
        });

        setDistribucionCategoria({
          labels: Object.keys(categoriasCount),
          datasets: [
            {
              data: Object.values(categoriasCount),
              backgroundColor: [
                "#ffc107",
                "#198754",
                "#0d6efd",
                "#fd7e14",
                "#6f42c1",
              ],
            },
          ],
        });

        // Entradas por mes
        const entradasRes = await fetch(
          "http://localhost:3001/api/entrada/entrada",
          {
            headers: { Authorization: `Bearer ${token}` },
          }
        );
        const entradasJson = await entradasRes.json();
        const entradas = Array.isArray(entradasJson.body)
          ? entradasJson.body
          : [entradasJson.body];
        const entradasPorMesData = {};
        entradas.forEach((e) => {
          const mes = new Date(e.Fecha).toLocaleString("es-ES", {
            month: "short",
          });
          entradasPorMesData[mes] =
            (entradasPorMesData[mes] || 0) + e.Cantidad;
        });
        setEntradasPorMes({
          labels: Object.keys(entradasPorMesData),
          datasets: [
            {
              label: "Entradas",
              data: Object.values(entradasPorMesData),
              borderColor: "#0d6efd",
              fill: false,
            },
          ],
        });

        // Productos más vendidos
        const ventasRes = await fetch(
          "http://localhost:3001/api/detalleVenta/detalleVenta",
          {
            headers: { Authorization: `Bearer ${token}` },
          }
        );
        const ventasJson = await ventasRes.json();
        const ventas = Array.isArray(ventasJson.body)
          ? ventasJson.body
          : [ventasJson.body];
        const ventasCount = {};
        ventas.forEach((v) => {
          ventasCount[v.Producto_id] =
            (ventasCount[v.Producto_id] || 0) + v.Cantidad;
        });

        const productosLabels = stockData.map((p) => p.producto);
        const productosIds = stockData.map((p) => p.id);
        setProductosMasVendidos({
          labels: productosLabels,
          datasets: [
            {
              label: "Unidades vendidas",
              data: productosIds.map((id) => ventasCount[id] || 0),
              backgroundColor: "#198754",
            },
          ],
        });

        // Resumen general
        setResumen({
          productos: stockData.length,
          categorias: Object.keys(categoriasCount).length,
          stockTotal: stockData.reduce((acc, p) => acc + p.disponible, 0),
        });
      } catch (err) {
        console.error("Error cargando reportes:", err);
      }
    };

    fetchData();
  }, []);

  const cerrarSesion = async () => {
    try {
      const token = localStorage.getItem("token");
      await fetch("http://localhost:3001/api/persona/logout", {
        method: "POST",
        headers: { Authorization: `Bearer ${token}` },
      });
    } catch {}
    localStorage.clear();
    Swal.fire({
      icon: "success",
      title: "Sesión cerrada ✅",
      confirmButtonColor: "#198754",
    }).then(() => navigate("/select-role", { replace: true }));
  };

  // ---------- Sidebar según rol ----------
  const sidebarItems = useMemo(() => {
    const items = [
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
    ];

    // 👉 Solo admin / superadmin ven REPORTES
    if (esAdmin) {
      items.push({
        label: "Reportes",
        icon: <BiLineChart />,
        action: () => navigate("/reportes"),
      });
    }

    // 👉 Solo admin / superadmin ven Usuarios
    if (esAdmin) {
      items.push({
        label: "Usuarios",
        icon: <BiUser />,
        action: () => navigate("/usuarios"),
      });
    }

    items.push(
      {
        label: "Mi Perfil",
        icon: <BiUser />,
        action: () => navigate("/my-profile"),
      },
      { label: "Salir", icon: <BiLogOut />, action: cerrarSesion }
    );

    return items;
  }, [esAdmin, navigate]);

  useEffect(() => {
    const handleClickOutside = (e) => {
      if (sidebarRef.current && !sidebarRef.current.contains(e.target))
        setSidebarVisible(false);
    };
    if (sidebarVisible)
      document.addEventListener("mousedown", handleClickOutside);
    return () =>
      document.removeEventListener("mousedown", handleClickOutside);
  }, [sidebarVisible]);

  const renderIconoEstado = (estado) => {
    if (estado === "rojo")
      return (
        <i className="bi bi-exclamation-triangle-fill text-danger me-2"></i>
      );
    if (estado === "amarillo")
      return (
        <i className="bi bi-exclamation-circle-fill text-warning me-2"></i>
      );
    if (estado === "verde")
      return (
        <i className="bi bi-check-circle-fill text-success me-2"></i>
      );
    return null;
  };

  // ---------- RENDER ----------
  return (
    <div className="min-vh-100 d-flex flex-column usuarios-background">
      {sidebarVisible && (
        <div
          className="position-fixed top-0 start-0 w-100 h-100"
          style={{ background: "rgba(0,0,0,0.3)", zIndex: 1900 }}
        ></div>
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
      >
        {sidebarItems.map((item, i) => (
          <button
            key={i}
            onClick={() => {
              item.action();
              setSidebarVisible(false);
            }}
            className="d-flex align-items-center gap-2 p-2 rounded shadow-sm border-0 bg-light text-dark"
            style={{
              cursor: "pointer",
              transition: "all 0.2s",
              marginTop: i === 0 ? "4rem" : "0",
            }}
          >
            {item.icon} <span>{item.label}</span>
          </button>
        ))}
      </div>

      <button
        id="btn-toggle-sidebar"
        onClick={() => setSidebarVisible(!sidebarVisible)}
        style={{ position: "absolute", top: 20, left: 20, zIndex: 2100 }}
      >
        &#9776;
      </button>

      {/* Header */}
      <header
        className="dashboard-header-top d-flex justify-content-between align-items-center px-4 py-2"
        style={{ backgroundColor: "transparent" }}
      >
        <div></div>
        <div className="text-center flex-grow-1">
          <h2 className="fw-bold text-success m-0">
            📊 Reportes del Inventario
          </h2>
        </div>
        <div className="header-right d-flex align-items-center gap-3">
          <div className="dropdown">
            <button
              className="btn p-0 border-0 bg-transparent dropdown-toggle"
              type="button"
              id="perfilDropdown"
              data-bs-toggle="dropdown"
            >
              <img
                src={`http://localhost:3001${foto}`}
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
            <ul className="dropdown-menu dropdown-menu-end">
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

      {/* Main */}
      <main className="container py-5 flex-grow-1">
        {/* 👉 Botones de acciones arriba (solo admins) */}
        {esAdmin && (
          <div className="d-flex justify-content-end gap-2 mb-3">
            <button
              className="btn btn-outline-success d-flex align-items-center gap-2"
              onClick={() => navigate("/facturas")}
            >
              <BiReceipt />
              Facturas
            </button>

            <button
              className="btn btn-success d-flex align-items-center gap-2"
              onClick={() => navigate("/historial")}
            >
              <i className="bi bi-clock-history"></i>
              Ver historial
            </button>
          </div>
        )}

        <div className="row g-4">
          {/* Columna izquierda */}
          <div className="col-12 col-lg-6 d-flex flex-column gap-4">
            <div className="card p-3 shadow h-100">
              <h5 className="text-center">Productos más vendidos</h5>
              {productosMasVendidos && <Bar data={productosMasVendidos} />}
            </div>

            {/* CARD ALERTAS DE STOCK */}
            <div className="card p-3 shadow h-100">
              <h5 className="text-center">Alertas de Stock</h5>

              {/* Buscador */}
              <input
                type="text"
                className="form-control mb-2"
                placeholder="Buscar producto..."
                value={busqueda}
                onChange={(e) => {
                  setBusqueda(e.target.value);
                  setPaginaActual(1); // resetear a la primera página cuando se filtra
                }}
              />

              <ul className="list-group list-group-flush">
                {alertasStock.length > 0 ? (
                  alertasStock
                    .filter((a) =>
                      a.producto
                        .toLowerCase()
                        .includes(busqueda.toLowerCase())
                    )
                    .slice(
                      (paginaActual - 1) * ITEMS_POR_PAGINA,
                      paginaActual * ITEMS_POR_PAGINA
                    )
                    .map((a, i) => (
                      <li
                        key={i}
                        className="list-group-item d-flex align-items-center"
                      >
                        {renderIconoEstado(a.estado)} {a.producto}
                      </li>
                    ))
                ) : (
                  <li className="list-group-item text-success d-flex align-items-center">
                    <i className="bi bi-check-circle-fill me-2"></i> Todo el
                    stock está en óptimas condiciones
                  </li>
                )}
              </ul>

              {/* Paginación */}
              {alertasStock.filter((a) =>
                a.producto.toLowerCase().includes(busqueda.toLowerCase())
              ).length > ITEMS_POR_PAGINA && (
                <div className="d-flex justify-content-between mt-2">
                  <button
                    className="btn btn-sm btn-outline-secondary"
                    disabled={paginaActual === 1}
                    onClick={() =>
                      setPaginaActual((prev) => Math.max(prev - 1, 1))
                    }
                  >
                    Anterior
                  </button>
                  <span className="align-self-center">
                    {paginaActual} /{" "}
                    {Math.ceil(
                      alertasStock.filter((a) =>
                        a.producto
                          .toLowerCase()
                          .includes(busqueda.toLowerCase())
                      ).length / ITEMS_POR_PAGINA
                    )}
                  </span>
                  <button
                    className="btn btn-sm btn-outline-secondary"
                    disabled={
                      paginaActual ===
                      Math.ceil(
                        alertasStock.filter((a) =>
                          a.producto
                            .toLowerCase()
                            .includes(busqueda.toLowerCase())
                        ).length / ITEMS_POR_PAGINA
                      )
                    }
                    onClick={() =>
                      setPaginaActual((prev) => prev + 1)
                    }
                  >
                    Siguiente
                  </button>
                </div>
              )}
            </div>

            <div className="card p-3 shadow h-100">
              <h5 className="text-center">Entradas por mes</h5>
              {entradasPorMes && <Line data={entradasPorMes} />}
            </div>

            <div className="card p-3 shadow h-100">
              <h5 className="text-center mb-3">Resumen general</h5>
              <ul className="list-group list-group-flush small">
                <li className="list-group-item">
                  <i className="bi bi-box-seam text-success me-2"></i> Productos
                  registrados: <strong>{resumen.productos}</strong>
                </li>
                <li className="list-group-item">
                  <i className="bi bi-tags text-info me-2"></i> Categorías
                  activas: <strong>{resumen.categorias}</strong>
                </li>
                <li className="list-group-item">
                  <i className="bi bi-archive-fill text-warning me-2"></i> Stock
                  total disponible:{" "}
                  <strong>{resumen.stockTotal}</strong>
                </li>
              </ul>
            </div>
          </div>

          {/* Columna derecha */}
          <div className="col-12 col-lg-6 d-flex flex-column gap-4">
            <div className="card p-3 shadow">
              <h5 className="text-center">Distribución por categoría</h5>
              {distribucionCategoria && (
                <div style={{ position: "relative", height: "350px" }}>
                  <Doughnut
                    data={distribucionCategoria}
                    options={{
                      responsive: true,
                      maintainAspectRatio: false,
                      plugins: { legend: { position: "bottom" } },
                    }}
                  />
                </div>
              )}
            </div>

            <div className="card p-3 shadow" style={{ height: "auto" }}>
              <h5 className="text-center">Stock actual</h5>
              {stockActual && (
                <div style={{ height: "400px" }}>
                  <Bar
                    data={stockActual}
                    options={{
                      indexAxis: "y",
                      maintainAspectRatio: false,
                    }}
                  />
                </div>
              )}
            </div>
          </div>
        </div>
      </main>

      <footer className="footer-dashboard mt-auto py-3 text-center">
        © 2025 <strong>DistriOchoa</strong>. Todos los derechos reservados.
      </footer>
    </div>
  );
}
