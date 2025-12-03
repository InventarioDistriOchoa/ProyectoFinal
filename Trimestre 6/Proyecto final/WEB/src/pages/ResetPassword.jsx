// src/pages/ResetPassword.jsx
import { useState } from "react";
import { useNavigate, useSearchParams } from "react-router-dom";
import axios from "axios";
import Swal from "sweetalert2";
import "bootstrap/dist/css/bootstrap.min.css";
import "bootstrap/dist/js/bootstrap.bundle.min.js";
import "../assets/styles.css";

export default function ResetPassword() {
  const [nuevaContrasena, setNuevaContrasena] = useState("");
  const [showPassword, setShowPassword] = useState(false); // 👈 para el ojito
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const token = searchParams.get("token"); // Obtenemos el token de la URL

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!nuevaContrasena) {
      Swal.fire({
        icon: "warning",
        title: "Ups... 🌱",
        text: "Ingresa tu nueva contraseña",
        confirmButtonColor: "#198754",
      });
      return;
    }

    try {
      const res = await axios.post(
        `http://localhost:3001/api/auth/reset-password/${token}`,
        { nuevaContrasena }
      );

      if (res.data.ok) {
        Swal.fire({
          icon: "success",
          title: "¡Listo! ✅",
          text: res.data.msg,
          confirmButtonColor: "#198754",
        }).then(() => navigate("/login"));
      } else {
        Swal.fire({
          icon: "error",
          title: "Error",
          text: res.data.msg || "Algo salió mal",
          confirmButtonColor: "#198754",
        });
      }
    } catch (err) {
      console.error(err);
      Swal.fire({
        icon: "error",
        title: "Error de servidor",
        text: "No se pudo actualizar la contraseña.",
        confirmButtonColor: "#198754",
      });
    }
  };

  return (
    <div className="container-fluid min-vh-100 d-flex justify-content-center align-items-center p-3">
      <div className="login-screen w-100">
        <div className="login-header">
          <img
            src="/img/logo.png"
            alt="Logo"
            className="logo-login"
            data-bs-toggle="tooltip"
            title="¡Hola, soy el logo oficial! 😄"
          />
          <span>DistriOchoa</span>
        </div>

        <div className="pantalla">
          <div
            className="login-box shadow-lg animate__animated animate__fadeInUp rounded-4 zoom-hover w-100"
            style={{ maxWidth: "480px" }}
          >
            <form onSubmit={handleSubmit}>
              <div className="mensaje-inicial text-center">
                Restablece tu contraseña <span className="emoji">🔑</span>
              </div>

              {/* Input nueva contraseña con ojito */}
              <div className="position-relative mb-3">
                <input
                  type={showPassword ? "text" : "password"}
                  name="nuevaContrasena"
                  className="form-control rounded-4 shadow-sm"
                  placeholder="Nueva contraseña"
                  value={nuevaContrasena}
                  onChange={(e) => setNuevaContrasena(e.target.value)}
                  required
                />
                <span
                  className="position-absolute top-50 end-3 translate-middle-y"
                  style={{ cursor: "pointer" }}
                  onClick={() => setShowPassword(!showPassword)}
                  title={showPassword ? "Ocultar contraseña" : "Mostrar contraseña"}
                >
                 
                </span>
              </div>

              <button type="submit" className="btn btn-success w-100 mt-2">
                Actualizar contraseña
              </button>
            </form>
          </div>
        </div>
      </div>
    </div>
  );
}
