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
  <title>Reportes – DistriOchoa</title>
  <link rel="stylesheet" href="../css/bootstrap.min.css" />
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet" />
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css" />
  <link rel="stylesheet" href="../css/styles.css" />
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

<!-- Vista de Reportes -->
<section id="vista-reportes" class="pantalla Dashboard-screen" style="display: block;">
  <div class="container py-5">
    <div class="d-flex align-items-center mb-4 gap-3">
      <img src="img/logo.jpeg" alt="Logo DistriOchoa" class="img-fluid" style="max-height: 60px; border-radius: 10px;" />
      <h2 class="text-success m-0"><i class="bi bi-bar-chart-fill"></i> Reportes del Inventario</h2>
    </div>

    <div class="row g-4">
      <div class="col-md-6">
        <div class="card p-3 shadow">
          <h5 class="text-center">Productos más vendidos</h5>
          <canvas id="graficoBarras" height="200"></canvas>
        </div>
      </div>
      <div class="col-md-6">
        <div class="card p-3 shadow">
          <h5 class="text-center">Distribución por categoría</h5>
          <canvas id="graficoPastel" height="200"></canvas>
        </div>
      </div>
      <div class="col-md-6">
        <div class="card p-3 shadow">
          <h5 class="text-center">Entradas por mes</h5>
          <canvas id="graficoLinea" height="200"></canvas>
        </div>
      </div>
      <div class="col-md-6">
        <div class="card p-3 shadow">
          <h5 class="text-center">Stock actual</h5>
          <canvas id="graficoHorizontal" height="200"></canvas>
        </div>
      </div>
    </div>

    <div class="text-center mt-4">
      <button onclick="volverInicio()" class="btn btn-success">
        <i class="bi bi-house-door-fill"></i> Volver al Inicio
      </button>
    </div>
  </div>
</section>

<!-- Scripts -->
<script src="../js/bootstrap.min.js"></script>
<script src="../js/script.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>

<script>
document.addEventListener("DOMContentLoaded", function () {
  new Chart(document.getElementById('graficoBarras'), {
    type: 'bar',
    data: {
      labels: ['Tomate', 'Papa', 'Cebolla', 'Manzana'],
      datasets: [{
        label: 'Cantidad vendida',
        data: [50, 75, 60, 40],
        backgroundColor: ['#2ecc71', '#3498db', '#f39c12', '#e74c3c']
      }]
    },
    options: {
      responsive: true,
      plugins: { legend: { display: false } }
    }
  });

  new Chart(document.getElementById('graficoPastel'), {
    type: 'pie',
    data: {
      labels: ['Frutas', 'Verduras', 'Tubérculos'],
      datasets: [{
        label: 'Categorías',
        data: [35, 45, 20],
        backgroundColor: ['#e67e22', '#1abc9c', '#9b59b6']
      }]
    }
  });

  new Chart(document.getElementById('graficoLinea'), {
    type: 'line',
    data: {
      labels: ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun'],
      datasets: [{
        label: 'Entradas',
        data: [10, 20, 15, 25, 22, 30],
        fill: true,
        backgroundColor: 'rgba(46,204,113,0.2)',
        borderColor: '#27ae60',
        tension: 0.3
      }]
    }
  });

  new Chart(document.getElementById('graficoHorizontal'), {
    type: 'bar',
    data: {
      labels: ['Tomate', 'Zanahoria', 'Papa', 'Limón'],
      datasets: [{
        label: 'Unidades en stock',
        data: [25, 40, 35, 15],
        backgroundColor: '#3498db'
      }]
    },
    options: {
      indexAxis: 'y',
      responsive: true,
      plugins: { legend: { display: false } }
    }
  });
});
</script>

</body>
</html>
