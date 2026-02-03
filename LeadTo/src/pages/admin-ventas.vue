<template>
  <q-page class="q-pa-md page-background relative-position">
    <!-- 🔄 CARGA SOLO INICIAL -->
    <q-inner-loading :showing="loading" class="z-top">
      <q-spinner-cube size="60px" color="primary" />
      <div class="q-mt-md text-primary text-weight-bold">
        Cargando pedidos...
      </div>
    </q-inner-loading>

    <!-- 🟦 HEADER -->
    <div class="header-card q-pa-md q-mb-xl text-white">
      <div class="row items-center justify-between">
        <div class="row items-center q-gutter-md">
          <div class="bg-white q-pa-sm rounded-borders">
            <q-icon name="restaurant_menu" size="32px" color="primary" />
          </div>

          <div>
            <div class="text-h5 text-weight-bold">Tablero de Pedidos</div>
            <div class="text-caption text-grey-3">Gestión en tiempo real</div>
          </div>
        </div>

        <q-btn
          flat
          round
          class="bg-white text-primary"
          icon="refresh"
          :loading="manualLoading"
          @click="recargaManual"
        >
          <q-tooltip>Recargar Datos</q-tooltip>
        </q-btn>
      </div>
    </div>

    <!-- 📊 KPIS -->
    <!-- Movemos los KPIs un poco hacia arriba para que se superpongan al header (efecto dashboard) -->
    <div class="row q-col-gutter-md q-mb-lg" style="margin-top: -40px">
      <div
        v-for="kpi in kpis"
        :key="kpi.label"
        class="col-12 col-sm-6 col-md-4 col-lg-2"
      >
        <q-card class="kpi-card q-pa-md">
          <div class="row items-center no-wrap">
            <div class="col">
              <div
                class="text-caption text-grey-7 text-uppercase letter-spacing-1"
              >
                {{ kpi.label }}
              </div>
              <div class="text-h5 text-weight-bolder q-mt-xs text-dark">
                {{ kpi.value }}
              </div>
            </div>

            <div
              class="kpi-icon-wrapper shadow-2"
              :class="`bg-${kpi.color}-1 text-${kpi.color}`"
            >
              <q-icon :name="kpi.icon" size="24px" />
            </div>
          </div>
        </q-card>
      </div>
    </div>

    <!-- 🧭 FILTROS -->
    <q-card class="filters-card q-pa-sm q-mb-lg">
      <div class="row items-center justify-between q-col-gutter-sm">
        <div class="col-12 col-md-auto">
          <q-tabs
            v-model="estadoFiltro"
            dense
            active-color="primary"
            indicator-color="primary"
            class="text-grey-7"
            align="left"
            mobile-arrows
          >
            <q-tab name="TODOS" label="Todos" />
            <q-tab name="ACTIVOS" label="Activos" />
            <q-tab name="PREPARANDO" label="Preparando" />
            <q-tab name="LISTO" label="Listos" />
            <q-tab name="ENTREGADO" label="Entregados" />
            <q-tab name="CANCELADO" label="Cancelados" />
          </q-tabs>
        </div>

        <div class="col-12 col-md row justify-end q-gutter-sm items-center">
          <q-input
            v-model="busqueda"
            dense
            outlined
            rounded
            debounce="300"
            placeholder="Buscar..."
            class="search-input col-12 col-sm-6"
            bg-color="grey-1"
          >
            <template #prepend>
              <q-icon name="search" class="text-grey" />
            </template>
            <template #append v-if="busqueda">
              <q-icon
                name="close"
                class="cursor-pointer"
                @click="busqueda = ''"
              />
            </template>
          </q-input>

          <q-btn
            flat
            round
            color="grey-7"
            icon="filter_alt_off"
            @click="limpiarFiltros"
          >
            <q-tooltip>Limpiar Filtros</q-tooltip>
          </q-btn>
        </div>
      </div>
    </q-card>

    <!-- 📦 PEDIDOS -->
    <transition-group
      appear
      enter-active-class="animated fadeIn"
      leave-active-class="animated fadeOut"
      tag="div"
      class="row q-col-gutter-md"
    >
      <div
        v-for="pedido in pedidosFiltrados"
        :key="pedido.folio"
        class="col-12 col-sm-6 col-md-4 col-lg-3"
      >
        <q-card
          class="pedido-card full-height column"
          :class="getBorderClass(pedido.status)"
        >
          <!-- Encabezado Tarjeta -->
          <div class="pedido-header row justify-between items-start">
            <div>
              <div class="text-h6 text-weight-bold text-dark">
                #{{ pedido.folio }}
              </div>
              <div class="text-caption text-grey-6">
                {{ formatFecha(pedido.fecha) }}
              </div>
            </div>
            <q-badge
              :color="getColor(pedido.status)"
              rounded
              class="q-py-xs q-px-sm"
            >
              {{ getLabel(pedido.status) }}
            </q-badge>
          </div>

          <!-- Divisor Ticket -->
          <div class="ticket-divider"></div>

          <!-- Lista de Items -->
          <q-card-section class="q-py-sm col scroll" style="max-height: 200px">
            <div
              v-for="(d, i) in pedido.detalles"
              :key="i"
              class="row no-wrap items-center q-mb-sm"
            >
              <div
                class="text-weight-bold q-mr-sm bg-grey-2 rounded-edges row flex-center"
                style="width: 24px; height: 24px; font-size: 12px"
              >
                {{ d.cantidad }}
              </div>
              <div
                class="text-body2 text-grey-9 text-weight-medium line-height-tight col"
              >
                {{ d.nombreProducto }}
              </div>
            </div>
          </q-card-section>

          <!-- Footer Total y Acciones -->
          <div class="q-pa-md mt-auto">
            <div class="row items-center justify-between q-mb-md">
              <div class="text-grey-7 is-size-7">Total</div>
              <div class="text-h5 text-primary text-weight-bolder">
                ${{ pedido.total.toFixed(2) }}
              </div>
            </div>

            <div class="row q-gutter-sm">
              <!-- Botón Principal Condicional -->
              <q-btn
                v-if="pedido.status === 1"
                class="col shadow-2"
                label="Preparar"
                color="warning"
                text-color="dark"
                icon="soup_kitchen"
                :disable="actualizando.has(pedido.folio)"
                rounded
                @click.stop="cambiarStatus(pedido, 2)"
              />
              <q-btn
                v-if="pedido.status === 2"
                class="col shadow-2"
                label="Listo"
                color="accent"
                icon="done_all"
                :disable="actualizando.has(pedido.folio)"
                rounded
                @click.stop="cambiarStatus(pedido, 3)"
              />
              <q-btn
                v-if="pedido.status === 3"
                class="col shadow-2"
                label="Entregar"
                color="positive"
                icon="local_shipping"
                :disable="actualizando.has(pedido.folio)"
                rounded
                @click.stop="cambiarStatus(pedido, 4)"
              />
            </div>
          </div>
        </q-card>
      </div>
    </transition-group>
  </q-page>
</template>

<script setup>
import {
  ref,
  computed,
  onMounted,
  onBeforeUnmount,
  getCurrentInstance,
} from "vue";
import { api } from "src/boot/axios";

const { proxy } = getCurrentInstance();

/* ================== STATE ================== */
const ventas = ref([]);
const loading = ref(true);
const manualLoading = ref(false);

/* 🔥 ahora es por pedido */
const actualizando = ref(new Set());

const estadoFiltro = ref("ACTIVOS");
const busqueda = ref("");

let intervalId;

/* ================== FILTROS ================== */
const filtrosEstado = {
  TODOS: null,
  ACTIVOS: new Set([1, 2, 3]),
  PREPARANDO: new Set([2]),
  LISTO: new Set([3]),
  ENTREGADO: new Set([4]),
  CANCELADO: new Set([5]),
};

const pedidosFiltrados = computed(() => {
  const filtro = filtrosEstado[estadoFiltro.value];
  const texto = busqueda.value.toLowerCase();

  return ventas.value.filter((p) => {
    if (filtro && !filtro.has(p.status)) return false;
    if (
      texto &&
      !String(p.folio).includes(texto) &&
      !p.detalles.some((d) => d.nombreProducto.toLowerCase().includes(texto))
    )
      return false;
    return true;
  });
});

/* ================== KPIS ================== */
const kpis = computed(() => [
  {
    label: "Total",
    value: ventas.value.length,
    icon: "receipt",
    color: "primary",
  },
  {
    label: "Preparando",
    value: ventas.value.filter((v) => v.status === 2).length,
    icon: "local_fire_department",
    color: "warning",
  },
  {
    label: "Listos",
    value: ventas.value.filter((v) => v.status === 3).length,
    icon: "done",
    color: "accent",
  },
  {
    label: "Entregados",
    value: ventas.value.filter((v) => v.status === 4).length,
    icon: "check_circle",
    color: "positive",
  },
  {
    label: "Cancelados",
    value: ventas.value.filter((v) => v.status === 5).length,
    icon: "cancel",
    color: "negative",
  },
]);

/* ================== HELPERS ================== */
function getColor(s) {
  return ["grey", "secondary", "warning", "accent", "positive", "negative"][s];
}

function getBorderClass(s) {
  return [
    "border-grey-6",
    "border-secondary",
    "border-warning",
    "border-accent",
    "border-positive",
    "border-negative",
  ][s];
}

function getLabel(s) {
  return [
    "Esperando pago",
    "Pago confirmado",
    "Preparando",
    "Listo",
    "Entregado",
    "Cancelado",
  ][s];
}

function formatFecha(f) {
  return new Date(f).toLocaleString("es-MX");
}

/* ================== DATA ================== */
async function getVentas({ silent = false } = {}) {
  if (!silent) loading.value = true;

  try {
    const res = await api.get("/ventas");
    ventas.value = res.data;
  } catch {
    if (!silent) {
      proxy.$q.notify({
        type: "negative",
        message: "Error al cargar pedidos",
      });
    }
  } finally {
    if (!silent) loading.value = false;
  }
}

async function recargaManual() {
  manualLoading.value = true;
  await getVentas({ silent: true });
  manualLoading.value = false;
}

/* ================== STATUS (OPTIMIZADO) ================== */
async function cambiarStatus(pedido, status) {
  if (actualizando.value.has(pedido.folio)) return;

  actualizando.value.add(pedido.folio);

  const anterior = pedido.status;
  pedido.status = status; // ⚡ UI inmediata

  try {
    await api.put(`/ventas/folio/${pedido.folio}/status`, { status });
    // ❌ NO recargar toda la lista aquí
  } catch {
    pedido.status = anterior;
    proxy.$q.notify({
      type: "negative",
      message: "Error al actualizar pedido",
    });
  } finally {
    actualizando.value.delete(pedido.folio);
  }
}

/* ================== FILTROS ================== */
function limpiarFiltros() {
  estadoFiltro.value = "ACTIVOS";
  busqueda.value = "";
}

/* ================== AUTO REFRESH ================== */
onMounted(async () => {
  await getVentas();

  intervalId = setInterval(() => {
    if (actualizando.value.size === 0) {
      getVentas({ silent: true });
    }
  }, 5000);
});

onBeforeUnmount(() => {
  clearInterval(intervalId);
});
</script>

<style scoped>
/* 🎨 ESTILOS PREMIUM */
.page-background {
  background-color: #f8f9fa;
  min-height: 100vh;
}

/* Header con Gradiente */
.header-card {
  border-radius: 20px;
  background: linear-gradient(135deg, #c62828 0%, #b71c1c 100%);
  box-shadow: 0 8px 20px rgba(198, 40, 40, 0.3);
  overflow: hidden;
  position: relative;
}

.header-card::before {
  content: "";
  position: absolute;
  top: -50%;
  left: -50%;
  width: 200%;
  height: 200%;
  background: radial-gradient(
    circle,
    rgba(255, 255, 255, 0.1) 0%,
    transparent 60%
  );
  transform: rotate(30deg);
  pointer-events: none;
}

/* KPI Cards */
.kpi-card {
  border-radius: 16px;
  border: none;
  background: white;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
  height: 100%;
}

.kpi-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 12px 24px rgba(0, 0, 0, 0.1);
}

.kpi-icon-wrapper {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* Filtros */
.filters-card {
  border-radius: 20px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
}

.search-input {
  transition: all 0.3s ease;
}

.search-input:focus-within {
  transform: scale(1.01);
}

/* Pedido Cards (Ticket Look) */
.pedido-container {
  perspective: 1000px;
}

.pedido-card {
  border-radius: 16px;
  border: none;
  background: white;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08); /* Sombra suave y difusa */
  transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
  display: flex;
  flex-direction: column;
  height: 100%;
  position: relative;
  overflow: hidden;
}

.pedido-card:hover {
  transform: translateY(-8px) scale(1.02);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.12);
  z-index: 10;
}

.pedido-header {
  padding: 16px;
  position: relative;
}

.ticket-divider {
  height: 2px;
  background-image: linear-gradient(to right, #e0e0e0 50%, transparent 50%);
  background-size: 10px 100%;
  margin: 10px 0;
}

/* Estados de Pedido - Bordes y Acentos */
.border-grey-6 {
  border-left: 5px solid #757575;
}
.border-secondary {
  border-left: 5px solid #0277bd;
}
.border-warning {
  border-left: 5px solid #f9a825;
}
.border-accent {
  border-left: 5px solid #26a69a;
}
.border-positive {
  border-left: 5px solid #2e7d32;
}
.border-negative {
  border-left: 5px solid #b71c1c;
}

/* Transiciones de lista */
.list-enter-active,
.list-leave-active {
  transition: all 0.4s ease;
}
.list-enter-from,
.list-leave-to {
  opacity: 0;
  transform: translateY(20px);
}
</style>
