<template>
  <q-page padding>
    <div class="max-w-md mx-auto bg-white p-6 rounded-xl shadow-md">
      <h2 class="text-xl font-bold mb-4">Iniciar Sesión</h2>

      <q-form @submit="login" class="q-gutter-md">
        <q-input
          v-model="credenciales.nombreUsuario"
          label="Nombre de Usuario"
          outlined
          required
        />
        <q-input
          v-model="credenciales.password"
          type="password"
          label="Contraseña"
          outlined
          required
        />
        <q-btn
          label="Ingresar"
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

const credenciales = ref({
  nombreUsuario: "",
  password: "",
});

const login = async () => {
  try {
    const { data } = await api.post("/auth/login", credenciales.value);

    localStorage.setItem("usuario", JSON.stringify(data));

    alert("Bienvenido " + data.nombreUsuario);
    router.push("/productos");
  } catch (err) {
    console.error("Error login:", err);
    alert("Usuario o contraseña incorrectos");
  }
};
</script>
