import { useState, useEffect, useRef } from "react";
import { useNavigate } from "react-router-dom";
import Swal from "sweetalert2";
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
} from "react-icons/bi";

export default function RegistroProducto() {
  const navigate = useNavigate();
  const sidebarRef = useRef(null);
  const token = localStorage.getItem("token");

  // Estados
  const [nombre, setNombre] = useState("");
  const [categoria, setCategoria] = useState("");
  const [precio, setPrecio] = useState("");
  const [categorias, setCategorias] = useState([]);
  const [usuario, setUsuario] = useState("");
  const [rol, setRol] = useState("");
  const [sidebarVisible, setSidebarVisible] = useState(false);

  // Cargar nombre y rol del usuario
  useEffect(() => {
    const nombreUsuario = localStorage.getItem("nombre") || "";
    const rolUsuario = localStorage.getItem("rol") || "";
    setUsuario(nombreUsuario);
    setRol(rolUsuario.toLowerCase());
  }, []);

  // Traer categorías desde la API
  useEffect(() => {
    if (!token) return;
    const fetchCategorias = async () => {
      try {
        const res = await fetch("http://localhost:3001/api/categoria/categoria", {
          headers: {
            Authorization: `Bearer ${token}`,
            "Content-Type": "application/json",
          },
        });
        if (!res.ok) throw new Error("Error al cargar categorías");
        const data = await res.json();
        setCategorias(data.body);
      } catch (err) {
        console.error("Error al cargar categorías:", err);
        Swal.fire("Error", "No se pudieron cargar las categorías", "error");
      }
    };
    fetchCategorias();
  }, [token]);

  // Proteger la página si no hay token
  useEffect(() => {
    if (!token) navigate("/select-role", { replace: true });
  }, [token, navigate]);

  // Cerrar sesión
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

  // Mostrar usuarios solo si el rol es admin/superadmin
  const mostrarModuloUsuarios = rol === "admin" || rol === "superadmin";

  // Opciones del sidebar (idéntico al Dashboard)
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

  // Cerrar sidebar al hacer clic fuera
  useEffect(() => {
    const handleClickOutside = (event) => {
      if (sidebarRef.current && !sidebarRef.current.contains(event.target)) {
        setSidebarVisible(false);
      }
    };
    if (sidebarVisible) {
      document.addEventListener("mousedown", handleClickOutside);
    }
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [sidebarVisible]);

  // Registrar producto
  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!nombre || !categoria || !precio) {
      Swal.fire("Error", "Todos los campos son obligatorios", "error");
      return;
    }
    const nuevoProducto = {
      Nombre: nombre,
      Precio: parseFloat(precio),
      Categoria_id: parseInt(categoria, 10),
      Cantidad_Actual: 0,
    };
    try {
      const res = await fetch("http://localhost:3001/api/producto/producto", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(nuevoProducto),
      });
      const data = await res.json();
      if (res.ok) {
        Swal.fire({
          title: "¡Producto Registrado!",
          html: `
            <strong>Nombre:</strong> ${nombre} <br/>
            <strong>Categoría:</strong> ${
              categorias.find((cat) => cat.idCategoria == categoria)?.Nombre_Categoria || ""
            } <br/>
            <strong>Precio:</strong> $${parseFloat(precio).toFixed(2)}
          `,
          icon: "success",
          confirmButtonColor: "#198754",
        });
        setNombre("");
        setCategoria("");
        setPrecio("");
      } else if (res.status === 409) {
        Swal.fire("Error", "El producto que intentas registrar ya existe", "warning");
      } else {
        Swal.fire("Error", data.message || "No se pudo registrar el producto", "error");
      }
    } catch (err) {
      console.error(err);
      Swal.fire("Error", "No se pudo registrar el producto", "error");
    }
  };

  return (
    <div className="min-vh-100 position-relative">
      {/* Overlay cuando el sidebar está abierto */}
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
          width: "240px",
          transform: sidebarVisible ? "translateX(0)" : "translateX(-100%)",
          transition: "transform 0.3s ease-in-out",
          zIndex: 2000,
        }}
        onMouseLeave={() => setSidebarVisible(false)}
      >
        {sidebarItems.map((item, index) => (
          <button
            key={index}
            onClick={() => {
              item.action();
              setSidebarVisible(false);
            }}
            className="d-flex align-items-center gap-2 p-2 rounded shadow-sm border-0 bg-light"
            style={{
              cursor: "pointer",
              marginTop: index === 0 ? "4rem" : "0",
            }}
            onMouseEnter={(e) => (e.currentTarget.style.backgroundColor = "#e2f0ff")}
            onMouseLeave={(e) => (e.currentTarget.style.backgroundColor = "#f8f9fa")}
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

      {/* Contenido principal */}
      <div className="container-fluid px-3 pt-5">
        <div className="row">
          {/* Formulario de registro */}
          <div className="col-12 col-md-6 d-flex justify-content-center align-items-start mb-4">
            <form onSubmit={handleSubmit} className="w-100" style={{ maxWidth: "500px" }}>
              <img
                src="/img/logo.png"
                alt="Logo"
                className="logo mb-4 d-block mx-auto"
                style={{ height: "80px" }}
              />
              <h1 className="mb-4 text-center fw-bold">Registrar Producto</h1>

              <div className="mb-3">
                <label className="form-label fw-bold">Nombre del producto</label>
                <input
                  type="text"
                  className="form-control"
                  value={nombre}
                  onChange={(e) => setNombre(e.target.value)}
                  placeholder="Ej: Pera"
                  required
                />
              </div>

              <div className="mb-3">
                <label className="form-label fw-bold">Categoría</label>
                <select
                  className="form-select"
                  value={categoria}
                  onChange={(e) => setCategoria(e.target.value)}
                  required
                >
                  <option value="">Selecciona una categoría</option>
                  {categorias.map((cat) => (
                    <option key={cat.idCategoria} value={cat.idCategoria}>
                      {cat.Nombre_Categoria}
                    </option>
                  ))}
                </select>
              </div>

              <div className="mb-3">
                <label className="form-label fw-bold">Precio unitario</label>
                <input
                  type="number"
                  className="form-control"
                  step="0.01"
                  value={precio}
                  onChange={(e) => setPrecio(e.target.value)}
                  required
                />
              </div>

              <div className="mb-3">
                <label className="form-label fw-bold">Cantidad actual</label>
                <input type="number" className="form-control" value={0} readOnly />
              </div>

              <div className="mb-3">
                <label className="form-label fw-bold">Responsable</label>
                <input type="text" className="form-control" value={usuario} readOnly />
              </div>

              <button type="submit" className="btn btn-success w-100 mb-3">
                Registrar Producto
              </button>
              <button
                type="button"
                className="btn btn-success w-100"
                onClick={() => navigate("/lista-productos")}
              >
                Ver lista de productos
              </button>
            </form>
          </div>

          {/* Banner lateral */}
          <div className="d-none d-md-flex col-md-6 justify-content-center align-items-center">
            <div
              className="card shadow-lg border-0"
              style={{
                overflow: "hidden",
                borderRadius: "20px",
                maxWidth: "950px",
              }}
            >
              <img
                src="/img/banner-distriochoa.png"
                alt="Banner"
                className="img-fluid efecto-hover"
                style={{
                  width: "100%",
                  maxHeight: "800px",
                  objectFit: "contain",
                  transition: "transform 0.3s ease-in-out",
                }}
              />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
