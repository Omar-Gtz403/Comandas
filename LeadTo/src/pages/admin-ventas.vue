<template>
  <q-page class="q-pa-lg bg-grey-2">
    <!-- 🔄 CARGA -->
    <q-inner-loading :showing="loading">
      <q-spinner-cube size="60px" color="primary" />
      <div class="q-mt-md text-primary text-weight-bold">
        Cargando pedidos...
      </div>
    </q-inner-loading>

    <!-- 🟦 HEADER -->
    <q-card class="q-pa-md q-mb-lg bg-primary text-white">
      <div class="row items-center justify-between">
        <div class="row items-center">
          <q-icon name="restaurant" size="36px" />
          <div class="text-h5 text-weight-bold q-ml-sm">
            Administración de Pedidos
          </div>
        </div>

        <q-btn flat icon="refresh" label="Recargar" @click="getVentas" />
      </div>
    </q-card>

    <!-- 📊 KPIS -->
    <div class="row q-col-gutter-md q-mb-lg">
      <q-card v-for="kpi in kpis" :key="kpi.label" class="col bg-white q-pa-md">
        <div class="row items-center justify-between">
          <div>
            <div class="text-subtitle2 text-grey-7">{{ kpi.label }}</div>
            <div class="text-h5 text-weight-bold">{{ kpi.value }}</div>
          </div>
          <q-icon :name="kpi.icon" size="32px" :color="kpi.color" />
        </div>
      </q-card>
    </div>

    <!-- 🧭 FILTROS -->
    <q-card class="q-pa-md q-mb-md">
      <q-tabs
        v-model="estadoFiltro"
        dense
        align="justify"
        active-color="primary"
        indicator-color="primary"
      >
        <q-tab name="TODOS" label="Todos" />
        <q-tab name="ACTIVOS" label="Activos" />
        <q-tab name="PREPARANDO" label="Preparando" />
        <q-tab name="LISTO" label="Listos" />
        <q-tab name="ENTREGADO" label="Entregados" />
        <q-tab name="CANCELADO" label="Cancelados" />
      </q-tabs>

      <div class="row q-col-gutter-md q-mt-md">
        <q-input
          v-model="busqueda"
          dense
          outlined
          debounce="300"
          placeholder="Buscar por folio o producto"
          class="col"
          clearable
        >
          <template #prepend>
            <q-icon name="search" />
          </template>
        </q-input>

        <q-btn
          outline
          icon="filter_alt_off"
          label="Limpiar filtros"
          @click="limpiarFiltros"
        />
      </div>
    </q-card>

    <!-- 📦 PEDIDOS -->
    <div class="row q-col-gutter-md">
      <div
        v-for="pedido in pedidosFiltrados"
        :key="pedido.folio"
        class="col-xs-12 col-sm-6 col-md-4 col-lg-3"
      >
        <q-card
          class="cartelera-card cursor-pointer"
          @click="abrirDetalle(pedido)"
        >
          <q-card-section
            class="text-white text-center"
            :class="getHeaderClass(pedido.status)"
          >
            <div class="text-h6">Pedido #{{ pedido.folio }}</div>
            <div class="text-caption">{{ formatFecha(pedido.fecha) }}</div>
          </q-card-section>

          <q-card-section class="bg-white">
            <div v-for="(d, i) in pedido.detalles" :key="i" class="text-body2">
              🍴 {{ d.cantidad }} x {{ d.nombreProducto }}
            </div>
          </q-card-section>

          <q-separator />

          <q-card-section class="text-center">
            <div class="text-h6 text-weight-bold">
              ${{ pedido.total.toFixed(2) }}
            </div>

            <q-chip
              :color="getColor(pedido.status)"
              text-color="white"
              dense
              class="q-mt-sm"
            >
              {{ getLabel(pedido.status) }}
            </q-chip>

            <div class="row justify-center q-gutter-sm q-mt-sm">
              <q-btn
                v-if="pedido.status === 1"
                label="Preparar"
                color="warning"
                dense
                @click.stop="cambiarStatus(pedido, 2)"
              />
              <q-btn
                v-if="pedido.status === 2"
                label="Listo"
                color="accent"
                dense
                @click.stop="cambiarStatus(pedido, 3)"
              />
              <q-btn
                v-if="pedido.status === 3"
                label="Entregar"
                color="positive"
                dense
                @click.stop="cambiarStatus(pedido, 4)"
              />
            </div>
          </q-card-section>
        </q-card>
      </div>
    </div>

    <!-- 📌 DETALLE -->
    <q-dialog v-model="dialogoDetalle">
      <q-card class="detalle-pedido-card">
        <q-card-section
          class="text-white text-center"
          :class="getHeaderClass(pedidoSeleccionado?.status)"
        >
          <div class="text-h6">Pedido #{{ pedidoSeleccionado?.folio }}</div>
        </q-card-section>

        <q-card-section>
          <q-list bordered separator>
            <q-item v-for="(d, i) in pedidoSeleccionado?.detalles" :key="i">
              <q-item-section>
                {{ d.cantidad }} x {{ d.nombreProducto }}
              </q-item-section>
            </q-item>
          </q-list>
        </q-card-section>

        <q-card-actions align="right">
          <q-btn flat label="Cerrar" color="primary" v-close-popup />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup>
import { ref, computed, onMounted, getCurrentInstance } from "vue";
import { api } from "src/boot/axios";

const { proxy } = getCurrentInstance();

const ventas = ref([]);
const loading = ref(false);
const estadoFiltro = ref("ACTIVOS");
const busqueda = ref("");
const pedidoSeleccionado = ref(null);
const dialogoDetalle = ref(false);

/* 🔥 MAPA DE FILTROS */
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

  const resultado = [];

  for (const p of ventas.value) {
    if (filtro && !filtro.has(p.status)) continue;

    if (
      texto &&
      !String(p.folio).includes(texto) &&
      !p.detalles.some((d) => d.nombreProducto.toLowerCase().includes(texto))
    )
      continue;

    resultado.push(p);
  }

  return resultado;
});

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

function limpiarFiltros() {
  estadoFiltro.value = "ACTIVOS";
  busqueda.value = "";
}

function abrirDetalle(p) {
  pedidoSeleccionado.value = p;
  dialogoDetalle.value = true;
}

function getColor(s) {
  return ["grey", "secondary", "warning", "accent", "positive", "negative"][s];
}

function getHeaderClass(s) {
  return [
    "bg-grey-6",
    "bg-secondary",
    "bg-warning",
    "bg-accent",
    "bg-positive",
    "bg-negative",
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

async function getVentas() {
  loading.value = true;
  try {
    const res = await api.get("/ventas");
    ventas.value = res.data;
  } catch {
    proxy.$q.notify({ type: "negative", message: "Error al cargar pedidos" });
  } finally {
    loading.value = false;
  }
}

async function cambiarStatus(pedido, status) {
  await api.put(`/ventas/folio/${pedido.folio}/status`, { status });
  pedido.status = status;
  proxy.$q.notify({ type: "positive", message: "Pedido actualizado" });
}

onMounted(() => {
  getVentas();
  setInterval(getVentas, 5000);
});
</script>

<style scoped>
.cartelera-card {
  border-radius: 16px;
  box-shadow: 0 6px 18px rgba(2, 119, 189, 0.15);
}
.detalle-pedido-card {
  width: 90vw;
  max-width: 420px;
  border-radius: 16px;
}
</style>
