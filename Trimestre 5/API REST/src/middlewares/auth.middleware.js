import jwt from "jsonwebtoken";
import { activeTokens } from "../middlewares/tokenStore.js";

const verifyToken = (req, res, next) => {
  let token = req.headers.authorization;

  if (!token) {
    return res.status(401).json({
      ok: false,
      status: 401,
      Message: "Token no encontrado"
    });
  }

  token = token.split(" ")[1]; // Quita "Bearer"
  try {
    const decoded = jwt.verify(token, process.env.JWK_SECRET); // ✅ JWK_SECRET
    req.userId = decoded.id;
    req.userRol = decoded.rol;  // ✅ corrige nombre
    next();
  } catch (err) {
    return res.status(401).json({
      ok: false,
      status: 401,
      Message: "Token inválido"
    });
  }
};

export default verifyToken;
