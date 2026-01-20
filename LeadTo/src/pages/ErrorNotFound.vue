<template>
  <div class="fullscreen flex flex-center error-page q-pa-md">
    <q-card class="error-card q-pa-lg text-center shadow-10" flat bordered>
      <!-- 🔄 Spinner -->
      <q-spinner-orbit size="48px" color="primary" class="q-mb-md" />

      <!-- 404 -->
      <div class="error-code">404</div>

      <!-- Texto -->
      <div class="text-h5 text-weight-bold text-primary q-mt-sm">
        Página no encontrada
      </div>

      <div class="text-subtitle2 text-grey-7 q-mt-xs">
        Lo sentimos, la página que buscas no existe o fue movida.
      </div>

      <!-- Botón -->
      <q-btn
        class="q-mt-lg"
        color="primary"
        icon="home"
        unelevated
        no-caps
        label="Volver al inicio"
        to="/"
      />
    </q-card>
  </div>
</template>
<script setup>
/* No se requiere lógica */
</script>
<style lang="scss" scoped>
.error-page {
  background: linear-gradient(
    135deg,
    var(--q-primary-light) 0%,
    var(--q-body-background) 100%
  );
}

.error-card {
  max-width: 420px;
  width: 100%;
  border-radius: 20px;
  background: white;
  animation: fadeIn 0.4s ease;
}

.error-code {
  font-size: clamp(6rem, 20vw, 10rem);
  font-weight: 900;
  color: var(--q-primary);
  line-height: 1;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(12px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>
