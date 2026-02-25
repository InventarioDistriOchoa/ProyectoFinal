// lib/config/api_endpoints.dart
class ApiEndpoints {
  // AUTH
 
  static const String logout = '/persona/logout';         // POST /api/auth/logout
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String me = '/persona/me';                // GET /api/persona/me

  // PERSONA
  static const String personaBase = '/persona';
  static const String personas = '/persona/persona';   // GET/POST /api/persona/persona
  static const String personaLogin = '/persona/login'; // tienes 2 logins, yo usaría el de /auth

  // PRODUCTOS
  static const String productos = '/producto/producto';       // GET /api/producto/producto
  static const String productoById = '/producto/producto';    // + '/:id'

  // PROVEEDOR
  static const String proveedores = '/proveedor/proveedor';   // /api/proveedor/proveedor

  // CATEGORIA
  static const String categorias = '/categoria/categoria';    // /api/categoria/categoria
   static const String activarCategoria = '/categoria/categoria/activar';

  // ENTRADAS
  static const String entradas = '/entrada/entrada';          // /api/entrada/entrada

  // VENTAS
  static const String ventas = '/venta/venta';                // /api/venta/venta
  static const String detalleVentas = '/detalleVenta/detalleVenta';

  // DEVOLUCIONES
  static const String devoluciones = '/devolucion/devolucion';
  static const String tiposDevolucion = '/tipoDevolucion/tipoDevolucion';
  static String activarTipoDevolucion(int id) => '/tipoDevolucion/activar/$id';

  // ROLES / TIPOS DE DOC
  static const String roles = '/rol/rol';
  static const String tipoDocumento = '/tipoDocumento/tipoDocumento';

  // STOCK
  // En stock.router.js es router.get("/", ...) montado en /api/stock
  static const String stock = '/stock';                    // GET /api/stock

  // REPORTES
  static const String dashboard = '/reportes/dashboard';       // /api/reportes/dashboard

  // FACTURA
  static const String factura = '/factura';                    // /api/factura/:idVenta
}
