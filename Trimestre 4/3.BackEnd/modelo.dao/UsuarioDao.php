<?php
require_once '../conexion/conexion.php';
require_once '../modelo.dto/UsuarioDto.php';

class UsuarioDao {
    private $pdo;

    public function __construct() {
        $this->pdo = Conexion::getConexion();
    }

    public function insertar($usuario) {
        try {
            // Validar si el ID o correo ya existen
            $verificar = $this->pdo->prepare("SELECT COUNT(*) FROM persona WHERE idPersona = ? OR correo = ?");
            $verificar->execute([$usuario->getIdPersona(), $usuario->getCorreo()]);
            if ($verificar->fetchColumn() > 0) return false;

            $sql = "INSERT INTO persona (idPersona, nombre, correo, Contrasena, Tipo_Documento_idTipo_Documento, Rol_idRol)
                    VALUES (?, ?, ?, ?, ?, ?)";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute([
                $usuario->getIdPersona(),
                $usuario->getNombre(),
                $usuario->getCorreo(),
                $usuario->getContrasena(),
                $usuario->getTipoDocumento(),
                $usuario->getRol()
            ]);
            return true;
        } catch (PDOException $e) {
            return false;
        }
    }

    public function actualizar($usuario) {
        try {
            $sql = "UPDATE persona SET nombre=?, correo=?, Contrasena=?, Tipo_Documento_idTipo_Documento=?, Rol_idRol=?
                    WHERE idPersona=?";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute([
                $usuario->getNombre(),
                $usuario->getCorreo(),
                $usuario->getContrasena(),
                $usuario->getTipoDocumento(),
                $usuario->getRol(),
                $usuario->getIdPersona()
            ]);
            return true;
        } catch (PDOException $e) {
            return false;
        }
    }

 public function eliminar($idPersona) {
    try {
        $sql = "DELETE FROM persona WHERE idPersona = ?";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute([$idPersona]);
        return true;
    } catch (PDOException $e) {
        // Si hay un error por restricción de clave foránea, devuelve false
        return false;
    }
}



public function listarTodos() {
    try {
        $sql = "SELECT 
                    p.idPersona, 
                    p.nombre, 
                    p.correo, 
                    p.Contrasena,
                    p.Tipo_Documento_idTipo_Documento AS idTipo_Documento,
                    td.descripcion AS tipo_documento,
                    p.Rol_idRol AS idRol,
                    r.Descripcion_Rol AS rol
                FROM persona p
                INNER JOIN tipo_documento td ON p.Tipo_Documento_idTipo_Documento = td.idTipo_Documento
                INNER JOIN roles r ON p.Rol_idRol = r.idRol
                ORDER BY p.idPersona DESC";
        $stmt = $this->pdo->query($sql);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    } catch (PDOException $e) {
        return [];
    }
}



    public function obtenerPorId($idPersona) {
        try {
            $sql = "SELECT * FROM persona WHERE idPersona = ?";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute([$idPersona]);
            return $stmt->fetch(PDO::FETCH_ASSOC);
        } catch (PDOException $e) {
            return null;
        }
    }

    public function existeId($idPersona) {
    try {
        $sql = "SELECT COUNT(*) FROM persona WHERE idPersona = ?";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute([$idPersona]);
        $count = $stmt->fetchColumn();
        return $count > 0;
    } catch (PDOException $e) {
        return false;
    }
}

public function existeCorreo($correo, $idPersona = null) {
    try {
        if ($idPersona) {
            $sql = "SELECT COUNT(*) FROM persona WHERE correo = ? AND idPersona != ?";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute([$correo, $idPersona]);
        } else {
            $sql = "SELECT COUNT(*) FROM persona WHERE correo = ?";
            $stmt = $this->pdo->prepare($sql);
            $stmt->execute([$correo]);
        }
        return $stmt->fetchColumn() > 0;
    } catch (PDOException $e) {
        return false;
    }
}

}
?>
