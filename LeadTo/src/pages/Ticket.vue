<template>
  <q-page class="q-pa-sm flex flex-center column">
    <!-- LOADING -->
    <q-inner-loading :showing="loading">
      <q-spinner size="50px" color="primary" />
      <div class="text-primary q-mt-sm">Cargando pedido...</div>
    </q-inner-loading>

    <!-- ERROR -->
    <div v-if="!loading && error" class="text-center text-negative q-mt-xl">
      ⚠️ {{ error }}
    </div>

    <!-- TICKET -->
    <div
      v-if="!loading && !error"
      ref="ticketCard"
      class="ticket-wrapper q-pa-sm"
    >
      <q-card class="q-pa-md shadow-2 ticket-card">
        <q-card-section>
          <!-- HEADER -->
          <div class="text-h6 text-center text-primary q-mb-xs">
            🐟 Solo Veracruz Es Bello
          </div>
          <div class="text-caption text-center q-mb-sm">
            Av. del Trabajo 13, Tlalnepantla Centro, 54000 Tlalnepantla, Méx<br />
            Tel: (55) 55650170
          </div>

          <q-separator />

          <!-- INFO -->
          <div class="q-mt-sm text-body2">
            <div class="row justify-between q-mb-xs">
              <strong>ID Pedido</strong>
              <span>{{ folio }}</span>
            </div>
            <div class="row justify-between q-mb-xs">
              <strong>Fecha</strong>
              <span>{{ fechaPedido }}</span>
            </div>
          </div>

          <q-separator class="q-my-sm" />

          <!-- PRODUCTOS -->
          <div>
            <div class="text-subtitle2 q-mb-xs">Productos</div>
            <div
              v-for="item in productos"
              :key="item.nombreProducto"
              class="row justify-between q-py-xs text-body2"
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

          <q-separator class="q-my-sm" />

          <!-- TOTAL -->
          <div class="row justify-between text-h6 q-mt-xs">
            <strong>Total</strong>
            <strong>${{ total.toFixed(2) }}</strong>
          </div>

          <q-separator class="q-my-md" />

          <!-- NOTA -->
          <div class="nota-cancelacion q-mb-md">
            ⚠️ Solo podrás cancelar tu pedido si aún no ha comenzado la
            preparación.
          </div>

          <!-- QR -->
          <div class="flex flex-center column">
            <qrcode-vue :value="qrValue" :size="160" level="H" />
            <div class="text-caption text-center q-mt-sm">
              Muestra este QR para recoger tu pedido
            </div>
          </div>

          <q-separator class="q-my-sm" />

          <div class="text-center text-caption q-mt-sm">
            ¡Gracias por tu compra! 🐟
          </div>
        </q-card-section>
      </q-card>
    </div>

    <!-- ACTIONS -->
    <div v-if="!loading && !error" class="q-mt-md full-width actions">
      <q-btn
        color="primary"
        icon="download"
        label="Descargar Ticket"
        class="full-width q-mb-sm"
        @click="descargarTicket"
      />
      <q-btn
        color="secondary"
        icon="track_changes"
        label="Seguir mi pedido"
        class="full-width"
        :to="{ path: '/status', query: { folio } }"
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
    const folio = ref(route.query.folio || null);

    const productos = ref([]);
    const qrValue = ref(folio.value);
    const ticketCard = ref(null);
    const fechaPedido = ref("");
    const error = ref("");
    const loading = ref(true);

    const total = computed(() =>
      productos.value.reduce(
        (acc, p) => acc + Number(p.precioUnitario) * Number(p.cantidad),
        0
      )
    );

    const cargarDetalles = async () => {
      loading.value = true;
      error.value = "";

      if (!folio.value) {
        error.value = "Folio inválido o inexistente.";
        loading.value = false;
        return;
      }

      try {
        const res = await api.get(`/ventas/folio/${folio.value}`);

        if (!res.data || [0, 5].includes(res.data.status)) {
          error.value = "El pedido no está disponible.";
          loading.value = false;
          return;
        }

        const detalles = await api.get(`/ventas/folio/${folio.value}/detalles`);

        if (!detalles.data.length) {
          error.value = "No se encontraron productos.";
          loading.value = false;
          return;
        }

        productos.value = detalles.data;

        const d = new Date(detalles.data[0].fecha || new Date());
        fechaPedido.value =
          d.toLocaleDateString("es-MX") +
          " " +
          d.toLocaleTimeString("es-MX", {
            hour: "2-digit",
            minute: "2-digit",
          });
      } catch (err) {
        console.error(err);
        error.value = "No se pudo cargar el pedido.";
      } finally {
        loading.value = false;
      }
    };

    const descargarTicket = async () => {
      if (!ticketCard.value) return;

      const canvas = await html2canvas(ticketCard.value, {
        scale: 2,
        backgroundColor: "#fff",
      });

      const link = document.createElement("a");
      link.href = canvas.toDataURL("image/png");
      link.download = `ticket-${folio.value}.png`;
      link.click();
    };

    onMounted(cargarDetalles);

    return {
      folio,
      productos,
      total,
      qrValue,
      ticketCard,
      fechaPedido,
      descargarTicket,
      error,
      loading,
    };
  },
};
</script>

<style scoped>
.ticket-wrapper {
  max-width: 480px;
  width: 100%;
}

.ticket-card {
  border-radius: 12px;
  font-family: monospace;
}

.text-primary {
  color: #ff6f00;
}

.nota-cancelacion {
  background: #fff3e0;
  border-left: 4px solid #ff6f00;
  padding: 8px;
  font-size: 0.8rem;
  border-radius: 6px;
}

.actions {
  max-width: 480px;
}
.text-negative {
  font-weight: 600;
}
</style>
