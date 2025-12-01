import { useEffect, useRef } from "react";
import {jwtDecode} from "jwt-decode";   // ✅ sin llaves
import Swal from "sweetalert2";
import { useNavigate } from "react-router-dom";

export default function AuthWatcher({ timeoutInMinutes = 30 }) { // ← 30 min por defecto
  const navigate = useNavigate();
  const lastActivity = useRef(Date.now());

  useEffect(() => {
    const token = localStorage.getItem("token");
    if (!token) return;

    // ⏱ Revisa el exp del token cada 30 s
    const checkToken = setInterval(() => {
      try {
        const { exp } = jwtDecode(token);
        const now = Math.floor(Date.now() / 1000);
        if (exp < now) cerrarSesion("Tu sesión ha expirado.");
      } catch {
        cerrarSesion("Token inválido.");
      }
    }, 30000);

    // 🖱 Reinicia contador con actividad del usuario
    const resetTimer = () => (lastActivity.current = Date.now());
    window.addEventListener("mousemove", resetTimer);
    window.addEventListener("keydown", resetTimer);

    // ⏳ Revisa inactividad
    const checkInactivity = setInterval(() => {
      if (Date.now() - lastActivity.current > timeoutInMinutes * 60 * 1000) {
        cerrarSesion(`Inactividad de ${timeoutInMinutes} min.`);
      }
    }, 60000);

    return () => {
      clearInterval(checkToken);
      clearInterval(checkInactivity);
      window.removeEventListener("mousemove", resetTimer);
      window.removeEventListener("keydown", resetTimer);
    };
  }, [navigate, timeoutInMinutes]);

  const cerrarSesion = (msg) => {
    localStorage.clear();
    Swal.fire({
      icon: "warning",
      title: "Sesión cerrada",
      text: msg + " Por favor inicia sesión de nuevo.",
      confirmButtonColor: "#198754",
    }).then(() => navigate("/login", { replace: true }));
  };

  return null; // No renderiza nada
}
