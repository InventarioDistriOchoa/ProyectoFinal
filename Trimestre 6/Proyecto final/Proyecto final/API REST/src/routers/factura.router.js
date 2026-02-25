import { Router } from "express";
import { generarFactura } from "../controllers/factura.controller.js";
import verifyToken from "../middlewares/auth.middleware.js";

const router = Router();


router.get("/factura/:idVenta", verifyToken, generarFactura);

router.get("/factura/:idVenta/:token", (req, res, next) => {
  const { token } = req.params;

  if (token) {
    // Le inyectamos el authorization para que verifyToken funcione igual
    req.headers.authorization = `Bearer ${token}`;
  }

  verifyToken(req, res, (err) => {
    if (err) return; // verifyToken ya respondió (401/403)
    generarFactura(req, res, next);
  });
});

export default router;
