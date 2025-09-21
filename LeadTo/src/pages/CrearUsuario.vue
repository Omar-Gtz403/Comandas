<template>
  <q-page
    class="flex flex-center bg-gradient-to-r from-blue-500 to-indigo-600 q-pa-md"
  >
    <div
      class="w-full max-w-md bg-white/90 backdrop-blur-md rounded-2xl shadow-2xl p-8 transition-all duration-300 hover:scale-[1.01]"
    >
      <h2
        class="text-3xl font-extrabold text-center text-gray-800 mb-8 tracking-tight"
      >
        Registrar Usuario
      </h2>

      <q-form @submit="registrarUsuario" class="q-gutter-md">
        <q-input
          v-model="usuario.nombreUsuario"
          label="Nombre de Usuario"
          outlined
          dense
          standout="bg-blue-50 text-black"
          class="rounded-lg"
          color="primary"
          required
        />

        <q-input
          v-model="usuario.password"
          type="password"
          label="Contraseña"
          outlined
          dense
          standout="bg-blue-50 text-black"
          class="rounded-lg"
          color="primary"
          required
        />

        <q-select
          v-model="usuario.permiso"
          :options="permisos"
          label="Permiso"
          outlined
          dense
          standout="bg-blue-50 text-black"
          class="rounded-lg"
          color="primary"
        />

        <q-btn
          label="Registrar"
          type="submit"
          color="primary"
          class="w-full py-3 text-lg font-bold rounded-lg shadow-lg transition-all duration-300 hover:shadow-xl hover:scale-[1.02]"
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
  permiso: 1,
});

const permisos = [
  { label: "Administrador", value: 1 },
  { label: "Usuario", value: 0 },
];

const registrarUsuario = async () => {
  try {
    await api.post("/auth/register", usuario.value);
    $q.notify({ type: "positive", message: "Usuario registrado con éxito" });
    usuario.value = { nombreUsuario: "", password: "", permiso: 1 };
    router.push("/productos");
  } catch (err) {
    console.error("Error registrando usuario:", err);
    $q.notify({ type: "negative", message: "Error al registrar usuario" });
  }
};
</script>
