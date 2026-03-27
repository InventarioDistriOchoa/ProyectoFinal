<?php
header("Content-Type: application/json; charset=utf-8");
include "conexion.php";

$input = file_get_contents("php://input");
$data = json_decode($input, true);

if (!$data || !isset($data['email']) || !isset($data['clave'])) {
    echo json_encode([
        "status" => "error",
        "mensaje" => "Datos incompletos"
    ]);
    exit();
}

$email = $data['email'];
$clave = $data['clave'];

$sql = "SELECT id, nombre, email FROM usuarios WHERE email='$email' AND clave='$clave'";
$resultado = $conexion->query($sql);

if ($resultado->num_rows > 0) {
    $usuario = $resultado->fetch_assoc();
    echo json_encode([
        "status" => "ok",
        "mensaje" => "Login exitoso",
        "usuario" => $usuario
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "mensaje" => "Correo o clave incorrectos"
    ]);
}
?>