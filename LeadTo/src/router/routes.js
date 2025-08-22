const routes = [
  {
    path: "/",
    component: () => import("layouts/MainLayout.vue"), // Layout principal
    children: [
      { path: "", component: () => import("layouts/MenuComida.vue") },
      { path: "registro", component: () => import("layouts/Registro.vue") },
      { path: "pagos", component: () => import("layouts/PagosComandas.vue") },
      { path: "pedidos", component: () => import("layouts/admin-ventas.vue") },
    ],
  },

  {
    path: "/:catchAll(.*)*",
    component: () => import("pages/ErrorNotFound.vue"),
  },
];

export default routes;
