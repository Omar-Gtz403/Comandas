<template>
  <q-layout view="lHh Lpr lFf">
    <q-page-container class="bg-grey-2">
      <!-- Toolbar -->
      <q-toolbar class="q-px-md q-py-sm bg-primary text-white shadow-2">
        <q-toolbar-title class="text-h5 text-center text-uppercase">
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

      <!-- Menú agrupado por categorías -->
      <div
        v-for="(productos, categoria) in productosPorCategoria"
        :key="categoria"
      >
        <div class="categoria-header q-mt-lg q-mb-md">
          <span>{{ categoria }}</span>
        </div>

        <q-infinite-scroll @load="loadMore" :offset="100">
          <div class="row q-col-gutter-md justify-center">
            <div
              v-for="item in productosAMostrarPorCategoria[categoria]"
              :key="item.codigoBarras"
              class="col-xs-12 col-sm-6 col-md-4 col-lg-3"
            >
              <q-card class="my-card bg-white">
                <q-img
                  :src="
                    item.img ||
                    'https://via.placeholder.com/300x200?text=Sin+Imagen'
                  "
                  class="my-card-img"
                />
                <q-card-section class="text-center">
                  <div class="text-h6 text-bold ellipsis">
                    {{ item.nombreProducto }}
                  </div>
                  <div class="text-subtitle2 text-primary mt-1">
                    $ {{ item.precioVenta.toFixed(2) }}
                  </div>
                  <div class="text-caption text-grey-6 mt-1">
                    {{ item.descripcion }}
                  </div>
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
                    class="text-bold"
                  />
                </q-card-actions>
              </q-card>
            </div>
          </div>
        </q-infinite-scroll>
      </div>

      <!-- Carrito -->
      <q-dialog v-model="dialogVisible">
        <q-card style="min-width: 450px">
          <q-card-section>
            <div class="text-h6 text-center">Carrito de Compras</div>
          </q-card-section>
          <q-separator />
          <q-card-section>
            <div v-if="carrito.length === 0" class="text-center q-pa-md">
              Tu carrito está vacío.
            </div>
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
import { ref, computed, onMounted } from "vue";
import { useQuasar, Notify } from "quasar";
import { api } from "src/boot/axios";
import { useRouter } from "vue-router";

export default {
  name: "MenuComida",
  setup() {
    const router = useRouter();
    const $q = useQuasar();

    const menu = ref([]);
    const carrito = ref([]);
    const dialogVisible = ref(false);
    const visiblesPorCategoria = ref({}); // cantidad visible por categoría

    // Cargar menú desde backend
    const getMenu = async () => {
      try {
        const res = await api.get("/productos");
        menu.value = res.data;

        // Inicializamos visiblesPorCategoria con 5 productos por categoría
        const categoriasUnicas = [
          ...new Set(
            menu.value
              .filter((p) => p.activo) // solo activos
              .map((p) => p.categoria?.nombre || "Sin categoría")
          ),
        ];

        categoriasUnicas.forEach((cat) => {
          visiblesPorCategoria.value[cat] = 5;
        });
      } catch (err) {
        console.error("Error cargando productos:", err);
      }
    };

    // Agrupar productos activos por categoría
    const productosPorCategoria = computed(() => {
      return menu.value
        .filter((producto) => producto.activo) // solo activos
        .reduce((acc, producto) => {
          const categoria = producto.categoria?.nombre || "Sin categoría";
          if (!acc[categoria]) acc[categoria] = [];
          acc[categoria].push(producto);
          return acc;
        }, {});
    });

    // Productos a mostrar (control de infinite scroll) por categoría
    const productosAMostrarPorCategoria = computed(() => {
      const result = {};
      for (const cat in productosPorCategoria.value) {
        // Slice según la cantidad visible, evita dejar espacios
        result[cat] = productosPorCategoria.value[cat].slice(
          0,
          visiblesPorCategoria.value[cat] ||
            productosPorCategoria.value[cat].length
        );
      }
      return result;
    });

    // Cargar más productos al hacer scroll
    const loadMore = (index, done) => {
      for (const cat in visiblesPorCategoria.value) {
        visiblesPorCategoria.value[cat] += 5;
      }
      done();
    };

    // Funciones de carrito
    const agregarAlCarrito = (item) => {
      const index = carrito.value.findIndex(
        (p) => p.codigoBarras === item.codigoBarras
      );
      if (index !== -1) carrito.value[index].cantidad += 1;
      else carrito.value.push({ ...item, cantidad: 1 });

      Notify.create({
        type: "positive",
        message: `Agregado al carrito: ${item.nombreProducto}`,
        position: "top",
      });
    };

    const eliminarDelCarrito = (index) => carrito.value.splice(index, 1);
    const incrementarCantidad = (i) => (carrito.value[i].cantidad += 1);
    const reducirCantidad = (i) =>
      carrito.value[i].cantidad > 1
        ? carrito.value[i].cantidad--
        : carrito.value.splice(i, 1);
    const abrirCarrito = () => (dialogVisible.value = true);

    // Confirmar pedido
 const confirmarPedido = async () => {
  try {
    const venta = {
      total: totalCarrito.value,
      status: 0, // <<--- agregar esto
      detalles: carrito.value.map((item) => ({
        codigoBarras: item.codigoBarras,
        cantidad: item.cantidad,
        precioUnitario: item.precioVenta,
      })),
    };

    const res = await api.post("/ventas", venta);
    const folio = res.data.folio;
    const total = res.data.total || totalCarrito.value;

    carrito.value = [];
    dialogVisible.value = false;

    $q.notify({
      type: "positive",
      message: "Pedido registrado correctamente",
      position: "top",
    });

    router.push({ path: "/pagos", query: { folio, total } });
  } catch (err) {
    console.error(err);
    $q.notify({
      type: "negative",
      message: "Error al registrar el pedido",
      position: "top",
    });
  }
};

    // Computed para total de carrito
    const totalCarrito = computed(() =>
      carrito.value.reduce(
        (total, item) => total + item.precioVenta * item.cantidad,
        0
      )
    );

    const totalItems = computed(() =>
      carrito.value.reduce((acc, item) => acc + item.cantidad, 0)
    );

    onMounted(() => {
      getMenu();
    });

    return {
      menu,
      carrito,
      dialogVisible,
      productosPorCategoria,
      productosAMostrarPorCategoria,
      agregarAlCarrito,
      eliminarDelCarrito,
      incrementarCantidad,
      reducirCantidad,
      abrirCarrito,
      confirmarPedido,
      totalCarrito,
      totalItems,
      loadMore,
    };
  },
};
</script>

<style lang="sass" scoped>
/* --- Categorías --- */
.categoria-header
  padding: 12px 20px
  margin-bottom: 12px
  font-size: 1.4rem
  font-weight: bold
  color: white
  background: linear-gradient(90deg, #ff8a65, #ff7043)
  border-radius: 12px
  text-align: center
  box-shadow: 0 4px 15px rgba(0,0,0,0.2)

/* --- Tarjetas --- */
.my-card
  width: 100%
  height: 100%
  border-radius: 16px
  display: flex
  flex-direction: column
  transition: transform 0.3s ease, box-shadow 0.3s ease
  cursor: pointer
  box-shadow: 0 4px 12px rgba(0,0,0,0.1)
  &:hover
    transform: translateY(-6px)
    box-shadow: 0 12px 25px rgba(0,0,0,0.2)

.my-card-img
  height: 200px
  object-fit: cover
  border-top-left-radius: 16px
  border-top-right-radius: 16px
  transition: transform 0.3s ease
  &:hover
    transform: scale(1.05)

.q-card-section
  min-height: 70px
  text-align: center

/* --- Botón agregar --- */
.q-btn
  font-weight: bold
  text-transform: uppercase

/* --- Fondo de la página --- */
.bg-grey-2
  background-color: #f5f5f5
</style>
