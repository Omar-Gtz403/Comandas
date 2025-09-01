<template>
  <q-page class="q-pa-md flex flex-center">
    <q-card class="q-pa-lg shadow-2" style="max-width: 420px; width: 100%">
      <q-card-section>
        <div class="text-h6 text-center">🎟 Ticket de Pedido</div>
        <div class="text-subtitle2 text-center q-mt-sm">
          ID Pedido: <span class="text-bold text-primary">{{ idVenta }}</span>
        </div>
      </q-card-section>

      <q-separator />

      <q-card-section class="flex flex-center column">
        <!-- 🔹 Aquí va el QR -->
        <qrcode-vue :value="qrValue" :size="200" level="H" class="q-mb-md" />

        <q-btn
          color="primary"
          icon="download"
          label="Descargar QR"
          @click="descargarQR"
        />
      </q-card-section>
    </q-card>
  </q-page>
</template>

<script>
import { ref, onMounted } from "vue";
import { useRoute } from "vue-router";
import QrcodeVue from "qrcode.vue";

export default {
  name: "TicketPedido",
  components: { QrcodeVue },
  setup() {
    const route = useRoute();
    const idVenta = ref(route.query.id || null);

    // 🔹 Valor del QR (puede ser un link a tu status.vue)
    const qrValue = ref(
      `${window.location.origin}/#/status?id=${idVenta.value}`
    );

    const descargarQR = () => {
      const canvas = document.querySelector("canvas");
      const link = document.createElement("a");
      link.href = canvas.toDataURL("image/png");
      link.download = `pedido-${idVenta.value}.png`;
      link.click();
    };

    return { idVenta, qrValue, descargarQR };
  },
};
</script>
