<template>
  <q-layout view="lHh Lpr lFf">
    <q-page-container>
      <q-page class="bg-grey-2 menu-page">
        <!-- 🏪 INFO SUCURSAL -->
        <q-card class="q-mx-md q-mt-md q-mb-sm bg-transparent">
          <div class="row items-center justify-between">
            <div>
              <div class="text-subtitle1 text-weight-bold text-primary">
                Marisquería Solo Veracruz Es Bello
              </div>
              <div class="text-caption text-grey-7">
                Sucursal Centro · Av. Hidalgo #123
              </div>
              <div class="text-caption">
                🕒 10:00 am – 9:00 pm ·
                <span class="text-positive text-weight-bold">Abierto</span>
              </div>
            </div>

            <q-chip color="primary" text-color="white" icon="restaurant">
              Consumo en local
            </q-chip>
          </div>
        </q-card>

        <!-- 🔥 STICKY CATEGORÍAS -->
        <div
          class="sticky-categorias row items-center no-wrap"
          :class="{ compact: stickyCompact }"
        >
          <q-btn
            v-show="$q.screen.gt.sm"
            flat
            round
            dense
            icon="chevron_left"
            @click="scrollCats(-220)"
          />

          <q-scroll-area
            ref="scrollCatsRef"
            horizontal
            class="scroll-categorias col"
          >
            <div class="row no-wrap items-center q-px-md">
              <q-chip
                v-for="cat in categoriasOrdenadas"
                :key="cat"
                :ref="(el) => (chipRefs[cat] = el)"
                clickable
                @click="scrollToCategoria(cat)"
                :class="['chip-cat', { active: categoriaActiva === cat }]"
              >
                {{ cat }}
              </q-chip>
            </div>
          </q-scroll-area>

          <q-btn
            v-show="$q.screen.gt.sm"
            flat
            round
            dense
            icon="chevron_right"
            @click="scrollCats(220)"
          />
        </div>

        <!-- ⏳ LOADING MENÚ -->
        <div v-if="loadingMenu" class="q-pa-xl flex flex-center">
          <q-spinner-dots size="50px" color="primary" />
        </div>

        <!-- 🍽️ CONTENIDO -->
        <div
          v-for="(productos, categoria) in productosPorCategoria"
          :key="categoria"
          :ref="(el) => (categoriaRefs[categoria] = el)"
          class="categoria-wrapper"
        >
          <div class="categoria-header">{{ categoria }}</div>

          <div class="row q-col-gutter-md justify-center">
            <div
              v-for="item in productos"
              :key="item.codigoBarras"
              class="col-xs-12 col-md-6"
            >
              <q-card flat bordered class="producto-card">
                <div class="row no-wrap items-center">
                  <q-img
                    :src="item.img || 'https://via.placeholder.com/120'"
                    class="producto-img"
                    ratio="1"
                  />

                  <div class="col q-pa-sm">
                    <div class="text-weight-bold">
                      {{ item.nombreProducto }}
                    </div>

                    <div class="text-caption text-grey-7 ellipsis-2-lines">
                      {{ item.descripcion }}
                    </div>

                    <div class="row items-center justify-between q-mt-xs">
                      <div class="text-primary text-weight-bold">
                        $ {{ item.precioVenta.toFixed(2) }}
                      </div>

                      <q-btn
                        dense
                        round
                        color="primary"
                        icon="add"
                        @click="agregarAlCarrito(item)"
                      />
                    </div>
                  </div>
                </div>
              </q-card>
            </div>
          </div>
        </div>

        <!-- 🛒 BOTÓN FLOTANTE -->
        <q-page-sticky position="bottom-right" :offset="[18, 18]">
          <q-btn
            fab
            icon="shopping_cart"
            color="primary"
            @click="dialogVisible = true"
          >
            <q-badge
              v-if="totalItems"
              color="red"
              floating
              :label="totalItems"
            />
          </q-btn>
        </q-page-sticky>

        <!-- 🛒 CARRITO -->
        <q-dialog v-model="dialogVisible" position="bottom">
          <q-card class="carrito-card">
            <q-inner-loading :showing="loadingConfirmar">
              <q-spinner size="50px" color="primary" />
            </q-inner-loading>

            <q-card-section
              class="row items-center justify-between carrito-header"
            >
              <div class="text-h6 text-weight-bold">Tu pedido</div>
              <q-btn flat round icon="close" v-close-popup />
            </q-card-section>

            <q-separator />

            <q-card-section class="carrito-body">
              <div
                v-if="!carrito.length"
                class="text-center text-grey-6 q-pa-lg"
              >
                🛒 Tu carrito está vacío
              </div>

              <q-card
                v-for="(item, i) in carrito"
                :key="i"
                flat
                bordered
                class="q-mb-sm carrito-item"
              >
                <div class="row no-wrap items-center">
                  <q-img
                    :src="item.img || 'https://via.placeholder.com/80'"
                    ratio="1"
                    class="carrito-img"
                  />

                  <div class="col q-pl-sm">
                    <div class="text-weight-bold">
                      {{ item.nombreProducto }}
                    </div>
                    <div class="text-caption text-grey-7">
                      ${{ item.precioVenta.toFixed(2) }} c/u
                    </div>

                    <div class="row items-center justify-between q-mt-xs">
                      <div class="cantidad-control">
                        <q-btn
                          dense
                          round
                          flat
                          icon="remove"
                          @click="reducirCantidad(i)"
                        />
                        <span class="q-mx-sm text-weight-bold">{{
                          item.cantidad
                        }}</span>
                        <q-btn
                          dense
                          round
                          flat
                          icon="add"
                          @click="incrementarCantidad(i)"
                        />
                      </div>

                      <div class="text-primary text-weight-bold">
                        ${{ (item.precioVenta * item.cantidad).toFixed(2) }}
                      </div>
                    </div>
                  </div>

                  <q-btn
                    flat
                    round
                    icon="delete"
                    color="negative"
                    @click="eliminarDelCarrito(i)"
                  />
                </div>
              </q-card>
            </q-card-section>

            <q-separator />

            <q-card-section class="carrito-footer">
              <div class="row items-center justify-between">
                <div>
                  <div class="text-caption text-grey-7">Total</div>
                  <div class="text-h6 text-weight-bold">
                    ${{ totalCarrito.toFixed(2) }}
                  </div>
                </div>

                <q-btn
                  color="primary"
                  label="Confirmar pedido"
                  icon="check_circle"
                  unelevated
                  :loading="loadingConfirmar"
                  :disable="!carrito.length || loadingConfirmar"
                  @click="confirmarPedido"
                />
              </div>
            </q-card-section>
          </q-card>
        </q-dialog>
      </q-page>
    </q-page-container>
  </q-layout>
</template>

<script setup>
import { ref, computed, onMounted, watch, nextTick } from "vue";
import { Notify, useQuasar } from "quasar";
import { api } from "src/boot/axios";
import { useRouter } from "vue-router";

const router = useRouter();
const $q = useQuasar();
const loadingMenu = ref(false);
const loadingConfirmar = ref(false);
const menu = ref([]);
const carrito = ref(JSON.parse(localStorage.getItem("carrito")) || []);
const dialogVisible = ref(false);

const visiblesPorCategoria = ref({});
const categoriaRefs = ref({});
const categoriaActiva = ref("");
const scrollCatsRef = ref(null);
const chipRefs = ref({});
const stickyCompact = ref(false);

let observer;
let scrollingByClick = false;

/* Persistencia */
watch(carrito, (v) => localStorage.setItem("carrito", JSON.stringify(v)), {
  deep: true,
});

/* Scroll sticky animado */
const onScroll = () => {
  stickyCompact.value = window.scrollY > 80;
};

/* Centrar chip activo */
const centrarChipActivo = async (cat) => {
  await nextTick();
  const chip = chipRefs.value[cat];
  if (!chip || !scrollCatsRef.value) return;

  const chipEl = chip.$el || chip;
  const container = scrollCatsRef.value.$el.querySelector(
    ".q-scrollarea__container"
  );

  const chipRect = chipEl.getBoundingClientRect();
  const contRect = container.getBoundingClientRect();

  const offset =
    chipRect.left - contRect.left - contRect.width / 2 + chipRect.width / 2;

  scrollCatsRef.value.setScrollPosition(
    "horizontal",
    scrollCatsRef.value.getScrollPosition().left + offset,
    300
  );
};

/* API */
const getMenu = async () => {
  try {
    loadingMenu.value = true;
    const res = await api.get("/productos");
    menu.value = res.data;
    await nextTick();
    initObserver();
  } finally {
    loadingMenu.value = false;
  }
};

/* Computed */
const productosPorCategoria = computed(() => {
  const g = {};
  menu.value
    .filter((p) => p.activo && p.categoria?.activo && p.categoria.id !== 5)
    .sort((a, b) => a.categoria.orden - b.categoria.orden)
    .forEach((p) => {
      const c = p.categoria.nombre;
      if (!g[c]) g[c] = [];
      g[c].push(p);
    });
  return g;
});

const categoriasOrdenadas = computed(() =>
  Object.keys(productosPorCategoria.value)
);

const totalItems = computed(() =>
  carrito.value.reduce((a, i) => a + i.cantidad, 0)
);
const totalCarrito = computed(() =>
  carrito.value.reduce((t, i) => t + i.precioVenta * i.cantidad, 0)
);

/* Métodos */
const agregarAlCarrito = (item) => {
  const i = carrito.value.findIndex(
    (p) => p.codigoBarras === item.codigoBarras
  );
  i !== -1
    ? carrito.value[i].cantidad++
    : carrito.value.push({ ...item, cantidad: 1 });
  Notify.create({ type: "positive", message: "Agregado al carrito" });
};

const eliminarDelCarrito = (i) => carrito.value.splice(i, 1);
const incrementarCantidad = (i) => carrito.value[i].cantidad++;
const reducirCantidad = (i) =>
  carrito.value[i].cantidad > 1
    ? carrito.value[i].cantidad--
    : eliminarDelCarrito(i);

const confirmarPedido = async () => {
  try {
    loadingConfirmar.value = true;

    const venta = {
      total: totalCarrito.value,
      status: 0,
      detalles: carrito.value.map((i) => ({
        codigoBarras: i.codigoBarras,
        cantidad: i.cantidad,
        precioUnitario: i.precioVenta,
      })),
    };

    const res = await api.post("/ventas", venta);

    carrito.value = [];
    dialogVisible.value = false;

    $q.notify({ type: "positive", message: "Pedido registrado" });

    router.push({
      path: "/pagos",
      query: { folio: res.data.folio, total: venta.total },
    });
  } catch (err) {
    $q.notify({
      type: "negative",
      message: "Error al registrar el pedido",
    });
  } finally {
    loadingConfirmar.value = false;
  }
};

/* Sticky categorías */
const scrollToCategoria = (cat) => {
  scrollingByClick = true;
  categoriaActiva.value = cat;
  centrarChipActivo(cat);

  categoriaRefs.value[cat]?.scrollIntoView({
    behavior: "smooth",
    block: "start",
  });
  setTimeout(() => (scrollingByClick = false), 700);
};

const scrollCats = (amount) => {
  const pos = scrollCatsRef.value.getScrollPosition().left;
  scrollCatsRef.value.setScrollPosition("horizontal", pos + amount, 300);
};

const initObserver = () => {
  observer = new IntersectionObserver(
    (entries) => {
      if (scrollingByClick) return;
      entries.forEach((e) => {
        if (e.isIntersecting) {
          const cat = Object.keys(categoriaRefs.value).find(
            (k) => categoriaRefs.value[k] === e.target
          );
          if (cat) {
            categoriaActiva.value = cat;
            centrarChipActivo(cat);
          }
        }
      });
    },
    { rootMargin: "-120px 0px -60% 0px", threshold: 0.1 }
  );

  Object.values(categoriaRefs.value).forEach((el) => observer.observe(el));
};

onMounted(() => {
  window.addEventListener("scroll", onScroll);
  getMenu();
});
</script>

<style scoped lang="sass">
.menu-page
  padding-top: 1px

@media (max-width: 599px)
  .menu-page
    padding-top: 0

.sticky-categorias
  position: sticky
  top: 56px
  height: 56px
  z-index: 100
  display: flex
  align-items: center
  transition: all .25s ease
  border-bottom: 1px solid rgba(0,0,0,.08)

.sticky-categorias.compact
  height: 48px
  box-shadow: 0 6px 18px rgba(0,0,0,.12)
  backdrop-filter: blur(8px)

.scroll-categorias
  height: 56px
  overflow: hidden

.chip-cat
  font-weight: 700
  border-radius: 999px
  padding: 0 16px
  height: 38px
  background: #f1f1f1
  transition: all .25s ease

.chip-cat.active
  background: var(--q-primary)
  color: white
  box-shadow: 0 4px 10px rgba(0,0,0,.25)

.categoria-wrapper
  margin-bottom: 24px
  scroll-margin-top: 120px


.categoria-header
  margin: 16px
  padding: 12px
  font-size: 1.35rem
  font-weight: 800
  color: white
  text-align: center
  border-radius: 14px
  background: var(--q-primary)


.producto-card
  border-radius: 14px
  background: white
  transition: transform .2s ease, box-shadow .2s ease

.producto-card:hover
  transform: translateY(-2px)
  box-shadow: 0 6px 16px rgba(0,0,0,.12)

.producto-img
  width: 110px
  min-width: 110px
  border-radius: 14px 0 0 14px
.scroll-categorias :deep(.q-scrollarea__bar),
.scroll-categorias :deep(.q-scrollarea__thumb)
  display: none !important

.carrito-card
  border-radius: 20px 20px 0 0
  max-height: 85vh
  display: flex
  flex-direction: column


.carrito-header
  background: var(--q-primary)
  color: white

.carrito-body
  overflow-y: auto
  padding-bottom: 8px

.carrito-item
  border-radius: 14px
  background: white

.carrito-img
  width: 80px
  min-width: 80px
  border-radius: 12px

.cantidad-control
  display: flex
  align-items: center
  border-radius: 999px
  background: #f3f3f3
  padding: 2px 6px

.carrito-footer
  background: white
  box-shadow: 0 -6px 16px rgba(0,0,0,.12)
</style>
