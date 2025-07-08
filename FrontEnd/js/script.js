document.addEventListener('DOMContentLoaded', () => {
  aplicarPermisos();

  const rolSelector = document.getElementById('rol-selector');
  if (rolSelector) {
    rolSelector.addEventListener('change', mostrarLogin);
  }

  const formDevoluciones = document.querySelector('.form-devoluciones');
  if (formDevoluciones) {
    formDevoluciones.addEventListener('submit', registrarDevolucion);
  }

  const formUsuarios = document.getElementById('form-usuarios');
  if (formUsuarios) {
    formUsuarios.addEventListener('submit', guardarUsuario);
  }

  const stockTable = document.getElementById('tabla-stock');
  if (stockTable) {
    cargarStock();
  }

  const contenedorAlertas = document.getElementById('contenedor-alertas');
  if (contenedorAlertas) {
    generarAlertas();
  }

  const gridUsuarios = document.getElementById('usuarios-grid');
  if (gridUsuarios) {
    cargarUsuarios();
  }

  const vistaReportes = document.getElementById('vista-reportes');
  if (vistaReportes) {
    vistaReportes.style.display = 'flex';
    generarAlertas();
  }

  const btnAgregar = document.getElementById('btn-agregar-usuario');
  if (btnAgregar) {
    btnAgregar.addEventListener('click', mostrarFormularioUsuario);
  }

  const btnVerLista = document.getElementById('btn-ver-lista');
  if (btnVerLista) {
    btnVerLista.addEventListener('click', mostrarListaUsuarios);
  }

  const fotoInput = document.getElementById('fotoPerfil');
  if (fotoInput) {
    fotoInput.addEventListener('change', function () {
      const nombre = this.files[0]?.name || 'Ningún archivo seleccionado';
      const nombreArchivo = document.getElementById('nombre-archivo');
      if (nombreArchivo) nombreArchivo.textContent = nombre;
    });
  }

  // === SIDEBAR CORREGIDO ===
  const sidebar = document.getElementById("sidebar-vertical");
  const toggleBtn = document.getElementById("btn-toggle-sidebar");

  if (sidebar && toggleBtn) {
    sidebar.style.display = "none"; // Ocultar al cargar
    toggleBtn.addEventListener("click", function (e) {
      e.stopPropagation();
      sidebar.style.display = (sidebar.style.display === "flex") ? "none" : "flex";
    });

    window.addEventListener("click", function (e) {
      if (
        sidebar.style.display === "flex" &&
        !sidebar.contains(e.target) &&
        e.target !== toggleBtn &&
        !toggleBtn.contains(e.target)
      ) {
        sidebar.style.display = "none";
      }
    });
  }
});

// Navegación desde index.html
function mostrarLogin() {
  const rol = document.getElementById('rol-selector').value;
  if (!rol) return;
  localStorage.setItem('rolSeleccionado', rol);
  window.location.href = '../html/login.php';
}

// Inicio de sesión
function iniciarSesion(e) {
  e.preventDefault();
  const correo = document.getElementById('correo').value;
  const contrasena = document.getElementById('contrasena').value;
  if (!correo || !contrasena) {
    alert('Completa todos los campos');
    return;
  }
  localStorage.setItem('correo', correo);
  window.location.href = '../html/dashboard.php';
}

function recuperarContrasena() {
  const correo = prompt('Ingresa tu correo para recuperar tu contraseña:');
  if (correo) alert('Se ha enviado un enlace de recuperación a ' + correo);
}

function cerrarSesion() {
  localStorage.clear();
  window.location.href = '../html/index.php';
}

function volverInicio() {
  window.location.href = '../html/dashboard.php';
}

function volverRegistro() {
  window.location.href = '../html/registro-productos.php';
}

// ========== STOCK ==========
function cargarStock() {
  const cont = document.getElementById('tabla-stock');
  if (!cont) return;
  cont.innerHTML = '';
  const productos = JSON.parse(localStorage.getItem('productos') || '[]');

  if (!productos.length) {
    const tr = document.createElement('tr');
    tr.innerHTML = '<td colspan="8"><div class="alerta-ok">✅ No hay productos registrados.</div></td>';
    cont.appendChild(tr);
    return;
  }

  productos.forEach(prod => {
    const estado = obtenerEstado(prod.cantidad);
    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td>${prod.id}</td>
      <td>${prod.nombre}</td>
      <td><span class="estado ${estado}"></span></td>
      <td>${prod.categoria}</td>
      <td>${prod.cantidad}</td>
      <td>${prod.entradas}</td>
      <td>${prod.salidas}</td>
      <td>
        <button onclick="borrarFila(${prod.id})">🗑️</button>
      </td>`;
    cont.appendChild(tr);
  });
}

function obtenerEstado(cantidad) {
  if (cantidad === 0) return 'rojo';
  if (cantidad <= 15) return 'amarillo';
  return 'verde';
}

function borrarFila(id) {
  let productos = JSON.parse(localStorage.getItem('productos') || '[]');
  productos = productos.filter(p => p.id !== id);
  localStorage.setItem('productos', JSON.stringify(productos));
  cargarStock();
}

// ========== PRODUCTOS ==========
function guardarProducto(evento) {
  evento.preventDefault();
  const nombre = document.getElementById('prod-nombre').value;
  const categoria = document.getElementById('prod-categoria').value;
  const precio = parseFloat(document.getElementById('prod-precio').value);
  const cantidad = parseInt(document.getElementById('prod-cantidad').value);

  const producto = {
    id: Date.now(),
    nombre,
    categoria,
    precio,
    cantidad,
    entradas: cantidad,
    salidas: 0
  };

  const productos = JSON.parse(localStorage.getItem('productos') || '[]');
  productos.push(producto);
  localStorage.setItem('productos', JSON.stringify(productos));
  window.location.href = 'alerta-confirmacion.php';
}

// ========== SALIDAS ==========
function procesarRegistroSalida(event) {
  event.preventDefault();

  const nombre = document.getElementById('salida-prod-nombre').value.trim();
  const categoria = document.getElementById('salida-prod-categoria').value.trim();
  const cantidad = parseInt(document.getElementById('salida-prod-cantidad').value);

  if (!nombre || !categoria || isNaN(cantidad) || cantidad <= 0) {
    Swal.fire({
      icon: 'warning',
      title: 'Campos incompletos o inválidos',
      text: 'Por favor completa todos los campos correctamente.',
      confirmButtonColor: '#e67e22'
    });
    return;
  }

  let productos = JSON.parse(localStorage.getItem('productos') || '[]');
  const idx = productos.findIndex(p =>
    p.nombre.toLowerCase() === nombre.toLowerCase() &&
    p.categoria.toLowerCase() === categoria.toLowerCase()
  );

  if (idx === -1) {
    Swal.fire({
      icon: 'error',
      title: 'Producto no encontrado',
      text: 'No existe ese producto registrado en el inventario.',
      confirmButtonColor: '#e74c3c'
    });
    return;
  }

  if (productos[idx].cantidad < cantidad) {
    Swal.fire({
      icon: 'error',
      title: 'Stock insuficiente',
      text: 'No hay suficiente cantidad disponible.',
      confirmButtonColor: '#e74c3c'
    });
    return;
  }

  // Actualizar producto
  productos[idx].cantidad -= cantidad;
  productos[idx].salidas += cantidad;
  localStorage.setItem('productos', JSON.stringify(productos));

  // Mostrar alerta con opciones
  Swal.fire({
    icon: 'success',
    title: '✅ Salida registrada con éxito',
    text: '¿Qué deseas hacer ahora?',
    showCancelButton: true,
    confirmButtonText: '📋 Ir a ventas registradas',
    cancelButtonText: '➕ Registrar otra salida',
    confirmButtonColor: '#27ae60',
    cancelButtonColor: '#3498db'
  }).then((result) => {
    if (result.isConfirmed) {
      window.location.href = 'stock.php#ventas';
    } else {
      // Limpiar formulario actual para registrar otra salida
      event.target.reset();
      document.getElementById('salida-prod-nombre').focus();
    }
  });
}


// ========== REPORTES ==========
function generarAlertas() {
  const contenedor = document.getElementById('contenedor-alertas');
  if (!contenedor) return;

  const productos = JSON.parse(localStorage.getItem('productos') || '[]');
  contenedor.innerHTML = '';

  productos.forEach(prod => {
    let mensaje = '';
    if (prod.cantidad === 0) mensaje = `🔴 ¡AGOTADO!: "${prod.nombre}" no tiene unidades.`;
    else if (prod.cantidad < 5) mensaje = `⚠️ Stock bajo: "${prod.nombre}" tiene solo ${prod.cantidad}.`;
    else if (prod.cantidad <= 15) mensaje = `🟡 Por agotarse: "${prod.nombre}" tiene ${prod.cantidad}.`;

    if (mensaje) {
      const alerta = document.createElement('div');
      alerta.className = 'alerta';
      alerta.innerHTML = `<p>${mensaje}</p><button onclick="this.parentElement.remove()">❌</button>`;
      contenedor.appendChild(alerta);
    }
  });

  if (!contenedor.innerHTML.trim()) {
    contenedor.innerHTML = '<div class="alerta-ok">✅ Todo en orden.</div>';
  }
}

// ========== DEVOLUCIONES ==========
function registrarDevolucion(event) {
  event.preventDefault();
  const inputs = this.querySelectorAll('input');
  const devolucion = {
    id: Date.now(),
    nombre: inputs[0].value,
    proveedor: inputs[1].value,
    empleadoResponsable: inputs[2].value,
    cantidad: inputs[3].value,
    motivo: inputs[4].value,
    fecha: inputs[5].value
  };

  const arr = JSON.parse(localStorage.getItem('devoluciones') || '[]');
  arr.push(devolucion);
  localStorage.setItem('devoluciones', JSON.stringify(arr));
  alert('Devolución registrada con éxito.');
  this.reset();
}

// ========== NAVEGACIÓN CON CIERRE DE SIDEBAR ==========
function cerrarSidebarYRedirigir(url) {
  const sidebar = document.getElementById("sidebar-vertical");
  if (sidebar) sidebar.style.display = "none";
  window.location.href = url;
}

function mostrarRegistro() {
  cerrarSidebarYRedirigir('../html/registro-productos.php');
}

function mostrarRegistrarSalida() {
  cerrarSidebarYRedirigir('../html/registro-salidas.php');
}

function mostrarReportes() {
  cerrarSidebarYRedirigir('../html/reportes.php');
}

function mostrarStock() {
  cerrarSidebarYRedirigir('../html/stock.php');
}

function mostrarRegistroUsuarios() {
  cerrarSidebarYRedirigir('../html/registro-usuarios.php');
}

function mostrarDevoluciones() {
  cerrarSidebarYRedirigir('../html/devoluciones.php');
}

function mostrarGestionCategorias() {
  cerrarSidebarYRedirigir('../html/categorias.php');
}

function aplicarPermisos() {
  const rol = (localStorage.getItem('rolSeleccionado') || '').toLowerCase();
  const btnUsuariosSidebar = document.getElementById('btn-sidebar-usuarios');
  if (btnUsuariosSidebar) {
    btnUsuariosSidebar.style.display = rol === 'administrador' ? 'block' : 'none';
  }

  const btnUsuariosOpcion = document.querySelector('.opcion-usuarios');
  if (btnUsuariosOpcion) {
    btnUsuariosOpcion.style.display = rol === 'administrador' ? 'block' : 'none';
  }

  if (rol === 'auxiliar') {
    const moduloRegistrarUsuarios = document.querySelector(".opcion img[alt='Registrar Usuarios']")?.closest('.opcion');
    if (moduloRegistrarUsuarios) moduloRegistrarUsuarios.style.display = 'none';
  }
}
function mostrarStock() {
  const vistaStock = document.getElementById('vista-stock');

  if (vistaStock) {
    ocultarTodasLasVistas();
    vistaStock.style.display = 'flex';
    cargarStock();
  } else {
    cerrarSidebarYRedirigir('../html/stock.php');
  }
}
function editarUsuario(id, nombre, correo, tipoDoc, rol) {
  document.getElementById("idPersona").value = id;
  document.getElementById("idPersona").readOnly = true; // evitar editar ID primario
  document.getElementById("nombre").value = nombre;
  document.getElementById("correo").value = correo;
  document.getElementById("tipo_documento").value = tipoDoc;
  document.getElementById("rol").value = rol;
  document.getElementById("editar").value = "1";

  const boton = document.querySelector('form button[type="submit"]');
  if (boton) boton.textContent = "Actualizar usuario";
}

function editarCategoria(id, nombre, descripcion) {
  document.getElementById('idCategoria').value = id;
  document.getElementById('Nombre_Categoria').value = nombre;
  document.getElementById('descripcion').value = descripcion;
  document.getElementById('modo').value = 'editar';

  const boton = document.querySelector('form button[type="submit"]');
  if (boton) boton.textContent = "Actualizar categoría";
}


 

  var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
  tooltipTriggerList.map(function (tooltipTriggerEl) {
    return new bootstrap.Tooltip(tooltipTriggerEl)
  })


  var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
  tooltipTriggerList.map(function (tooltipTriggerEl) {
    return new bootstrap.Tooltip(tooltipTriggerEl);
  });



 // ========== REGISTRAR ENTRADA ==========
function registrarEntrada(event) {
  event.preventDefault();

  const nombre = document.getElementById('prod-nombre').value.trim();
  const categoria = document.getElementById('prod-categoria').value.trim();
  const precio = parseFloat(document.getElementById('prod-precio').value);
  const cantidad = parseInt(document.getElementById('prod-cantidad').value);
  const proveedor = document.getElementById('prod-proveedor').value.trim();
  const persona = document.getElementById('prod-persona').value.trim();
  const fecha = document.getElementById('prod-fecha').value;


  if (!nombre || !categoria || isNaN(precio) || isNaN(cantidad) || !proveedor || !persona) {
    alert("❗ Por favor, completa todos los campos correctamente.");
    return;
  }

  let productos = JSON.parse(localStorage.getItem("productos") || "[]");
  let entradas = JSON.parse(localStorage.getItem("entradas") || "[]");

  let producto = productos.find(p =>
    p.nombre.toLowerCase() === nombre.toLowerCase() &&
    p.categoria.toLowerCase() === categoria.toLowerCase()
  );

  if (producto) {
    producto.cantidad += cantidad;
    producto.entradas += cantidad;
  } else {
    producto = {
      id: Date.now(),
      nombre,
      categoria,
      precio,
      cantidad,
      entradas: cantidad,
      salidas: 0
    };
    productos.push(producto);
  }

  const nuevaEntrada = {
    idEntrada: Date.now(),
    fecha,
    cantidad,
    proveedor,
    persona,
    productoId: producto.id
  };

  entradas.push(nuevaEntrada);

  localStorage.setItem("productos", JSON.stringify(productos));
  localStorage.setItem("entradas", JSON.stringify(entradas));

  alert("✅ Entrada registrada exitosamente.");
  event.target.reset();
  cargarStock();
}

document.addEventListener("DOMContentLoaded", function () {
  const formSalida = document.getElementById("form-registrar-salida");
  if (formSalida) {
    formSalida.addEventListener("submit", registrarVenta);
  }
});



// ========== REGISTRAR VENTA (SALIDA) ==========
function registrarVenta(event) {
  event.preventDefault();

  console.log("👉 Función registrarVenta llamada");

  const nombreProd = document.getElementById('producto').value.trim();
  const categoria = document.getElementById('categoria').value.trim();
  const cantidad = parseInt(document.getElementById('cantidad').value);
  const precioUnitario = parseFloat(document.getElementById('precio').value);
  const fecha = new Date().toISOString().split('T')[0];

  if (!nombreProd || !categoria || isNaN(cantidad) || isNaN(precioUnitario)) {
    Swal.fire({
      icon: 'warning',
      title: 'Campos incompletos',
      text: 'Por favor completa todos los campos correctamente.',
      confirmButtonColor: '#27ae60'
    });
    return;
  }

  let productos = JSON.parse(localStorage.getItem('productos') || '[]');
  const prodIndex = productos.findIndex(p =>
    p.nombre.toLowerCase() === nombreProd.toLowerCase() &&
    p.categoria.toLowerCase() === categoria.toLowerCase()
  );

  if (prodIndex === -1) {
    Swal.fire({
      icon: 'error',
      title: 'Producto no encontrado',
      text: 'Este producto no está en stock.',
      confirmButtonColor: '#e74c3c'
    });
    return;
  }

  if (productos[prodIndex].cantidad < cantidad) {
    Swal.fire({
      icon: 'error',
      title: 'Stock insuficiente',
      text: 'No hay suficiente cantidad disponible en el inventario.',
      confirmButtonColor: '#e74c3c'
    });
    return;
  }

  // Actualizar producto
  productos[prodIndex].cantidad -= cantidad;
  productos[prodIndex].salidas += cantidad;
  localStorage.setItem('productos', JSON.stringify(productos));

  // Generar ID único sin riesgo de duplicado
  const idVenta = Date.now() + Math.floor(Math.random() * 1000);
  const subtotal = parseFloat((cantidad * precioUnitario).toFixed(2));
  const total = subtotal;

  // Validación de duplicado
  const ventas = JSON.parse(localStorage.getItem('ventas') || '[]');
  const detalles = JSON.parse(localStorage.getItem('detalleVentas') || '[]');

  if (ventas.find(v => v.idVenta === idVenta)) {
    console.warn("🚫 Venta duplicada, cancelando registro.");
    return;
  }

  const venta = {
    idVenta,
    fecha,
    total,
    empleado: localStorage.getItem('correo') || 'Empleado X'
  };

  const detalle = {
    idDetalleVenta: idVenta + 1,
    idVenta,
    nombreProd,
    categoria,
    cantidad,
    precioUnitario,
    subtotal
  };

  ventas.push(venta);
  detalles.push(detalle);

  localStorage.setItem('ventas', JSON.stringify(ventas));
  localStorage.setItem('detalleVentas', JSON.stringify(detalles));

  cargarStock();

  Swal.fire({
    icon: 'success',
    title: '✅ Salida registrada con éxito',
    text: '¿Qué deseas hacer ahora?',
    showCancelButton: true,
    confirmButtonText: '📋 Ir a ventas registradas',
    cancelButtonText: '➕ Registrar otra salida',
    confirmButtonColor: '#27ae60',
    cancelButtonColor: '#3498db'
  }).then((result) => {
    if (result.isConfirmed) {
      window.location.href = 'stock.php#ventas';
    } else {
      document.getElementById("form-registrar-salida").reset();
      document.getElementById("producto").focus();
    }
  });
}

document.addEventListener("DOMContentLoaded", function () {
  const formSalida = document.getElementById("form-registrar-salida");
  if (formSalida) {
    formSalida.addEventListener("submit", registrarVenta);
  }
});




// ========== CARGAR STOCK ==========
function cargarStock() {
  const cont = document.getElementById('tabla-stock');
  if (!cont) return;
  cont.innerHTML = '';
  const productos = JSON.parse(localStorage.getItem('productos') || '[]');

  if (!productos.length) {
    cont.innerHTML = '<tr><td colspan="8"><div class="alerta-ok">✅ No hay productos registrados.</div></td></tr>';
    return;
  }

  productos.forEach(prod => {
    const estado = obtenerEstado(prod.cantidad);

    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td>${prod.id}</td>
      <td>${prod.nombre}</td>
      <td><span class="estado ${estado}"></span></td>
      <td>${prod.categoria}</td>
      <td>${prod.cantidad}</td>
      <td>${prod.entradas}</td>
      <td>${prod.salidas}</td>
      <td><button onclick="borrarFila(${prod.id})">🗑️</button></td>
    `;
    cont.appendChild(tr);
  });
}

function obtenerEstado(cantidad) {
  if (cantidad === 0) return 'rojo';
  if (cantidad <= 15) return 'amarillo';
  return 'verde';
}

function borrarFila(id) {
  let productos = JSON.parse(localStorage.getItem('productos') || '[]');
  productos = productos.filter(p => p.id !== id);
  localStorage.setItem('productos', JSON.stringify(productos));
  cargarStock();
}


// ========== CARGAR VENTAS ==========
function cargarVentas() {
  const ventas = JSON.parse(localStorage.getItem('ventas') || '[]');
  const detalles = JSON.parse(localStorage.getItem('detalleVentas') || '[]');
  const cuerpo = document.getElementById("tabla-ventas");
  if (!cuerpo) return;

  cuerpo.innerHTML = '';

  if (ventas.length === 0 || detalles.length === 0) {
    cuerpo.innerHTML = `<tr><td colspan="10"><div class="alerta-ok">✅ No hay ventas registradas aún.</div></td></tr>`;
    return;
  }

  detalles.forEach(det => {
    const venta = ventas.find(v => v.idVenta === det.idVenta);
    if (venta) {
      const fila = document.createElement('tr');
      fila.innerHTML = `
        <td>${venta.idVenta}</td>
        <td>${det.nombreProd}</td>
        <td>${det.categoria}</td>
        <td>${det.cantidad}</td>
        <td>$${det.precioUnitario.toFixed(2)}</td>
        <td>$${det.subtotal.toFixed(2)}</td>
        <td>$${venta.total.toFixed(2)}</td>
        <td>${venta.fecha}</td>
        <td>${venta.empleado}</td>
        <td><button onclick="eliminarVenta(${venta.idVenta})">🗑️</button></td>
      `;
      cuerpo.appendChild(fila);
    }
  });
}


function eliminarVenta(idVenta) {
  if (!confirm("¿Estás segura de eliminar esta venta?")) return;

  let ventas = JSON.parse(localStorage.getItem('ventas') || '[]');
  let detalles = JSON.parse(localStorage.getItem('detalleVentas') || '[]');
  let productos = JSON.parse(localStorage.getItem('productos') || '[]');

  // Recuperar detalle para devolver stock
  const detalle = detalles.find(d => d.idVenta === idVenta);
  if (detalle) {
    const producto = productos.find(p =>
      p.nombre.toLowerCase() === detalle.nombreProd.toLowerCase() &&
      p.categoria.toLowerCase() === detalle.categoria.toLowerCase()
    );
    if (producto) {
      producto.cantidad += detalle.cantidad;
      producto.salidas -= detalle.cantidad;
    }
  }

  // Filtrar los arrays
  ventas = ventas.filter(v => v.idVenta !== idVenta);
  detalles = detalles.filter(d => d.idVenta !== idVenta);

  // Guardar actualizados
  localStorage.setItem('ventas', JSON.stringify(ventas));
  localStorage.setItem('detalleVentas', JSON.stringify(detalles));
  localStorage.setItem('productos', JSON.stringify(productos));

  // Recargar tablas
  cargarVentas();
  cargarStock();
}


  document.addEventListener("DOMContentLoaded", function () {
    cargarStock();    // Actualiza la tabla de stock
    cargarVentas();   // Llena la tabla de ventas registradas
  });


  function mostrarVentasRegistradas() {
  document.getElementById('subvista-ventas').style.display = 'block';
  document.getElementById('subvista-stock').style.display = 'none';

  document.getElementById('btn-ventas').classList.add('activo');
  document.getElementById('btn-stock').classList.remove('activo');

  cargarVentas();
}

function mostrarStockProductos() {
  document.getElementById('subvista-stock').style.display = 'block';
  document.getElementById('subvista-ventas').style.display = 'none';

  document.getElementById('btn-stock').classList.add('activo');
  document.getElementById('btn-ventas').classList.remove('activo');

  cargarStock();
}

function obtenerEstado(cantidad) {
  if (cantidad === 0) return 'rojo';
  if (cantidad <= 15) return 'amarillo';
  return 'verde';
}


function mostrarFormularioUsuarios() {
  document.getElementById('formulario-usuarios').style.display = 'block';
  document.getElementById('lista-usuarios').style.display = 'none';
}
function mostrarListaUsuarios() {
  document.getElementById('formulario-usuarios').style.display = 'none';
  document.getElementById('lista-usuarios').style.display = 'block';
}
function abrirModalEditarUsuario(id, nombre, correo, tipoDoc, rol) {
  document.getElementById('edit-idPersona').value = id;
  document.getElementById('edit-nombre').value = nombre;
  document.getElementById('edit-correo').value = correo;
  document.getElementById('edit-contrasena').value = '';
  document.getElementById('edit-tipo_documento').value = tipoDoc;
  document.getElementById('edit-rol').value = rol;
  const modal = new bootstrap.Modal(document.getElementById('modalEditarUsuario'));
  modal.show();
}


  function mostrarFormularioCategoria() {
    document.getElementById('formulario-categoria').style.display = 'block';
    document.getElementById('listado-categorias').style.display = 'none';
  }
  function mostrarListadoCategorias() {
    document.getElementById('formulario-categoria').style.display = 'none';
    document.getElementById('listado-categorias').style.display = 'block';
  }
  function abrirModalEditarCategoria(id, nombre, descripcion) {
    document.getElementById('edit-idCategoria').value = id;
    document.getElementById('edit-Nombre_Categoria').value = nombre;
    document.getElementById('edit-descripcion').value = descripcion;
    let modal = new bootstrap.Modal(document.getElementById('modalEditarCategoria'));
    modal.show();
  }


  

function mostrarFormularioDevolucion() {
  document.getElementById("vista-formulario-devolucion").classList.remove("d-none");
  document.getElementById("vista-listado-devoluciones").classList.add("d-none");
}

function mostrarListadoDevoluciones() {
  document.getElementById("vista-formulario-devolucion").classList.add("d-none");
  document.getElementById("vista-listado-devoluciones").classList.remove("d-none");
  cargarTablaDevoluciones();
}

function registrarDevolucion(event) {
  event.preventDefault();
  const devolucion = {
    nombre: document.getElementById("dev-nombre").value,
    proveedor: document.getElementById("dev-proveedor").value,
    responsable: document.getElementById("dev-responsable").value,
    cantidad: document.getElementById("dev-cantidad").value,
    fecha: document.getElementById("dev-fecha").value,
    motivo: document.getElementById("dev-motivo").value,
  };

  let devoluciones = JSON.parse(localStorage.getItem("devoluciones")) || [];
  devoluciones.push(devolucion);
  localStorage.setItem("devoluciones", JSON.stringify(devoluciones));

  // Limpiar formulario
  event.target.reset();

  // Actualizar tabla
  cargarTablaDevoluciones();

  // Mostrar notificación
  Swal.fire('¡Éxito!', 'Devolución registrada correctamente.', 'success');
}


function cargarTablaDevoluciones() {
  const cuerpo = document.getElementById("tablaDevoluciones");
  cuerpo.innerHTML = "";

  const devoluciones = JSON.parse(localStorage.getItem("devoluciones")) || [];

  devoluciones.forEach(dev => {
    const fila = `
      <tr>
        <td>${dev.nombre}</td>
        <td>${dev.proveedor}</td>
        <td>${dev.responsable}</td>
        <td>${dev.cantidad}</td>
        <td>${dev.fecha}</td>
        <td>${dev.motivo}</td>
      </tr>`;
    cuerpo.innerHTML += fila;
  });
}


document.addEventListener("DOMContentLoaded", function () {
  const productos = JSON.parse(localStorage.getItem("productos") || "[]");
  const detalleVentas = JSON.parse(localStorage.getItem("detalleVentas") || "[]");
  const entradas = JSON.parse(localStorage.getItem("entradas") || "[]");

  // ====== GRAFICO DE BARRAS: Productos más vendidos ======
  const ventasPorProducto = {};
  detalleVentas.forEach(det => {
    ventasPorProducto[det.nombreProd] = (ventasPorProducto[det.nombreProd] || 0) + det.cantidad;
  });

  const labelsVendidos = Object.keys(ventasPorProducto);
  const dataVendidos = Object.values(ventasPorProducto);

  new Chart(document.getElementById('graficoBarras'), {
    type: 'bar',
    data: {
      labels: labelsVendidos,
      datasets: [{
        label: 'Cantidad vendida',
        data: dataVendidos,
        backgroundColor: '#2ecc71'
      }]
    },
    options: {
      responsive: true,
      plugins: { legend: { display: false } }
    }
  });

  // ====== GRAFICO DE PASTEL: Categorías más frecuentes en inventario ======
  const categoriasTotales = {};
  productos.forEach(p => {
    categoriasTotales[p.categoria] = (categoriasTotales[p.categoria] || 0) + 1;
  });

  new Chart(document.getElementById('graficoPastel'), {
    type: 'pie',
    data: {
      labels: Object.keys(categoriasTotales),
      datasets: [{
        data: Object.values(categoriasTotales),
        backgroundColor: ['#e67e22', '#1abc9c', '#9b59b6', '#f1c40f']
      }]
    }
  });

  // ====== GRAFICO DE LINEA: Entradas por mes (simulado desde fechas de entrada) ======
  const entradasMensuales = { 'Ene': 0, 'Feb': 0, 'Mar': 0, 'Abr': 0, 'May': 0, 'Jun': 0 };
  entradas.forEach(e => {
    const mes = new Date(e.fecha).getMonth();
    const nombreMes = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun'][mes];
    if (nombreMes) entradasMensuales[nombreMes] += e.cantidad;
  });

  new Chart(document.getElementById('graficoLinea'), {
    type: 'line',
    data: {
      labels: Object.keys(entradasMensuales),
      datasets: [{
        label: 'Entradas',
        data: Object.values(entradasMensuales),
        fill: true,
        backgroundColor: 'rgba(52,152,219,0.2)',
        borderColor: '#2980b9',
        tension: 0.3
      }]
    }
  });

  // ====== GRAFICO DE BARRAS HORIZONTALES: Stock actual ======
  const labelsStock = productos.map(p => p.nombre);
  const dataStock = productos.map(p => p.cantidad);

  new Chart(document.getElementById('graficoHorizontal'), {
    type: 'bar',
    data: {
      labels: labelsStock,
      datasets: [{
        label: 'Stock disponible',
        data: dataStock,
        backgroundColor: '#8e44ad'
      }]
    },
    options: {
      indexAxis: 'y',
      responsive: true,
      plugins: { legend: { display: false } }
    }
  });
});

document.addEventListener("DOMContentLoaded", function () {
  const formSalida = document.getElementById("form-registrar-salida");
  if (formSalida && !formSalida.dataset.listenerAdded) {
    formSalida.addEventListener("submit", registrarVenta);
    formSalida.dataset.listenerAdded = "true";
  }
});
