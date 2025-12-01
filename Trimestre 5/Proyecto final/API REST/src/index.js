import app from './app/app.js';                  // Importamos la app con rutas y middlewares
import dotenv from 'dotenv';                     // Para variables de entorno
import { modelsApp } from './config/models.app.js'; // Importamos la función que registra modelos
import 'dotenv/config';

// Cargar variables de entorno
dotenv.config();

// Sincronizar modelos con la base de datos
modelsApp(true); // true = sincroniza y crea tablas si no existen

// Puerto del servidor
const port = process.env.SERVER_PORT || 3001;

// Levantar servidor
app.listen(port, () => {

    console.log("EMAIL_USER:", process.env.EMAIL_USER);
console.log("EMAIL_PASS:", process.env.EMAIL_PASS ? "OK" : "NO");

    console.log(`✅ Servidor corriendo en http://localhost:${port}`);
});
