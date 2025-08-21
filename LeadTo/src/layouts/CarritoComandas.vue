<template>
  <q-layout view="lHh Lpr lFf">
    <q-header elevated class="bg-primary text-white">
      <q-toolbar>
        <q-toolbar-title>
          Carrito de Ventas
        </q-toolbar-title>
      </q-toolbar>
    </q-header>

    <q-page-container>
      <div class="q-pa-md">
        <q-card class="q-pa-lg shadow-2" style="max-width: 600px; margin: auto;">
          <q-card-section>
            <div class="text-h6 q-mb-md">Productos en el carrito</div>
            <q-list bordered>
              <q-item v-for="(item, idx) in carrito" :key="item.id">
                <q-item-section>
                  <div class="text-subtitle1">{{ item.nombre }}</div>
                  <div class="text-caption">Precio: ${{ item.precio.toFixed(2) }}</div>
                </q-item-section>
                <q-item-section side>
                  <q-input
                    type="number"
                    v-model.number="item.cantidad"
                    min="1"
                    style="width: 60px"
                  />
                </q-item-section>
                <q-item-section side>
                  <q-btn
                    icon="delete"
                    color="negative"
                    flat
                    @click="eliminarProducto(idx)"
                  />
                </q-item-section>
              </q-item>
            </q-list>
            <q-separator spaced />
            <div class="text-h6 text-right q-mt-md">
              Total: ${{ totalCarrito.toFixed(2) }}
            </div>
            <q-btn
              label="Finalizar compra"
              color="primary"
              class="full-width q-mt-lg"
              @click="finalizarCompra"
              :disable="carrito.length === 0"
            />
          </q-card-section>
        </q-card>
      </div>
    </q-page-container>

    <q-footer class="bg-grey-2 text-black q-py-md" elevated>
      <q-toolbar class="justify-center">
        <div class="text-center text-subtitle2">Carrito</div>
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

    // Ejemplo de productos en el carrito
    const carrito = ref([
      { id: 1, nombre: "Producto A", precio: 100, cantidad: 2 },
      { id: 2, nombre: "Producto B", precio: 50, cantidad: 1 },
    ]);

    const totalCarrito = computed(() =>
      carrito.value.reduce((acc, item) => acc + item.precio * item.cantidad, 0)
    );

    function eliminarProducto(idx) {
      carrito.value.splice(idx, 1);
    }

    function finalizarCompra() {
      $q.notify({
        type: "positive",
        message: "¡Compra finalizada!",
        position: "top",
      });
      carrito.value = [];
    }

    return {
      carrito,
      totalCarrito,
      eliminarProducto,
      finalizarCompra,
    };
  },
};
</script>
