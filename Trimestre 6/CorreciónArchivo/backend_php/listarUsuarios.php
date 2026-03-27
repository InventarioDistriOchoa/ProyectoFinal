<?php
include "conexion.php";

$sql = "SELECT id, nombre, email FROM usuarios";
$resultado = $conexion->query($sql);

$usuarios = array();

while ($row = $resultado->fetch_assoc()) {
    $usuarios[] = $row;
}

echo json_encode([
    "status" => "ok",
    "data" => $usuarios
]);
?>