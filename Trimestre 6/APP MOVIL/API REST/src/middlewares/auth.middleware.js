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

    // Guardar ID y rol en req
    req.userId = decoded.id;        // ✅ se usa en el controller
    req.userRol = decoded.userRol;  // opcional, para permisos

    next();
  } catch (err) {
    return res.status(401).json({ ok: false, Message: "Token inválido" });
  }
};

export default verifyToken;
