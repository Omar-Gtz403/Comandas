<template>
  <q-layout view="lHh Lpr lFf">
    <q-page-container class="bg-grey-1">
      <!-- Toolbar -->
      <q-toolbar class="q-px-sm q-py-xs">
        <q-toolbar-title class="text-h6 text-center text-uppercase">
          Menú
        </q-toolbar-title>
        <q-btn flat round size="md" icon="shopping_cart" @click="abrirCarrito">
          <q-badge
            v-if="totalItems > 0"
            color="red"
            floating
            transparent
            :label="totalItems"
            class="text-caption"
          />
        </q-btn>
      </q-toolbar>

      <!-- Productos -->
      <div class="q-pa-md row q-col-gutter-md justify-center">
        <div
          v-for="(item, index) in productosAMostrar"
          :key="index"
          class="col-xs-12 col-sm-6 col-md-4 col-lg-3"
        >
          <q-card class="my-card" flat bordered>
            <q-img
              :src="
                item.img ||
                'https://via.placeholder.com/300x200?text=Sin+Imagen'
              "
              class="my-card-img"
            />
            <q-card-section>
              <div class="text-h6 text-bold ellipsis">
                {{ item.nombreProducto }}
              </div>
            </q-card-section>
            <q-card-section class="q-pt-none">
              <div class="text-subtitle1 text-primary">
                $ {{ item.precioVenta.toFixed(2) }}
              </div>
              <div class="text-caption text-grey-7">{{ item.descripcion }}</div>
            </q-card-section>
            <q-separator />
            <q-card-actions align="center" class="q-pa-sm">
              <q-btn
                flat
                rounded
                color="primary"
                icon="add_shopping_cart"
                @click="agregarAlCarrito(item)"
                label="Agregar"
              />
            </q-card-actions>
          </q-card>
        </div>
      </div>

      <!-- Botón para cargar más -->
      <div class="q-mt-md flex flex-center">
        <q-btn
          v-if="productosVisibles < menu.length"
          label="Cargar más"
          color="primary"
          @click="productosVisibles += 5"
        />
      </div>

      <!-- Carrito -->
      <q-dialog v-model="dialogVisible">
        <q-card style="width: 100%; max-width: 450px">
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
                  {{ item.nombreProducto }} - ${{
                    (item.precioVenta * item.cantidad).toFixed(2)
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
              <div class="text-subtitle1 text-right text-bold">
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
  </q-layout>
</template>

<script>
import { ref, computed, onMounted, watch } from "vue";
import { useQuasar, Notify } from "quasar";
import { api } from "src/boot/axios";
import { useRouter } from "vue-router";

export default {
  setup() {
    const $q = useQuasar();
    const menu = ref([]);
    const carrito = ref([]);
    const dialogVisible = ref(false);
    const router = useRouter();

    // Control de productos visibles
    const productosVisibles = ref(5);

    const getMenu = async () => {
      try {
        const res = await api.get("/productos");
        menu.value = res.data;
      } catch (err) {
        console.error("Error cargando productos:", err);
      }
    };

    const productosAMostrar = computed(() => {
      return menu.value.slice(0, productosVisibles.value);
    });

    const agregarAlCarrito = (item) => {
      const index = carrito.value.findIndex(
        (p) => p.codigoBarras === item.codigoBarras
      );
      if (index !== -1) {
        carrito.value[index].cantidad += 1;
      } else {
        carrito.value.push({ ...item, cantidad: 1 });
      }
      carrito.value = [...carrito.value]; // forzar reactividad

      Notify.create({
        type: "positive",
        message: `Agregado al carrito: ${item.nombreProducto}`,
        position: "top",
      });
    };

    const eliminarDelCarrito = (index) => {
      carrito.value.splice(index, 1);
      carrito.value = [...carrito.value];
    };

    const incrementarCantidad = (index) => {
      carrito.value[index].cantidad += 1;
      carrito.value = [...carrito.value];
    };

    const reducirCantidad = (index) => {
      if (carrito.value[index].cantidad > 1) {
        carrito.value[index].cantidad -= 1;
      } else {
        carrito.value.splice(index, 1);
      }
      carrito.value = [...carrito.value];
    };

    const abrirCarrito = () => {
      dialogVisible.value = true;
    };

    const confirmarPedido = async () => {
      try {
        const venta = {
          total: totalCarrito.value,
          detalles: carrito.value.map((item) => ({
            codigoBarras: item.codigoBarras,
            cantidad: item.cantidad,
            precioUnitario: item.precioVenta,
          })),
        };

        const res = await api.post("/ventas", venta);
        Notify.create({
          type: "positive",
          message:
            "Pedido registrado exitosamente, se despachará después de su pago",
          position: "top",
        });

        router.push({
          path: "/pagos",
          query: { total: totalCarrito.value, idVenta: res.data.id },
        });

        carrito.value = [];
        localStorage.removeItem("carrito"); // limpiar carrito guardado
        dialogVisible.value = false;
      } catch (err) {
        console.error("Error registrando venta:", err);
        $q.notify({
          type: "negative",
          message: "Error al registrar el pedido.",
          position: "top",
        });
      }
    };

    const totalCarrito = computed(() =>
      carrito.value.reduce(
        (total, item) => total + item.precioVenta * item.cantidad,
        0
      )
    );

    const totalItems = computed(() =>
      carrito.value.reduce((acc, item) => acc + item.cantidad, 0)
    );

    // Guardar carrito automáticamente en localStorage
    watch(
      carrito,
      (nuevoCarrito) => {
        localStorage.setItem("carrito", JSON.stringify(nuevoCarrito));
      },
      { deep: true }
    );

    onMounted(() => {
      getMenu();

      // Recuperar carrito si existe en localStorage
      const carritoGuardado = localStorage.getItem("carrito");
      if (carritoGuardado) {
        carrito.value = JSON.parse(carritoGuardado);
      }
    });

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
      productosVisibles,
      productosAMostrar,
    };
  },
};
</script>

<style lang="sass" scoped>
.my-card
  width: 100%
  max-width: 360px
  margin: 0 auto
  border-radius: 12px
  transition: transform 0.25s ease, box-shadow 0.25s ease
  cursor: pointer

@media (hover: hover)
  .my-card:hover
    transform: scale(1.05)
    box-shadow: 0 12px 25px rgba(0,0,0,0.2)

.my-card-img
  border-top-left-radius: 12px
  border-top-right-radius: 12px
  transition: transform 0.3s ease

@media (hover: hover)
  .my-card-img:hover
    transform: scale(1.1)
</style>
