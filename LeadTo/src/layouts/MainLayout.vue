<template>
  <q-layout view="lHh Lpr lFf">
    <!-- Header -->
    <q-header elevated class="bg-primary text-white">
      <q-toolbar>
        <q-btn flat @click="drawer = !drawer" round dense icon="menu" />
        <q-toolbar-title>Mi Dashboard</q-toolbar-title>
      </q-toolbar>
    </q-header>

    <!-- Sidebar / Drawer -->
    <q-drawer v-model="drawer" show-if-above :width="220" bordered>
      <!-- Perfil / Imagen superior -->
      <q-img
        class="absolute-top"
        src="https://cdn.quasar.dev/img/material.png"
        style="height: 120px"
      >
        <div class="absolute-bottom bg-transparent q-pa-sm">
          <q-avatar size="50px" class="q-mb-xs">
            <img src="https://cdn.quasar.dev/img/boy-avatar.png" />
          </q-avatar>
          <div class="text-weight-bold">
            {{ usuario?.nombreUsuario || "." }}
          </div>
          <div>@</div>
        </div>
      </q-img>

      <!-- Lista de secciones -->
      <q-scroll-area style="height: calc(100% - 120px); margin-top: 120px">
        <q-list padding>
          <!-- 📌 Opciones para clientes -->
          <q-item clickable v-ripple @click="irA('/')">
            <q-item-section avatar>
              <q-icon name="restaurant_menu" />
            </q-item-section>
            <q-item-section>Menú</q-item-section>
          </q-item>

          <q-item clickable v-ripple @click="irA('/status')">
            <q-item-section avatar>
              <q-icon name="receipt_long" />
            </q-item-section>
            <q-item-section>Estatus De Mi Pedido</q-item-section>
          </q-item>

          <!-- 📌 Opciones de administración (solo empresa) -->
          <template v-if="[1, 2].includes(usuario?.permiso)">
            <q-separator spaced />
            <div class="text-subtitle2 text-grey q-px-md q-mb-sm">
              Administración
            </div>

            <q-item clickable v-ripple @click="irA('/registro')">
              <q-item-section avatar>
                <q-icon name="add_box" />
              </q-item-section>
              <q-item-section>Registrar Producto</q-item-section>
            </q-item>
            <q-item clickable v-ripple @click="irA('/scan')">
              <q-item-section avatar>
                <q-icon name="camera" />
              </q-item-section>
              <q-item-section>Escanear Ticket</q-item-section>
            </q-item>
            <q-item clickable v-ripple @click="irA('/pagos')">
              <q-item-section avatar>
                <q-icon name="payment" />
              </q-item-section>
              <q-item-section>Pagos</q-item-section>
            </q-item>

            <q-item clickable v-ripple @click="irA('/productos')">
              <q-item-section avatar>
                <q-icon name="inventory_2" />
              </q-item-section>
              <q-item-section>Lista de Productos</q-item-section>
            </q-item>

            <q-item clickable v-ripple @click="irA('/pedidos')">
              <q-item-section avatar>
                <q-icon name="shopping_cart" />
              </q-item-section>
              <q-item-section>Pedidos</q-item-section>
            </q-item>

            <!-- Botón de cerrar sesión -->
            <q-separator spaced />
            <q-item clickable v-ripple @click="cerrarSesion">
              <q-item-section avatar>
                <q-icon name="logout" />
              </q-item-section>
              <q-item-section>Cerrar Sesión</q-item-section>
            </q-item>
          </template>
        </q-list>
      </q-scroll-area>
    </q-drawer>

    <!-- Contenido principal -->
    <q-page-container>
      <router-view />
    </q-page-container>

    <!-- Footer -->
    <q-footer class="bg-grey-2 text-black q-py-md" elevated>
      <q-toolbar class="justify-center">
        <div class="text-center text-subtitle2">Dashboard</div>
      </q-toolbar>
    </q-footer>
  </q-layout>
</template>

<script>
import { ref } from "vue";
import { useRouter } from "vue-router";

export default {
  setup() {
    const drawer = ref(false);
    const router = useRouter();

    // Obtener usuario desde localStorage
    const usuario = JSON.parse(localStorage.getItem("usuario"));

    const irA = (ruta) => {
      drawer.value = false;
      router.push(ruta);
    };

    const cerrarSesion = () => {
      localStorage.removeItem("usuario");
      router.push("/login");
    };

    return { drawer, irA, usuario, cerrarSesion };
  },
};
</script>

<style scoped lang="sass">
.q-drawer
  background-color: #f5f5f5
.q-avatar img
  object-fit: cover
</style>
