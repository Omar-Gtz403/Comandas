<template>
  <div class="login-page flex flex-center q-pa-md">
    <q-card class="q-pa-lg shadow-10 full-width" style="max-width: 400px">
      <!-- Header -->
      <q-card-section class="text-center">
        <q-avatar size="80px" class="bg-primary text-white q-mx-auto q-mb-sm">
          <q-icon name="person" size="48px" />
        </q-avatar>
        <div class="text-h5 text-primary q-mt-sm">Bienvenido</div>
        <div class="text-subtitle2 text-color-secondary">
          Inicia sesión para continuar
        </div>
      </q-card-section>

      <q-separator spaced />

      <!-- Formulario -->
      <q-form @submit.prevent="login" class="q-gutter-md">
        <q-input
          filled
          dense
          v-model="credenciales.nombreUsuario"
          label="Usuario"
          type="text"
          autocomplete="username"
          color="primary"
          label-color="primary"
          prepend-icon="person"
        />

        <q-input
          filled
          dense
          v-model="credenciales.password"
          label="Contraseña"
          type="password"
          autocomplete="current-password"
          color="primary"
          label-color="primary"
          prepend-icon="lock"
        />

        <q-checkbox v-model="recordar" label="Recordarme" color="primary" />

        <!-- Botón -->
        <q-btn
          label="Iniciar sesión"
          type="submit"
          class="btn-principal full-width"
          icon="login"
          unelevated
        />
      </q-form>

      <q-card-section class="text-center">
        <q-btn
          flat
          label="¿Olvidaste tu contraseña?"
          icon="lock_reset"
          class="btn-link"
          @click="router.push('/recuperar')"
        />
      </q-card-section>
    </q-card>
  </div>
</template>

<script setup>
import { ref } from "vue";
import { useRouter } from "vue-router";
import { Notify } from "quasar";
import { api } from "boot/axios"; // tu instancia axios con baseURL

const router = useRouter();

const credenciales = ref({
  nombreUsuario: "",
  password: "",
});

const recordar = ref(false);

const login = async () => {
  try {
    const { data } = await api.post("/auth/login", credenciales.value);

    localStorage.setItem("usuario", JSON.stringify(data));

    Notify.create({
      type: "positive",
      message: `¡Bienvenido ${data.nombreUsuario}!`,
      position: "top",
      timeout: 2500,
    });

    router.push("/productos");
  } catch (err) {
    console.error("Error login:", err);

    Notify.create({
      type: "negative",
      message: "Usuario o contraseña incorrectos",
      position: "top",
      timeout: 2500,
    });
  }
};
</script>

<style lang="scss" scoped>
.login-page {
  min-height: 100vh;
  background: $body-background; // fondo claro definido en variables
  display: flex;
  justify-content: center;
  align-items: center;
}

/* Botón principal simple y tradicional */
.btn-principal {
  background: $primary !important;
  color: #fff;
  font-weight: 600;
  border-radius: $btn-border-radius;
  padding: $btn-padding;
  box-shadow: $btn-box-shadow;
  transition: background 0.3s ease, transform 0.2s ease;
}
.btn-principal:hover {
  transform: scale(1.01);
}

/* Links */
.btn-link {
  color: $secondary;
  font-weight: 500;
  text-transform: none;
}
</style>
