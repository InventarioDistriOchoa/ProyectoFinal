<?php

header("Content-Type: application/json; charset=utf-8");

$host = "localhost";
$user = "root";
$pass = "";
$db = "proyecto_valka";

$conexion = new mysqli($host, $user, $pass, $db);

if ($conexion->connect_error) {
    die(json_encode([
        "status" => "error",
        "mensaje" => "Error en la conexión: " . $conexion->connect_error
    ]));
}

?>