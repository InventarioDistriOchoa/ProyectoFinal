<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');

// ✅ Manejo de preflight para Flutter Web
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Configuración de la Base de Datos
$servername = "localhost";
$username = "root"; 
$password = ""; 
$dbname = "distriochoa"; 

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    http_response_code(500);
    die(json_encode(["message" => "Error de conexión a la base de datos: " . $conn->connect_error]));
}

$sql = "SELECT id, nombre, descripcion FROM categoria ORDER BY id ASC";
$result = $conn->query($sql);

$categorias = array();

if ($result) {
    if ($result->num_rows > 0) {
        while($row = $result->fetch_assoc()) {
            $categorias[] = $row;
        }
        http_response_code(200);
        echo json_encode($categorias);
    } else {
        http_response_code(200);
        echo json_encode([]);
    }
    $result->free();
} else {
    http_response_code(500);
    echo json_encode(["message" => "Error al ejecutar la consulta: " . $conn->error]);
}

$conn->close();
