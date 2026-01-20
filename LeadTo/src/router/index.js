import { route } from "quasar/wrappers";
import {
  createRouter,
  createMemoryHistory,
  createWebHistory,
  createWebHashHistory,
} from "vue-router";
import routes from "./routes";

export default route(function () {
  const createHistory = process.env.SERVER
    ? createMemoryHistory
    : process.env.VUE_ROUTER_MODE === "history"
    ? createWebHistory
    : createWebHashHistory;

  const Router = createRouter({
    scrollBehavior: () => ({ left: 0, top: 0 }),
    routes,
    history: createHistory(
      process.env.MODE === "ssr" ? void 0 : process.env.VUE_ROUTER_BASE
    ),
  });

  // 🔥 AGREGAMOS EL BLOQUEO AQUÍ
  Router.beforeEach((to, from, next) => {
    const usuario = JSON.parse(localStorage.getItem("usuario"));

    // ✅ Rutas que cualquier persona puede ver
    const rutasPublicas = ["/", "/status", "/ticket", "/pagos"];

    // Si la página está en rutas públicas → permitir acceso
    if (rutasPublicas.includes(to.path)) {
      return next();
    }

    // Si la ruta NO requiere permisos → permitir
    if (!to.meta?.requierePermiso) {
      return next();
    }

    // Si no hay sesión → mandar a login
    if (!usuario) {
      return next("/login");
    }

    // Obtener las rutas permitidas según el rol
    const permisosRol = usuario.rol?.permisos?.map((p) => p.ruta) || [];

    // Si el usuario tiene el permiso → permitir
    if (permisosRol.includes(to.meta.requierePermiso)) {
      return next();
    }

    // 🚫 Si no tiene permiso → regresar al menú principal
    return next("/");
  });

  return Router;
});
