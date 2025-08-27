const routes = [
  {
    path: "/",
    component: () => import("layouts/MainLayout.vue"),
    children: [
      { path: "", component: () => import("layouts/MenuComida.vue") },
      { path: "registro", component: () => import("layouts/Registro.vue") },
      { path: "pagos", component: () => import("layouts/PagosComandas.vue") },
      { path: "pedidos", component: () => import("layouts/admin-ventas.vue") },
      { path: "status", component: () => import("layouts/Estatuspedido.vue") },
      {
        path: "productos",
        component: () => import("layouts/ListaProductos.vue"),
      },
    ],
  },

  {
    path: "/:catchAll(.*)*",
    component: () => import("pages/ErrorNotFound.vue"),
  },
];

export default routes;
