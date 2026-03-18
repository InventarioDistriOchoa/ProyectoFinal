<?php
session_start();

if (!isset($_SESSION['nombre']) || !isset($_SESSION['rol'])) {
  header('Location: login.php');
  exit();
}

$rol = $_SESSION['rol'];
$nombreUsuario = $_SESSION['nombre'];
?>

<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <title>Registrar Producto – DistriOchoa</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />

  <link rel="stylesheet" href="../css/styles.css" />
  <link rel="stylesheet" href="../css/bootstrap.min.css">
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
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

<!-- Botón hamburguesa -->
<button id="btn-toggle-sidebar" class="hamburguesa">
  <i class="bi bi-list"></i>
</button>

<!-- Registro de Productos -->
<div id="registro-productos" class="pantalla bienvenida registro-screen d-flex flex-wrap">
  <!-- Lado izquierdo -->
  <div class="columna-izquierda p-5" style="flex: 1;">
    <img src="img/logo.jpeg" alt="Logo" class="logo mb-4" />
    <h1 class="mb-4">Registrar Entrada</h1>

    <form id="form-registro" onsubmit="registrarEntrada(event)" class="w-100">
      <div class="mb-3">
        <label for="prod-nombre" class="form-label fw-bold">Nombre del producto</label>
        <input type="text" id="prod-nombre" class="form-control" required />
      </div>

      <div class="mb-3">
        <label for="prod-categoria" class="form-label fw-bold">Categoría</label>
        <select id="prod-categoria" class="form-select" required>
          <option value="" disabled selected>Selecciona una categoría</option>
          <option value="Frutas">Frutas</option>
          <option value="Verduras">Verduras</option>
          <option value="Tubérculos">Tubérculos</option>
          <option value="Hierbas Aromáticas">Hierbas Aromáticas</option>
        </select>
      </div>

      <div class="mb-3">
        <label for="prod-precio" class="form-label fw-bold">Precio unitario</label>
        <input type="number" id="prod-precio" class="form-control" step="0.01" required />
      </div>

      <div class="mb-3">
        <label for="prod-cantidad" class="form-label fw-bold">Cantidad ingresada</label>
        <input type="number" id="prod-cantidad" class="form-control" min="1" required />
      </div>

      <div class="mb-3">
        <label for="prod-proveedor" class="form-label fw-bold">Proveedor</label>
        <select id="prod-proveedor" class="form-select" required>
          <option value="" disabled selected>Selecciona un proveedor</option>
          <option value="Proveedor A">Proveedor A</option>
          <option value="Proveedor B">Proveedor B</option>
          <option value="Proveedor C">Proveedor C</option>
        </select>
      </div>

      <div class="mb-3">
        <label for="prod-persona" class="form-label fw-bold">Responsable</label>
        <input type="text" id="prod-persona" class="form-control" value="<?php echo htmlspecialchars($nombreUsuario); ?>" readonly />
      </div>
<div class="mb-3">
  <label for="prod-fecha" class="form-label fw-bold">Fecha de entrada</label>
  <input type="date" id="prod-fecha" class="form-control" required />
</div>


      <button type="submit" class="btn btn-success w-100">Registrar Entrada ➔</button>
    </form>
  </div>

  <!-- Lado derecho con imagen -->
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

<script src="../js/script.js"></script>
<script src="../js/bootstrap.min.js"></script>
</body>
</html>
