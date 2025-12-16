<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);
// =======================================================================
// CONFIGURACIÓN DE DEPURACIÓN Y CABECERAS (CRÍTICO PARA JSON)
// =======================================================================
// 1. Desactiva la visualización de errores y advertencias de PHP 
//    para que no contaminen la respuesta JSON (Esto soluciona el FormatException).
ini_set('display_errors', 0); 
error_reporting(E_ALL); 

// 2. Cabeceras necesarias
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS"); // Incluimos GET para la búsqueda

// =======================================================================
// CONFIGURACIÓN DE LA BASE DE DATOS
// =======================================================================
$servername = "localhost";
// ¡IMPORTANTE! Reemplaza "tu_usuario" y "tu_clave" con tus credenciales reales de XAMPP
$username = "root"; 
$password = ""; 
$dbname = "DISTRIOCHOA"; 

// --- 1. Obtener y validar el ID ---
if (isset($_GET['id']) && is_numeric($_GET['id'])) {
    $id = intval($_GET['id']);
} else {
    // Si no se recibe el ID, devolvemos 400 Bad Request
    http_response_code(400); 
    echo json_encode(["success" => false, "message" => "El ID de la categoría es obligatorio y debe ser un número."]);
    exit();
}

// Conexión
$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    // Si falla la conexión a la base de datos, devolvemos 500
    http_response_code(500);
    echo json_encode(["success" => false, "message" => "Error de conexión a la base de datos: " . $conn->connect_error]);
    exit();
}

// Consulta SQL para seleccionar la categoría por ID (USANDO CONSULTAS PREPARADAS)
$sql = "SELECT id, nombre, descripcion FROM categorias WHERE id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $id); // "i" es para integer (entero)
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    // 2. Éxito: Encontramos la categoría
    $categoria = $result->fetch_assoc();
    http_response_code(200); // 200 OK
    echo json_encode(["success" => true, "data" => $categoria]);
} else {
    // 3. No encontrado
    http_response_code(404); // 404 Not Found
    echo json_encode(["success" => false, "message" => "Categoría con ID $id no encontrada."]);
}

$stmt->close();
$conn->close();
?>