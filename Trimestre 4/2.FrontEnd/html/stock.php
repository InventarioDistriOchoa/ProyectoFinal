<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <title>Stock – DistriOchoa</title>
  <!-- CSS de Bootstrap -->
  <link rel="stylesheet" href="../css/bootstrap.min.css" />
  <!-- Google Fonts y demás -->
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css"/>
  <!--  CSS mio -->
  <link rel="stylesheet" href="../css/styles.css" />
  <!-- Scripts -->
  <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body>

  <!-- Capa de fondo con imagen -->
  <div class="background-layer"></div>

  <!-- Botón hamburguesa -->
  <button id="btn-toggle-sidebar" class="hamburguesa">
    <i class="bi bi-list"></i>
  </button>

  <!-- Sidebar -->
  <div id="sidebar-vertical" class="sidebar" style="display: none;">
    <button onclick="mostrarRegistro()">Registrar Producto</button>
    <button onclick="mostrarRegistrarSalida()">Registrar Salida</button>
    <button onclick="mostrarReportes()">Reportes</button>
    <button onclick="mostrarRegistroUsuarios()">Usuarios</button>
    <button onclick="mostrarGestionCategorias()">Categorías</button>
    <button onclick="mostrarStock()">📦 Ver Stock</button>
    <button onclick="mostrarDevoluciones()">Devoluciones</button>
    <button onclick="volverInicio()">Volver al Inicio</button>
  </div>

  <!-- Vista de Stock -->
  <div id="vista-stock" class="pantalla Dashboard-screen fondo-blur" style="display: flex;">

    <main class="dashboard stock-screen">

      <!-- Botones de navegación -->
      <div class="tabs">
        <button onclick="mostrarVentasRegistradas()" class="btn-tab activo" id="btn-ventas">📋 Ventas Registradas</button>
        <button onclick="mostrarStockProductos()" class="btn-tab" id="btn-stock">📦 Stock de Productos</button>
      </div>

      <!-- Subvista: Ventas Registradas -->
      <section id="subvista-ventas" style="display: block;">
        <div class="card-tabla">
          <h2>📋 Ventas Registradas</h2>
          <table>
            <thead>
              <tr>
                <th>ID Venta</th>
                <th>Producto</th>
                <th>Categoría</th>
                <th>Cantidad</th>
                <th>Precio Unitario</th>
                <th>Subtotal</th>
                <th>Total</th>
                <th>Fecha</th>
                <th>Empleado</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody id="tabla-ventas"></tbody>
          </table>
        </div>
      </section>

      <!-- Subvista: Stock de Productos -->
      <section id="subvista-stock" style="display: none;">
        <div class="card-tabla">
          <h2>📦 Stock de Productos</h2>
          <table>
            <thead>
              <tr>
                <th>ID</th>
                <th>Producto</th>
                <th>Estado</th>
                <th>Categoría</th>
                <th>Disponible</th>
                <th>Entradas</th>
                <th>Salidas</th>
                <th></th>
              </tr>
            </thead>
            <tbody id="tabla-stock"></tbody>
          </table>
        </div>
      </section>

      <!-- Botones finales -->
      <div class="botones-abajo">
        <button onclick="volverInicio()" class="btn-guardar">Volver al inicio 🏠</button>
        <button onclick="mostrarReportes()" class="btn-guardar">Ver informes 📊</button>
      </div>
    </main>
  </div>

  <script src="../js/script.js"></script>
  <script src="../js/bootstrap.min.js"></script>
</body>
</html>
