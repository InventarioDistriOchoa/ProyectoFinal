<?php
session_start();

if (!isset($_SESSION['nombre']) || !isset($_SESSION['rol'])) {
  header('Location: login.php');
  exit();
}

$rol = $_SESSION['rol'];
?>

<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <title>Registrar Salida – DistriOchoa</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  
  <!-- Estilos -->
  <link rel="stylesheet" href="../css/styles.css" />
  <link rel="stylesheet" href="../css/bootstrap.min.css">
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" />
  <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body>

<!-- SIDEBAR -->
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

<!-- Botón hamburguesa -->
<button id="btn-toggle-sidebar" class="hamburguesa">
  <i class="bi bi-list"></i>
</button>

<!-- Pantalla principal -->
<div id="registrar-salida" class="pantalla bienvenida registro-screen d-flex flex-wrap">

  <!-- Columna Izquierda - Formulario -->
  <div class="columna-izquierda p-5" style="flex: 1;">
    <img src="img/logo.jpeg" alt="Logo" class="logo mb-4" />
    <h1 class="mb-4 text-success">Salidas</h1>

    <form id="form-registrar-salida" onsubmit="registrarVenta(event)" class="w-100">
      <div class="mb-3">
        <label for="producto" class="form-label fw-bold">Producto</label>
        <input type="text" id="producto" name="producto" class="form-control" required placeholder="Ej: Tomate" autocomplete="off" />
      </div>

      <div class="mb-3">
        <label for="categoria" class="form-label fw-bold">Categoría</label>
        <select id="categoria" name="categoria" class="form-select" required>
          <option value="" disabled>Selecciona una categoría</option>
          <option value="Frutas">Frutas</option>
          <option value="Verduras">Verduras</option>
          <option value="Tubérculos">Tubérculos</option>
          <option value="Hierbas Aromáticas">Hierbas Aromáticas</option>
        </select>
      </div>

      <div class="mb-3">
        <label for="cantidad" class="form-label fw-bold">Cantidad</label>
        <input type="number" id="cantidad" name="cantidad" class="form-control" required min="1" placeholder="Ej: 10" />
      </div>

      <div class="mb-4">
        <label for="precio" class="form-label fw-bold">Precio Unitario</label>
        <input type="number" id="precio" name="precio" class="form-control" required min="0.01" step="0.01" placeholder="Ej: 2.50" />
      </div>

      <button type="submit" class="btn btn-success w-100">
        Registrar Salida ➔
      </button>
    </form>
  </div>

  <!-- Columna Derecha - Imagen -->
  <div class="columna-derecha d-flex align-items-start justify-content-center p-4" style="flex: 1;">
    <div class="card shadow-lg border-0" style="overflow: hidden; border-radius: 20px;">
      <img 
        src="img/banner-distriochoa.png" 
        alt="Banner"
        class="img-fluid efecto-hover"
        style="max-height: 550px; width: auto; transition: transform 0.3s ease-in-out;" 
      />
    </div>
  </div>
</div>

<!-- FOOTER -->
<footer class="footer-dashboard mt-auto py-3">
  <div class="container text-center">
    <p class="mb-2 text-success">© 2025 <strong>DistriOchoa</strong>. Todos los derechos reservados.</p>
    <div class="redes-sociales">
      <a href="https://www.facebook.com" target="_blank"><i class="bi bi-facebook"></i></a>
      <a href="https://www.instagram.com" target="_blank"><i class="bi bi-instagram"></i></a>
      <a href="https://www.twitter.com" target="_blank"><i class="bi bi-twitter-x"></i></a>
      <a href="mailto:soporte@distriochoa.com"><i class="bi bi-envelope-fill"></i></a>
    </div>
  </div>
</footer>

<!-- Scripts -->
<script src="../js/script.js"></script>
<script src="../js/bootstrap.min.js"></script>
</body>
</html>
