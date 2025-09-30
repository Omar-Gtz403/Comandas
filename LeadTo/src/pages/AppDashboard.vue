<template>
  <q-page class="q-pa-lg bg-gradient">
    <!-- Título -->
    <div class="text-center q-mb-xl">
      <h2 class="text-h4 text-black text-bold">📊 Dashboard de Ventas</h2>
    </div>

    <!-- KPIs rápidos -->
    <q-row gutter="24" class="q-mb-lg">
      <q-col xs="12" sm="6" md="3" v-for="kpi in kpis" :key="kpi.label">
        <q-card class="glass-card q-pa-md">
          <div class="text-subtitle2 text-grey-7">{{ kpi.label }}</div>
          <div class="text-h5 text-bold q-mt-sm">{{ kpi.value }}</div>
          <q-badge
            v-if="kpi.trend !== null"
            :color="kpi.trend > 0 ? 'green' : 'red'"
            align="top"
            class="q-mt-sm"
          >
            {{ kpi.trend > 0 ? "▲" : "▼" }} {{ Math.abs(kpi.trend) }}%
          </q-badge>
        </q-card>
      </q-col>
    </q-row>

    <q-row gutter="24">
      <!-- Ventas Diarias -->
      <q-col xs="12" md="6">
        <q-card class="glass-card">
          <q-card-section>
            <div class="row items-center justify-between q-mb-md">
              <div class="text-h6 text-primary flex items-center">
                <q-icon name="event" class="q-mr-sm" color="primary" />
                Ventas Diarias
              </div>
              <q-badge color="primary" align="top">Últimos 5 días</q-badge>
            </div>
            <BarChart :chart-data="datosDiarios" />
          </q-card-section>
        </q-card>
      </q-col>

      <!-- Ventas Mensuales -->
      <q-col xs="12" md="6">
        <q-card class="glass-card">
          <q-card-section>
            <div class="row items-center justify-between q-mb-md">
              <div class="text-h6 text-teal flex items-center">
                <q-icon name="calendar_month" class="q-mr-sm" color="teal" />
                Ventas Mensuales
              </div>
              <q-badge color="teal" align="top">Este Año</q-badge>
            </div>
            <BarChart :chart-data="datosMensuales" />
          </q-card-section>
        </q-card>
      </q-col>

      <!-- Comparativa Mensual vs Promedio Anual -->
      <q-col xs="12" md="12">
        <q-card class="glass-card">
          <q-card-section>
            <div class="row items-center justify-between q-mb-md">
              <div class="text-h6 text-purple flex items-center">
                <q-icon name="show_chart" class="q-mr-sm" color="purple" />
                Comparativa Ventas Mensuales vs Promedio Anual
              </div>
            </div>
            <BarChart :chart-data="datosComparativa" />
          </q-card-section>
        </q-card>
      </q-col>

      <!-- Top 10 Platillos -->
      <q-col xs="12" md="12">
        <q-card class="glass-card">
          <q-card-section>
            <div class="row items-center justify-between q-mb-md">
              <div class="text-h6 text-blue flex items-center">
                <q-icon name="restaurant_menu" class="q-mr-sm" color="blue" />
                Top 10 Platillos Más Vendidos
              </div>
              <q-btn-toggle
                v-model="periodoPlatillos"
                :options="[
                  { label: 'Diario', value: 'diario' },
                  { label: 'Mensual', value: 'mensual' },
                  { label: 'Anual', value: 'anual' },
                ]"
                color="primary"
                glossy
                unelevated
                size="sm"
                toggle-color="blue-6"
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
import BarChart from "src/components/BarChart.vue";
import { api } from "src/boot/axios";

const datosDiarios = ref({ labels: [], datasets: [] });
const datosMensuales = ref({ labels: [], datasets: [] });
const datosAnuales = ref({ labels: [], datasets: [] });
const datosComparativa = ref({ labels: [], datasets: [] });
const datosPlatillos = ref({ labels: [], datasets: [] });
const periodoPlatillos = ref("mensual");

const kpis = ref([
  { label: "Total Ventas Hoy", value: "$0", trend: null },
  { label: "Pedidos Hoy", value: "0", trend: null },
  { label: "Ingresos del Mes", value: "$0", trend: null },
]);

// ---------------- KPIs ----------------
async function cargarKPIs() {
  const res = await api.get("/ventas");
  const ventas = res.data;

  const hoy = new Date().toISOString().slice(0, 10);
  const mesActual = new Date().toISOString().slice(0, 7);

  // Ventas de hoy
  const ventasHoy = ventas.filter(
    (v) => ![0, 5].includes(v.estatus) && v.fecha?.slice(0, 10) === hoy
  );

  // Ventas del mes
  const ventasMes = ventas.filter(
    (v) => ![0, 5].includes(v.estatus) && v.fecha?.slice(0, 7) === mesActual
  );

  kpis.value[0].value = formatearMoneda(
    ventasHoy.reduce((acc, v) => acc + v.total, 0)
  );
  kpis.value[1].value = ventasHoy.length.toString();
  kpis.value[2].value = formatearMoneda(
    ventasMes.reduce((acc, v) => acc + v.total, 0)
  );
}

// ---------------- Gráficas ----------------
async function cargarVentasDiarias() {
  const res = await api.get("/ventas");
  const ventas = res.data;

  const agrupado = {};
  ventas.forEach((v) => {
    if ([0, 5].includes(v.estatus)) return;
    const fecha = v.fecha?.slice(0, 10) || "Sin fecha";
    agrupado[fecha] = (agrupado[fecha] || 0) + v.total;
  });

  const labels = Object.keys(agrupado).slice(-5);
  const data = Object.values(agrupado).slice(-5);

  datosDiarios.value = {
    labels,
    datasets: [{ label: "Ventas ($)", data, backgroundColor: "#1976d2" }],
  };
}

async function cargarVentasMensuales() {
  const res = await api.get("/ventas");
  const ventas = res.data;

  const agrupado = {};
  ventas.forEach((v) => {
    if ([0, 5].includes(v.estatus)) return;
    const mes = v.fecha?.slice(0, 7) || "Desconocido";
    agrupado[mes] = (agrupado[mes] || 0) + v.total;
  });

  datosMensuales.value = {
    labels: Object.keys(agrupado),
    datasets: [
      {
        label: "Ventas Mensuales ($)",
        data: Object.values(agrupado),
        backgroundColor: "#26a69a",
      },
    ],
  };
}

async function cargarVentasAnuales() {
  const res = await api.get("/ventas");
  const ventas = res.data;

  const agrupado = {};
  ventas.forEach((v) => {
    if ([0, 5].includes(v.estatus)) return;
    const anio = v.fecha?.slice(0, 4) || "Sin año";
    agrupado[anio] = (agrupado[anio] || 0) + v.total;
  });

  datosAnuales.value = {
    labels: Object.keys(agrupado),
    datasets: [
      {
        label: "Ventas Anuales ($)",
        data: Object.values(agrupado),
        backgroundColor: "#fbc02d",
      },
    ],
  };
}

async function cargarComparativa() {
  const mensualData = datosMensuales.value.datasets?.[0]?.data || [];
  const anualPromedio =
    datosAnuales.value.datasets?.[0]?.data.reduce((a, b) => a + b, 0) /
    (datosAnuales.value.datasets?.[0]?.data.length || 1);

  datosComparativa.value = {
    labels: datosMensuales.value.labels || [],
    datasets: [
      {
        label: "Mensual",
        data: mensualData,
        backgroundColor: "#26a69a",
      },
      {
        label: "Promedio Anual",
        data: mensualData.map(() => anualPromedio),
        backgroundColor: "#ab47bc",
      },
    ],
  };
}

// ---------------- Platillos ----------------
async function cargarPlatillos() {
  const res = await api.get("/ventas");
  const ventas = res.data;

  const hoy = new Date().toISOString().slice(0, 10);
  const mesActual = new Date().toISOString().slice(0, 7);
  const anioActual = new Date().toISOString().slice(0, 4);

  let ventasFiltradas = ventas.filter((v) => ![0, 5].includes(v.estatus));

  if (periodoPlatillos.value === "diario") {
    ventasFiltradas = ventasFiltradas.filter(
      (v) => v.fecha?.slice(0, 10) === hoy
    );
  } else if (periodoPlatillos.value === "mensual") {
    ventasFiltradas = ventasFiltradas.filter(
      (v) => v.fecha?.slice(0, 7) === mesActual
    );
  } else if (periodoPlatillos.value === "anual") {
    ventasFiltradas = ventasFiltradas.filter(
      (v) => v.fecha?.slice(0, 4) === anioActual
    );
  }

  const contador = {};
  for (let v of ventasFiltradas) {
    const det = await api.get(`/ventas/${v.id}/detalles`);
    det.data.forEach((d) => {
      const nombre = d.nombreProducto || "Desconocido";
      contador[nombre] = (contador[nombre] || 0) + d.cantidad;
    });
  }

  const top = Object.entries(contador)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 10);

  datosPlatillos.value = {
    labels: top.map(([nombre]) => nombre),
    datasets: [
      {
        label: `Platillos más vendidos (${periodoPlatillos.value})`,
        data: top.map(([_, cant]) => cant),
        backgroundColor: "#42a5f5",
      },
    ],
  };
}

// ---------------- Utilidad ----------------
function formatearMoneda(valor) {
  return new Intl.NumberFormat("es-MX", {
    style: "currency",
    currency: "MXN",
    minimumFractionDigits: 2,
  }).format(valor);
}

onMounted(async () => {
  await cargarVentasDiarias();
  await cargarVentasMensuales();
  await cargarVentasAnuales();
  await cargarComparativa();
  await cargarPlatillos();
  await cargarKPIs();
});
</script>

<style scoped>
.bg-gradient {
  background: linear-gradient(135deg, #fff8f0 0%, #ffe6d5 100%);
  min-height: 100vh;
  padding-bottom: 40px;
}
.glass-card {
  background: rgba(255, 255, 255, 0.85);
  backdrop-filter: blur(10px);
  border-radius: 18px;
  box-shadow: 0 6px 16px rgba(62, 39, 35, 0.25);
  color: #3e2723;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}
.glass-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 10px 22px rgba(62, 39, 35, 0.35);
}
.text-h6 {
  font-weight: 600;
  color: #d32f2f;
}
.q-badge {
  font-weight: bold;
  border-radius: 10px;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.2);
}
</style>
