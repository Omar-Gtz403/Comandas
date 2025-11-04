<template>
  <div class="login-page flex flex-center q-pa-md">
    <q-card class="q-pa-lg shadow-10 full-width" style="max-width: 400px">
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

      <q-form @submit.prevent="login" class="q-gutter-md">
        <q-input
          filled
          dense
          v-model="credenciales.nombreUsuario"
          label="Usuario"
          type="text"
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
          color="primary"
          label-color="primary"
          prepend-icon="lock"
        />

        <q-btn
          label="Iniciar sesión"
          type="submit"
          color="primary"
          class="full-width"
          icon="login"
          unelevated
        />
      </q-form>
    </q-card>
  </div>
</template>

<script setup>
import { ref } from "vue";
import { useRouter } from "vue-router";
import { Notify } from "quasar";
import { api } from "boot/axios";

const router = useRouter();

const credenciales = ref({
  nombreUsuario: "",
  password: "",
});

const login = async () => {
  if (!credenciales.value.nombreUsuario || !credenciales.value.password) {
    return Notify.create({
      type: "warning",
      message: "Completa todos los campos",
      position: "top",
    });
  }

  try {
    const { data } = await api.post("/auth/login", credenciales.value);

    localStorage.setItem("usuario", JSON.stringify(data));

    Notify.create({
      type: "positive",
      message: `¡Bienvenido ${data.nombreUsuario}!`,
      position: "top",
    });

    // Si el usuario tiene permisos, lo mandamos al primero disponible
    const rutas = data?.rol?.permisos?.map((p) => p.ruta) || [];

    if (rutas.length > 0) {
      router.push(rutas[0]); // primer permiso
    } else {
      // si no tiene permisos, menú público
      router.push("/");
    }
  } catch (err) {
    Notify.create({
      type: "negative",
      message: "Usuario o contraseña incorrectos",
      position: "top",
    });
  }
};
</script>

<style lang="scss" scoped>
.login-page {
  min-height: 100vh;
  background: $body-background;
  display: flex;
  justify-content: center;
  align-items: center;
}
</style>
