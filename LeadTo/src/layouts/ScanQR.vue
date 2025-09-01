<template>
  <q-page class="q-pa-md flex flex-center column">
    <q-card class="q-pa-lg shadow-2" style="max-width: 500px; width: 100%">
      <q-card-section>
        <div class="text-h6 text-center text-primary">
          📷 Escanear QR de Pedido
        </div>
        <div class="text-subtitle2 text-center q-mt-sm">
          Al escanear, el pedido se marcará como <b>Entregado</b>.
        </div>
      </q-card-section>

      <q-separator />

      <q-card-section class="flex flex-center">
        <qrcode-stream @decode="onDecode" @init="onInit" />
      </q-card-section>

      <q-card-section v-if="scannedId">
        <div class="text-center text-positive">
          ✅ Pedido #{{ scannedId }} actualizado como entregado
        </div>
      </q-card-section>
    </q-card>
  </q-page>
</template>

<script>
import { ref } from "vue";
import { useQuasar } from "quasar";
import axios from "axios";
import { QrcodeStream } from "vue-qrcode-reader";

export default {
  name: "ScanQR",
  components: { QrcodeStream },
  setup() {
    const $q = useQuasar();
    const scannedId = ref(null);

    const onDecode = async (result) => {
      try {
        // El QR tiene un link como: http://localhost:9000/#/status?id=5
        const url = new URL(result);
        const idVenta = url.searchParams.get("id");

        if (idVenta) {
          scannedId.value = idVenta;

          // Actualizamos a "Entregado" (status = 4)
          await axios.put(
            `http://localhost:8082/api/ventas/${idVenta}/status`,
            { status: 4 },
            { headers: { "Content-Type": "application/json" } }
          );

          $q.notify({
            type: "positive",
            message: `Pedido #${idVenta} marcado como Entregado ✅`,
            position: "top",
          });
        }
      } catch (err) {
        console.error("Error al procesar QR:", err);
        $q.notify({
          type: "negative",
          message: "No se pudo actualizar el pedido ❌",
          position: "top",
        });
      }
    };

    const onInit = (promise) => {
      promise.catch((err) => {
        console.error(err);
        $q.notify({
          type: "negative",
          message: "No se pudo acceder a la cámara 📷",
          position: "top",
        });
      });
    };

    return { onDecode, onInit, scannedId };
  },
};
</script>
