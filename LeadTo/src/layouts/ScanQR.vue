<template>
  <div class="scan-qr-container">
    <h2>Lector de QR</h2>
    <div id="qr-reader" style="width: 300px; margin-bottom: 16px;"></div>
    <p v-if="result">Resultado: {{ result }}</p>
    <p v-else>Apunta la cámara a un QR para leerlo</p>
  </div>
</template>

<script>
import { ref, onMounted, onBeforeUnmount } from 'vue';
import { Html5Qrcode } from 'html5-qrcode';

export default {
  name: 'ScanQR',
  setup() {
    const result = ref('');
    let qrCodeScanner = null;

    onMounted(() => {
      qrCodeScanner = new Html5Qrcode("qr-reader");

      qrCodeScanner.start(
        { facingMode: "environment" }, // cámara trasera
        {
          fps: 10,
          qrbox: 250
        },
        (decodedText, decodedResult) => {
          result.value = decodedText;
        },
        (errorMessage) => {
          console.warn('Error QR:', errorMessage);
        }
      ).catch(err => console.error('No se pudo iniciar el lector QR:', err));
    });

    onBeforeUnmount(() => {
      if (qrCodeScanner) {
        qrCodeScanner.stop().catch(err => console.error('Error al detener QR scanner:', err));
      }
    });

    return { result };
  },
};
</script>

<style scoped>
.scan-qr-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  font-family: Arial, sans-serif;
}

#qr-reader {
  border: 2px solid #ccc;
  border-radius: 8px;
}
</style>
