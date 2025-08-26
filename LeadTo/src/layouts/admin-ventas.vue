<template>
  <q-layout view="lHh Lpr lFf">
    <q-page-container class="q-pa-md">
      <q-card class="q-pa-md">
        <q-card-section>
          <div class="text-h6">Ventas registradas</div>
        </q-card-section>

        <q-table
          :rows="ventas"
          :columns="columns"
          row-key="id"
          flat
          bordered
          :pagination="{ rowsPerPage: 20 }"
          :rows-per-page-options="[5, 10, 20, 50]"
        >
          <!-- Botón Ver Detalles -->
          <template v-slot:body-cell-detalles="props">
            <q-btn
              dense
              color="primary"
              label="Ver detalles"
              @click="verDetalles(props.row)"
            />
          </template>

          <!-- Estado Pagado / Pendiente -->
          <template v-slot:body-cell-pagado="props">
            <q-chip
              :color="props.row.pagado ? 'green' : 'red'"
              text-color="white"
              dense
            >
              {{ props.row.pagado ? "Pagado" : "Pendiente" }}
            </q-chip>
          </template>

          <!-- Estatus del pedido con QSelect -->
          <template v-slot:body-cell-status="props">
            <q-select
              v-model="props.row.status"
              :options="estatusOptions"
              dense
              outlined
              emit-value
              map-options
              @update:model-value="(val) => actualizarStatus(props.row.id, val)"
            />
          </template>
        </q-table>
      </q-card>

      <!-- Diálogo de Detalles -->
      <q-dialog v-model="dialogDetalles">
        <q-card style="min-width: 400px">
          <q-card-section>
            <div class="text-h6">Detalles de la venta</div>
          </q-card-section>
          <q-separator />
          <q-card-section>
            <div v-for="(d, i) in detallesVenta" :key="i">
              {{ d.nombreProducto }} - Cant: {{ d.cantidad }} - $
              {{ (d.precioUnitario * d.cantidad).toFixed(2) }}
            </div>
            <div class="text-right text-bold q-mt-md">
              Total: ${{ ventaSeleccionada?.total.toFixed(2) }}
            </div>
          </q-card-section>
          <q-card-actions align="right">
            <q-btn flat label="Cerrar" v-close-popup />
          </q-card-actions>
        </q-card>
      </q-dialog>
    </q-page-container>
  </q-layout>
</template>

<script>
import { ref, onMounted } from "vue";
import axios from "axios";

export default {
  name: "VentasAdmin",
  setup() {
    const ventas = ref([]);
    const dialogDetalles = ref(false);
    const detallesVenta = ref([]);
    const ventaSeleccionada = ref(null);

    // Opciones de estatus del pedido
    const estatusOptions = [
      { label: "Pago aceptado", value: 0 },
      { label: "Pedido realizado", value: 1 },
      { label: "En preparación", value: 2 },
      { label: "Listo para recoger", value: 3 },
      { label: "Entregado", value: 4 },
    ];

    // Columnas para la tabla
    const columns = [
      { name: "id", label: "ID", field: "id", align: "left" },
      { name: "total", label: "Total", field: "total", align: "right" },
      { name: "pagado", label: "Pagado", field: "pagado", align: "center" },
      { name: "status", label: "Estatus", field: "status", align: "center" },
      {
        name: "detalles",
        label: "Acciones",
        field: "detalles",
        align: "center",
      },
    ];

    // Obtener todas las ventas
    const getVentas = async () => {
      try {
        const res = await axios.get("http://localhost:8082/api/ventas");
        ventas.value = res.data;
      } catch (error) {
        console.error("Error al obtener ventas:", error);
      }
    };

    // Obtener detalles de una venta específica
    const verDetalles = async (venta) => {
      try {
        ventaSeleccionada.value = venta;
        const res = await axios.get(
          `http://localhost:8082/api/ventas/${venta.id}/detalles`
        );
        detallesVenta.value = res.data;
        dialogDetalles.value = true;
      } catch (error) {
        console.error("Error al obtener detalles:", error);
      }
    };

    // Actualizar el estatus en backend
    const actualizarStatus = async (id, nuevoStatus) => {
      try {
        await axios.put(
          `http://localhost:8082/api/ventas/${id}/status`,
          nuevoStatus,
          { headers: { "Content-Type": "application/json" } }
        );
        console.log(`Pedido ${id} actualizado a status ${nuevoStatus}`);
      } catch (error) {
        console.error("Error al actualizar status:", error);
      }
    };

    onMounted(getVentas);

    return {
      ventas,
      columns,
      dialogDetalles,
      detallesVenta,
      ventaSeleccionada,
      verDetalles,
      estatusOptions,
      actualizarStatus,
    };
  },
};
</script>
