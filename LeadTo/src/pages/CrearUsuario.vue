<template>
  <div class="login-page flex flex-center q-pa-md">
    <q-card
      class="q-pa-lg shadow-10 full-width card-container bg-white"
      style="max-width: 420px"
    >
      <!-- 🔄 SPINNER GLOBAL -->
      <q-inner-loading :showing="loading">
        <q-spinner-dots size="48px" color="primary" />
        <div class="text-primary q-mt-sm text-weight-medium">Procesando...</div>
      </q-inner-loading>

      <!-- HEADER -->
      <q-card-section class="text-center">
        <q-avatar
          size="80px"
          class="q-mx-auto q-mb-sm"
          color="primary"
          text-color="white"
        >
          <q-icon name="person_add" size="48px" />
        </q-avatar>

        <div class="text-h5 text-primary text-weight-bold">
          Registrar Usuario
        </div>
        <div class="text-subtitle2 text-grey-7">
          Crea una nueva cuenta de acceso
        </div>
      </q-card-section>

      <q-separator spaced />

      <!-- FORMULARIO -->
      <q-form @submit.prevent="registrarUsuario" class="q-gutter-md">
        <q-input
          v-model="usuario.nombreUsuario"
          label="Nombre de Usuario"
          outlined
          dense
          clearable
          autocomplete="username"
          prepend-icon="person"
          color="primary"
          :disable="loading"
          :rules="[(v) => !!v || 'Campo requerido']"
        />

        <q-input
          v-model="usuario.password"
          label="Contraseña"
          outlined
          dense
          type="password"
          autocomplete="new-password"
          prepend-icon="lock"
          color="primary"
          :disable="loading"
          :rules="[(v) => v?.length >= 4 || 'Mínimo 4 caracteres']"
        />

        <q-select
          v-model="usuario.rolId"
          :options="roles"
          label="Rol del Usuario"
          outlined
          dense
          emit-value
          map-options
          prepend-icon="verified_user"
          color="primary"
          :disable="loading"
          :rules="[(v) => !!v || 'Selecciona un rol']"
        />

        <q-btn
          label="Registrar Usuario"
          type="submit"
          icon="how_to_reg"
          color="primary"
          unelevated
          class="full-width q-mt-md"
          :loading="loading"
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
const loading = ref(false);

const usuario = ref({
  nombreUsuario: "",
  password: "",
  rolId: null,
});

const roles = ref([]);

/* =========================
   CARGAR ROLES
========================= */
const cargarRoles = async () => {
  loading.value = true;
  try {
    const { data } = await api.get("/roles");
    roles.value = data.map((r) => ({
      label: r.nombre,
      value: r.id,
    }));
  } catch {
    Notify.create({
      type: "negative",
      message: "No se pudieron cargar los roles",
      position: "top",
    });
  } finally {
    loading.value = false;
  }
};

onMounted(cargarRoles);

/* =========================
   REGISTRAR USUARIO
========================= */
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

  loading.value = true;
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
    Notify.create({
      type: "negative",
      message: err.response?.data?.message || "Error al registrar usuario",
      position: "top",
    });
  } finally {
    loading.value = false;
  }
};
</script>
<style lang="scss" scoped>
.login-page {
  min-height: 100vh;
  background: var(--q-body-background);
  display: flex;
  justify-content: center;
  align-items: center;
}

.card-container {
  position: relative;
  border-radius: 18px;
}

.q-avatar {
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.15);
}
</style>
