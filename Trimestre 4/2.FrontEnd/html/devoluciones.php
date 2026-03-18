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
  <title>Devoluciones – DistriOchoa</title>
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

<!-- Vista Devoluciones -->
<!-- Contenedor principal de la sección -->
<div id="seccionDevoluciones" class="pantalla bienvenida registro-screen d-flex flex-column px-4">

  <!-- Botones de navegación -->
  <div class="text-center my-3">
    <button class="btn btn-outline-success me-2" onclick="mostrarFormularioDevolucion()">
      <i class="bi bi-pencil-square"></i> Registrar Devolución
    </button>
  <button class="btn btn-outline-success" onclick="mostrarListadoDevoluciones()">
  <i class="bi bi-card-list"></i> Ver Registros
</button>

  </div>

  <!-- Subvista: Formulario de devoluciones -->
  <div id="vista-formulario-devolucion" class="d-flex flex-wrap align-items-center justify-content-center">
    <!-- Lado izquierdo: Formulario -->
    <div class="p-5" style="flex: 1; min-width: 300px; max-width: 600px;">
      <h2 class="text-center mb-4 text-success">
        <i class="bi bi-arrow-counterclockwise"></i> Devoluciones
      </h2>
      <form class="row g-3 bg-white rounded-4 shadow-lg p-4" onsubmit="registrarDevolucion(event)">
        <div class="col-12">
          <input type="text" id="dev-nombre" placeholder="Nombre del producto" class="form-control shadow-sm rounded-3" required />
        </div>
        <div class="col-12">
          <input type="text" id="dev-proveedor" placeholder="Proveedor" class="form-control shadow-sm rounded-3" required />
        </div>
        <div class="col-12">
          <input type="text" id="dev-responsable" placeholder="Empleado responsable" class="form-control shadow-sm rounded-3" required />
        </div>
        <div class="col-md-6">
          <input type="number" id="dev-cantidad" placeholder="Cantidad" class="form-control shadow-sm rounded-3" required />
        </div>
        <div class="col-md-6">
          <input type="date" id="dev-fecha" class="form-control shadow-sm rounded-3" required />
        </div>
        <div class="col-12">
          <input type="text" id="dev-motivo" placeholder="Motivo" class="form-control shadow-sm rounded-3" required />
        </div>
        <div class="col-12">
          <button type="submit" class="btn btn-outline-success w-100 rounded-3">
            <i class="bi bi-upload"></i> Generar devolución ➔
          </button>
        </div>
      </form>
    </div>

    <!-- Lado derecho: Imagen -->
    <div class="p-4 d-flex justify-content-center align-items-center" style="flex: 1;">
      <img src="img/banner-distriochoa.png" alt="Banner Devoluciones"
        class="img-fluid efecto-hover"
        style="max-height: 500px; border-radius: 20px; box-shadow: 0 0 15px rgba(0,0,0,0.1);" />
    </div>
  </div>

  <!-- Subvista: Listado de devoluciones -->
  <div id="vista-listado-devoluciones" class="d-none mt-4">
  <h4 class="text-center mb-4 text-success"><i class="bi bi-card-list"></i> Historial de Devoluciones</h4>

    <div class="table-responsive">
      <table class="table table-hover table-bordered bg-white rounded-4 shadow-sm">
        <thead class="table-success">
          <tr>
            <th>Producto</th>
            <th>Proveedor</th>
            <th>Responsable</th>
            <th>Cantidad</th>
            <th>Fecha</th>
            <th>Motivo</th>
          </tr>
        </thead>
        <tbody id="tablaDevoluciones">
          <!-- Aquí se insertarán filas dinámicamente -->
        </tbody>
      </table>
    </div>
  </div>
</div>


</div>

<!-- FOOTER -->
<footer class="footer-dashboard mt-5 py-3">
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






<script src="../js/bootstrap.min.js"></script>
<script src="../js/script.js"></script> <!-- Tu lógica personalizada -->


</body>
</html>

