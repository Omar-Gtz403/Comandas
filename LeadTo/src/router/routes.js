const routes = [
  {
    path: "/",
    component: () => import("layouts/MainLayout.vue"), // Layout principal
    children: [
      { path: "", component: () => import("layouts/MenuComida.vue") },
      { path: "registro", component: () => import("layouts/Registro.vue") },
      { path: "carrito", component: () => import("layouts/CarritoComandas.vue") }, // si hay otra página de carrito
      { path: "productos", component: () => import("layouts/MenuComida.vue") }, // si hay otra página de productos
       {
    path: "pagos",
    component: () => import("src/layouts/PagosComandas.vue"),
  },
    ],
  },

  {
    path: "/:catchAll(.*)*",
    component: () => import("pages/ErrorNotFound.vue"),
  },
];

export default routes;
