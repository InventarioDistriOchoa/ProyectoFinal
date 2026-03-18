<?php
require_once '../conexion/conexion.php';
require_once '../modelo.dto/CategoriaDto.php';
require_once '../modelo.dao/CategoriaDao.php';

$dao = new CategoriaDao();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $categoria = new CategoriaDto();
    $categoria->setIdCategoria($_POST['idCategoria']);
    $categoria->setNombre($_POST['Nombre_Categoria']);
    $categoria->setDescripcion($_POST['descripcion']);
    $modo = $_POST['modo'] ?? 'crear';

    if ($modo === 'crear') {
        // Si ya existe una categoría con ese ID, no permite crear
        if ($dao->obtenerPorId($_POST['idCategoria'])) {
            header("Location: ../html/categorias.php?mensaje=Ya existe una categoría con ese ID");
            exit();
        }

        // Inserta nueva
        if ($dao->insertar($categoria)) {
            header("Location: ../html/categorias.php?mensaje=Categoría registrada con éxito");
        } else {
            header("Location: ../html/categorias.php?mensaje=Error al registrar la categoría");
        }
    } else {
        // Modo editar
        if ($dao->actualizar($categoria)) {
            header("Location: ../html/categorias.php?mensaje=Categoría actualizada correctamente");
        } else {
            header("Location: ../html/categorias.php?mensaje=Error al actualizar la categoría");
        }
    }
    exit();
}

if (isset($_GET['eliminar'])) {
    $id = $_GET['eliminar'];
    if ($dao->eliminar($id)) {
        header('Location: ../html/categorias.php?mensaje=Categoría eliminada');
    } else {
        header('Location: ../html/categorias.php?mensaje=Error al eliminar');
    }
    exit();
}
?>
