// src/pages/SelectRole.jsx
import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import Swal from "sweetalert2";
import "bootstrap/dist/css/bootstrap.min.css";
import "bootstrap/dist/js/bootstrap.bundle.min.js";
import { Tooltip } from "bootstrap";
import "../assets/styles.css";

export default function SelectRole({ onRoleSelected }) {
  const [rol, setRol] = useState("");
  const navigate = useNavigate();

  useEffect(() => {
    const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]');
    tooltipTriggerList.forEach((el) => new Tooltip(el));
  }, []);

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!rol) {
      Swal.fire({
        icon: "warning",
        title: "Rol requerido",
        text: "Selecciona un rol para continuar",
        confirmButtonColor: "#198754",
      });
      return;
    }
    localStorage.setItem("rol_seleccionado", rol);
    if (onRoleSelected) onRoleSelected(rol);
    navigate("/login");
  };

  return (
    <div className="container-fluid min-vh-100 d-flex align-items-center justify-content-center px-3">
      <div className="row align-items-center justify-content-center w-100">
        <div className="col-12 col-md-6 d-flex flex-column justify-content-center align-items-center text-center mb-5 mb-md-0">
          <img
            src="/img/logo.png"
            alt="Logo"
            className="logo-login"
            style={{ width: "100px" }}
            data-bs-toggle="tooltip"
            title="¡Hola, soy el logo!"
          />
          <h1 className="display-4 fw-bold text-success">BIENVENIDO</h1>
          <p className="lead">Al sistema de gestión de inventario.</p>

          <form
            onSubmit={handleSubmit}
            className="w-100 d-flex flex-column align-items-center animate__animated animate__fadeInDown"
          >
            <label
              htmlFor="rol"
              className="form-label text-success fw-bold fs-5"
            >
              👤 Rol de acceso
            </label>
            <select
              id="rol"
              className="form-select form-select-lg w-75 border-success shadow-sm mb-3 rounded-pill"
              value={rol}
              onChange={(e) => setRol(e.target.value)}
              required
            >
              <option value="">Selecciona tu Rol</option>
              <option value="admin">🛡️ Administrador</option>
              <option value="auxiliar">🧰 Auxiliar</option>
              <option value="superadmin">👑 SuperAdmin</option> {/* NUEVO */}
            </select>

            <button
              type="submit"
              className="btn btn-success btn-lg px-5 rounded-pill shadow-sm"
            >
              Continuar <i className="bi bi-arrow-right-circle ms-2"></i>
            </button>
          </form>
        </div>

        <div className="col-12 col-md-6 text-center d-none d-md-block">
          <img
            src="/img/banner-distriochoa.png"
            alt="Banner"
            className="imagen-bienvenida img-fluid rounded shadow"
            style={{ maxWidth: "600px", height: "auto" }}
            data-bs-toggle="tooltip"
            title="Banner con flow 😌"
          />
        </div>
      </div>
    </div>
  );
}
