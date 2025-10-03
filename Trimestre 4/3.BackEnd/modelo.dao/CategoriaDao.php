<?php
require_once '../conexion/conexion.php';

class CategoriaDao {
    private $pdo;

    public function __construct() {
        $this->pdo = Conexion::getConexion();
    }

    public function insertar($categoria) {
        try {
            $sql = "INSERT INTO categorias (idCategoria, Nombre_Categoria, descripcion) VALUES (?, ?, ?)";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute([
                $categoria->getIdCategoria(),
                $categoria->getNombre(),
                $categoria->getDescripcion()
            ]);
            return true;
        } catch (PDOException $e) {
            error_log("Error al insertar categoría: " . $e->getMessage());
            return false;
        }
    }

    public function eliminar($idCategoria) {
        try {
            $sql = "DELETE FROM categorias WHERE idCategoria = ?";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute([$idCategoria]);
            return true;
        } catch (PDOException $e) {
            return false;
        }
    }

    public function actualizar($categoria) {
        try {
            $sql = "UPDATE categorias SET Nombre_Categoria = ?, descripcion = ? WHERE idCategoria = ?";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute([
                $categoria->getNombre(),
                $categoria->getDescripcion(),
                $categoria->getIdCategoria()
            ]);
            return true;
        } catch (PDOException $e) {
            return false;
        }
    }

    public function listarTodos() {
        try {
            $sql = "SELECT * FROM categorias ORDER BY idCategoria DESC";
            $stmt = $this->pdo->query($sql);
            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (PDOException $e) {
            return [];
        }
    }

    public function obtenerPorId($idCategoria) {
        try {
            $sql = "SELECT * FROM categorias WHERE idCategoria = ?";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute([$idCategoria]);
            return $stmt->fetch(PDO::FETCH_ASSOC);
        } catch (PDOException $e) {
            return null;
        }
    }
}
?>
