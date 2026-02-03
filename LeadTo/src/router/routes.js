export default [
  {
    path: "/",
    component: () => import("layouts/MainLayout.vue"),
    children: [
      {
        path: "",
        component: () => import("pages/MenuComida.vue"),
        meta: { publica: true },
      },
      {
        path: "status",
        component: () => import("pages/Estatuspedido.vue"),
        meta: { publica: true },
      },
      {
        path: "ticket",
        component: () => import("pages/Ticket.vue"),
        meta: { publica: true },
      },
      {
        path: "pagos",
        component: () => import("pages/PagosComandasLayout.vue"),
        meta: { publica: true },
      },

      {
        path: "rol",
        component: () => import("pages/CrearRol.vue"),
        meta: { requierePermiso: "/rol" },
      },
      {
        path: "scan",
        component: () => import("pages/ScanQR.vue"),
        meta: { requierePermiso: "/scan" },
      },
      {
        path: "caja",
        component: () => import("pages/CajaPage.vue"),
        meta: { requierePermiso: "/caja" },
      },
      {
        path: "dashboard",
        component: () => import("pages/AppDashboard.vue"),
        meta: { requierePermiso: "/dashboard" },
      },
      {
        path: "registro",
        component: () => import("pages/Registro.vue"),
        meta: { requierePermiso: "/registro" },
      },
      {
        path: "categorias",
        component: () => import("pages/CategoriaCrear.vue"),
        meta: { requierePermiso: "/categorias" },
      },
      {
        path: "pedidos",
        component: () => import("pages/admin-ventas.vue"),
        meta: { requierePermiso: "/pedidos" },
      },
      {
        path: "productos",
        component: () => import("pages/ListaProductos.vue"),
        meta: { requierePermiso: "/productos" },
      },
      {
        path: "inventario",
        component: () => import("pages/PaginaInventarios.vue"),
        meta: { requierePermiso: "/inventario" },
      },
      {
        path: "registrousuario",
        component: () => import("pages/CrearUsuario.vue"),
        meta: { requierePermiso: "/registrousuario" },
      },
    ],
  },

  {
    path: "/login",
    component: () => import("layouts/AuthLayout.vue"),
    children: [{ path: "", component: () => import("pages/LoginPage.vue") }],
  },

  {
    path: "/:catchAll(.*)*",
    component: () => import("pages/ErrorNotFound.vue"),
  },
];
