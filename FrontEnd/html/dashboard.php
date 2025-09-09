<?php
session_start();

// Redirigir si no hay sesión válida
if (!isset($_SESSION['nombre']) || !isset($_SESSION['rol'])) {
  header('Location: login.php');
  exit();
}

$nombre = $_SESSION['nombre'];
$rol = $_SESSION['rol'];
?>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <title>Login – DistriOchoa</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <!-- CSS de Bootstrap -->
  <link rel="stylesheet" href="../css/bootstrap.min.css" />
  <!-- Google Fonts y demás -->
   
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css"/>
  
  <!--  CSS personalizado -->
  <link rel="stylesheet" href="../css/styles.css" />
  <!-- Scripts -->
  <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

</head>
<body>

<!-- Sidebar -->
<div id="sidebar-vertical" class="sidebar" style="display: none;">
  <button onclick="mostrarRegistro()">Registrar Producto</button>
  <button onclick="mostrarRegistrarSalida()">Registrar Salida</button>
  <button onclick="mostrarReportes()">Reportes</button>

   <?php if ($rol === 'admin'): ?>
    <button onclick="mostrarRegistroUsuarios()">Usuarios</button>
    
  <?php endif; ?>

  <!-- Categorías visible para todos -->
  <button onclick="mostrarGestionCategorias()">Categorías</button>

  <button onclick="mostrarStock()">📦 Ver Stock</button>
  <button onclick="mostrarDevoluciones()">Devoluciones</button>
  <button onclick="volverInicio()">Volver al Inicio</button>
</div>

<!-- Botón hamburguesa -->
<button id="btn-toggle-sidebar" class="hamburguesa">
  <i class="bi bi-list"></i>
</button>

<header class="dashboard-header-top d-flex justify-content-between align-items-center px-4 py-2">
  <!-- Logo -->
  <div class="header-left d-flex align-items-center">
    <img src="img/logo.png" class="logo-top me-2" />
  </div>

  <!-- Centro: título y nombre del usuario debajo -->
  <div class="header-center text-center flex-grow-1 d-flex flex-column align-items-center">
    <div class="app-name">DistriOchoa</div>
    <div class="usuario-header">
      <?= htmlspecialchars($nombre) ?> (<?= htmlspecialchars($rol) ?>)
    </div>
  </div>

 

<!-- Botón cerrar sesión estilizado -->
<div class="header-right">
  <a href="cerrar-sesion.php"
     class="btn btn-success btn-sm cerrar-sesion-btn d-flex align-items-center justify-content-center">
    <i class="bi bi-box-arrow-right"></i>
    <span class="cerrar-texto">Cerrar sesión</span>
  </a>
</div>


</header>





<main class="dashboard py-4">
  <!-- Fila 1 -->
  <div class="fila-opciones justify-content-center">
    <div class="opcion tarjeta-dashboard" onclick="window.location.href='registro-productos.php'">
      <img src="img/icon-productos.png" alt="Registrar productos" />
      <p>Registrar productos</p>
    </div>

    <div class="opcion tarjeta-dashboard" onclick="window.location.href='stock.php'">
      <img src="img/icon-stock.png" alt="Stock" />
      <p>Stock</p>
    </div>

    <?php if ($rol === 'admin'): ?>
    <div class="opcion tarjeta-dashboard" onclick="window.location.href='registro-usuarios.php'">
      <img src="img/icon-usuarios.png" alt="Registrar Usuarios" />
      <p>Registrar Usuarios</p>
    </div>
    <?php endif; ?>

    <div class="opcion tarjeta-dashboard" onclick="window.location.href='reportes.php'">
      <img src="img/icon-reportes.png" alt="Reportes" />
      <p>Reportes</p>
    </div>
  </div>

  <!-- Fila 2 -->
  <div class="fila-opciones justify-content-center">
    <div class="opcion tarjeta-dashboard" onclick="window.location.href='registro-salidas.php'">
      <img src="img/icon-salidas.png" alt="Registrar Salidas" />
      <p>Registrar Salidas</p>
    </div>

    <div class="opcion tarjeta-dashboard" onclick="window.location.href='devoluciones.php'">
      <img src="img/icon-devoluciones.png" alt="Registrar Devoluciones" />
      <p>Registrar Devoluciones</p>
    </div>

    <div class="opcion tarjeta-dashboard" onclick="window.location.href='categorias.php'">
      <img src="img/icono-categorias.png" alt="Categorías" />
      <p>Categorías</p>
    </div>
  </div>
</main>

<script src="../js/script.js"></script>
<script src="../js/bootstrap.min.js"></script>

<footer class="footer-dashboard mt-auto py-3">
  <div class="container text-center">
    <p class="mb-2">© 2025 <strong>DistriOchoa</strong>. Todos los derechos reservados.</p>
    
    <div class="redes-sociales">
      <a href="https://www.facebook.com" target="_blank"><i class="bi bi-facebook"></i></a>
      <a href="https://www.instagram.com" target="_blank"><i class="bi bi-instagram"></i></a>
      <a href="https://www.twitter.com" target="_blank"><i class="bi bi-twitter-x"></i></a>
      <a href="mailto:soporte@distriochoa.com"><i class="bi bi-envelope-fill"></i></a>
    </div>
  </div>
</footer>

</body>
</html>


