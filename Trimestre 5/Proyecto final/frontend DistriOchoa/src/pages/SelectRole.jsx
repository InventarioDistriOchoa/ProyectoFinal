// src/pages/SelectRole.jsx
import { useEffect } from "react";
import { useNavigate } from "react-router-dom";
import Swal from "sweetalert2";
import "bootstrap/dist/css/bootstrap.min.css";
import "bootstrap/dist/js/bootstrap.bundle.min.js";
import { Tooltip } from "bootstrap";
import "../assets/styles.css";

export default function SelectRole() {
  const navigate = useNavigate();

  useEffect(() => {
    const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]');
    tooltipTriggerList.forEach((el) => new Tooltip(el));
  }, []);

  const handleContinue = (e) => {
    e.preventDefault();
    navigate("/login");
  };

  return (
    <div className="container-fluid min-vh-100 d-flex align-items-center justify-content-center px-3">
      <div className="row align-items-center justify-content-center w-100">

        {/* COLUMNA IZQUIERDA */}
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
          <p className="text-muted fs-5">Haz clic en continuar para ingresar.</p>

          <button
            onClick={handleContinue}
            className="btn btn-success btn-lg px-5 rounded-pill shadow-sm mt-3"
          >
            Continuar <i className="bi bi-arrow-right-circle ms-2"></i>
          </button>
        </div>

        {/* COLUMNA DERECHA */}
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
