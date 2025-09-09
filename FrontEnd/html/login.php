<?php
session_start();
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['rol'])) {
  $_SESSION['rol_seleccionado'] = $_POST['rol'];
  header('Location: login.php');
  exit();
}
if (isset($_SESSION['nombre']) && isset($_SESSION['rol'])) {
  header('Location: dashboard.php');
  exit();
}
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
  <!--  CSS mio -->
  <link rel="stylesheet" href="../css/styles.css" />
  <!-- Scripts -->
  <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body>


<div class="container-fluid min-vh-100 d-flex justify-content-center align-items-center p-3">
  <div class="login-screen w-100">

    <!-- Cabecera con  el logo -->
    <div class="login-header">
      <img src="../html/img/logo.png" alt="Logo" class="logo-login" data-bs-toggle="tooltip" title="¡Hola, soy el logo oficial! 😄" />
      <span>DistriOchoa</span>
    </div>

    <!-- Contenedor del formulario claroo -->
    <div id="form-login">
      <div class="pantalla">
        <div class="login-box shadow-lg animate__animated animate__fadeInUp rounded-4 zoom-hover w-100" style="max-width: 480px;">
          <form action="loginproceso.php" method="POST">

            <div class="mensaje-inicial text-center">
              ¡Hola! Inicia aquí <span class="emoji">😉</span>
              <div class="flecha-abajo">👇</div>
            </div>

            <input type="email" name="correo" class="form-control rounded-4 shadow-sm mb-3" placeholder="Correo" required />
            <input type="password" name="contrasena" class="form-control rounded-4 shadow-sm mb-3" placeholder="Contraseña" required />
            <button type="submit" class="btn btn-success w-100 mt-2">Iniciar sesión</button>

            <!-- parte de Olvidaste tu contraseña -->
            <a href="#" class="recuperar d-block mt-3" onclick="Swal.fire({
              icon: 'success',
              title: '¡Tranquila!',
              text: 'Revisa tu correo para recuperar tu contraseña 😉',
              confirmButtonColor: '#198754'
            })">¿Has olvidado tu contraseña?</a>

          </form>
        </div>
      </div>
    </div>
  </div>
</div>

<?php
if (isset($_GET['error']) && $_GET['error'] == 1) {
  echo "<script>
    Swal.fire({
      icon: 'success',
      title: 'Ups... Creo que asi no era 🌱',
      text: 'Correo o contraseña incorrectos',
      confirmButtonColor: '#198754'
    });
  </script>";
}

if (isset($_GET['rolerror']) && $_GET['rolerror'] === 'mismatch') {
  echo "<script>
    Swal.fire({
      icon: 'success',
      title: 'Rol incorrecto, pero tranquilo 🍃',
      text: 'Este usuario no tiene permitido ingresar como el rol seleccionado.',
      confirmButtonColor: '#198754'
    });
  </script>";
}

if (isset($_GET['cerrada']) && $_GET['cerrada'] == 1) {
  echo "<script>
    Swal.fire({
      icon: 'success',
      title: 'Sesión cerrada ✅',
      text: 'Has cerrado sesión exitosamente.',
      confirmButtonColor: '#198754'
    });
  </script>";
}
?>


</body>
</html>

