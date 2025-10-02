const routes = [
  {
    path: "/",
    component: () => import("layouts/MainLayout.vue"),
    children: [
      { path: "", component: () => import("pages/MenuComida.vue") }, // página principal
      { path: "status", component: () => import("pages/Estatuspedido.vue") },
      { path: "ticket", component: () => import("pages/Ticket.vue") },
      { path: "scan", component: () => import("pages/ScanQR.vue") },
      { path: "dashboard", component: () => import("pages/AppDashboard.vue") },
      {
        path: "pagos",
        component: () => import("pages/PagosComandasLayout.vue"),
      },

      {
        path: "scan",
        component: () => import("pages/ScanQR.vue"),
        beforeEnter: (to, from, next) => {
          const usuario = JSON.parse(localStorage.getItem("usuario"));
          if (usuario && usuario.permiso === 1) next();
          else next("/login");
        },
      },
      {
        path: "registro",
        component: () => import("pages/Registro.vue"),
        beforeEnter: (to, from, next) => {
          const usuario = JSON.parse(localStorage.getItem("usuario"));
          if (usuario && usuario.permiso === 1) next();
          else next("/login");
        },
      },
      {
        path: "categorias",
        component: () => import("pages/CategoriaCrear.vue"),
        beforeEnter: (to, from, next) => {
          const usuario = JSON.parse(localStorage.getItem("usuario"));
          if (usuario && usuario.permiso === 1) next();
          else next("/login");
        },
      },
      {
        path: "pedidos",
        component: () => import("pages/admin-ventas.vue"),
        beforeEnter: (to, from, next) => {
          const usuario = JSON.parse(localStorage.getItem("usuario"));
          if (usuario && usuario.permiso === 1) next();
          else next("/login");
        },
      },
      {
        path: "productos",
        component: () => import("pages/ListaProductos.vue"),
        beforeEnter: (to, from, next) => {
          const usuario = JSON.parse(localStorage.getItem("usuario"));
          if (usuario && usuario.permiso === 1) next();
          else next("/login");
        },
      },
      {
        path: "inventario",
        component: () => import("pages/PaginaInventarios.vue"),
        beforeEnter: (to, from, next) => {
          const usuario = JSON.parse(localStorage.getItem("usuario"));
          if (usuario && usuario.permiso === 1) next();
          else next("/login");
        },
      },

      {
        path: "registrousuario",
        name: "registerpage",
        component: () => import("pages/CrearUsuario.vue"),
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
    children: [{ path: "", component: () => import("pages/LoginPage.vue") }],
  },

  // Ruta de error 404
  {
    path: "/:catchAll(.*)*",
    component: () => import("pages/ErrorNotFound.vue"),
  },
];

export default routes;
