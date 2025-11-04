<template>
  <div class="login-page flex flex-center q-pa-md">
    <q-card class="q-pa-lg shadow-10 full-width" style="max-width: 400px">
      <!-- Header -->
      <q-card-section class="text-center">
        <q-avatar size="80px" class="bg-primary text-white q-mx-auto q-mb-sm">
          <q-icon name="person_add" size="48px" />
        </q-avatar>
        <div class="text-h5 text-primary q-mt-sm">Registrar Usuario</div>
        <div class="text-subtitle2 text-color-secondary">
          Crea una nueva cuenta de acceso
        </div>
      </q-card-section>

      <q-separator spaced />

      <!-- Formulario -->
      <q-form @submit.prevent="registrarUsuario" class="q-gutter-md">
        <q-input
          filled
          dense
          v-model="usuario.nombreUsuario"
          label="Nombre de Usuario"
          type="text"
          autocomplete="username"
          color="primary"
          label-color="primary"
          prepend-icon="person"
          required
        />

        <q-input
          filled
          dense
          v-model="usuario.password"
          label="Contraseña"
          type="password"
          autocomplete="new-password"
          color="primary"
          label-color="primary"
          prepend-icon="lock"
          required
        />

        <q-select
          filled
          dense
          v-model="usuario.rolId"
          :options="roles"
          label="Rol del Usuario"
          color="primary"
          label-color="primary"
          emit-value
          map-options
          prepend-icon="verified_user"
          required
        />

        <q-btn
          label="Registrar"
          type="submit"
          color="primary"
          class="full-width"
          icon="how_to_reg"
          unelevated
        />
      </q-form>
    </q-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { useRouter } from "vue-router";
import { Notify } from "quasar";
import { api } from "boot/axios";

const router = useRouter();

const usuario = ref({
  nombreUsuario: "",
  password: "",
  rolId: null,
});

const roles = ref([]);

onMounted(async () => {
  try {
    const { data } = await api.get("/roles");
    roles.value = data.map((r) => ({
      label: r.nombre,
      value: r.id,
    }));
  } catch (err) {
    console.error("Error cargando roles:", err);
    Notify.create({
      type: "negative",
      message: "No se pudieron cargar los roles",
    });
  }
});

const registrarUsuario = async () => {
  if (
    !usuario.value.nombreUsuario ||
    !usuario.value.password ||
    !usuario.value.rolId
  ) {
    return Notify.create({
      type: "warning",
      message: "Completa todos los campos",
      position: "top",
    });
  }

  try {
    await api.post("/auth/register", {
      nombreUsuario: usuario.value.nombreUsuario,
      password: usuario.value.password,
      rol: { id: usuario.value.rolId },
    });

    Notify.create({
      type: "positive",
      message: "Usuario registrado con éxito",
      position: "top",
    });

    usuario.value = { nombreUsuario: "", password: "", rolId: null };
    router.push("/login");
  } catch (err) {
    console.error(err);
    Notify.create({
      type: "negative",
      message: err.response?.data?.message || "Error al registrar usuario",
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

.btn-link {
  color: $secondary;
  font-weight: 500;
}
</style>
