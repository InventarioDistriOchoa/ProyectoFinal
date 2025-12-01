// src/pages/Login.jsx
import { useState } from "react";
import { useNavigate } from "react-router-dom";
import axios from "axios";
import Swal from "sweetalert2";
import "bootstrap/dist/css/bootstrap.min.css";
import "bootstrap/dist/js/bootstrap.bundle.min.js";
import "../assets/styles.css";
import { BiShow, BiHide } from "react-icons/bi"; // <-- ESTO

export default function Login() {
  const [correo, setCorreo] = useState("");
  const [contrasena, setContrasena] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!correo || !contrasena) {
      Swal.fire({
        icon: "warning",
        title: "Ups... 🌱",
        text: "Correo o contraseña requeridos",
        confirmButtonColor: "#198754",
      });
      return;
    }

    try {
      const res = await axios.post("http://localhost:3001/api/persona/login", {
        Correo: correo,
        Contrasena: contrasena,
      });

      if (res.data.ok) {
        const rolSeleccionado = localStorage.getItem("rol_seleccionado");
        const rolBD = res.data.body.Rol;

        // ✅ Comparación insensible a mayúsculas/minúsculas
        if (rolSeleccionado && rolSeleccionado.toLowerCase() !== rolBD.toLowerCase()) {
          Swal.fire({
            icon: "error",
            title: "Rol incorrecto",
            text: `Seleccionaste "${rolSeleccionado}", pero este usuario es "${rolBD}".`,
            confirmButtonColor: "#198754",
          }).then(() => {
            localStorage.removeItem("rol_seleccionado");
            navigate("/");
          });
          return;
        }

        // Guardar datos
        localStorage.setItem("token", res.data.token);
        localStorage.setItem("nombre", res.data.body.Nombre);
        localStorage.setItem("rol", rolBD);

        Swal.fire({
          icon: "success",
          title: "¡Bienvenido! 🎉",
          text: `Hola ${res.data.body.Nombre}`,
          confirmButtonColor: "#198754",
        }).then(() => navigate("/dashboard"));
      } else {
        Swal.fire({
          icon: "error",
          title: "Error",
          text: res.data.Message,
          confirmButtonColor: "#198754",
        });
      }
    } catch (err) {
      console.error(err);
      // Distinción entre usuario no registrado y contraseña incorrecta
      if (err.response?.status === 401) {
        Swal.fire({
          icon: "error",
          title: "Credenciales incorrectas",
          text: err.response.data.Message || "Correo o contraseña incorrectos",
          confirmButtonColor: "#198754",
        });
      } else {
        Swal.fire({
          icon: "error",
          title: "Error de servidor",
          text: "No se pudo iniciar sesión. Revisa que tu usuario esté registrado 😑.",
          confirmButtonColor: "#198754",
        });
      }
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

        <div id="form-login">
          <div className="pantalla">
            <div
              className="login-box shadow-lg animate__animated animate__fadeInUp rounded-4 zoom-hover w-100"
              style={{ maxWidth: "480px" }}
            >
              <form onSubmit={handleSubmit}>
                <div className="mensaje-inicial text-center">
                  ¡Hola! Inicia aquí <span className="emoji">😉</span>
                  <div className="flecha-abajo">👇</div>
                </div>

             {/* Correo */}
<input
  type="email"
  name="correo"
  className="form-control rounded-4 shadow-sm mb-3"
  placeholder="Correo"
  value={correo}
  onChange={(e) => setCorreo(e.target.value)}
  required
/>
{/* Contraseña con ojito perfectamente centrado */}
<div className="position-relative mb-3">
  <input
    type={showPassword ? "text" : "password"}
    className="form-control rounded-4 shadow-sm pe-5"
    placeholder="Contraseña"
    value={contrasena}
    onChange={(e) => setContrasena(e.target.value)}
    required
  />
  <span
    onClick={() => setShowPassword(!showPassword)}
    title={showPassword ? "Ocultar contraseña" : "Mostrar contraseña"}
    style={{
    //centrar verticalmente
      
      position: "absolute",
      top: "37%",
      right: "1rem",
      transform: "translateY(-50%)",
      cursor: "pointer",
      fontSize: "1.3rem",
      color: showPassword ? "#dc3545" : "#198754",
      transition: "color 0.3s ease",
    }}
  >
    <i className={`bi ${showPassword ? "bi-eye-slash-fill" : "bi-eye-fill"}`}></i>
  </span>
</div>




                <button type="submit" className="btn btn-success w-100 mt-2">
                  Iniciar sesión
                </button>

                <a
                  href="#"
                  className="recuperar d-block mt-3"
                  onClick={async (e) => {
                    e.preventDefault();

                    if (!correo) {
                      Swal.fire({
                        icon: "warning",
                        title: "Ups... 🌱",
                        text: "Ingresa tu correo primero",
                        confirmButtonColor: "#198754",
                      });
                      return;
                    }

                    try {
                      const res = await axios.post(
                        "http://localhost:3001/api/auth/forgot-password",
                        { Correo: correo }
                      );

                      if (res.data.ok) {
                        Swal.fire({
                          icon: "success",
                          title: "¡Correo enviado! ✉️",
                          text: "Revisa tu correo para restablecer tu contraseña 😉",
                          confirmButtonColor: "#198754",
                        });
                      } else {
                        Swal.fire({
                          icon: "error",
                          title: "Error",
                          text: res.data.msg || "No se pudo enviar el correo",
                          confirmButtonColor: "#198754",
                        });
                      }
                    } catch (err) {
                      console.error(err);
                      Swal.fire({
                        icon: "error",
                        title: "Error de servidor",
                        text: "No se pudo enviar el correo de recuperación",
                        confirmButtonColor: "#198754",
                      });
                    }
                  }}
                >
                  ¿Has olvidado tu contraseña?
                </a>
              </form>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
