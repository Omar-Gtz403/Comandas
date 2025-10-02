<template>
  <q-page class="q-pa-md">
    <q-card class="q-pa-md">
      <q-card-section>
        <div class="text-h6 text-center">Registrar Compra</div>
      </q-card-section>

      <q-card-section>
        <q-form
          @submit.prevent="submitCompra"
          ref="compraForm"
          class="q-gutter-md"
        >
          <!-- Producto solo Insumos -->
          <q-select
            v-model="compra.producto"
            :options="productosInsumos"
            option-label="nombreProducto"
            option-value="codigoBarras"
            label="Producto (Insumos)"
            emit-value
            map-options
            outlined
            dense
            required
          />

          <!-- Fecha -->
          <q-input
            v-model="compra.fecha"
            label="Fecha"
            type="date"
            outlined
            dense
            :rules="[(val) => !!val || 'Fecha requerida']"
          />

          <!-- Cantidad Comprada -->
          <q-input
            v-model.number="compra.cantidadCompra"
            label="Cantidad Comprada"
            type="number"
            outlined
            dense
            :rules="[(val) => val > 0 || 'Debe ser mayor que 0']"
          />

          <!-- Unidad de Compra -->
          <q-select
            v-model="compra.unidadCompra"
            :options="['pieza', 'caja', 'kg', 'litro']"
            label="Unidad de Compra"
            outlined
            dense
            required
          />

          <!-- Factor de Conversión -->
          <q-input
            v-model.number="compra.factorConversion"
            label="Factor de Conversión (unidad base)"
            type="number"
            outlined
            dense
            :rules="[(val) => val > 0 || 'Debe ser mayor que 0']"
          />

          <!-- Precio Unitario -->
          <q-input
            v-model.number="compra.precioUnitario"
            label="Precio Unitario"
            type="number"
            outlined
            dense
            :rules="[(val) => val >= 0 || 'Debe ser >= 0']"
          />

          <!-- Cantidad Equivalente (automático) -->
          <q-input
            v-model="cantidadEquivalente"
            label="Cantidad Equivalente (unidades base)"
            outlined
            dense
            readonly
          />

          <!-- Total (automático) -->
          <q-input v-model="total" label="Total" outlined dense readonly />

          <!-- Botón Enviar -->
          <q-btn
            label="Registrar Compra"
            type="submit"
            color="primary"
            class="full-width q-mt-md"
            size="lg"
            rounded
          />
        </q-form>
      </q-card-section>
    </q-card>
  </q-page>
</template>

<script setup>
defineOptions({ name: "InventarioPage" });

import { ref, reactive, computed, onMounted } from "vue";
import { api } from "src/boot/axios";

const productos = ref([]);
const compra = reactive({
  producto: null,
  fecha: new Date().toISOString().substr(0, 10),
  cantidadCompra: 0,
  unidadCompra: "pieza",
  factorConversion: 1,
  precioUnitario: 0,
});

// Computed que filtra solo productos con categoria.id = 5
const productosInsumos = computed(() =>
  productos.value.filter((p) => p.categoria && p.categoria.id === 5)
);

const cantidadEquivalente = computed(
  () => compra.cantidadCompra * compra.factorConversion
);
const total = computed(() => compra.cantidadCompra * compra.precioUnitario);

// Cargar productos desde API
onMounted(async () => {
  try {
    const res = await api.get("/productos");
    productos.value = res.data;
  } catch (err) {
    console.error("Error cargando productos:", err);
  }
});

// Función de envío
const submitCompra = async () => {
  try {
    const payload = {
      producto: { codigoBarras: compra.producto },
      fecha: compra.fecha,
      cantidadCompra: compra.cantidadCompra,
      unidadCompra: compra.unidadCompra,
      factorConversion: compra.factorConversion,
      precioUnitario: compra.precioUnitario,
    };

    await api.post("/compras", payload);
    alert("Compra registrada correctamente");

    // Reset form
    compra.cantidadCompra = 0;
    compra.unidadCompra = "pieza";
    compra.factorConversion = 1;
    compra.precioUnitario = 0;
    compra.producto = null;
  } catch (err) {
    console.error("Error registrando compra:", err);
    alert("Error al registrar compra");
  }
};
</script>

<style scoped>
.q-gutter-md > * {
  margin-bottom: 1rem;
}

.q-input,
.q-select {
  width: 100%;
}
</style>
