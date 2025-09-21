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

      <q-card-section class="flex flex-center column">
        <!-- Contenedor del QR -->
        <div id="qr-reader" style="width: 300px; margin-bottom: 16px"></div>
        <p v-if="scannedId" class="text-center text-positive">
          ✅ Pedido #{{ scannedId }} actualizado como entregado
        </p>
        <p v-else class="text-center">Apunta la cámara a un QR para leerlo</p>
      </q-card-section>
    </q-card>
  </q-page>
</template>

<script>
import { ref, onMounted, onBeforeUnmount } from "vue";
import { useQuasar } from "quasar";
import axios from "axios";
import { Html5Qrcode } from "html5-qrcode";
import { api } from "src/boot/axios";
export default {
  name: "ScanQR",
  setup() {
    const $q = useQuasar();
    const scannedId = ref(null);
    let qrCodeScanner = null;

    const handleDecoded = async (decodedText) => {
      console.log("📌 QR detectado:", decodedText);

      try {
        // Asegúrate de que el texto sea una URL válida
        let idVenta = null;
        try {
          const url = new URL(decodedText);
          idVenta = url.searchParams.get("id");
        } catch (e) {
          // Si no es URL, tal vez QR solo tiene el id
          idVenta = decodedText;
        }

        console.log("🆔 ID de venta extraído:", idVenta);

        if (idVenta) {
          scannedId.value = idVenta;

          const response = await api.put(`/ventas/${idVenta}/status`, {
            status: 4,
          });
          console.log("✅ Respuesta backend:", response.data);

          $q.notify({
            type: "positive",
            message: `Pedido #${idVenta} marcado como Entregado ✅`,
            position: "top",
          });
        } else {
          console.warn("⚠️ El QR no contenía un id válido");
        }
      } catch (err) {
        console.error("❌ Error al procesar QR:", err);
        $q.notify({
          type: "negative",
          message: "No se pudo actualizar el pedido ❌",
          position: "top",
        });
      }
    };

    onMounted(async () => {
      qrCodeScanner = new Html5Qrcode("qr-reader");

      try {
        const cameras = await Html5Qrcode.getCameras();
        console.log("Cámaras disponibles:", cameras);

        const cameraId = cameras.length > 1 ? cameras[1].id : cameras[0].id; // 👈 mejor que facingMode
        await qrCodeScanner.start(
          cameraId,
          { fps: 10, qrbox: 250 },
          handleDecoded,
          (errorMessage) => {
            console.warn("Error QR:", errorMessage);
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

    return { scannedId };
  },
};
</script>

<style scoped>
#qr-reader {
  border: 2px solid #ccc;
  border-radius: 8px;
}
</style>
