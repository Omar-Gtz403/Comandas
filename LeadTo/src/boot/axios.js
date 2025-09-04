import { boot } from "quasar/wrappers";
import axios from "axios";

// Detecta si estás en desarrollo o producción
const BASE_URL =
  process.env.NODE_ENV === "production"
    ? "http://TU_IP_O_DOMINIO:8082" // Cambia TU_IP_O_DOMINIO por la IP de tu servidor
    : "https://192.168.1.69:8443"; // Localhost para desarrollo

const api = axios.create({
  baseURL: `${BASE_URL}/api`, // Solo pones /api al final
});

export default boot(({ app }) => {
  app.config.globalProperties.$axios = axios; // axios normal
  app.config.globalProperties.$api = api; // axios con baseURL
});

export { api };
