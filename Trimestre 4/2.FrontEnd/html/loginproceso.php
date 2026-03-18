<?php
session_start();
require_once '../conexion/conexion.php'; //conexion xd

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
  $correo = $_POST['correo'];
  $contrasena = $_POST['contrasena'];
  $rolSeleccionado = $_SESSION['rol_seleccionado'] ?? null; 

  try {
    $pdo = Conexion::getConexion();
    $stmt = $pdo->prepare("CALL validar_login(?, ?)");
    $stmt->execute([$correo, $contrasena]);

    $usuario = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($usuario) {
      $rolAsignado = ($usuario['Rol_idRol'] == 1) ? 'admin' : 'auxiliar';

if (strtolower($rolSeleccionado) !== strtolower($rolAsignado)) {
  session_destroy();
  header("Location: index.php?rolerror=mismatch&realrol=$rolAsignado");
  exit();
}



      $_SESSION['id'] = $usuario['idPersona'];
      $_SESSION['nombre'] = $usuario['nombre'];
      $_SESSION['correo'] = $usuario['correo'];
      $_SESSION['rol'] = $rolAsignado;

      // pa que ambos van al mismo dashboard
      header('Location: dashboard.php');
      exit();

    } else {
      header('Location: login.php?error=1');
      exit();
    }

  } catch (PDOException $e) {
    echo "Error: " . $e->getMessage();
    exit();
  }
}
