<?php
include "conexion.php";

// Recibir JSON bruto desde la petición
$input = file_get_contents("php://input");
$data = json_decode($input, true);

// Validar que venga JSON correcto
if (!$data || !isset($data['nombre']) || !isset($data['email']) || !isset($data['clave'])) {
    echo json_encode([
        "status" => "error",
        "mensaje" => "Faltan datos o JSON inválido"
    ]);
    exit();
}

// Extraer los campos
$nombre = $data['nombre'];
$email  = $data['email'];
$clave  = $data['clave'];

// Insertar en la BD
$sql = "INSERT INTO usuarios(nombre, email, clave) VALUES ('$nombre', '$email', '$clave')";
$resultado = $conexion->query($sql);

if ($resultado) {
    echo json_encode([
        "status" => "Excelente  ",
        "mensaje" => "Usuario registrado con éxito"
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "mensaje" => "No se pudo hacer el registro. Inténtalo nuevamente"
    ]);
}
?>