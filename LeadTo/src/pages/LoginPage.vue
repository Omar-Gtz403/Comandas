<template>
  <q-page class="login-page flex flex-center q-pa-md">
    <q-inner-loading
      :showing="loading"
      label="Iniciando sesión..."
      label-class="text-primary"
    >
      <q-spinner-gears size="48px" color="primary" />
    </q-inner-loading>

    <q-card
      class="q-pa-lg shadow-12 full-width rounded-borders"
      style="max-width: 420px"
    >
      <q-card-section class="text-center">
        <q-avatar
          size="80px"
          color="primary"
          text-color="white"
          class="q-mx-auto q-mb-sm"
        >
          <q-icon name="person" size="48px" />
        </q-avatar>

        <div class="text-h5 text-primary text-weight-bold q-mt-sm">
          Bienvenido
        </div>
        <div class="text-subtitle2 text-secondary">
          Inicia sesión para continuar
        </div>
      </q-card-section>

      <q-separator spaced />

      <q-form @submit.prevent="login" class="q-gutter-md">
        <q-input
          v-model="credenciales.nombreUsuario"
          filled
          dense
          autofocus
          label="Usuario"
          color="primary"
          prepend-icon="person"
          :disable="loading"
        />

        <q-input
          v-model="credenciales.password"
          filled
          dense
          type="password"
          label="Contraseña"
          color="primary"
          prepend-icon="lock"
          :disable="loading"
        />

        <q-btn
          type="submit"
          label="Iniciar sesión"
          icon="login"
          color="primary"
          class="full-width q-mt-sm"
          unelevated
          :loading="loading"
        />
      </q-form>

      <q-card-section class="text-center text-caption text-grey-7 q-pt-md">
        © {{ new Date().getFullYear() }} LeadTo · Todos los derechos reservados
      </q-card-section>
    </q-card>
  </q-page>
</template>

<script setup>
import { ref } from "vue";
import { useRouter } from "vue-router";
import { Notify } from "quasar";
import { api } from "boot/axios";

const router = useRouter();
const loading = ref(false);

const credenciales = ref({
  nombreUsuario: "",
  password: "",
});

const login = async () => {
  if (!credenciales.value.nombreUsuario || !credenciales.value.password) {
    Notify.create({
      type: "warning",
      message: "Completa todos los campos",
      position: "top",
    });
    return;
  }

  loading.value = true;

  try {
    const { data } = await api.post("/auth/login", credenciales.value);

    localStorage.setItem("usuario", JSON.stringify(data));

    Notify.create({
      type: "positive",
      message: `¡Bienvenido ${data.nombreUsuario}!`,
      position: "top",
    });

    const rutas = data?.rol?.permisos?.map((p) => p.ruta) || [];
    router.push(rutas.length ? rutas[0] : "/");
  } catch {
    Notify.create({
      type: "negative",
      message: "Usuario o contraseña incorrectos",
      position: "top",
    });
  } finally {
    loading.value = false;
  }
};
</script>

<style scoped>
.login-page {
  min-height: 100vh;
}

.rounded-borders {
  border-radius: 16px;
}
</style>
