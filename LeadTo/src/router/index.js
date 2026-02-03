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

  Router.beforeEach((to, from, next) => {
    const usuario = JSON.parse(localStorage.getItem("usuario"));

    // 1️⃣ Ruta pública
    if (to.meta?.publica) return next();

    // 2️⃣ Ruta sin permiso
    if (!to.meta?.requierePermiso) return next();

    // 3️⃣ Sin sesión
    if (!usuario) return next("/login");

    // 4️⃣ Validar permiso
    const permisos = usuario.rol?.permisos?.map((p) => p.ruta) || [];

    if (permisos.includes(to.meta.requierePermiso)) {
      return next();
    }

    // 5️⃣ Sin permiso
    return next("/");
  });

  return Router;
});
