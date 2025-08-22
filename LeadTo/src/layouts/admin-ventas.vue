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
          <template v-slot:body-cell-detalles="props">
            <q-btn
              dense
              color="primary"
              label="Ver detalles"
              @click="verDetalles(props.row)"
            />
          </template>

          <template v-slot:body-cell-pagado="props">
            <q-chip
              :color="props.row.pagado ? 'green' : 'red'"
              text-color="white"
              dense
            >
              {{ props.row.pagado ? "Pagado" : "Pendiente" }}
            </q-chip>
          </template>
        </q-table>
      </q-card>

      <q-dialog v-model="dialogDetalles">
        <q-card style="min-width: 400px">
          <q-card-section>
            <div class="text-h6">Detalles de la venta</div>
          </q-card-section>
          <q-separator />
          <q-card-section>
            <div v-for="(d, i) in detallesVenta" :key="i">
              {{ d.producto?.nombreProducto || d.codigoBarras }}
              - Cant: {{ d.cantidad }} - $
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
  setup() {
    const ventas = ref([]);
    const dialogDetalles = ref(false);
    const detallesVenta = ref([]);
    const ventaSeleccionada = ref(null);

    const columns = [
      { name: "idVenta", label: "ID", field: "idVenta", align: "left" },
      { name: "total", label: "Total", field: "total", align: "right" },
      { name: "pagado", label: "Estado", field: "pagado", align: "center" },
      {
        name: "detalles",
        label: "Acciones",
        field: "detalles",
        align: "center",
      },
    ];

    const getVentas = async () => {
      const res = await axios.get("http://localhost:8082/api/ventas");
      ventas.value = res.data;
    };

    const verDetalles = (venta) => {
      ventaSeleccionada.value = venta;
      detallesVenta.value = venta.detalles || [];
      dialogDetalles.value = true;
    };

    onMounted(getVentas);

    return {
      ventas,
      columns,
      dialogDetalles,
      detallesVenta,
      ventaSeleccionada,
      verDetalles,
    };
  },
};
</script>
