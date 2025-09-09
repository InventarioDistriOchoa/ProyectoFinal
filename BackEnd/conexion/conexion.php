<?php
class Conexion {
    public static function getConexion() {
        try {
            $conn = new PDO("mysql:host=localhost;dbname=distriochoa", "root", "");
            $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            return $conn;
        } catch (PDOException $ex) {
            die("Error de conexión: " . $ex->getMessage());
        }
    }
}
?>