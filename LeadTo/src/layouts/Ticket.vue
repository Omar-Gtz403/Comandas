<template>
  <q-page class="q-pa-md flex flex-center column">
    <!-- Contenedor del ticket (lo que se descargará) -->
    <div
      ref="ticketCard"
      class="ticket-wrapper q-pa-md"
      style="
        background: #fff;
        border-radius: 12px;
        max-width: 480px;
        width: 100%;
      "
    >
      <q-card class="q-pa-lg shadow-2" style="border-radius: 12px">
        <!-- Título -->
        <q-card-section>
          <div class="text-h5 text-center text-primary q-mb-md">
            🎟 Ticket de Pedido
          </div>

          <!-- ID Pedido -->
          <div class="text-subtitle2 q-mb-sm">
            <strong>ID Pedido:</strong>
            <span class="text-bold">{{ idVenta }}</span>
          </div>

          <q-separator />

          <!-- Lista de productos -->
          <div v-if="productos.length" class="q-mt-md">
            <div
              v-for="item in productos"
              :key="item.nombreProducto"
              class="row justify-between items-center q-py-xs"
            >
              <div class="col-6">
                {{ item.nombreProducto }} x{{ item.cantidad }}
              </div>
              <div class="col-6 text-right">
                ${{
                  (
                    Number(item.precioUnitario) * Number(item.cantidad) || 0
                  ).toFixed(2)
                }}
              </div>
            </div>
            <q-separator class="q-mt-sm" />
            <div class="row justify-between text-bold q-mt-sm">
              <div>Total:</div>
              <div>${{ total.toFixed(2) }}</div>
            </div>
          </div>

          <q-separator class="q-my-md" />

          <!-- QR con leyenda -->
          <div class="flex flex-center column q-mb-md">
            <qrcode-vue
              :value="qrValue"
              :size="200"
              level="H"
              class="q-mb-sm"
            />
            <div class="text-center text-subtitle2 q-mb-md">
              Por favor, muestra este QR para la recolección de tu pedido.
            </div>
          </div>
        </q-card-section>
      </q-card>
    </div>

    <!-- Botones fuera del ticket para no interferir con html2canvas -->
    <div
      class="row justify-around q-gutter-sm q-mt-md"
      style="max-width: 480px; width: 100%"
    >
      <q-btn
        color="primary"
        icon="download"
        label="Descargar Ticket"
        @click="descargarTicket"
      />
      <q-btn
        color="secondary"
        icon="track_changes"
        label="Seguir mi pedido"
        :to="{ path: '/status', query: { id: idVenta } }"
      />
    </div>
  </q-page>
</template>

<script>
import { ref, onMounted, computed } from "vue";
import { useRoute } from "vue-router";
import QrcodeVue from "qrcode.vue";
import html2canvas from "html2canvas";
import { api } from "src/boot/axios";

export default {
  name: "TicketPedido",
  components: { QrcodeVue },
  setup() {
    const route = useRoute();
    const idVenta = ref(route.query.id || null);
    const productos = ref([]);
    const qrValue = ref(idVenta.value);
    const ticketCard = ref(null);

    // Total de la compra
    const total = computed(() =>
      productos.value.reduce(
        (acc, p) => acc + Number(p.precioUnitario) * Number(p.cantidad),
        0
      )
    );

    // Traer detalles de la venta
    const cargarDetalles = async () => {
      if (!idVenta.value) return;
      try {
        const res = await api.get(`/ventas/${idVenta.value}/detalles`);
        productos.value = res.data;
      } catch (err) {
        console.error("Error al cargar los detalles:", err);
      }
    };

    // Descargar todo el ticket como imagen
    const descargarTicket = async () => {
      if (!ticketCard.value) {
        console.error("ticketCard aún no está disponible");
        return;
      }
      try {
        const canvas = await html2canvas(ticketCard.value, {
          scale: 2,
          useCORS: true,
          backgroundColor: "#fff",
        });
        const link = document.createElement("a");
        link.href = canvas.toDataURL("image/png");
        link.download = `ticket-${idVenta.value}.png`;
        link.click();
      } catch (err) {
        console.error("Error al generar el ticket:", err);
      }
    };

    onMounted(() => {
      cargarDetalles();
    });

    return {
      idVenta,
      productos,
      total,
      qrValue,
      ticketCard,
      descargarTicket,
    };
  },
};
</script>

<style scoped>
.q-card {
  font-family: "Roboto", sans-serif;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}
.text-primary {
  color: #ff6f00;
}
.row {
  font-size: 0.95rem;
}
.ticket-wrapper {
  background: #fff;
  border-radius: 12px;
}
</style>
