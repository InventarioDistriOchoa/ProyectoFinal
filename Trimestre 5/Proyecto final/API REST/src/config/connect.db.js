import dotenv from "dotenv";
import { Sequelize } from "sequelize";

// Cargar variables de entorno
dotenv.config({ path: ".env" });

// Configuración de la conexión
const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASSWORD,
  {
    host: process.env.DB_HOST,
    dialect: process.env.DB_DIALECT,
    logging: false,
  }
);

// Probar conexión
async function testConnection() {
  try {
    await sequelize.authenticate();
    console.log("✅ Base de datos conectada correctamente.");
  } catch (error) {
    console.error("❌ Error al conectar la base de datos:", error);
  }
}

testConnection();

export default sequelize;
