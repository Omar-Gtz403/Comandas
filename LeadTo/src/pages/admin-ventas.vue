<template>
  <q-page class="q-pa-md">
    <q-card flat bordered class="q-pa-md">
      <q-card-section>
        <div class="text-h6 text-primary text-center">Ventas</div>
      </q-card-section>

      <q-table
        :rows="ventas"
        :columns="columns"
        row-key="id"
        flat
        bordered
        separator="horizontal"
        wrap-cells
        :rows-per-page-options="[50]"
        :grid="$q.screen.lt.md"
      >
        <!-- 🖥️ Vista tabla (desktop) -->
        <template v-slot:body="props">
          <q-tr :props="props">
            <q-td
              v-for="col in props.cols"
              :key="col.name"
              :props="props"
              :class="getColColor(col.name)"
            >
              <template v-if="col.name === 'productos'">
                <div class="column q-gutter-xs text-body2">
                  <div v-for="(d, idx) in props.row.detalles" :key="idx">
                    {{ d.cantidad }}x {{ d.nombreProducto }}
                  </div>
                </div>
              </template>

              <template v-else-if="col.name === 'total'">
                <div class="text-right text-weight-bold">
                  ${{ props.row.total.toFixed(2) }}
                </div>
              </template>

              <template v-else-if="col.name === 'status'">
                <div
                  class="row items-center justify-center no-wrap q-gutter-sm"
                >
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

              <template v-else>
                {{ col.value }}
              </template>
            </q-td>
          </q-tr>
        </template>

        <!-- 📱 Vista cards en móvil -->
        <template v-slot:item="props">
          <q-card class="q-ma-xs q-pa-sm full-width shadow-2">
            <div class="text-subtitle1 text-primary text-bold">
              Pedido #{{ props.row.id }}
            </div>

            <!-- Productos -->
            <div
              class="q-mt-sm text-body2 bg-col-productos q-pa-xs rounded-borders"
            >
              <div v-for="(d, idx) in props.row.detalles" :key="idx">
                {{ d.cantidad }}x {{ d.nombreProducto }}
              </div>
            </div>

            <!-- Total -->
            <div
              class="text-right text-weight-bold q-mt-sm bg-col-total q-pa-xs rounded-borders"
            >
              ${{ props.row.total.toFixed(2) }}
            </div>

            <!-- Estado -->
            <div
              class="row items-center q-mt-sm bg-col-status q-pa-xs rounded-borders"
            >
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
                class="q-ml-sm full-width"
                @update:model-value="
                  (val) => actualizarStatus(props.row.id, val)
                "
              />
            </div>
          </q-card>
        </template>
      </q-table>
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
    const { proxy } = getCurrentInstance();

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
        ventas.value = res.data.map((venta) => ({
          ...venta,
          detalles: venta.detalles || [],
          status: Number(venta.status),
        }));
      } catch (error) {
        console.error("Error al obtener ventas:", error);
      }
    };

    const actualizarStatus = async (id, nuevoStatus) => {
      try {
        await api.put(`/ventas/${id}/status`, { status: nuevoStatus });
      } catch (error) {
        console.error("Error al actualizar status:", error);
      }
    };

    const getColColor = (colName) => {
      switch (colName) {
        case "id":
          return "bg-col-id";
        case "productos":
          return "bg-col-productos";
        case "total":
          return "bg-col-total";
        case "status":
          return "bg-col-status";
        default:
          return "";
      }
    };

    onMounted(() => {
      getVentas();
      setInterval(getVentas, 5000);
    });

    return {
      ventas,
      columns,
      estatusOptions,
      getColor,
      getLabel,
      actualizarStatus,
      getColColor,
    };
  },
};
</script>

<style scoped>
/* 🎨 Colores por columna */
.bg-col-id {
  background-color: #ffe8a1; /* Amarillo suave */
}
.bg-col-productos {
  background-color: #e1f5fe; /* Azul claro */
}
.bg-col-total {
  background-color: #ffe0e0; /* Rojo muy claro */
}
.bg-col-status {
  background-color: #e8f5e9; /* Verde claro */
}

/* General */
.q-table .q-td {
  vertical-align: middle;
  padding: 10px;
}

.q-table .q-th {
  background: #f8f9fa;
  font-weight: 600;
  text-align: center;
}
</style>
