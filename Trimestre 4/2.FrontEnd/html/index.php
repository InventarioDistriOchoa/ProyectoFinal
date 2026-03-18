<?php
session_start();

// Redirigir si ya inició sesión
if (isset($_SESSION['nombre']) && isset($_SESSION['rol'])) {
  header('Location: dashboard.php');
  exit();
}

// Destruir sesión si viene de cierre
if (isset($_GET['cerrada']) && $_GET['cerrada'] == 1) {
  session_destroy();
}

// Procesar rol elegido
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
  if (!empty($_POST['rol'])) {
    $_SESSION['rol_seleccionado'] = $_POST['rol'];
    header('Location: login.php');
    exit();
  }
}
?>

<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <title>DistriOchoa – Sistema de Inventario</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <!-- CSS de Bootstrap -->
  <link rel="stylesheet" href="../css/bootstrap.min.css" />
  <!-- Google Fonts y demás -->
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css"/>
  <!--  CSS  -->
  <link rel="stylesheet" href="../css/styles.css" />
  <!-- Scripts -->
  <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body>

<!-- Contenedor para asegurar responsividad -->
<div class="container-fluid min-vh-100 d-flex align-items-center justify-content-center px-3">
  <div class="row align-items-center justify-content-center w-100">

    <!-- 👇 Columna principal sin tarjeta -->
    <div class="col-12 col-md-6 d-flex flex-column justify-content-center align-items-center text-center mb-5 mb-md-0">

      <!-- 🧃 Logo -->
      <img src="../html/img/logo.png" 
           alt="Logo" 
           class="logo-login" 
           data-bs-toggle="tooltip" 
           title="¡Hola, soy el logo oficial! 😄" 
           style="width: 100px;" />

      <!-- 💬 Título de bienvenida -->
      <h1 class="display-4 fw-bold text-success">BIENVENIDO</h1>
      <p class="lead">Al sistema de gestión de inventario.</p>

      <!-- 📝 Formulario de rol -->
      <form action="login.php" method="POST" class="w-100 d-flex flex-column align-items-center animate__animated animate__fadeInDown">

        <!-- Etiqueta y Select -->
        <label for="rol" class="form-label text-success fw-bold fs-5">👤 Rol de acceso</label>
        <select name="rol" id="rol" class="form-select form-select-lg w-75 border-success shadow-sm mb-3 rounded-pill" required>
          <option value="">Selecciona tu Rol</option>
          <option value="admin">🛡️ Administrador</option>
          <option value="auxiliar">🧰 Auxiliar</option>
        </select>

        <!-- Botón con tooltip e ícono -->
        <button type="submit" class="btn btn-success btn-lg px-5 rounded-pill shadow-sm" data-bs-toggle="tooltip" data-bs-placement="top" title="Haz clic para continuar">
          Continuar <i class="bi bi-arrow-right-circle ms-2"></i>
        </button>
      </form>
    </div>

    <!-- Derecha -->
    <div class="col-12 col-md-6 text-center">
      <!-- Imagen sin borde, pero con sombra, hover y tooltip facherito -->
<img src="img/banner-distriochoa.png"
     alt="Imagen principal"
     class="imagen-bienvenida img-fluid rounded shadow"
        style="max-width: 600px; height: auto;"
     data-bs-toggle="tooltip" 
     title="Banner con flow 😌" />



    </div>
  </div>
</div>

<?php
// Alerta si el rol no coincide
if (isset($_GET['rolerror']) && $_GET['rolerror'] === 'mismatch') {
  $real = $_GET['realrol'] ?? '';
  $mensaje = '';

  if ($real === 'admin') {
    $mensaje = "Este usuario es administrador. Por favor selecciona correctamente ese rol.";
  } elseif ($real === 'auxiliar') {
    $mensaje = "Este usuario es auxiliar. Por favor selecciona correctamente ese rol.";
  }

  if ($mensaje !== '') {
  echo "<script>
    Swal.fire({
      icon: 'warning',
      title: 'Rol incorrecto',
      text: '$mensaje',
      confirmButtonColor: '#198754'
    });
  </script>";
}

}
?>
</body>
</html>
