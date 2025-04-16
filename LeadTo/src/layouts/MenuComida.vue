<template>
  <q-layout view="lHh Lpr lFf">
    <q-header elevated>
      <q-toolbar>
        <q-toolbar-title> Menú </q-toolbar-title>
      </q-toolbar>
    </q-header>

    <q-page-container>
      <div class="q-pa-md row q-col-gutter-md justify-center">
        <div
          v-for="(item, index) in menu"
          :key="index"
          class="col-xs-12 col-sm-6 col-md-4 col-lg-3"
        >
          <q-card class="my-card" flat bordered>
            <q-img :src="item.img" />

            <q-card-section>
              <q-btn
                fab
                color="primary"
                icon="shopping_cart"
                class="absolute"
                style="top: 0; right: 12px; transform: translateY(-50%)"
              />

              <div class="row no-wrap items-center">
                <div class="col text-h6 ellipsis">{{ item.nombre }}</div>
              </div>
            </q-card-section>

            <q-card-section class="q-pt-none">
              <div class="text-subtitle1">${{ item.precio }}</div>
              <div class="text-caption text-grey">
                {{ item.descripcion }}
              </div>
            </q-card-section>

            <q-separator />

            <q-card-actions>
              <q-btn flat round icon="shopping_cart" />
              <q-btn flat color="primary">Agregar al carrito</q-btn>
            </q-card-actions>
          </q-card>
        </div>
      </div>
    </q-page-container>

    <q-footer class="bg-grey-2 text-black" elevated>
      <q-toolbar class="justify-center">
        <div>Menu</div>
      </q-toolbar>
    </q-footer>
  </q-layout>
</template>

<script>
export default {
  setup() {
    const menu = [
      {
        nombre: "Papas Fritas Chicas",
        precio: 15,
        descripcion: "Porción pequeña de papas doradas al momento.",
        img: "https://cdn.quasar.dev/img/chicken-salad.jpg",
      },
      {
        nombre: "Papas Fritas Medianas",
        precio: 20,
        descripcion: "Porción mediana, ideal para compartir.",
        img: "https://cdn.quasar.dev/img/chicken-salad.jpg",
      },
      {
        nombre: "Papas Fritas Grandes",
        precio: 25,
        descripcion: "Porción grande para los más hambrientos.",
        img: "https://cdn.quasar.dev/img/chicken-salad.jpg",
      },
      {
        nombre: "Papas a la Francesa",
        precio: 45,
        descripcion: "Crujientes papas sazonadas con sal de ajo.",
        img: "https://cdn.quasar.dev/img/chicken-salad.jpg",
      },
      {
        nombre: "Plátanos Fritos",
        precio: 45,
        descripcion: "Deliciosos plátanos fritos con toque dulce.",
        img: "https://cdn.quasar.dev/img/chicken-salad.jpg",
      },
      {
        nombre: "Nachos con queso",
        precio: 40,
        descripcion: "Nachos con queso",
        img: "https://cdn.quasar.dev/img/chicken-salad.jpg",
      },
    ];

    return {
      menu,
    };
  },
};
</script>

<style lang="sass" scoped>
.my-card
  width: 100%
  transition: transform 0.2s ease, box-shadow 0.2s ease
  border-radius: 15px
  &:hover
    transform: scale(1.03)
    box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15)
</style>
