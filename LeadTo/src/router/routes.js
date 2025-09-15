const routes = [
  {
    path: "/",
    component: () => import("layouts/MainLayout.vue"),
    children: [
      { path: "", component: () => import("layouts/MenuComida.vue") }, // página principal
      { path: "status", component: () => import("layouts/Estatuspedido.vue") },
      { path: "ticket", component: () => import("layouts/Ticket.vue") },
      { path: "pedidos", component: () => import("layouts/admin-ventas.vue") },
      { path: "registro", component: () => import("layouts/Registro.vue") },
      { path: "scan", component: () => import("layouts/ScanQR.vue") },
      { path: "pagos", component: () => import("layouts/PagosComandas.vue") },
      {
        path: "productos",
        component: () => import("layouts/ListaProductos.vue"),
        beforeEnter: (to, from, next) => {
          const usuario = JSON.parse(localStorage.getItem("usuario"));
          if (usuario && usuario.permiso === 1) next();
          else next("/login");
        },
      },

      {
        path: "registrousuario",
        name: "registerpage",
        component: () => import("layouts/CrearUsuario.vue"),
        beforeEnter: (to, from, next) => {
          const usuario = JSON.parse(localStorage.getItem("usuario"));
          if (usuario && usuario.permiso === 1) next();
          else next("/login");
          next();
        },
      },
    ],
  },

  // Ruta de login fuera del layout principal
  {
    path: "/login",
    name: "loginpage",
    component: () => import("layouts/AuthLayout.vue"),
    children: [{ path: "", component: () => import("layouts/LoginPage.vue") }],
  },

  // Ruta de error 404
  {
    path: "/:catchAll(.*)*",
    component: () => import("pages/ErrorNotFound.vue"),
  },
];

export default routes;
