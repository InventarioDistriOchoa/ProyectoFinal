<?php
session_start();
$rol = $_SESSION['rol'] ?? null;
require_once '../modelo.dao/UsuarioDao.php';
require_once '../conexion/conexion.php';

$pdo = Conexion::getConexion();
$tiposStmt = $pdo->query("SELECT idTipo_Documento, descripcion FROM tipo_documento");
$tiposDocumento = $tiposStmt->fetchAll(PDO::FETCH_ASSOC);

$rolesStmt = $pdo->query("SELECT idRol, Descripcion_Rol FROM roles");
$roles = $rolesStmt->fetchAll(PDO::FETCH_ASSOC);

$dao = new UsuarioDao();
$usuarios = $dao->listarTodos();
?>

<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <title>Gestión de Usuarios - DistriOchoa</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <link rel="stylesheet" href="../css/bootstrap.min.css" />
  <link rel="stylesheet" href="../css/styles.css" />
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" />
  <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body>
 <div id="vista-usuarios"> <!-- ⬅️ Contenedor con fondo y capa borrosa -->

    <!-- Sidebar -->
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

<div class="container mt-4">
  <div class="d-flex justify-content-between align-items-center mb-3">
    <h2><i class="bi bi-person-circle"></i> Gestión de Usuarios</h2>
    <div>
      <button class="btn btn-outline-secondary" onclick="mostrarListaUsuarios()">
        <i class="bi bi-people-fill"></i> Ver Lista
      </button>
      <button class="btn btn-success" onclick="mostrarFormularioUsuarios()">
        <i class="bi bi-person-plus-fill"></i> Agregar Usuario
      </button>
    </div>
  </div>

  

  <!-- Formulario de Registro Mejorado -->
<div id="formulario-usuarios" style="display: none;">
  <div class="d-flex justify-content-center align-items-center min-vh-100">
    <div class="card p-4 shadow-lg rounded-4 animate__animated animate__fadeIn" style="max-width: 700px; width: 100%; background: rgba(255,255,255,0.9);">
      <h4 class="text-center mb-3"><i class="bi bi-person-plus-fill"></i> Agregar Usuario</h4>

      <form action="../controladores/controlador.usuarios.php" method="POST" class="row g-3">
        <input type="hidden" name="editar" id="editar" value="0">
        
        <div class="col-md-6">
          <label for="idPersona" class="form-label">ID</label>
          <input type="number" class="form-control rounded-3" name="idPersona" id="idPersona" required>
        </div>

        <div class="col-md-6">
          <label for="nombre" class="form-label">Nombre</label>
          <input type="text" class="form-control rounded-3" name="nombre" id="nombre" required>
        </div>

        <div class="col-md-6">
          <label for="correo" class="form-label">Correo</label>
          <input type="email" class="form-control rounded-3" name="correo" id="correo" required>
        </div>

        <div class="col-md-6">
          <label for="contrasena" class="form-label">Contraseña</label>
          <input type="password" class="form-control rounded-3" name="contrasena" id="contrasena" required>
        </div>

        <div class="col-md-6">
          <label for="tipo_documento" class="form-label">Tipo de Documento</label>
          <select class="form-select rounded-3" name="tipo_documento" id="tipo_documento" required>
            <option value="">Seleccione...</option>
            <?php foreach ($tiposDocumento as $td): ?>
              <option value="<?= $td['idTipo_Documento'] ?>"><?= htmlspecialchars($td['descripcion']) ?></option>
            <?php endforeach; ?>
          </select>
        </div>

        <div class="col-md-6">
          <label for="rol" class="form-label">Rol</label>
          <select class="form-select rounded-3" name="rol" id="rol" required>
            <option value="">Seleccione...</option>
            <?php foreach ($roles as $r): ?>
              <option value="<?= $r['idRol'] ?>"><?= htmlspecialchars($r['Descripcion_Rol']) ?></option>
            <?php endforeach; ?>
          </select>
        </div>

        <div class="col-12 text-end mt-3">
          <button type="submit" class="btn btn-success w-100 rounded-3 shadow-sm">
  <i class="bi bi-floppy-fill"></i> Guardar Usuario
</button>

        </div>
      </form>
    </div>
  </div>
</div>


<!-- Lista en Cards -->

<div id="lista-usuarios">
  <div class="row">
    <?php foreach ($usuarios as $u): ?>
      <div class="col-md-6 col-lg-4 mb-4">
        <div class="card h-100 shadow-sm border-success usuario-card">
          <div class="card-body text-center">
            <!-- Ícono de usuario compacto -->
            <div class="icono-usuario bg-success text-white rounded-circle d-flex align-items-center justify-content-center mx-auto mb-2" style="width: 60px; height: 60px;">
              <i class="bi bi-person-fill fs-4"></i>
            </div>

            <!-- Solo nombre y rol al inicio -->
            <h6 class="card-title mb-0"><?= htmlspecialchars($u['nombre']) ?></h6>
            <p class="mb-1">
              <span class="badge badge-gris-claro">
                <?= htmlspecialchars($u['rol']) ?>
              </span>
            </p>




            <!-- Detalles ocultos hasta hover -->
            <div class="detalles-usuario mt-2">
              <p class="card-text text-start small">
                <strong>ID:</strong> <?= htmlspecialchars($u['idPersona']) ?><br>
                <strong>Correo:</strong> <?= htmlspecialchars($u['correo']) ?><br>
                <strong>Tipo Documento:</strong> <?= htmlspecialchars($u['tipo_documento']) ?>
              </p>

           <!-- Botones -->
<!-- Botones centrados en una sola fila -->
<div class="d-flex justify-content-center gap-3 mt-3">
  <!-- Botón Editar -->
  <button class="btn btn-editar rounded-circle btn-icon"
    onclick="abrirModalEditarUsuario('<?= $u['idPersona'] ?>', '<?= $u['nombre'] ?>', '<?= $u['correo'] ?>', '<?= $u['idTipo_Documento'] ?>', '<?= $u['idRol'] ?>')"
    title="Editar">
    <i class="bi bi-pencil"></i>
  </button>

  <!-- Botón Eliminar -->
  <a href="../controladores/controlador.usuarios.php?eliminar=<?= $u['idPersona'] ?>"
    class="btn btn-eliminar rounded-circle btn-icon"
    onclick="return confirm('¿Eliminar este usuario?')"
    title="Eliminar">
    <i class="bi bi-trash3"></i>
  </a>
</div>


            </div>
          </div>
        </div>
      </div>
    <?php endforeach; ?>
  </div>
</div>


</div>

<!-- Modal para editar usuario -->
<div class="modal fade" id="modalEditarUsuario" tabindex="-1" aria-labelledby="modalEditarUsuarioLabel" aria-hidden="true">
  <div class="modal-dialog modal-lg">
    <div class="modal-content shadow">
      <div class="modal-header bg-success text-white">
        <h5 class="modal-title" id="modalEditarUsuarioLabel"><i class="bi bi-pencil-square"></i> Editar Usuario</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Cerrar"></button>
      </div>
      <form action="../controladores/controlador.usuarios.php" method="POST">
        <div class="modal-body">
          <input type="hidden" name="editar" value="1">
          <div class="row g-3">
            <div class="col-md-4">
              <label for="edit-idPersona" class="form-label">ID</label>
              <input type="number" class="form-control" name="idPersona" id="edit-idPersona" readonly>
            </div>
            <div class="col-md-4">
              <label for="edit-nombre" class="form-label">Nombre</label>
              <input type="text" class="form-control" name="nombre" id="edit-nombre" required>
            </div>
            <div class="col-md-4">
              <label for="edit-correo" class="form-label">Correo</label>
              <input type="email" class="form-control" name="correo" id="edit-correo" required>
            </div>
            <div class="col-md-4">
              <label for="edit-contrasena" class="form-label">Nueva Contraseña</label>
              <input type="password" class="form-control" name="contrasena" id="edit-contrasena" placeholder="Opcional">
            </div>
            <div class="col-md-4">
              <label for="edit-tipo_documento" class="form-label">Tipo de Documento</label>
              <select class="form-select" name="tipo_documento" id="edit-tipo_documento" required>
                <option value="">Seleccione...</option>
                <?php foreach ($tiposDocumento as $td): ?>
                  <option value="<?= $td['idTipo_Documento'] ?>"><?= htmlspecialchars($td['descripcion']) ?></option>
                <?php endforeach; ?>
              </select>
            </div>
            <div class="col-md-4">
              <label for="edit-rol" class="form-label">Rol</label>
              <select class="form-select" name="rol" id="edit-rol" required>
                <option value="">Seleccione...</option>
                <?php foreach ($roles as $r): ?>
                  <option value="<?= $r['idRol'] ?>"><?= htmlspecialchars($r['Descripcion_Rol']) ?></option>
                <?php endforeach; ?>
              </select>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button type="submit" class="btn btn-primary">Guardar Cambios</button>
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
        </div>
      </form>
    </div>
  </div>
</div>

<!-- Alerta -->
<?php if (isset($_GET['mensaje'])): ?>
<script>
Swal.fire({
  title: 'Información',
  text: <?= json_encode($_GET['mensaje']) ?>,
  icon: 'info',
  confirmButtonColor: '#3085d6'
});
</script>
<?php endif; ?>

<!-- Scripts -->

<script src="../js/script.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

</div>

</body>
</html>
