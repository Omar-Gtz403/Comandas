<template>
  <q-page class="q-pa-md flex flex-center column">
    <q-card class="q-pa-lg shadow-2" style="max-width: 500px; width: 100%">
      <q-card-section>
        <div class="text-h6 text-center text-primary">
          📷 Escanear QR de Pedido
        </div>
        <div class="text-subtitle2 text-center q-mt-sm">
          Solo los pedidos <b>Listos para recoger</b> se marcarán como
          <b>Entregado</b>.
        </div>
      </q-card-section>

      <q-separator />

      <q-card-section class="flex flex-center column">
        <!-- Contenedor del QR -->
        <div id="qr-reader" style="width: 300px; margin-bottom: 16px"></div>
        <p
          v-if="scannedId && message"
          :class="{ 'text-positive': success, 'text-negative': !success }"
          class="text-center"
        >
          {{ message }}
        </p>
        <p v-else class="text-center">Apunta la cámara a un QR para leerlo</p>
      </q-card-section>
    </q-card>
  </q-page>
</template>
<script>
import { ref, onMounted, onBeforeUnmount } from "vue";
import { useQuasar } from "quasar";
import { Html5Qrcode } from "html5-qrcode";
import { api } from "src/boot/axios";

export default {
  name: "ScanQR",
  setup() {
    const $q = useQuasar();
    const scannedId = ref(null);
    const message = ref("");
    const success = ref(false);
    let qrCodeScanner = null;
    let ultimoFolioProcesado = null;
    let procesando = false;

    const handleDecoded = async (decodedText) => {
      if (procesando) return; // Evita reentradas
      procesando = true;

      try {
        // Extraer folio del QR
        let folio = decodedText;
        try {
          const url = new URL(decodedText);
          folio = url.searchParams.get("folio") || decodedText;
        } catch (e) {
          folio = decodedText;
        }

        if (!folio || folio === ultimoFolioProcesado) {
          procesando = false;
          return;
        }

        ultimoFolioProcesado = folio;
        scannedId.value = folio;

        // Obtener el status actual usando folio
        const { data } = await api.get(`/ventas/folio/${folio}`);
        const statusActual = Number(data.status);

        if (statusActual === 3) {
          await api.put(`/ventas/folio/${folio}/status`, { status: 4 });
          message.value = `✅ Pedido #${folio} marcado como Entregado`;
          success.value = true;
          $q.notify({
            type: "positive",
            message: message.value,
            position: "top",
          });
        } else {
          message.value = `⚠️ Pedido #${folio} no está listo para recoger y no se puede marcar como entregado`;
          success.value = false;
          $q.notify({
            type: "warning",
            message: message.value,
            position: "top",
          });
        }
      } catch (err) {
        console.error("❌ Error al procesar QR:", err);
        message.value = "No se pudo actualizar el pedido ❌";
        success.value = false;
        $q.notify({
          type: "negative",
          message: message.value,
          position: "top",
        });
      } finally {
        // Espera un segundo antes de permitir otro escaneo
        setTimeout(() => {
          procesando = false;
        }, 1000);
      }
    };

    onMounted(async () => {
      qrCodeScanner = new Html5Qrcode("qr-reader");
      try {
        const cameras = await Html5Qrcode.getCameras();
        const cameraId = cameras.length > 1 ? cameras[1].id : cameras[0].id;
        await qrCodeScanner.start(
          cameraId,
          { fps: 10, qrbox: 250 },
          handleDecoded,
          (errorMessage) => {
            // Solo mostrar en consola para depuración, no notificar al usuario
            // console.warn("Error QR:", errorMessage);
          }
        );
      } catch (err) {
        console.error("No se pudo iniciar el lector QR:", err);
        $q.notify({
          type: "negative",
          message: "No se pudo acceder a la cámara 📷",
          position: "top",
        });
      }
    });

    onBeforeUnmount(() => {
      if (qrCodeScanner) {
        qrCodeScanner.stop().catch((err) => console.error(err));
      }
    });

    return { scannedId, message, success };
  },
};
</script>

<style scoped>
#qr-reader {
  border: 2px solid #ccc;
  border-radius: 8px;
}
.text-positive {
  color: green;
  font-weight: 600;
}
.text-negative {
  color: red;
  font-weight: 600;
}
</style>
