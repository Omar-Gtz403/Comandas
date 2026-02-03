<template>
  <q-page class="q-pa-sm flex flex-center column">
    <q-card class="q-pa-md shadow-2" style="max-width: 480px; width: 100%">
      <!-- HEADER -->
      <q-card-section>
        <div class="text-h6 text-center text-primary">
          📷 Escanear QR de Pedido
        </div>
        <div class="text-subtitle2 text-center q-mt-xs">
          Solo pedidos <b>Listos para recoger</b> se marcarán como
          <b>Entregado</b>.
        </div>
      </q-card-section>

      <q-separator />

      <!-- BOTÓN ACTIVAR SONIDO (iOS) -->
      <q-card-section class="text-center q-pt-sm">
        <q-btn
          flat
          dense
          icon="volume_up"
          label="Activar sonido"
          color="primary"
          @click="activarSonido"
        />
      </q-card-section>

      <!-- QR -->
      <q-card-section class="flex flex-center column">
        <div id="qr-reader" class="qr-box"></div>

        <p
          v-if="scannedId && message"
          :class="success ? 'text-positive' : 'text-negative'"
          class="text-center q-mt-sm"
        >
          {{ message }}
        </p>

        <p v-else class="text-center q-mt-sm text-grey">
          Apunta la cámara al código QR
        </p>
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

    /* ===============================
       🔊 SONIDOS (WAV)
    =============================== */
    const sounds = {
      success: new Audio("/sounds/success.wav"),
      warning: new Audio("/sounds/warning.wav"),
      error: new Audio("/sounds/error.wav"),
    };

    const playSound = (type) => {
      try {
        const audio = sounds[type];
        if (!audio) return;
        audio.currentTime = 0;
        audio.volume = 0.7;
        audio.play();
      } catch (e) {
        console.warn("No se pudo reproducir sonido");
      }
    };

    const activarSonido = () => {
      // iOS necesita una interacción previa
      playSound("success");
      $q.notify({
        type: "info",
        message: "Sonido activado 🔊",
        position: "top",
      });
    };

    /* ===============================
       📳 VIBRACIÓN
    =============================== */
    const vibrate = (pattern = [100]) => {
      if ("vibrate" in navigator) {
        navigator.vibrate(pattern);
      }
    };

    /* ===============================
       📸 QR DETECTADO
    =============================== */
    const handleDecoded = async (decodedText) => {
      if (procesando) return;
      procesando = true;

      try {
        let folio = decodedText;

        try {
          const url = new URL(decodedText);
          folio = url.searchParams.get("folio") || decodedText;
        } catch {
          folio = decodedText;
        }

        if (!folio || folio === ultimoFolioProcesado) {
          procesando = false;
          return;
        }

        ultimoFolioProcesado = folio;
        scannedId.value = folio;

        const { data } = await api.get(`/ventas/folio/${folio}`);
        const statusActual = Number(data.status);

        // ✅ LISTO PARA ENTREGAR
        if (statusActual === 3) {
          await api.put(`/ventas/folio/${folio}/status`, { status: 4 });

          message.value = `✅ Pedido #${folio} entregado`;
          success.value = true;

          playSound("success");
          vibrate([80, 40, 80]);

          $q.notify({
            type: "positive",
            message: message.value,
            position: "top",
          });
        } else {
          // ⚠️ NO LISTO
          message.value = `⚠️ Pedido #${folio} no está listo para entregar`;
          success.value = false;

          playSound("warning");
          vibrate([200]);

          $q.notify({
            type: "warning",
            message: message.value,
            position: "top",
          });
        }
      } catch (err) {
        console.error("❌ Error QR:", err);

        message.value = "❌ Error al procesar el pedido";
        success.value = false;

        playSound("error");
        vibrate([300, 100, 300]);

        $q.notify({
          type: "negative",
          message: message.value,
          position: "top",
        });
      } finally {
        setTimeout(() => {
          procesando = false;
        }, 1000);
      }
    };

    /* ===============================
       🚀 CÁMARA
    =============================== */
    onMounted(async () => {
      qrCodeScanner = new Html5Qrcode("qr-reader");

      try {
        const cameras = await Html5Qrcode.getCameras();
        const cameraId = cameras.length > 1 ? cameras[1].id : cameras[0].id;

        await qrCodeScanner.start(
          cameraId,
          { fps: 10, qrbox: 250 },
          handleDecoded,
          () => {}
        );
      } catch (err) {
        console.error("No se pudo acceder a la cámara", err);
        $q.notify({
          type: "negative",
          message: "No se pudo acceder a la cámara 📷",
          position: "top",
        });
      }
    });

    onBeforeUnmount(() => {
      if (qrCodeScanner) {
        qrCodeScanner.stop().catch(() => {});
      }
    });

    return {
      scannedId,
      message,
      success,
      activarSonido,
    };
  },
};
</script>

<style scoped>
.qr-box {
  width: 100%;
  max-width: 280px;
  border: 2px solid #ccc;
  border-radius: 10px;
  margin-bottom: 12px;
}

.text-positive {
  color: #2e7d32;
  font-weight: 600;
}

.text-negative {
  color: #c62828;
  font-weight: 600;
}
</style>
