<template>
  <q-page class="q-pa-md flex flex-center column">
    <div v-if="error" class="text-center text-negative q-mt-xl">
      ⚠️ {{ error }}
    </div>

    <div
      v-else
      ref="ticketCard"
      class="ticket-wrapper q-pa-md"
      style="
        background: #fff;
        border-radius: 12px;
        max-width: 480px;
        width: 100%;
      "
    >
      <q-card
        class="q-pa-lg shadow-2"
        style="border-radius: 12px; font-family: monospace"
      >
        <q-card-section>
          <div class="text-h6 text-center text-primary q-mb-sm">
            🍔 Restaurante Ejemplo
          </div>
          <div class="text-subtitle2 text-center q-mb-md">
            Calle Ficticia 123, Ciudad<br />
            Tel: (55) 1234-5678
          </div>

          <q-separator />

          <div class="q-mt-md">
            <div class="row justify-between q-mb-xs">
              <div><strong>ID Pedido:</strong></div>
              <div>{{ folio }}</div>
            </div>
            <div class="row justify-between q-mb-xs">
              <div><strong>Fecha:</strong></div>
              <div>{{ fechaPedido }}</div>
            </div>
          </div>

          <q-separator class="q-my-xs" />

          <div v-if="productos.length" class="q-mt-md">
            <div class="text-subtitle2 q-mb-sm">Productos:</div>
            <div
              v-for="item in productos"
              :key="item.nombreProducto"
              class="row justify-between items-center q-py-xs"
            >
              <div>{{ item.nombreProducto }} x{{ item.cantidad }}</div>
              <div>
                ${{
                  (Number(item.precioUnitario) * Number(item.cantidad)).toFixed(
                    2
                  )
                }}
              </div>
            </div>
          </div>

          <q-separator class="q-my-xs" />

          <div class="row justify-between text-h6 q-mt-sm">
            <div>Total:</div>
            <div>${{ total.toFixed(2) }}</div>
          </div>

          <q-separator class="q-my-md" />

          <div class="nota-cancelacion q-pa-sm q-mb-md">
            ⚠️ Nota: Solo podrás cancelar tu pedido si aún no ha comenzado la
            preparación. Una vez iniciado, no se podrá cancelar.
          </div>

          <div class="flex flex-center column q-mb-md">
            <qrcode-vue
              :value="qrValue"
              :size="180"
              level="H"
              class="q-mb-sm"
            />
            <div class="text-center text-subtitle2 q-mb-md">
              Por favor, muestra este QR para la recolección de tu pedido.
            </div>
          </div>

          <q-separator class="q-my-xs" />

          <div class="text-center text-subtitle2 q-mt-md">
            ¡Gracias por tu compra! 🍔
          </div>
        </q-card-section>
      </q-card>
    </div>

    <div
      v-if="!error"
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
        :to="{ path: '/status', query: { folio: folio } }"
      />
    </div>
  </q-page>
</template>

<script>
import { ref, onMounted, computed } from "vue";
import { useRoute, useRouter } from "vue-router";
import QrcodeVue from "qrcode.vue";
import html2canvas from "html2canvas";
import { api } from "src/boot/axios";

export default {
  name: "TicketPedido",
  components: { QrcodeVue },
  setup() {
    const route = useRoute();
    const router = useRouter();
    const folio = ref(route.query.folio || null);
    const productos = ref([]);
    const qrValue = ref(folio.value);
    const ticketCard = ref(null);
    const fechaPedido = ref("");
    const error = ref("");

    const total = computed(() =>
      productos.value.reduce(
        (acc, p) => acc + Number(p.precioUnitario) * Number(p.cantidad),
        0
      )
    );

    const cargarDetalles = async () => {
      if (!folio.value) {
        error.value = "⚠️ Folio inválido o inexistente.";
        return;
      }

      try {
        // Traemos info completa del pedido
        const res = await api.get(`/ventas/folio/${folio.value}`);

        // Validamos que exista y esté pagado
        if (!res.data || [0, 5].includes(res.data.status)) {
          error.value = "⚠️ El pedido no está disponible para ver el ticket.";
          return;
        }

        // Ahora sí traemos los detalles
        const detalles = await api.get(`/ventas/folio/${folio.value}/detalles`);
        if (!detalles.data.length) {
          error.value = "⚠️ No se encontraron productos para este folio.";
          return;
        }

        productos.value = detalles.data;
        qrValue.value = folio.value;

        const d = detalles.data[0].fecha
          ? new Date(detalles.data[0].fecha)
          : new Date();
        fechaPedido.value =
          d.toLocaleDateString("es-MX") +
          " " +
          d.toLocaleTimeString("es-MX", { hour: "2-digit", minute: "2-digit" });
      } catch (err) {
        console.error("Error al cargar los detalles:", err);
        error.value = "⚠️ No se pudo cargar el pedido. Folio inválido.";
      }
    };

    const descargarTicket = async () => {
      if (!ticketCard.value) return;
      try {
        const canvas = await html2canvas(ticketCard.value, {
          scale: 2,
          useCORS: true,
          backgroundColor: "#fff",
        });
        const link = document.createElement("a");
        link.href = canvas.toDataURL("image/png");
        link.download = `ticket-${folio.value}.png`;
        link.click();
      } catch (err) {
        console.error("Error al generar el ticket:", err);
      }
    };

    onMounted(() => {
      cargarDetalles();
    });

    return {
      folio,
      productos,
      total,
      qrValue,
      ticketCard,
      fechaPedido,
      descargarTicket,
      error,
    };
  },
};
</script>

<style scoped>
.q-card {
  font-family: monospace;
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
.nota-cancelacion {
  background-color: #fff3e0;
  border-left: 4px solid #ff6f00;
  color: #bf360c;
  font-size: 0.85rem;
  font-weight: 500;
  border-radius: 6px;
  padding: 8px;
  text-align: justify;
}
.text-negative {
  color: red;
  font-weight: 600;
}
</style>
