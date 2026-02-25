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
  BiReceipt,
} from "react-icons/bi";

import jsPDF from "jspdf";
import autoTable from "jspdf-autotable";
import * as XLSX from "xlsx";

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

  const esAdmin = rol === "admin" || rol === "superadmin";

  // ======== ESTADOS DE GRÁFICOS =========
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

  // 🆕 Nuevos gráficos
  const [stockPorEstado, setStockPorEstado] = useState(null);
  const [entradasVsVentas, setEntradasVsVentas] = useState(null);

  // Paginación interna para alertas
  const [paginaActual, setPaginaActual] = useState(1);
  const ITEMS_POR_PAGINA = 10;
  const [busqueda, setBusqueda] = useState("");

  // Datos crudos para exportar
  const [stockRows, setStockRows] = useState([]);
  const [entradasRows, setEntradasRows] = useState([]);
  const [ventasRows, setVentasRows] = useState([]);

  // ======== PERFIL / AUTH =========
  useEffect(() => {
    const storedNombre = localStorage.getItem("nombre");
    const storedRol = localStorage.getItem("rol");
    if (!storedNombre || !storedRol) {
      navigate("/select-role");
      return;
    }

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
        console.error("Error cargando perfil:", err);
      }
    };

    fetchProfile();
  }, [navigate]);

  // ======== CARGA DE DATOS DE REPORTES =========
  useEffect(() => {
    const fetchData = async () => {
      try {
        const token = localStorage.getItem("token");

        // ---------- STOCK ----------
        const stockRes = await fetch("http://localhost:3001/api/stock", {
          headers: { Authorization: `Bearer ${token}` },
        });
        const stockJson = await stockRes.json();
        const stockData = stockJson.body || [];

        setStockRows(stockData);

        // Gráfico de stock actual por producto
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

        // Lista de alertas
        setAlertasStock(
          stockData.map((p) => ({ producto: p.producto, estado: p.estado }))
        );
        setPaginaActual(1);

        // Distribución por categoría (doughnut)
        const categoriasCount = {};
        stockData.forEach((p) => {
          categoriasCount[p.categoria] =
            (categoriasCount[p.categoria] || 0) + 1;
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

        // 🆕 Distribución por estado (verde / amarillo / rojo)
        const estadosCount = { verde: 0, amarillo: 0, rojo: 0 };
        stockData.forEach((p) => {
          if (estadosCount[p.estado] !== undefined) {
            estadosCount[p.estado] += 1;
          }
        });

        setStockPorEstado({
          labels: ["En óptimo (verde)", "En observación (amarillo)", "Crítico (rojo)"],
          datasets: [
            {
              data: [
                estadosCount.verde,
                estadosCount.amarillo,
                estadosCount.rojo,
              ],
              backgroundColor: ["#20c997", "#ffc107", "#dc3545"],
            },
          ],
        });

        // ---------- ENTRADAS ----------
        const entradasRes = await fetch(
          "http://localhost:3001/api/entrada/entrada",
          {
            headers: { Authorization: `Bearer ${token}` },
          }
        );
        const entradasJson = await entradasRes.json();
        const entradas = Array.isArray(entradasJson.body)
          ? entradasJson.body
          : [entradasJson.body].filter(Boolean);

        setEntradasRows(entradas);

        const entradasPorMesData = {};
        entradas.forEach((e) => {
          const fecha = new Date(e.Fecha);
          const mes = fecha.toLocaleString("es-ES", {
            month: "short",
            year: "numeric",
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
              backgroundColor: "rgba(13, 110, 253, 0.2)",
              fill: true,
            },
          ],
        });

        // ---------- VENTAS ----------
        const ventasRes = await fetch(
          "http://localhost:3001/api/detalleVenta/detalleVenta",
          {
            headers: { Authorization: `Bearer ${token}` },
          }
        );
        const ventasJson = await ventasRes.json();
        const ventas = Array.isArray(ventasJson.body)
          ? ventasJson.body
          : [ventasJson.body].filter(Boolean);

        setVentasRows(ventas);

        // Conteo por producto para "Más vendidos"
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

        // 🆕 Ventas por mes, para comparativa con entradas
        const ventasPorMesData = {};
        ventas.forEach((v) => {
          const fecha = new Date(v.Fecha);
          const mes = fecha.toLocaleString("es-ES", {
            month: "short",
            year: "numeric",
          });
          ventasPorMesData[mes] =
            (ventasPorMesData[mes] || 0) + v.Cantidad;
        });

        const mesesUnicos = Array.from(
          new Set([
            ...Object.keys(entradasPorMesData),
            ...Object.keys(ventasPorMesData),
          ])
        ).sort((a, b) => {
          const [mesA, anoA] = a.split(" ");
          const [mesB, anoB] = b.split(" ");
          const fechaA = new Date(`${mesA} 1, ${anoA}`);
          const fechaB = new Date(`${mesB} 1, ${anoB}`);
          return fechaA - fechaB;
        });

        setEntradasVsVentas({
          labels: mesesUnicos,
          datasets: [
            {
              label: "Entradas",
              data: mesesUnicos.map((m) => entradasPorMesData[m] || 0),
              borderColor: "#0d6efd",
              backgroundColor: "rgba(13,110,253,0.2)",
              tension: 0.3,
            },
            {
              label: "Ventas",
              data: mesesUnicos.map((m) => ventasPorMesData[m] || 0),
              borderColor: "#dc3545",
              backgroundColor: "rgba(220,53,69,0.2)",
              tension: 0.3,
            },
          ],
        });

        // ---------- RESUMEN GENERAL ----------
        setResumen({
          productos: stockData.length,
          categorias: Object.keys(categoriasCount).length,
          stockTotal: stockData.reduce(
            (acc, p) => acc + (p.disponible || 0),
            0
          ),
        });
      } catch (err) {
        console.error("Error cargando reportes:", err);
      }
    };

    fetchData();
  }, []);

  // ======== CERRAR SESIÓN =========
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

  // ======== SIDEBAR =========
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

    if (esAdmin) {
      items.push({
        label: "Reportes",
        icon: <BiLineChart />,
        action: () => navigate("/reportes"),
      });
    }

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
      if (sidebarRef.current && !sidebarRef.current.contains(e.target)) {
        setSidebarVisible(false);
      }
    };
    if (sidebarVisible)
      document.addEventListener("mousedown", handleClickOutside);
    return () =>
      document.removeEventListener("mousedown", handleClickOutside);
  }, [sidebarVisible]);

  // ======== ICONO ESTADO STOCK =========
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

  // ======== EXPORTAR PDF =========
  const handleExportPDF = () => {
    try {
      const doc = new jsPDF();
      const verde = [25, 135, 84];

      let y = 12;

      // Título principal
      doc.setFontSize(16);
      doc.setTextColor(verde[0], verde[1], verde[2]);
      doc.text("Reporte de Inventario - DistriOchoa", 14, y);

      y += 8;
      doc.setFontSize(10);
      doc.setTextColor(0, 0, 0);
      doc.text(`Generado por: ${nombre} (${rol})`, 14, y);
      y += 6;
      doc.text(`Fecha: ${new Date().toLocaleString("es-CO")}`, 14, y);
      y += 8;

      // 1) Resumen general
      doc.setFontSize(13);
      doc.setTextColor(verde[0], verde[1], verde[2]);
      doc.text("1. Resumen general", 14, y);
      y += 4;
      doc.setTextColor(0, 0, 0);

      autoTable(doc, {
        startY: y,
        head: [["Métrica", "Valor"]],
        body: [
          ["Productos registrados", resumen.productos],
          ["Categorías activas", resumen.categorias],
          ["Stock total disponible", resumen.stockTotal],
        ],
      });

      let finalY = doc.lastAutoTable.finalY + 6;

      // 2) Stock actual
      doc.setFontSize(13);
      doc.setTextColor(verde[0], verde[1], verde[2]);
      doc.text("2. Stock actual", 14, finalY);
      finalY += 4;
      doc.setTextColor(0, 0, 0);

      autoTable(doc, {
        startY: finalY,
        head: [["Producto", "Categoría", "Disponible", "Estado"]],
        body: stockRows.map((s) => [
          s.producto,
          s.categoria,
          s.disponible,
          s.estado,
        ]),
      });

      finalY = doc.lastAutoTable.finalY + 6;

      // 3) Entradas registradas
      doc.setFontSize(13);
      doc.setTextColor(verde[0], verde[1], verde[2]);
      doc.text("3. Entradas registradas", 14, finalY);
      finalY += 4;
      doc.setTextColor(0, 0, 0);

      autoTable(doc, {
        startY: finalY,
        head: [["Fecha", "Producto ID", "Cantidad", "Proveedor ID"]],
        body: entradasRows.map((e) => [
          new Date(e.Fecha).toLocaleDateString("es-CO"),
          e.Producto_id,
          e.Cantidad,
          e.Proveedor_id,
        ]),
      });

      finalY = doc.lastAutoTable.finalY + 6;

      // 4) Ventas registradas
      doc.setFontSize(13);
      doc.setTextColor(verde[0], verde[1], verde[2]);
      doc.text("4. Ventas registradas", 14, finalY);
      finalY += 4;
      doc.setTextColor(0, 0, 0);

      autoTable(doc, {
        startY: finalY,
        head: [["Fecha", "Producto ID", "Cantidad"]],
        body: ventasRows.map((v) => [
          v.Fecha
            ? new Date(v.Fecha).toLocaleDateString("es-CO")
            : "-",
          v.Producto_id,
          v.Cantidad,
        ]),
      });

      doc.save("reportes_inventario.pdf");
    } catch (err) {
      console.error("Error exportando a PDF:", err);
      Swal.fire(
        "Error",
        "No se pudo exportar el PDF. Revisa la consola.",
        "error"
      );
    }
  };

  // ======== EXPORTAR EXCEL =========
  const handleExportExcel = () => {
    try {
      const wb = XLSX.utils.book_new();

      // Hoja de stock
      const stockSheetData = stockRows.map((s) => ({
        Producto: s.producto,
        Categoria: s.categoria,
        Disponible: s.disponible,
        Estado: s.estado,
      }));
      const wsStock = XLSX.utils.json_to_sheet(stockSheetData);
      XLSX.utils.book_append_sheet(wb, wsStock, "Stock");

      // Hoja de entradas
      const entradasSheetData = entradasRows.map((e) => ({
        Fecha: new Date(e.Fecha).toLocaleDateString("es-CO"),
        Producto_id: e.Producto_id,
        Cantidad: e.Cantidad,
        Proveedor_id: e.Proveedor_id,
      }));
      const wsEntradas = XLSX.utils.json_to_sheet(entradasSheetData);
      XLSX.utils.book_append_sheet(wb, wsEntradas, "Entradas");

      // Hoja de ventas
      const ventasSheetData = ventasRows.map((v) => ({
        Fecha: v.Fecha
          ? new Date(v.Fecha).toLocaleDateString("es-CO")
          : "",
        Producto_id: v.Producto_id,
        Cantidad: v.Cantidad,
      }));
      const wsVentas = XLSX.utils.json_to_sheet(ventasSheetData);
      XLSX.utils.book_append_sheet(wb, wsVentas, "Ventas");

      XLSX.writeFile(wb, "reportes_inventario.xlsx");
    } catch (err) {
      console.error("Error exportando a Excel:", err);
      Swal.fire(
        "Error",
        "No se pudo exportar el Excel. Revisa la consola.",
        "error"
      );
    }
  };

  // ============ RENDER ============

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
  {/* Botones de acciones arriba (solo admins) */}
  {esAdmin && (
    <div className="d-flex flex-wrap justify-content-end gap-3 mb-4">
      
      <button
        className="btn boton-verde-reporte d-flex align-items-center gap-2 px-3 py-2"
        onClick={() => navigate("/facturas")}
      >
        <BiReceipt />
        <span>Facturas</span>
      </button>

      <button
        className="btn boton-verde-reporte d-flex align-items-center gap-2 px-3 py-2"
        onClick={() => navigate("/historial")}
      >
        <i className="bi bi-clock-history"></i>
        <span>Ver historial</span>
      </button>

      <button
        className="btn boton-verde-reporte d-flex align-items-center gap-2 px-3 py-2"
        onClick={handleExportPDF}
      >
        <i className="bi bi-file-earmark-pdf"></i>
        <span>Exportar PDF</span>
      </button>

      <button
        className="btn boton-verde-reporte d-flex align-items-center gap-2 px-3 py-2"
        onClick={handleExportExcel}
      >
        <i className="bi bi-file-earmark-excel"></i>
        <span>Exportar Excel</span>
      </button>

    </div>
  )}

  {/* resto del main... */}

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
                  setPaginaActual(1);
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
                  <i className="bi bi-box-seam text-success me-2"></i>{" "}
                  Productos registrados:{" "}
                  <strong>{resumen.productos}</strong>
                </li>
                <li className="list-group-item">
                  <i className="bi bi-tags text-info me-2"></i> Categorías
                  activas: <strong>{resumen.categorias}</strong>
                </li>
                <li className="list-group-item">
                  <i className="bi bi-archive-fill text-warning me-2"></i>{" "}
                  Stock total disponible:{" "}
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

            {/* 🆕 Estado de stock */}
            <div className="card p-3 shadow">
              <h5 className="text-center mb-2">Estado del stock</h5>
              {stockPorEstado ? (
                <div style={{ position: "relative", height: "280px" }}>
                  <Doughnut
                    data={stockPorEstado}
                    options={{
                      responsive: true,
                      maintainAspectRatio: false,
                      plugins: { legend: { position: "bottom" } },
                    }}
                  />
                </div>
              ) : (
                <p className="text-center text-muted mb-0">
                  No hay datos de estado de stock.
                </p>
              )}
            </div>

            {/* 🆕 Entradas vs Ventas */}
            <div className="card p-3 shadow">
              <h5 className="text-center mb-2">
                Entradas vs Ventas por mes
              </h5>
              {entradasVsVentas ? (
                <div style={{ position: "relative", height: "300px" }}>
                  <Line
                    data={entradasVsVentas}
                    options={{
                      responsive: true,
                      maintainAspectRatio: false,
                      plugins: {
                        legend: { position: "bottom" },
                      },
                      scales: {
                        y: { beginAtZero: true },
                      },
                    }}
                  />
                </div>
              ) : (
                <p className="text-center text-muted mb-0">
                  No hay datos suficientes para comparar entradas y ventas.
                </p>
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
