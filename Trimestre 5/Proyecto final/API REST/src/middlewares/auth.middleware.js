// middlewares/verifyToken.js
import jwt from "jsonwebtoken";

const verifyToken = (req, res, next) => {
  let token = req.headers.authorization;

  if (!token) {
    return res.status(401).json({ ok: false, Message: "Token no encontrado" });
  }

  // Extraer el token del formato "Bearer TOKEN"
  token = token.split(" ")[1];

  console.log("Header Authorization:", req.headers.authorization);
  console.log("process.env.JWK_SECRET:", process.env.JWK_SECRET);

  try {
    // Verificar token
    const decoded = jwt.verify(token, process.env.JWK_SECRET);

    // 👇 Normalizamos tipos aquí
    req.userId = Number(decoded.id);        // id del usuario logueado
    req.userRol = Number(decoded.userRol);  // rol del usuario logueado

    next();
  } catch (err) {
    return res.status(401).json({ ok: false, Message: "Token inválido" });
  }
};

export default verifyToken;
