<template>
  <q-page class="q-pa-lg bg-gradient">
    <!-- TÍTULO -->
    <div class="text-center q-mb-xl">
      <h2 class="text-h4 text-bold">📊 Dashboard de Ventas</h2>
    </div>

    <!-- KPIs -->
    <q-row gutter="24" class="q-mb-lg">
      <q-col xs="12" sm="6" md="3" v-for="kpi in kpis" :key="kpi.label">
        <q-card class="glass-card q-pa-md">
          <div class="text-subtitle2 text-grey-7">{{ kpi.label }}</div>
          <div class="text-h5 text-bold q-mt-sm">{{ kpi.value }}</div>
        </q-card>
      </q-col>
    </q-row>

    <q-row gutter="24">
      <!-- Ventas diarias -->
      <q-col xs="12" md="6">
        <q-card class="glass-card">
          <q-card-section>
            <div class="text-h6 text-primary q-mb-md">
              <q-icon name="event" /> Ventas últimos 5 días
            </div>
            <BarChart :chart-data="datosDiarios" />
          </q-card-section>
        </q-card>
      </q-col>

      <!-- Ventas mensuales -->
      <q-col xs="12" md="6">
        <q-card class="glass-card">
          <q-card-section>
            <div class="text-h6 text-teal q-mb-md">
              <q-icon name="calendar_month" /> Ventas mensuales
            </div>
            <BarChart :chart-data="datosMensuales" />
          </q-card-section>
        </q-card>
      </q-col>

      <!-- Comparativa -->
      <q-col xs="12">
        <q-card class="glass-card">
          <q-card-section>
            <div class="text-h6 text-purple q-mb-md">
              <q-icon name="show_chart" /> Comparativa mensual vs promedio
            </div>
            <BarChart :chart-data="datosComparativa" />
          </q-card-section>
        </q-card>
      </q-col>

      <!-- Top platillos -->
      <q-col xs="12">
        <q-card class="glass-card">
          <q-card-section>
            <div class="row justify-between items-center q-mb-md">
              <div class="text-h6 text-blue">
                <q-icon name="restaurant_menu" /> Top platillos
              </div>
              <q-btn-toggle
                v-model="periodoPlatillos"
                :options="[
                  { label: 'Hoy', value: 'diario' },
                  { label: 'Mes', value: 'mensual' },
                  { label: 'Año', value: 'anual' },
                ]"
                color="primary"
                unelevated
                size="sm"
                @update:model-value="cargarPlatillos"
              />
            </div>
            <BarChart :chart-data="datosPlatillos" />
          </q-card-section>
        </q-card>
      </q-col>
    </q-row>
  </q-page>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { api } from "src/boot/axios";
import BarChart from "src/components/BarChart.vue";

/* ======================
   ESTADO
====================== */
const ventas = ref([]);
const kpis = ref([]);

const datosDiarios = ref({ labels: [], datasets: [] });
const datosMensuales = ref({ labels: [], datasets: [] });
const datosComparativa = ref({ labels: [], datasets: [] });
const datosPlatillos = ref({ labels: [], datasets: [] });

const periodoPlatillos = ref("mensual");

/* ======================
   HELPERS (HORA LOCAL 🔥)
====================== */
function normalizarFecha(fecha) {
  if (!fecha) return null;
  return new Date(fecha).toLocaleDateString("sv-SE"); // YYYY-MM-DD local
}

function normalizarMes(fecha) {
  if (!fecha) return null;
  return new Date(fecha).toLocaleDateString("sv-SE").slice(0, 7); // YYYY-MM
}

function moneda(valor) {
  return new Intl.NumberFormat("es-MX", {
    style: "currency",
    currency: "MXN",
  }).format(valor || 0);
}

/* ======================
   CARGA BASE
====================== */
async function cargarVentas() {
  const res = await api.get("/ventas");

  ventas.value = res.data
    .filter((v) => ![0, 5].includes(v.estatus))
    .map((v) => ({
      ...v,
      total: Number(v.total) || 0,
      fechaNorm: normalizarFecha(v.fecha),
      mesNorm: normalizarMes(v.fecha),
    }));
}

/* ======================
   KPIs
====================== */
function cargarKPIs() {
  const hoy = new Date().toLocaleDateString("sv-SE");
  const mes = hoy.slice(0, 7);

  const ventasHoy = ventas.value.filter((v) => v.fechaNorm === hoy);
  const ventasMes = ventas.value.filter((v) => v.mesNorm === mes);

  const totalHoy = ventasHoy.reduce((a, v) => a + v.total, 0);
  const totalMes = ventasMes.reduce((a, v) => a + v.total, 0);

  kpis.value = [
    { label: "Ventas Hoy", value: moneda(totalHoy) },
    { label: "Pedidos Hoy", value: ventasHoy.length },
    { label: "Ingresos del Mes", value: moneda(totalMes) },
    {
      label: "Ticket Promedio Hoy",
      value: moneda(ventasHoy.length ? totalHoy / ventasHoy.length : 0),
    },
  ];
}

/* ======================
   GRÁFICAS
====================== */
function cargarVentasDiarias() {
  const map = {};

  ventas.value.forEach((v) => {
    if (!v.fechaNorm) return;
    map[v.fechaNorm] = (map[v.fechaNorm] || 0) + v.total;
  });

  const labels = Object.keys(map).sort().slice(-5);

  datosDiarios.value = {
    labels,
    datasets: [
      {
        label: "Ventas",
        data: labels.map((l) => map[l]),
        backgroundColor: "#1976d2",
      },
    ],
  };
}

function cargarVentasMensuales() {
  const map = {};

  ventas.value.forEach((v) => {
    if (!v.mesNorm) return;
    map[v.mesNorm] = (map[v.mesNorm] || 0) + v.total;
  });

  const labels = Object.keys(map).sort();

  datosMensuales.value = {
    labels,
    datasets: [
      {
        label: "Ventas Mensuales",
        data: labels.map((l) => map[l]),
        backgroundColor: "#26a69a",
      },
    ],
  };
}

function cargarComparativa() {
  const data = datosMensuales.value.datasets[0]?.data || [];
  const promedio = data.length
    ? data.reduce((a, b) => a + b, 0) / data.length
    : 0;

  datosComparativa.value = {
    labels: datosMensuales.value.labels,
    datasets: [
      { label: "Mensual", data, backgroundColor: "#26a69a" },
      {
        label: "Promedio",
        data: data.map(() => promedio),
        backgroundColor: "#ab47bc",
      },
    ],
  };
}

/* ======================
   TOP PLATILLOS
====================== */
async function cargarPlatillos() {
  const hoy = new Date().toLocaleDateString("sv-SE");
  const mes = hoy.slice(0, 7);
  const anio = hoy.slice(0, 4);

  let filtradas = ventas.value;

  if (periodoPlatillos.value === "diario")
    filtradas = filtradas.filter((v) => v.fechaNorm === hoy);
  else if (periodoPlatillos.value === "mensual")
    filtradas = filtradas.filter((v) => v.mesNorm === mes);
  else filtradas = filtradas.filter((v) => v.fechaNorm?.startsWith(anio));

  const respuestas = await Promise.all(
    filtradas.map((v) => api.get(`/ventas/${v.id}/detalles`))
  );

  const contador = {};

  respuestas.forEach((r) => {
    r.data.forEach((d) => {
      contador[d.nombreProducto] =
        (contador[d.nombreProducto] || 0) + d.cantidad;
    });
  });

  const top = Object.entries(contador)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 10);

  datosPlatillos.value = {
    labels: top.map((t) => t[0]),
    datasets: [
      {
        label: "Platillos",
        data: top.map((t) => t[1]),
        backgroundColor: "#42a5f5",
      },
    ],
  };
}

/* ======================
   INIT
====================== */
onMounted(async () => {
  await cargarVentas();
  cargarKPIs();
  cargarVentasDiarias();
  cargarVentasMensuales();
  cargarComparativa();
  cargarPlatillos();
});
</script>

<style scoped>
.glass-card {
  background: rgba(255, 255, 255, 0.92);
  backdrop-filter: blur(10px);
  border-radius: 18px;
  box-shadow: 0 6px 16px rgba(62, 39, 35, 0.25);
}
</style>
