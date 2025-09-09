<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <title>Confirmación – DistriOchoa</title>
  <link rel="stylesheet" href="../css/styles.css" />
  <link rel="stylesheet" href="../css/bootstrap.min.css">
  <!-- ACTIVA LOS ÍCONOS DE BOOTSTRAP -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" />

</head>
<body>
    <!-- Menú lateral (Sidebar) -->
<div id="sidebar-vertical" class="sidebar" style="display: none;">
  <button onclick="mostrarRegistro()">Registrar Producto</button>
  <button onclick="mostrarRegistrarSalida()">Registrar Salida</button>
  <button onclick="mostrarReportes()">Reportes</button>
  <?php if ($rol === 'admin'): ?>
    <button onclick="mostrarRegistroUsuarios()">Usuarios</button>
    
  <?php endif; ?>
  <button onclick="mostrarGestionCategorias()">Categorías</button>
  <button onclick="mostrarStock()">📦 Ver Stock</button>
  <button onclick="mostrarDevoluciones()">Devoluciones</button>
  <button onclick="volverInicio()">Volver al Inicio</button>
</div>




<!-- Botón hamburguesa para mostrar el menú -->
<button id="btn-toggle-sidebar" class="hamburguesa">
  <i class="bi bi-list"></i>
</button>

 <body>
  <div class="pantalla login-screen" style="display: flex; flex-direction: column; justify-content: center; align-items: center; height: 100vh;">
    <div class="login-box" style="text-align: center;">
      <img src="img/logo.jpeg" alt="Logo" class="logo" style="width: 80px; margin-bottom: 10px;" />
      <h2 style="color: var(--verde); margin-bottom: 15px;">✅ Acción completada</h2>
      <p style="color: var(--gris-oscuro); margin-bottom: 25px;">Tu acción se registró correctamente.</p>

      <div style="display: flex; flex-direction: column; gap: 10px;">
        <button onclick="window.location.href='registro-productos.php'" class="btn-guardar">➕ Agregar otro producto</button>
        <button onclick="window.location.href='stock.php'" class="btn-guardar">📋 Ver stock</button>
        <button onclick="window.location.href='dashboard.php'" class="btn-volver-inicio">🏠 Volver al inicio</button>
      </div>
    </div>

    <div class="decoracion-abajo" style="margin-top: 30px;">
      <img src="img/decoracion-verduras.png" alt="Decoración verduras" />
    </div>
  </div>
  <script src="../js/script.js" defer></script>
  <script src="../js/bootstrap.min.js"></script>
</body>
</html>
