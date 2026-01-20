<template>
  <q-page class="q-pa-md">
    <div class="bg-white p-6 rounded-xl shadow-lg max-w-3xl mx-auto">
      <h2 class="text-2xl font-bold mb-4">Administrar Cajas</h2>

      <!-- Selector de usuario -->
      <div class="q-gutter-md flex items-center">
        <q-select
          v-model="usuarioSeleccionado"
          :options="usuarios"
          option-label="nombreUsuario"
          option-value="id"
          label="Seleccionar usuario"
          outlined
          class="w-full"
          @update:model-value="verificarCaja"
        />
      </div>

      <q-separator spaced />

      <!-- Caja abierta -->
      <div v-if="cajaAbierta">
        <div class="q-mb-md">
          <p>
            <strong>Usuario:</strong> {{ usuarioSeleccionado.nombreUsuario }}
          </p>
          <p>
            <strong>Fecha Apertura:</strong>
            {{ formatearFecha(caja.fechaApertura) }}
          </p>
          <p><strong>Monto Inicial:</strong> ${{ caja.montoInicial }}</p>
          <p>
            <strong>Estado:</strong> <q-badge color="green" label="ABIERTA" />
          </p>
        </div>

        <q-input
          v-model="montoFinal"
          label="Monto final"
          type="number"
          outlined
          class="q-mb-md"
        />
        <q-btn
          color="negative"
          label="Cerrar Caja"
          class="full-width"
          @click="cerrarCaja"
        />
      </div>

      <!-- Caja cerrada / sin abrir -->
      <div v-else>
        <q-input
          v-model="montoInicial"
          label="Monto inicial"
          type="number"
          outlined
          class="q-mb-md"
        />
        <q-btn
          color="primary"
          label="Abrir Caja"
          class="full-width"
          @click="abrirCaja"
          :disable="!usuarioSeleccionado"
        />
      </div>
    </div>
  </q-page>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { useQuasar } from "quasar";
import { api } from "src/boot/axios";
const $q = useQuasar();

// Datos del usuario logueado
const usuarioLogueado = JSON.parse(localStorage.getItem("usuario"));

// Variables reactivas
const usuarios = ref([]);
const usuarioSeleccionado = ref(null);
const caja = ref({});
const cajaAbierta = ref(false);
const montoInicial = ref(0);
const montoFinal = ref(0);

onMounted(() => {
  obtenerUsuarios();
});

const obtenerUsuarios = async () => {
  try {
    const res = await api.get("/usuarios");
    usuarios.value = res.data;
  } catch (e) {
    $q.notify({ type: "negative", message: "Error al obtener usuarios" });
  }
};

// Verificar si el usuario tiene una caja abierta
const verificarCaja = async () => {
  if (!usuarioSeleccionado.value) return;

  try {
    const res = await axios.get(
      `/api/caja/estado/${usuarioSeleccionado.value.id}`
    );
    if (res.data && res.data.estado === "ABIERTA") {
      cajaAbierta.value = true;
      caja.value = res.data;
    } else {
      cajaAbierta.value = false;
      caja.value = {};
    }
  } catch (e) {
    cajaAbierta.value = false;
  }
};

// Abrir caja
const abrirCaja = async () => {
  try {
    await axios.post("/api/caja/abrir", {
      usuarioId: usuarioSeleccionado.value.id,
      montoInicial: montoInicial.value,
    });
    $q.notify({ type: "positive", message: "Caja abierta correctamente" });
    verificarCaja();
  } catch (e) {
    $q.notify({ type: "negative", message: "Error al abrir caja" });
  }
};

// Cerrar caja
const cerrarCaja = async () => {
  try {
    await axios.post("/api/caja/cerrar", {
      usuarioId: usuarioSeleccionado.value.id,
      montoFinal: montoFinal.value,
    });
    $q.notify({ type: "positive", message: "Caja cerrada correctamente" });
    verificarCaja();
  } catch (e) {
    $q.notify({ type: "negative", message: "Error al cerrar caja" });
  }
};

// Formatear fecha
const formatearFecha = (fecha) => {
  return new Date(fecha).toLocaleString();
};
</script>

<style scoped>
.w-full {
  width: 100%;
}
</style>
