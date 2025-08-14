<template>
  <q-layout view="lHh Lpr lFf">

    <q-header elevated class="bg-primary text-white">
      <q-toolbar class="q-px-md q-py-sm">
        <q-toolbar-title class="text-h6 text-center text-uppercase">
          Menú
        </q-toolbar-title>
        <q-btn flat round size="lg" icon="shopping_cart" @click="abrirCarrito">
          <q-badge
            v-if="totalItems > 0"
            color="red"
            floating
            transparent
            :label="totalItems"
            style="font-size: 13px; padding: 3px 6px"
          />
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
            <q-img
              :src="
                item.img ||
                'https://via.placeholder.com/300x200?text=Sin+Imagen'
              "
            />
            <q-card-section>
              <div class="row no-wrap items-center">
                <div class="col text-subtitle1 ellipsis">{{ item.nombre }}</div>
              </div>
            </q-card-section>
            <q-card-section class="q-pt-none">
              <div class="text-subtitle1">${{ item.precio.toFixed(2) }}</div>
              <div class="text-caption text-grey">{{ item.descripcion }}</div>
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
        <q-card style="min-width: 450px">
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
                <div class="col-8">
                  {{ item.nombre }} - ${{
                    (item.precio * item.cantidad).toFixed(2)
                  }}
                </div>
                <div class="col-4 row items-center justify-end">
                  <q-btn
                    dense
                    flat
                    round
                    icon="remove"
                    size="sm"
                    @click="reducirCantidad(i)"
                  />
                  <div class="q-mx-sm">{{ item.cantidad }}</div>
                  <q-btn
                    dense
                    flat
                    round
                    icon="add"
                    size="sm"
                    @click="incrementarCantidad(i)"
                  />
                  <q-btn
                    dense
                    flat
                    round
                    icon="delete"
                    color="negative"
                    size="sm"
                    @click="eliminarDelCarrito(i)"
                    class="q-ml-sm"
                  />
                </div>
              </div>
              <q-separator class="q-my-sm" />
              <div class="text-subtitle1 text-right">
                Total: ${{ totalCarrito.toFixed(2) }}
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
import { ref, computed, onMounted } from "vue";
import { useQuasar } from "quasar";
import axios from "axios";

export default {
  setup() {
    const $q = useQuasar();
    const menu = ref([]);
    const carrito = ref([]);
    const dialogVisible = ref(false);

    const getMenu = async () => {
      try {
        const res = await axios.get("http://localhost:8082/api/productos");
        menu.value = res.data;
      } catch (err) {
        console.error("Error cargando productos:", err);
      }
    };

    const agregarAlCarrito = (item) => {
      const index = carrito.value.findIndex(
        (p) => p.codigoBarras === item.codigoBarras
      );
      if (index !== -1) {
        carrito.value[index].cantidad += 1;
      } else {
        carrito.value.push({ ...item, cantidad: 1 });
      }
      carrito.value = [...carrito.value];
    };

    const eliminarDelCarrito = (index) => {
      carrito.value.splice(index, 1);
    };

    const incrementarCantidad = (index) => {
      carrito.value[index].cantidad += 1;
    };

    const reducirCantidad = (index) => {
      if (carrito.value[index].cantidad > 1) {
        carrito.value[index].cantidad -= 1;
      } else {
        carrito.value.splice(index, 1);
      }
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
      carrito.value.reduce(
        (total, item) => total + item.precio * item.cantidad,
        0
      )
    );

    const totalItems = computed(() =>
      carrito.value.reduce((acc, item) => acc + item.cantidad, 0)
    );

    onMounted(getMenu);

    return {
      menu,
      carrito,
      dialogVisible,
      agregarAlCarrito,
      eliminarDelCarrito,
      incrementarCantidad,
      reducirCantidad,
      abrirCarrito,
      confirmarPedido,
      totalCarrito,
      totalItems,
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
