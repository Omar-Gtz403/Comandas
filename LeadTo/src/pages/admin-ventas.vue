<template>
  <q-page class="q-pa-md">
    <q-card flat bordered class="q-pa-md">
      <q-card-section>
        <div class="text-h6 text-primary text-center">Cartelera de Pedidos</div>
      </q-card-section>

      <!-- 🔍 Filtro de estatus -->
      <q-select
        v-model="filtroEstatus"
        :options="filtroOptions"
        label="Filtrar por estatus"
        dense
        outlined
        emit-value
        map-options
        class="q-mb-md"
      />

      <!-- 🎬 Vista estilo cartelera -->
      <div class="row q-col-gutter-md">
        <div
          v-for="pedido in ventasFiltradas"
          :key="pedido.folio"
          class="col-xs-12 col-sm-6 col-md-4 col-lg-3"
        >
          <q-card
            class="cartelera-card cursor-pointer"
            @click="abrirDetalle(pedido)"
          >
            <q-card-section
              class="text-center text-white"
              :class="getHeaderClass(pedido.status)"
            >
              <div class="text-h6">Pedido #{{ pedido.folio }}</div>
              <div class="text-caption">
                {{ formatFecha(pedido.fecha) }}
              </div>
            </q-card-section>

            <q-card-section class="bg-white">
              <div
                v-for="(d, idx) in pedido.detalles"
                :key="idx"
                class="text-body2"
              >
                {{ d.cantidad }}x {{ d.nombreProducto }}
              </div>
            </q-card-section>

            <q-separator />

            <q-card-section class="text-center">
              <div class="text-weight-bold text-h6">
                ${{ pedido.total.toFixed(2) }}
              </div>
              <q-chip
                :color="getColor(pedido.status)"
                text-color="white"
                class="q-mt-sm"
                dense
              >
                {{ getLabel(pedido.status) }}
              </q-chip>
            </q-card-section>
          </q-card>
        </div>
      </div>
    </q-card>

    <!-- 📌 Modal Detalles del pedido -->
    <q-dialog v-model="dialogoDetalle" persistent>
      <q-card class="detalle-pedido-card">
        <!-- Header con color según estatus -->
        <q-card-section
          class="text-center text-white"
          :class="getHeaderClass(pedidoSeleccionado?.status)"
        >
          <div class="text-h6">Pedido #{{ pedidoSeleccionado?.folio }}</div>
          <div class="text-caption">
            {{ formatFecha(pedidoSeleccionado?.fecha) }}
          </div>
        </q-card-section>

        <!-- Productos -->
        <q-card-section>
          <div class="text-subtitle2 text-grey-8 q-mb-sm">Productos</div>
          <q-list bordered separator class="rounded-borders">
            <q-item v-for="(d, idx) in pedidoSeleccionado?.detalles" :key="idx">
              <q-item-section
                >{{ d.cantidad }}x {{ d.nombreProducto }}</q-item-section
              >
            </q-item>
          </q-list>
        </q-card-section>

        <!-- Total -->
        <q-card-section class="text-right bg-grey-2">
          <div class="text-h6 text-weight-bold text-primary">
            Total: ${{ pedidoSeleccionado?.total.toFixed(2) }}
          </div>
        </q-card-section>

        <!-- 🔥 Cambio de estatus -->
        <q-card-section>
          <div class="text-subtitle2 text-grey-8 q-mb-sm">Cambiar Estatus</div>
          <q-select
            v-model="pedidoSeleccionado.status"
            :options="estatusOptions"
            dense
            outlined
            emit-value
            map-options
            class="full-width"
            @update:model-value="
              (val) => cambiarStatusYCerrar(pedidoSeleccionado.folio, val)
            "
          />
        </q-card-section>

        <!-- Acciones -->
        <q-card-actions align="right">
          <q-btn flat label="Cerrar" color="primary" v-close-popup />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script>
import { ref, computed, onMounted, getCurrentInstance } from "vue";
import { api } from "src/boot/axios";

export default {
  name: "VentasAdmin",
  setup() {
    const ventas = ref([]);
    const { proxy } = getCurrentInstance();

    const pedidoSeleccionado = ref(null);
    const dialogoDetalle = ref(false);

    const estatusOptions = [
      { label: "Esperando pago", value: 0 },
      { label: "Pago confirmado", value: 1 },
      { label: "Preparando", value: 2 },
      { label: "Listo para recoger", value: 3 },
      { label: "Entregado", value: 4 },
      { label: "Cancelado", value: 5 },
    ];

    const filtroOptions = [
      { label: "Sólo pagos confirmados y preparando", value: "activos" },
      { label: "Todos los pedidos", value: "todos" },
      { label: "Esperando pago", value: 0 },
      { label: "Listo para recoger", value: 3 },
      { label: "Entregado", value: 4 },
      { label: "Cancelados", value: 5 },
    ];
    const filtroEstatus = ref("activos");

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
        case 5:
          return "negative";
        default:
          return "grey";
      }
    };

    const getHeaderClass = (status) => {
      switch (status) {
        case 0:
          return "bg-grey-7";
        case 1:
          return "bg-green-6";
        case 2:
          return "bg-orange-6";
        case 3:
          return "bg-blue-6";
        case 4:
          return "bg-purple-6";
        case 5:
          return "bg-red-7";
        default:
          return "bg-grey-6";
      }
    };

    const getLabel = (status) => {
      const option = estatusOptions.find((o) => o.value === status);
      return option ? option.label : "";
    };

    const formatFecha = (fecha) => {
      const d = new Date(fecha);
      return (
        d.toLocaleDateString("es-MX", {
          day: "2-digit",
          month: "2-digit",
          year: "numeric",
        }) +
        " " +
        d.toLocaleTimeString("es-MX", { hour: "2-digit", minute: "2-digit" })
      );
    };

    const getVentas = async () => {
      try {
        const res = await api.get("/ventas");
        ventas.value = res.data.map((venta) => ({
          ...venta,
          detalles: venta.detalles || [],
          status: Number(venta.status),
          fecha: new Date(venta.fecha || Date.now()),
        }));
      } catch (error) {
        console.error("Error al obtener ventas:", error);
      }
    };

    const ventasFiltradas = computed(() => {
      let lista = [...ventas.value];
      const hoy = new Date();
      const inicioHoy = new Date(
        hoy.getFullYear(),
        hoy.getMonth(),
        hoy.getDate()
      );
      const finHoy = new Date(inicioHoy);
      finHoy.setDate(finHoy.getDate() + 1);

      if (filtroEstatus.value === "activos") {
        lista = lista.filter(
          (v) =>
            [1, 2].includes(v.status) &&
            v.fecha >= inicioHoy &&
            v.fecha < finHoy
        );
      } else if (filtroEstatus.value !== "todos") {
        lista = lista.filter((v) => v.status === filtroEstatus.value);
      }

      const prioridadStatus = { 1: 1, 2: 2, 3: 3, 4: 4, 0: 5, 5: 6 };

      return lista.sort((a, b) => {
        const diff = prioridadStatus[a.status] - prioridadStatus[b.status];
        if (diff !== 0) return diff;
        return new Date(a.fecha) - new Date(b.fecha);
      });
    });

    const actualizarStatus = async (folio, nuevoStatus) => {
      try {
        await api.put(`/ventas/folio/${folio}/status`, { status: nuevoStatus });
        const index = ventas.value.findIndex((v) => v.folio === folio);
        if (index !== -1) ventas.value[index].status = nuevoStatus;
      } catch (error) {
        console.error("Error al actualizar status:", error);
      }
    };

    const cambiarStatusYCerrar = async (folio, nuevoStatus) => {
      await actualizarStatus(folio, nuevoStatus);
      dialogoDetalle.value = false; // 🔥 se cierra solo
    };

    const abrirDetalle = (pedido) => {
      pedidoSeleccionado.value = pedido;
      dialogoDetalle.value = true;
    };

    onMounted(() => {
      getVentas();
      setInterval(getVentas, 5000);
    });

    return {
      ventas,
      ventasFiltradas,
      filtroEstatus,
      filtroOptions,
      getColor,
      getLabel,
      getHeaderClass,
      formatFecha,
      pedidoSeleccionado,
      dialogoDetalle,
      abrirDetalle,
      estatusOptions,
      actualizarStatus,
      cambiarStatusYCerrar,
    };
  },
};
</script>

<style scoped>
.cartelera-card {
  border-radius: 12px;
  transition: transform 0.2s;
}
.cartelera-card:hover {
  transform: scale(1.03);
}

.detalle-pedido-card {
  width: 90vw;
  max-width: 420px;
  border-radius: 16px;
  overflow: hidden;
}
</style>
