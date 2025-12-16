<?php
// ✅ CORS para permitir Flutter Web
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header('Content-Type: application/json');

// ✅ Respuesta a petición OPTIONS (Chrome preflight)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// ✅ Configuración BD
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "distriochoa";

// ✅ Conexión
$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    http_response_code(500);
    die(json_encode(["message" => "Error de conexión a la base de datos: " . $conn->connect_error]));
}

// ✅ Soporte JSON y FORM DATA
$rawData = file_get_contents("php://input");
$data = json_decode($rawData, true);

// Si viene desde Flutter Web con form-data ($_POST)
if (!$data) {
    $data = $_POST;
}

// ✅ Validación
if (empty($data['nombre'])) {
    http_response_code(400);
    echo json_encode(["message" => "El campo 'nombre' es obligatorio."]);
    $conn->close();
    exit();
}

$nombre = $data['nombre'];
$descripcion = $data['descripcion'] ?? "";

// ✅ SQL seguro
$sql = "INSERT INTO categoria (nombre, descripcion) VALUES (?, ?)";
$stmt = $conn->prepare($sql);

if (!$stmt) {
    http_response_code(500);
    echo json_encode(["message" => "Error al preparar la consulta: " . $conn->error]);
    $conn->close();
    exit();
}

$stmt->bind_param("ss", $nombre, $descripcion);

// ✅ Ejecutar
if ($stmt->execute()) {
    http_response_code(201);
    echo json_encode([
        "message" => "Categoría creada exitosamente.",
        "id" => $stmt->insert_id,
        "nombre" => $nombre,
        "descripcion" => $descripcion
    ]);
} else {
    http_response_code(500);
    echo json_encode(["message" => "Error al crear la categoría: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
