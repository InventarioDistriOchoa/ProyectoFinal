// src/pages/AuthWatcher.jsx
import { useEffect, useRef } from "react";
import { jwtDecode } from "jwt-decode";
import Swal from "sweetalert2";
import { useNavigate } from "react-router-dom";

export default function AuthWatcher() {
  const navigate = useNavigate();

  const lastActivity = useRef(Date.now());
  const warningShown = useRef(false);
  const inactivityIntervalRef = useRef(null);
  const autoLogoutTimerRef = useRef(null);

//45 minutos sin actividad → aviso
const WARN_AFTER_MS = 45 * 60 * 1000;

// ⏳ Si no responde al aviso en 15 minutos → cerrar sesión
const AUTO_LOGOUT_MS = 15 * 60 * 1000;

  useEffect(() => {
    const token = localStorage.getItem("token");
    if (!token) {
      console.log("[AuthWatcher] No hay token, no monitoreo inactividad.");
      return;
    }

    console.log("%c[AuthWatcher] MONTADO", "color: green; font-weight: bold;");

    // ========= 1. Revisar expiración del JWT cada 30s =========
    const checkToken = setInterval(() => {
      try {
        const decoded = jwtDecode(token);
        const now = Math.floor(Date.now() / 1000);

        if (decoded.exp && decoded.exp < now) {
          console.log("[AuthWatcher] Token expirado");
          cerrarSesion("Tu sesión ha expirado.");
        }
      } catch (err) {
        console.error("[AuthWatcher] Error al decodificar token:", err);
        cerrarSesion("Token inválido.");
      }
    }, 30000);

    // ========= 2. Detectar actividad del usuario =========
    const resetActivity = () => {
      lastActivity.current = Date.now();
      // console.log("[AuthWatcher] Actividad detectada");
    };

    window.addEventListener("mousemove", resetActivity);
    window.addEventListener("keydown", resetActivity);

    // ========= 3. Comprobar inactividad periódicamente =========
    inactivityIntervalRef.current = setInterval(() => {
      const now = Date.now();

      if (!warningShown.current && now - lastActivity.current > WARN_AFTER_MS) {
        warningShown.current = true;
        mostrarAvisoContinuar();
      }
    }, 10000); // cada 10s

    // Limpieza
    return () => {
      console.log("[AuthWatcher] DESMONTADO");
      clearInterval(checkToken);
      clearInterval(inactivityIntervalRef.current);
      clearTimeout(autoLogoutTimerRef.current);
      window.removeEventListener("mousemove", resetActivity);
      window.removeEventListener("keydown", resetActivity);
    };
  }, [navigate]);

  const mostrarAvisoContinuar = () => {
    console.log("%c[AuthWatcher] MOSTRANDO AVISO", "color: orange; font-weight: bold;");

    Swal.fire({
      title: "¿Sigues ahí?",
      text: "Has estado inactivo por un momento.",
      icon: "warning", // 🚨
      showCancelButton: true,
      //boton de si seguir aqui verde, boton de cerrar sesion rojo
      confirmButtonColor: "#198754",
      cancelButtonColor: "#dc3545",
      confirmButtonText: "Sí, seguir aquí",
      cancelButtonText: "Cerrar sesión",
      allowOutsideClick: false,
      allowEscapeKey: false,
    }).then((res) => {
      if (res.isConfirmed) {
        console.log("[AuthWatcher] Usuario decidió seguir");
        lastActivity.current = Date.now();
        warningShown.current = false;
        clearTimeout(autoLogoutTimerRef.current);
      } else {
        cerrarSesion("Has cerrado la sesión.");
      }
    });

    // Si NO responde en AUTO_LOGOUT_AFTER_MS → cerrar sesión auto
    autoLogoutTimerRef.current = setTimeout(() => {
      cerrarSesion("Sesión cerrada por inactividad (no respondiste al aviso).");
    }, AUTO_LOGOUT_AFTER_MS);
  };

  const cerrarSesion = (msg) => {
    console.log("%c[AuthWatcher] CERRANDO SESIÓN: " + msg, "color: red; font-weight: bold;");

    localStorage.clear();
    warningShown.current = false;
    clearTimeout(autoLogoutTimerRef.current);

    Swal.fire({
      icon: "warning",
      title: "Sesión cerrada",
      text: msg,
      confirmButtonColor: "#198754",
    }).then(() => navigate("/login", { replace: true }));
  };

  return null;
}
