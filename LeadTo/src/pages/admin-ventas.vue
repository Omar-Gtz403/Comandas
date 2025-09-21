<template>
  <q-page class="q-pa-md">
    <q-card flat bordered class="q-pa-md">
      <q-card-section>
        <div class="text-h6 text-primary text-center">Ventas</div>
      </q-card-section>

      <div class="responsive-table">
        <q-table
          :rows="ventas"
          :columns="columns"
          row-key="id"
          flat
          bordered
          separator="cell"
          wrap-cells
          :rows-per-page-options="[50]"
          :grid="$q.screen.lt.md"
        >
          <!-- Productos -->
          <template v-slot:body-cell-productos="props">
            <div class="column q-gutter-xs">
              <div
                v-for="(d, idx) in props.row.detalles"
                :key="idx"
                class="text-body2"
              >
                {{ d.cantidad }}x {{ d.nombreProducto }}
              </div>
            </div>
          </template>

          <!-- Total -->
          <template v-slot:body-cell-total="props">
            <div class="text-right text-weight-bold text-primary">
              ${{ props.row.total.toFixed(2) }}
            </div>
          </template>

          <!-- Estado -->
          <template v-slot:body-cell-status="props">
            <div class="row items-center justify-center q-gutter-sm">
              <q-chip
                :color="getColor(props.row.status)"
                text-color="white"
                dense
                class="text-weight-medium"
              >
                {{ getLabel(props.row.status) }}
              </q-chip>
              <q-select
                v-model="props.row.status"
                :options="estatusOptions"
                dense
                outlined
                emit-value
                map-options
                class="status-select"
                @update:model-value="
                  (val) => actualizarStatus(props.row.id, val)
                "
              />
            </div>
          </template>
        </q-table>
      </div>
    </q-card>
  </q-page>
</template>
<script>
import { ref, onMounted, getCurrentInstance } from "vue";
import { api } from "src/boot/axios";
export default {
  name: "VentasAdmin",
  setup() {
    const ventas = ref([]);
    const { proxy } = getCurrentInstance(); // para usar proxy.$q.notify

    const estatusOptions = [
      { label: "Esperando pago", value: 0 },
      { label: "Pago confirmado", value: 1 },
      { label: "Preparando", value: 2 },
      { label: "Listo para recoger", value: 3 },
      { label: "Entregado", value: 4 },
    ];

    const columns = [
      { name: "id", label: "ID", field: "id", align: "center" },
      {
        name: "productos",
        label: "Productos",
        field: "productos",
        align: "left",
      },
      { name: "total", label: "Total ($)", field: "total", align: "right" },
      { name: "status", label: "Estado", field: "status", align: "center" },
    ];

    const getColor = (status) => {
      switch (status) {
        case 0:
          return "grey";
        case 1:
          return "green";
        case 2:
          return "orange";
        case 3:
          return "blue";
        case 4:
          return "purple";
        default:
          return "grey";
      }
    };

    const getLabel = (status) => {
      const option = estatusOptions.find((o) => o.value === status);
      return option ? option.label : "";
    };

    const getVentas = async () => {
      try {
        const res = await api.get("/ventas");
        const nuevasVentas = res.data.map((venta) => ({
          ...venta,
          detalles: venta.detalles || [],
          status: Number(venta.status),
        }));

        // 🔔 Detectar nuevo pedido
        if (ventas.value.length && nuevasVentas.length > ventas.value.length) {
          proxy.$q.notify({
            type: "positive",
            message: "¡Nuevo pedido recibido!",
            color: "green",
            position: "top-right",
            timeout: 3000,
            icon: "shopping_cart",
          });

          // Opcional: reproducir sonido
          const audio = new Audio("/alerta.mp3"); // coloca alerta.mp3 en carpeta /public
          audio.play().catch(() => {
            console.warn(
              "El navegador bloqueó la reproducción automática del audio"
            );
          });
        }

        ventas.value = nuevasVentas;
      } catch (error) {
        console.error("Error al obtener ventas:", error);
      }
    };

    const actualizarStatus = async (id, nuevoStatus) => {
      try {
        await api.put(
          `/ventas/${id}/status`,
          { status: nuevoStatus },
          { headers: { "Content-Type": "application/json" } }
        );
      } catch (error) {
        console.error("Error al actualizar status:", error);
      }
    };

    onMounted(() => {
      getVentas();
      setInterval(getVentas, 5000); // refresca cada 5 segundos
    });

    return {
      ventas,
      columns,
      estatusOptions,
      getColor,
      getLabel,
      actualizarStatus,
    };
  },
};
</script>
<style scoped>
/* Hace scroll en pantallas pequeñas */
.responsive-table {
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
}

.q-table .q-td {
  vertical-align: middle;
  padding: 10px;
}

/* Ajusta ancho del select en móviles */
@media (max-width: 768px) {
  .status-select {
    min-width: 100% !important;
  }
}
</style>
