<template>
  <q-layout view="lHh Lpr lFf">
    <q-header elevated class="bg-primary text-white">
      <q-toolbar class="q-px-md q-py-sm">
        <q-toolbar-title class="text-h6 text-center text-uppercase">
          Menú
        </q-toolbar-title>
        <q-btn flat round size="xl" icon="shopping_cart" @click="abrirCarrito">
          <q-badge
            v-if="carrito.length > 0"
            color="red"
            floating
            transparent
            style="font-size: 25px; padding: 4px 8px"
          >
            {{ carrito.length }}
          </q-badge>
        </q-btn>
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
              <div class="row no-wrap items-center">
                <div class="col text-subtitle1 ellipsis">{{ item.nombre }}</div>
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
              <q-btn
                flat
                round
                size="xl"
                icon="add_shopping_cart"
                @click="agregarAlCarrito(item)"
              />
              <q-btn flat color="primary" @click="agregarAlCarrito(item)">
                Agregar al carrito
              </q-btn>
            </q-card-actions>
          </q-card>
        </div>
      </div>
      <q-dialog v-model="dialogVisible">
        <q-card style="min-width: 350px">
          <q-card-section>
            <div class="text-h6">Carrito de Compras</div>
          </q-card-section>
          <q-separator />
          <q-card-section>
            <div v-if="carrito.length === 0">Tu carrito está vacío.</div>
            <div v-else>
              <div
                v-for="(item, i) in carrito"
                :key="i"
                class="q-mb-sm row items-center justify-between"
              >
                <div>{{ item.nombre }} - ${{ item.precio }}</div>
                <q-btn
                  flat
                  round
                  icon="delete"
                  color="negative"
                  size="sm"
                  @click="eliminarDelCarrito(i)"
                />
              </div>
              <q-separator class="q-my-sm" />
              <div class="text-subtitle1 text-right">
                Total: ${{ totalCarrito }}
              </div>
            </div>
          </q-card-section>
          <q-separator />
          <q-card-actions align="right">
            <q-btn flat label="Cerrar" v-close-popup />
            <q-btn
              v-if="carrito.length > 0"
              label="Confirmar pedido"
              color="primary"
              @click="confirmarPedido"
            />
          </q-card-actions>
        </q-card>
      </q-dialog>
    </q-page-container>
    <q-footer class="bg-grey-2 text-black q-py-md" elevated>
      <q-toolbar class="justify-center">
        <div class="text-center text-subtitle2">Menú</div>
      </q-toolbar>
    </q-footer>
  </q-layout>
</template>

<script>
import { ref, computed } from "vue";
import { useQuasar } from "quasar";
export default {
  setup() {
    const $q = useQuasar();
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
    const carrito = ref([]);
    const dialogVisible = ref(false);
    const agregarAlCarrito = (item) => {
      carrito.value.push(item);
    };
    const eliminarDelCarrito = (index) => {
      carrito.value.splice(index, 1);
    };
    const abrirCarrito = () => {
      dialogVisible.value = true;
    };
    const confirmarPedido = () => {
      $q.notify({
        type: "positive",
        message: "¡Pedido confirmado!",
        position: "top",
      });
      carrito.value = [];
      dialogVisible.value = false;
    };
    const totalCarrito = computed(() =>
      carrito.value.reduce((total, item) => total + item.precio, 0)
    );
    return {
      menu,
      carrito,
      dialogVisible,
      agregarAlCarrito,
      eliminarDelCarrito,
      abrirCarrito,
      confirmarPedido,
      totalCarrito,
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
