document.addEventListener('DOMContentLoaded', () => {
  // Aplicar permisos al cargar la página (para ocultar elementos según el rol)
  aplicarPermisos();

  const volverDashboardDevoluciones = document.getElementById("volverDashboard");
  if (volverDashboardDevoluciones) {
      volverDashboardDevoluciones.addEventListener("click", () => {
          document.getElementById("seccionDevoluciones").style.display = "none";
          document.getElementById("menu-admin").style.display = "flex";
      });
  }

  const formDevoluciones = document.querySelector('.form-devoluciones');
  if (formDevoluciones) {
      formDevoluciones.addEventListener('submit', registrarDevolucion);
  }

  const formUsuarios = document.getElementById('form-usuarios');
  if (formUsuarios) {
      formUsuarios.addEventListener('submit', guardarUsuario);
  }
});

// Mostrar pantalla de login al seleccionar rol
function mostrarLogin() {
  const rol = document.getElementById('rol-selector').value;
  if (!rol) return;
  localStorage.setItem('rolSeleccionado', rol);
  document.getElementById('bienvenida').style.display = 'none';
  document.getElementById('form-login').style.display = 'flex';
}

// Iniciar sesión
function iniciarSesion(event) {
  event.preventDefault();
  const correo = document.getElementById('correo').value;
  const contrasena = document.getElementById('contrasena').value;
  const rol = localStorage.getItem('rolSeleccionado');

  if (!correo || !contrasena) {
      alert('Por favor, completa todos los campos.');
      return;
  }

  document.getElementById('form-login').style.display = 'none';
  document.getElementById('menu-admin').style.display = 'flex'; // Siempre mostrar el menú principal

  aplicarPermisos(); // Aplicar permisos al iniciar sesión
  // Aquí podrías agregar lógica adicional según el rol si es necesario para la interfaz del menú
}

// Recuperar contraseña
function recuperarContrasena() {
  const correo = prompt('Ingresa tu correo para recuperar tu contraseña:');
  if (correo) {
      alert('Se ha enviado un enlace de recuperación a ' + correo);
  }
}

// Cerrar sesión
function cerrarSesion() {
  localStorage.removeItem('rolSeleccionado');
  location.reload();
}

// Función genérica para ocultar todas las pantallas excepto la que se va a mostrar
function ocultarTodasLasPantallas() {
  const pantallas = document.querySelectorAll('.pantalla');
  pantallas.forEach(pantalla => {
      pantalla.style.display = 'none';
  });
}

// Registro de productos
function mostrarRegistro() {
  ocultarTodasLasPantallas();
  document.getElementById('registro-productos').style.display = 'flex';
}

function guardarProducto(evento) {
  evento.preventDefault();
  const nombre = document.getElementById('prod-nombre').value;
  const categoria = document.getElementById('prod-categoria').value;
  const precio = parseFloat(document.getElementById('prod-precio').value);
  const cantidad = parseInt(document.getElementById('prod-cantidad').value, 10);

  const producto = { id: Date.now(), nombre, categoria, precio, cantidad, entradas: cantidad, salidas: 0 };
  const productos = JSON.parse(localStorage.getItem('productos') || '[]');
  productos.push(producto);
  localStorage.setItem('productos', JSON.stringify(productos));

  document.getElementById('registro-productos').style.display = 'none';
  document.getElementById('confirmacion').querySelector('p').textContent = 'Acción completada con éxito';
  document.getElementById('confirmacion').style.display = 'flex';
  document.getElementById('form-registro').reset();
}

function volverRegistro() {
  document.getElementById('confirmacion').style.display = 'none';
  document.getElementById('registro-productos').style.display = 'flex';
}

function verStock() {
  ocultarTodasLasPantallas();
  document.getElementById('vista-stock').style.display = 'flex';
  cargarStock();
}

function volverInicio() {
  ocultarTodasLasPantallas();
  document.getElementById('menu-admin').style.display = 'flex';
}

// Manejo de stock
function cargarStock() {
  const tbody = document.getElementById('tabla-stock');
  tbody.innerHTML = '';
  const productos = JSON.parse(localStorage.getItem('productos') || '[]');

  productos.forEach(prod => {
      const tr = document.createElement('tr');
      const estado = obtenerEstado(prod.cantidad);

      tr.innerHTML = `
          <td>${prod.id}</td>
          <td>${prod.nombre}</td>
          <td><span class="estado ${estado}"></span></td>
          <td>${prod.categoria}</td>
          <td>${prod.cantidad}</td>
          <td>${prod.entradas}</td>
          <td>${prod.salidas}</td>
          <td>
              <button class="btn-salida" onclick="mostrarFormularioSalida(${prod.id})">📉</button>
              <button class="btn-borrar" onclick="borrarFila(${prod.id})">🗑️</button>
          </td>
      `;
      tbody.appendChild(tr);
  });
}

function obtenerEstado(cantidad) {
  if (cantidad === 0) return 'rojo';
  if (cantidad <= 25) return 'amarillo';
  return 'verde';
}

function borrarFila(id) {
  let productos = JSON.parse(localStorage.getItem('productos') || '[]');
  productos = productos.filter(p => p.id !== id);
  localStorage.setItem('productos', JSON.stringify(productos));
  cargarStock();
}

// Registro y listado de usuarios
function mostrarRegistroUsuarios() {
  ocultarTodasLasPantallas();
  document.getElementById('registro-usuarios').style.display = 'flex';
  cargarUsuarios();
}

function cargarUsuarios() {
  const grid = document.getElementById('usuarios-grid');
  const formCont = document.getElementById('usuarios-form-container');
  const btnAgregar = document.getElementById('btn-agregar-usuario');
  const rolAdmin = localStorage.getItem('rolSeleccionado') === 'administrador';
  grid.innerHTML = '';

  const usuarios = JSON.parse(localStorage.getItem('usuarios') || '[]');
  if (usuarios.length === 0) {
      formCont.style.display = 'block';
      btnAgregar.style.display = 'none';
      return;
  }

  formCont.style.display = 'none';
  btnAgregar.style.display = 'block';

  usuarios.forEach(u => {
      const avatarUrl = `https://i.pravatar.cc/100?u=${u.id}`;
      const card = document.createElement('div');
      card.className = 'usuario-card';

      let html = `
          <img src="${avatarUrl}" alt="Avatar de ${u.nombre}" />
          <p><strong>${u.nombre}</strong></p>
          <p>${u.rol}</p>
      `;
      if (rolAdmin) {
          html += `<button class="btn-delete" onclick="eliminarUsuario(${u.id})">🗑️</button>`;
      }
      card.innerHTML = html;
      grid.appendChild(card);
  });
}

function eliminarUsuario(id) {
  let arr = JSON.parse(localStorage.getItem('usuarios') || '[]');
  arr = arr.filter(u => u.id !== id);
  localStorage.setItem('usuarios', JSON.stringify(arr));
  cargarUsuarios();
}

function guardarUsuario(evento) {
  evento.preventDefault();
  const nombre = document.getElementById('nombre-usuario').value;
  const correo = document.getElementById('user-correo').value;
  const password = document.getElementById('usuario-contraseña').value;
  const rol = document.getElementById('user-rol').value;

  const usr = { id: Date.now(), nombre, correo, password, rol };
  const arr = JSON.parse(localStorage.getItem('usuarios') || '[]');
  arr.push(usr);
  localStorage.setItem('usuarios', JSON.stringify(arr));

  cargarUsuarios();
  document.getElementById('form-usuarios').reset();

  console.log(JSON.parse(localStorage.getItem('usuarios'))); // Para verificar en la consola
}

document.getElementById('btn-agregar-usuario')
  .addEventListener('click', () => {
      document.getElementById('usuarios-form-container').style.display = 'block';
  });

// Mostrar informes de productos con bajo stock (Módulo de Reportes)
function mostrarReportes() {
  ocultarTodasLasPantallas();
  document.getElementById('vista-reportes').style.display = 'flex';
  generarAlertas();
}

function generarAlertas() {
  const contenedor = document.getElementById('contenedor-alertas');
  contenedor.innerHTML = '';

  const productos = JSON.parse(localStorage.getItem('productos') || '[]');

  if (productos.length === 0) {
      const alerta = crearAlerta('No hay productos registrados en el sistema.');
      contenedor.appendChild(alerta);
      return;
  }

  productos.forEach(prod => {
      if (prod.cantidad < 5) {
          const alerta = crearAlerta(`⚠️ Stock bajo: "${prod.nombre}" tiene solo ${prod.cantidad} unidades.`);
          contenedor.appendChild(alerta);
      } else if (prod.cantidad === 0) {
          const alerta = crearAlerta(`🔴 ¡AGOTADO!: "${prod.nombre}" no tiene unidades en stock.`);
          contenedor.appendChild(alerta);
      } else if (prod.cantidad <= 15 && prod.cantidad >= 5) {
          const alerta = crearAlerta(`🟡 Por agotarse: "${prod.nombre}" tiene ${prod.cantidad} unidades.`);
          contenedor.appendChild(alerta);
      }
  });

  if (contenedor.innerHTML === '') {
      const ok = document.createElement('div');
      ok.className = 'alerta-ok';
      ok.textContent = ' ✅ Todo en orden. No hay alertas por ahora.';
      contenedor.appendChild(ok);
  }
}

function crearAlerta(mensaje) {
  const card = document.createElement('div');
  card.className = 'alerta';
  card.innerHTML = `<p>${mensaje}</p><button onclick="this.parentElement.remove()">❌</button>`;
  return card;
}

// Mostrar pantalla de registrar salida
function mostrarRegistrarSalida() {
  ocultarTodasLasPantallas();
  document.getElementById('registrar-salida-pantalla').style.display = 'flex';
}

function procesarRegistroSalida(evento) {
  evento.preventDefault();
  const nombre = document.getElementById('salida-prod-nombre').value;
  const categoria = document.getElementById('salida-prod-categoria').value;
  const cantidadRetirar = parseInt(document.getElementById('salida-prod-cantidad').value, 10);

  if (!nombre || !categoria || isNaN(cantidadRetirar) || cantidadRetirar <= 0) {
      alert('Por favor, completa todos los campos correctamente.');
      return;
  }

  let productos = JSON.parse(localStorage.getItem('productos') || '[]');
  const productoIndex = productos.findIndex(p => p.nombre.toLowerCase() === nombre.toLowerCase() && p.categoria.toLowerCase() === categoria.toLowerCase());

  if (productoIndex === -1) {
      alert('No se encontró el producto.');
      return;
  }

  if (productos[productoIndex].cantidad < cantidadRetirar) {
      alert(`No hay suficiente stock para "${nombre}". Stock disponible: ${productos[productoIndex].cantidad}`);
      return;
  }

  productos[productoIndex].cantidad -= cantidadRetirar;
  productos[productoIndex].salidas += cantidadRetirar;
  localStorage.setItem('productos', JSON.stringify(productos));

  document.getElementById('registrar-salida-pantalla').style.display = 'none';
  document.getElementById('confirmacion').querySelector('p').textContent = `Se registraron ${cantidadRetirar} unidades de "${nombre}" como salida.`;
  document.getElementById('confirmacion').style.display = 'flex';
  document.getElementById('form-registrar-salida').reset();

  // Opcional: Actualizar la vista de stock si está visible
  if (document.getElementById('vista-stock').style.display === 'flex') {
      cargarStock();
  }
}

// Sección Devoluciones
function mostrarDevoluciones() {
  ocultarTodasLasPantallas();
  document.getElementById('seccionDevoluciones').style.display = 'flex';
}

function registrarDevolucion(event) {
  event.preventDefault();
  const nombre = this.querySelector('input[placeholder="Nombre:"]').value;
  const proveedor = this.querySelector('input[placeholder="Proveedor"]').value;
  const empleadoResponsable = this.querySelector('input[placeholder="Empleado responsable:"]').value;
  const cantidad = this.querySelector('input[placeholder="Cantidad:"]').value;
  const motivo = this.querySelector('input[placeholder="Motivo:"]').value;
  const fecha = this.querySelector('input[placeholder="Fecha:"]').value;

  const devolucion = {
      id: Date.now(),
      nombre,
      proveedor,
      empleadoResponsable,
      cantidad,
      motivo,
      fecha
  };

  const devoluciones = JSON.parse(localStorage.getItem('devoluciones') || '[]');
  devoluciones.push(devolucion);
  localStorage.setItem('devoluciones', JSON.stringify(devoluciones));

  alert('Devolución registrada con éxito.');
  this.reset();
}

function aplicarPermisos() {
  const rol = localStorage.getItem('rolSeleccionado');
  // Si NO es administrador, ocultamos el botón de Registrar Usuarios
  const usuOpt = document.getElementById('opcion-registrar-usuarios');
  if (usuOpt) {
      usuOpt.style.display = (rol === 'administrador') ? 'block' : 'none';
  }
}

function cargarStock() {
  const cont = document.getElementById('tabla-stock'); // Corregido: era 'grid-stock' en el HTML
  cont.innerHTML = '';
  const productos = JSON.parse(localStorage.getItem('productos') || '[]');

  productos.forEach(prod => {
      // Crea la fila de la tabla
      const tr = document.createElement('tr');
      tr.innerHTML = `
          <td>${prod.id}</td>
          <td>${prod.nombre}</td>
          <td><span class="estado ${obtenerEstado(prod.cantidad)}"></span></td>
          <td>${prod.categoria}</td>
          <td>${prod.cantidad}</td>
          <td>${prod.entradas}</td>
          <td>${prod.salidas}</td>
          <td>
              <button class="btn-salida" onclick="mostrarFormularioSalida(${prod.id})">📉</button>
              <button class="btn-borrar" onclick="borrarFila(${prod.id})">🗑️</button>
          </td>`;
      cont.appendChild(tr);
  });

  // Si no hay productos:
  if (!productos.length) {
      const tr = document.createElement('tr');
      tr.innerHTML = '<td colspan="8"><div class="alerta-ok">✅ No hay productos registrados.</div></td>';
      cont.appendChild(tr);
  }
}