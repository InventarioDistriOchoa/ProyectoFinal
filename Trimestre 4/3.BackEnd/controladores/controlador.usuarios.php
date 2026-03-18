controlador.usuarios.php
<?php
require_once '../conexion/conexion.php';
require_once '../modelo.dao/UsuarioDao.php';
require_once '../modelo.dto/UsuarioDto.php';

$dao = new UsuarioDao();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $idPersona   = $_POST['idPersona'];
    $nombre      = $_POST['nombre'];
    $correo      = $_POST['correo'];
    $contrasena  = $_POST['contrasena']; // texto plano
    $tipoDoc     = $_POST['tipo_documento'];
    $rol         = $_POST['rol'];
    $editar      = $_POST['editar'];

    try {
        $pdo = Conexion::getConexion();

        if (!empty($editar) && $editar == "1") {
            // Verificar si el correo ya existe en otro usuario
            if ($dao->existeCorreo($correo, $idPersona)) {
                header("Location: ../html/registro-usuarios.php?mensaje=Este correo ya está registrado");
                exit();
            }

            // Encriptar la nueva contraseña con la función
            $stmt = $pdo->prepare("UPDATE persona SET 
                nombre = ?, 
                correo = ?, 
                Contrasena = encriptar_contrasena(?), 
                Tipo_Documento_idTipo_Documento = ?, 
                Rol_idRol = ?
                WHERE idPersona = ?");
            $stmt->execute([$nombre, $correo, $contrasena, $tipoDoc, $rol, $idPersona]);

            header("Location: ../html/registro-usuarios.php?mensaje=Usuario actualizado correctamente");
            exit();

        } else {
            // Verificar si ya existe el correo
            if ($dao->existeCorreo($correo)) {
                header("Location: ../html/registro-usuarios.php?mensaje=Este correo ya está registrado");
                exit();
            }

            // Insertar llamando al procedimiento
            $stmt = $pdo->prepare("CALL insertar_usuario_encriptado(?, ?, ?, ?, ?, ?)");
            $stmt->execute([$idPersona, $nombre, $correo, $contrasena, $tipoDoc, $rol]);

            header("Location: ../html/registro-usuarios.php?mensaje=Usuario registrado con éxito");
            exit();
        }

    } catch (PDOException $e) {
        echo "Error al registrar: " . $e->getMessage();
        exit();
    }
}

if (isset($_GET['eliminar'])) {
    $id = $_GET['eliminar'];
    if ($dao->eliminar($id)) {
        header('Location: ../html/registro-usuarios.php?mensaje=Usuario eliminado correctamente');
    } else {
        header('Location: ../html/registro-usuarios.php?mensaje=No se puede eliminar este usuario porque tiene datos relacionados');
    }
    exit();
}
?>


