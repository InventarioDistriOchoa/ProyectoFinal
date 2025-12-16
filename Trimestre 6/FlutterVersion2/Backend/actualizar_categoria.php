<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "distriochoa";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode(["message" => "Error de conexión"]);
    exit();
}

// ✅ Leer JSON
$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['id']) || !isset($data['nombre'])) {
    http_response_code(400);
    echo json_encode(["message" => "Datos incompletos"]);
    exit();
}

$id = intval($data['id']);
$nombre = $data['nombre'];

$sql = "UPDATE categoria SET nombre = ? WHERE id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("si", $nombre, $id);

if ($stmt->execute()) {
    http_response_code(200);
    echo json_encode(["message" => "Categoría actualizada"]);
} else {
    http_response_code(500);
    echo json_encode(["message" => "Error al actualizar"]);
}

$stmt->close();
$conn->close();
