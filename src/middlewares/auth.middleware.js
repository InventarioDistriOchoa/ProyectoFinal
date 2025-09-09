import jwt from "jsonwebtoken";

const verifyToken = (req, res, next) => {
  let token = req.headers.authorization;

  if (!token) {
    return res.status(401).json({
      ok: false,
      status: 401,
      Message: "Token no encontrado",
    });
  }

  token = token.split(" ")[1];

  try {
    // Verificar firma y expiración
    const decoded = jwt.verify(token, process.env.JWK_SECRET);

    req.userId = decoded.id;
    req.userRol = decoded.userRol;

    next();
  } catch (err) {
    if (err.name === "TokenExpiredError") {
      return res.status(401).json({
        ok: false,
        status: 401,
        Message: "Su sesión ha expirado, por favor inicie sesión nuevamente.",
      });
    }

    return res.status(401).json({
      ok: false,
      status: 401,
      Message: "Token no válido",
    });
  }
};

export default verifyToken;
