<template>
  <q-page class="q-pa-md">
    <h2 class="q-mb-lg">Dashboard de Ventas</h2>
    <q-row gutter="32">
      <q-col xs="12" md="6">
        <q-card class="q-mb-lg">
          <q-card-section>
            <h4 class="q-mb-md">Ventas Diarias</h4>
            <q-input
              filled
              type="date"
              v-model="fechaDiaria"
              label="Selecciona fecha"
              @input="actualizarGraficaDiaria"
              class="q-mb-md"
            />
            <BarChart :chart-data="datosDiarios" />
          </q-card-section>
        </q-card>
      </q-col>
      <q-col xs="12" md="6">
        <q-card class="q-mb-lg">
          <q-card-section>
            <h4 class="q-mb-md">Ventas Mensuales</h4>
            <q-input
              filled
              type="month"
              v-model="fechaMensual"
              label="Selecciona mes"
              @input="actualizarGraficaMensual"
              class="q-mb-md"
            />
            <BarChart :chart-data="datosMensuales" />
          </q-card-section>
        </q-card>
      </q-col>
      <q-col xs="12" md="12">
        <q-card>
          <q-card-section>
            <h4 class="q-mb-md">Ventas Anuales</h4>
            <q-input
              filled
              type="number"
              v-model="fechaAnual"
              label="Selecciona año"
              min="2020"
              max="2100"
              @input="actualizarGraficaAnual"
              class="q-mb-md"
            />
            <BarChart :chart-data="datosAnuales" />
          </q-card-section>
        </q-card>
      </q-col>
      <q-col xs="12" md="12">
        <q-card>
          <q-card-section>
            <div class="row items-center q-mb-md">
              <h4 class="q-mr-md">Top 10 Platillos Más Vendidos</h4>
              <q-btn-toggle
                v-model="periodoPlatillos"
                :options="[
                  { label: 'Diario', value: 'diario' },
                  { label: 'Mensual', value: 'mensual' },
                  { label: 'Anual', value: 'anual' },
                ]"
                color="primary"
                dense
              />
            </div>
            <BarChart :chart-data="datosPlatillos()" />
          </q-card-section>
        </q-card>
      </q-col>
    </q-row>
  </q-page>
</template>

<script setup>
import { ref } from "vue";
import BarChart from "src/components/BarChart.vue";

const fechaDiaria = ref(new Date().toISOString().slice(0, 10));
const fechaMensual = ref(new Date().toISOString().slice(0, 7));
const fechaAnual = ref(new Date().getFullYear());

const datosDiarios = ref({
  labels: ["8:00", "10:00", "12:00", "14:00", "16:00"],
  datasets: [
    { label: "Ventas", data: [5, 10, 7, 12, 8], backgroundColor: "#1976d2" },
  ],
});

const datosMensuales = ref({
  labels: ["Semana 1", "Semana 2", "Semana 3", "Semana 4"],
  datasets: [
    { label: "Ventas", data: [120, 150, 100, 170], backgroundColor: "#26a69a" },
  ],
});
const platillosDiarios = ref({
  labels: [
    "Tacos",
    "Pizza",
    "Hamburguesa",
    "Ensalada",
    "Sushi",
    "Pollo",
    "Pasta",
    "Carne",
    "Mariscos",
    "Sandwich",
  ],
  datasets: [
    {
      label: "Platillos más vendidos (Día)",
      data: [20, 18, 15, 14, 13, 12, 11, 10, 9, 8],
      backgroundColor: "#42a5f5",
    },
  ],
});

const platillosMensuales = ref({
  labels: [
    "Tacos",
    "Pizza",
    "Hamburguesa",
    "Ensalada",
    "Sushi",
    "Pollo",
    "Pasta",
    "Carne",
    "Mariscos",
    "Sandwich",
  ],
  datasets: [
    {
      label: "Platillos más vendidos (Mes)",
      data: [200, 180, 150, 140, 130, 120, 110, 100, 90, 80],
      backgroundColor: "#66bb6a",
    },
  ],
});

const platillosAnuales = ref({
  labels: [
    "Tacos",
    "Pizza",
    "Hamburguesa",
    "Ensalada",
    "Sushi",
    "Pollo",
    "Pasta",
    "Carne",
    "Mariscos",
    "Sandwich",
  ],
  datasets: [
    {
      label: "Platillos más vendidos (Año)",
      data: [2000, 1800, 1500, 1400, 1300, 1200, 1100, 1000, 900, 800],
      backgroundColor: "#ffa726",
    },
  ],
});

// Control para el periodo seleccionado
const periodoPlatillos = ref("diario");

function datosPlatillos() {
  if (periodoPlatillos.value === "diario") return platillosDiarios.value;
  if (periodoPlatillos.value === "mensual") return platillosMensuales.value;
  return platillosAnuales.value;
}
const datosAnuales = ref({
  labels: [
    "Ene",
    "Feb",
    "Mar",
    "Abr",
    "May",
    "Jun",
    "Jul",
    "Ago",
    "Sep",
    "Oct",
    "Nov",
    "Dic",
  ],
  datasets: [
    {
      label: "Ventas",
      data: [
        1200, 1500, 1100, 1700, 1600, 1400, 1300, 1800, 1750, 1600, 1550, 1900,
      ],
      backgroundColor: "#fbc02d",
    },
  ],
});

function actualizarGraficaDiaria() {}
function actualizarGraficaMensual() {}
function actualizarGraficaAnual() {}
</script>

<style scoped>
.q-mb-lg {
  margin-bottom: 2rem;
}
.q-mb-md {
  margin-bottom: 1rem;
}
</style>
