<template>
  <div class="chart-container">
    <Bar :data="chartData" :options="chartOptions" />
  </div>
</template>

<script setup>
import { Bar } from "vue-chartjs";
import {
  Chart,
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend,
} from "chart.js";

Chart.register(CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend);

const props = defineProps({
  chartData: {
    type: Object,
    required: true,
  },
});

const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    title: {
      display: true,
      text: "Gráfica de Ventas",
      font: {
        size: 20,
        weight: "bold",
      },
      color: "#1976d2",
      padding: { top: 10, bottom: 30 },
    },
    legend: {
      display: true,
      position: "top",
      labels: {
        color: "#333",
        font: {
          size: 14,
        },
        boxWidth: 20,
        padding: 20,
      },
    },
    tooltip: {
      enabled: true,
      backgroundColor: "#1976d2",
      titleColor: "#fff",
      bodyColor: "#fff",
      borderColor: "#fff",
      borderWidth: 1,
      padding: 10,
    },
  },
  scales: {
    x: {
      grid: {
        display: false,
      },
      ticks: {
        color: "#1976d2",
        font: {
          size: 13,
        },
      },
    },
    y: {
      beginAtZero: true,
      grid: {
        color: "#e0e0e0",
      },
      ticks: {
        color: "#1976d2",
        font: {
          size: 13,
        },
      },
    },
  },
};
</script>

<style scoped>
.chart-container {
  width: 100%;
  min-height: 300px;
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.07);
  padding: 24px;
}
</style>
