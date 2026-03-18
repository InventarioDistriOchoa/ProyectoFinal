<?php
session_start();

if (!isset($_SESSION['nombre']) || !isset($_SESSION['rol'])) {
  header('Location: login.php');
  exit();
}

$rol = $_SESSION['rol'];
?>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Gestión de Categorías - DistriOchoa</title>
  <link rel="stylesheet" href="../css/styles.css">
  <link rel="stylesheet" href="../css/bootstrap.min.css">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
<!-- SIDEBAR -->
<div id="sidebar-vertical" class="sidebar" style="display: none;">
  <button onclick="mostrarRegistro()">Registrar Producto</button>
  <button onclick="mostrarRegistrarSalida()">Registrar Salida</button>
  <button onclick="mostrarReportes()">Reportes</button>
  <?php if ($rol === 'admin'): ?>
    <button onclick="mostrarRegistroUsuarios()">Usuarios</button>
  <?php endif; ?>
  <button onclick="mostrarGestionCategorias()">Categorías</button>
  <button onclick="mostrarStock()">📦 Ver Stock</button>
  <button onclick="mostrarDevoluciones()">Devoluciones</button>
  <button onclick="volverInicio()">Volver al Inicio</button>
</div>

<!-- Botón hamburguesa -->
<button id="btn-toggle-sidebar" class="hamburguesa">
  <i class="bi bi-list"></i>
</button>

<!-- Vista Categorías -->
<div id="vista-categorias" class="pantalla bienvenida registro-screen">
  <div class="container mt-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
      <h2 class="mb-0"><i class="bi bi-tags"></i> Gestión de Categorías</h2>
      <div>
        <button class="btn btn-outline-secondary me-2" onclick="mostrarListadoCategorias()">
          <i class="bi bi-card-list"></i> Ver Listado
        </button>
        <button class="btn btn-success" onclick="mostrarFormularioCategoria()">
          <i class="bi bi-plus-circle"></i> Nueva Categoría
        </button>
      </div>
    </div>

    <!-- FORMULARIO DE REGISTRO -->
    <div id="formulario-categoria" style="display: none;">
      <form action="../controladores/controlador.categorias.php" method="POST" class="row g-3">
        <input type="hidden" name="modo" id="modo" value="crear">
        <div class="col-md-4">
          <label for="idCategoria" class="form-label">ID Categoría</label>
          <input type="text" class="form-control" name="idCategoria" id="idCategoria" required>
        </div>
        <div class="col-md-4">
          <label for="Nombre_Categoria" class="form-label">Nombre</label>
          <input type="text" class="form-control" name="Nombre_Categoria" id="Nombre_Categoria" required>
        </div>
        <div class="col-md-4">
          <label for="descripcion" class="form-label">Descripción</label>
          <input type="text" class="form-control" name="descripcion" id="descripcion" required>
        </div>
        <div class="col-12">
          <button type="submit" class="btn btn-success"><i class="bi bi-save"></i> Guardar Categoría</button>
        </div>
      </form>
    </div>

    <!-- LISTADO DE CATEGORIAS -->
    <div id="listado-categorias">
      <h4 class="mb-3">Listado de Categorías</h4>
      <table class="table table-bordered table-hover">
        <thead class="table-success">
          <tr>
            <th>ID</th>
            <th>Nombre</th>
            <th>Descripción</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <?php
          require_once '../modelo.dao/CategoriaDao.php';
          $dao = new CategoriaDao();
          $categorias = $dao->listarTodos();
          foreach ($categorias as $cat) {
            echo "<tr>";
            echo "<td>{$cat['idCategoria']}</td>";
            echo "<td>{$cat['Nombre_Categoria']}</td>";
            echo "<td>{$cat['descripcion']}</td>";
            echo "<td class='text-center'>";
            echo "<button class='btn btn-editar btn-icon rounded-circle me-2' onclick=\"abrirModalEditarCategoria('{$cat['idCategoria']}', '{$cat['Nombre_Categoria']}', '{$cat['descripcion']}')\"><i class='bi bi-pencil'></i></button>";
            echo "<a href='../controladores/controlador.categorias.php?eliminar={$cat['idCategoria']}' class='btn btn-eliminar btn-icon rounded-circle' onclick=\"return confirm('¿Eliminar esta categoría?')\"><i class='bi bi-trash'></i></a>";
            echo "</td>";
            echo "</tr>";
          }
          ?>
        </tbody>
      </table>
    </div>

    <?php if (isset($_GET['mensaje'])): ?>
      <div class="alert alert-info mt-4 text-center">
        <?= htmlspecialchars($_GET['mensaje']) ?>
      </div>
    <?php endif; ?>
  </div>
</div>

<!-- MODAL EDICION CATEGORIA -->
<div class="modal fade" id="modalEditarCategoria" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <form action="../controladores/controlador.categorias.php" method="POST">
        <div class="modal-header">
          <h5 class="modal-title">Editar Categoría</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
        </div>
        <div class="modal-body">
          <input type="hidden" name="modo" value="editar">
          <div class="mb-3">
            <label for="edit-idCategoria" class="form-label">ID</label>
            <input type="text" class="form-control" id="edit-idCategoria" name="idCategoria" readonly>
          </div>
          <div class="mb-3">
            <label for="edit-Nombre_Categoria" class="form-label">Nombre</label>
            <input type="text" class="form-control" id="edit-Nombre_Categoria" name="Nombre_Categoria" required>
          </div>
          <div class="mb-3">
            <label for="edit-descripcion" class="form-label">Descripción</label>
            <input type="text" class="form-control" id="edit-descripcion" name="descripcion" required>
          </div>
        </div>
        <div class="modal-footer">
          <button type="submit" class="btn btn-success w-100"><i class="bi bi-check-circle"></i> Actualizar</button>
        </div>
      </form>
    </div>
  </div>
</div>

<!-- FOOTER -->
<footer class="footer-dashboard mt-auto py-3">
  <div class="container text-center">
    <p class="mb-2 text-success">&copy; 2025 <strong>DistriOchoa</strong>. Todos los derechos reservados.</p>
    <div class="redes-sociales">
      <a href="https://www.facebook.com" target="_blank"><i class="bi bi-facebook"></i></a>
      <a href="https://www.instagram.com" target="_blank"><i class="bi bi-instagram"></i></a>
      <a href="https://www.twitter.com" target="_blank"><i class="bi bi-twitter-x"></i></a>
      <a href="mailto:soporte@distriochoa.com"><i class="bi bi-envelope-fill"></i></a>
    </div>
  </div>
</footer>

<!-- SCRIPTS -->
<script src="../js/script.js"></script>

</script>
</body>
</html>
