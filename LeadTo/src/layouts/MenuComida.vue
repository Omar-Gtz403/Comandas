<template>
  <q-layout view="lHh Lpr lFf">
    <q-page-container class="bg-grey-1">
      <q-toolbar class="q-px-md q-py-sm">
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
import { useQuasar } from "quasar";
import axios from "axios";
import { useRouter } from "vue-router";
import { Notify } from 'quasar'

export default {
  setup() {
    const $q = useQuasar();
    const menu = ref([]);
    const carrito = ref([]);
    const dialogVisible = ref(false);
    const router = useRouter();
    const carritoAnimado = ref(false);

    const getMenu = async () => {
      try {
        const res = await axios.get("http://192.168.100.220:8082/api/productos");
        menu.value = res.data;
      } catch (err) {
        console.error("Error cargando productos:", err);
      }
    };
   /*const getMenu = async () => {
  menu.value = [
    {
      codigoBarras: "001",
      nombreProducto: "Tacos al Pastor",
      descripcion: "Tortilla de maíz, carne al pastor y piña.",
      precioVenta: 55,
      img: "https://www.entornoturistico.com/wp-content/uploads/2023/02/3-tacos-al-pastor-1280x720.jpeg"
    },
    {
      codigoBarras: "002",
      nombreProducto: "Pozole",
      descripcion: "Sopa tradicional de maíz con carne y condimentos.",
      precioVenta: 90,
      img: "https://nutritionstudies.org/wp-content/uploads/2023/10/red-posole-with-mushroom.jpg"
    },
    {
      codigoBarras: "003",
      nombreProducto: "Enchiladas Verdes",
      descripcion: "Tortillas rellenas bañadas en salsa verde.",
      precioVenta: 75,
      img: "https://i.ytimg.com/vi/E_qLMOf9lDs/sddefault.jpg"
    },
    {
      codigoBarras: "004",
      nombreProducto: "Guacamole",
      descripcion: "Aguacate, jitomate, cebolla y limón.",
      precioVenta: 60,
      img: "https://cdn.pixabay.com/photo/2016/03/05/19/02/guacamole-1238252_1280.jpg"
    }
  ];
};*/
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

     //   await axios.post("http://192.168.100.220:8082/api/ventas", venta);
       // await axios.post("http://localhost:8082/api/ventas", venta);

       Notify.create({
          type: "positive",
          message: "Pedido registrado exitosamente, se despachará después de su pago",
          position: "top",
        });


        // Navega a PagosComandas y pasa el total como query param
        router.push({ path: "/pagos", query: { total: totalCarrito.value } });

        carrito.value = [];
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
  border-radius: 12px
  transition: transform 0.25s ease, box-shadow 0.25s ease
  cursor: pointer
  &:hover
    transform: scale(1.05)
    box-shadow: 0 12px 25px rgba(0,0,0,0.2)

.my-card-img
  border-top-left-radius: 12px
  border-top-right-radius: 12px
  transition: transform 0.3s ease
  &:hover
    transform: scale(1.1)
</style>
