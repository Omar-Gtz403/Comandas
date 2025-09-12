<template>
  <q-page padding>
    <div class="max-w-md mx-auto bg-white p-6 rounded-xl shadow-md">
      <h2 class="text-xl font-bold mb-4">Registrar Usuario</h2>

      <q-form @submit="registrarUsuario" class="q-gutter-md">
        <q-input
          v-model="usuario.nombreUsuario"
          label="Nombre de Usuario"
          outlined
          required
        />

        <q-input
          v-model="usuario.password"
          type="password"
          label="Contraseña"
          outlined
          required
        />

        <q-select
          v-model="usuario.permiso"
          :options="permisos"
          label="Permiso"
          outlined
        />

        <q-btn
          label="Registrar"
          type="submit"
          color="primary"
          class="full-width"
        />
      </q-form>
    </div>
  </q-page>
</template>

<script setup>
import { ref } from "vue";
import { useRouter } from "vue-router";
import { api } from "boot/axios";

const router = useRouter();

const usuario = ref({
  nombreUsuario: "",
  password: "",
  permiso: 1, // solo administrativos
});

const permisos = [
  { label: "Administrador", value: 1 },
  { label: "Usuario", value: 0 }, // no se usará en tu caso
];

const registrarUsuario = async () => {
  try {
    await api.post("/auth/register", usuario.value);
    alert("Usuario registrado con éxito");
    usuario.value = { nombreUsuario: "", password: "", permiso: 1 };
    router.push("/productos"); // redirigir a pantalla admin después de registrar
  } catch (err) {
    console.error("Error registrando usuario:", err);
    alert("Error al registrar usuario");
  }
};
</script>
