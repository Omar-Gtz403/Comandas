<template>
  <q-page class="q-pa-md">
    <q-card class="q-pa-lg shadow-10" style="max-width: 600px; margin: auto">
      <q-card-section class="text-h6 text-center">
        Registrar Compra
      </q-card-section>

      <q-form @submit.prevent="registrarCompra" class="q-gutter-md">
        <!-- Selección de producto -->
        <q-select
          v-model="form.producto"
          :options="productos"
          option-value="codigoBarras"
          option-label="nombreProducto"
          label="Producto"
          emit-value
          map-options
          outlined
          dense
          required
        />

        <!-- Fecha -->
        <q-input
          v-model="form.fecha"
          label="Fecha"
          type="date"
          outlined
          dense
          required
        />

        <!-- Unidad de compra -->
        <q-select
          v-model="form.unidadCompra"
          :options="['pieza', 'caja', 'kg', 'litro']"
          label="Unidad de compra"
          outlined
          dense
          required
        />

        <!-- Cantidad comprada -->
        <q-input
          v-model.number="form.cantidadCompra"
          label="Cantidad comprada"
          type="number"
          outlined
          dense
          required
        />

        <!-- Factor de conversión -->
        <q-input
          v-model.number="form.factorConversion"
          label="Factor de conversión (ej. caja=24 piezas)"
          type="number"
          outlined
          dense
          required
        />

        <!-- Cantidad equivalente (auto) -->
        <q-input
          v-model="cantidadEquivalente"
          label="Cantidad equivalente"
          type="number"
          outlined
          dense
          disable
        />

        <!-- Precio unitario -->
        <q-input
          v-model.number="form.precioUnitario"
          label="Precio unitario (por unidad de compra)"
          type="number"
          outlined
          dense
          required
        />

        <!-- Total (auto) -->
        <q-input
          v-model="total"
          label="Total"
          type="number"
          outlined
          dense
          disable
        />

        <!-- Botón -->
        <q-btn
          type="submit"
          color="primary"
          label="Registrar Compra"
          class="full-width"
        />
      </q-form>
    </q-card>
  </q-page>
</template>

<script setup>
import { ref, computed, onMounted } from "vue";
import { useQuasar } from "quasar";
import axios from "axios";

const $q = useQuasar();

// Datos del formulario
const form = ref({
  producto: null,
  fecha: new Date().toISOString().split("T")[0],
  unidadCompra: "",
  cantidadCompra: 0,
  factorConversion: 1,
  precioUnitario: 0,
});

// Lista de productos (traída del backend)
const productos = ref([]);

// Cálculo automático
const cantidadEquivalente = computed(() =>
  (form.value.cantidadCompra * form.value.factorConversion).toFixed(2)
);

const total = computed(() =>
  (form.value.cantidadCompra * form.value.precioUnitario).toFixed(2)
);

// Cargar productos al iniciar
onMounted(async () => {
  try {
    const res = await axios.get(
      "https://comandasleadto.duckdns.org/api/productos"
    );
    productos.value = res.data;
  } catch (err) {
    $q.notify({ type: "negative", message: "Error al cargar productos" });
  }
});

// Registrar compra
const registrarCompra = async () => {
  try {
    const payload = {
      producto: { codigoBarras: form.value.producto },
      fecha: form.value.fecha,
      unidadCompra: form.value.unidadCompra,
      cantidadCompra: form.value.cantidadCompra,
      factorConversion: form.value.factorConversion,
      cantidadEquivalente: cantidadEquivalente.value,
      precioUnitario: form.value.precioUnitario,
      total: total.value,
    };

    await axios.post("https://comandasleadto.duckdns.org/api/compras", payload);

    $q.notify({ type: "positive", message: "Compra registrada con éxito ✅" });

    // Reset formulario
    form.value = {
      producto: null,
      fecha: new Date().toISOString().split("T")[0],
      unidadCompra: "",
      cantidadCompra: 0,
      factorConversion: 1,
      precioUnitario: 0,
    };
  } catch (err) {
    $q.notify({ type: "negative", message: "Error al registrar compra" });
  }
};
</script>
