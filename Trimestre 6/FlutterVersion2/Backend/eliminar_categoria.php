<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Content-Type: application/json");

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "distriochoa";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode(["message" => "Error de conexión: " . $conn->connect_error]);
    exit();
}

// ✅ ACEPTAR ID POR POST O GET
$id = $_POST['id'] ?? $_GET['id'] ?? null;

if (!$id || !is_numeric($id)) {
    http_response_code(400);
    echo json_encode(["message" => "ID inválido o no enviado"]);
    exit();
}

$id = intval($id);

$sql = "DELETE FROM categoria WHERE id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $id);

if ($stmt->execute()) {

    if ($stmt->affected_rows > 0) {
        http_response_code(200);
        echo json_encode(["message" => "Categoría eliminada correctamente"]);
    } else {
        http_response_code(404);
        echo json_encode(["message" => "No existe una categoría con ese ID"]);
    }

} else {
    http_response_code(500);
    echo json_encode(["message" => "Error al eliminar: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
