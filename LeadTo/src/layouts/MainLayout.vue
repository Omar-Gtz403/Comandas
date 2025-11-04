<template>
  <q-layout view="lHh Lpr lFf">
    <!-- HEADER -->
    <q-header elevated class="bg-primary text-white">
      <q-toolbar>
        <q-btn flat @click="drawer = !drawer" round dense icon="menu" />
        <q-toolbar-title>{{ tituloPagina }}</q-toolbar-title>
      </q-toolbar>
    </q-header>

    <!-- DRAWER -->
    <q-drawer v-model="drawer" show-if-above :width="240" bordered>
      <!-- Perfil -->
      <q-img
        class="absolute-top"
        src="https://cdn.quasar.dev/img/material.png"
        style="height: 130px"
      >
        <div class="absolute-bottom bg-transparent q-pa-sm text-center">
          <q-avatar size="56px" class="q-mb-xs shadow-2">
            <img src="https://cdn.quasar.dev/img/boy-avatar.png" />
          </q-avatar>
          <div class="text-weight-bold text-white">
            {{ usuario ? usuario.nombreUsuario : "Bienvenido 👋" }}
          </div>
          <div class="text-caption text-grey-2">
            {{ usuario ? usuario.rol?.nombre : "¿Listo para el antojo?" }}
          </div>
        </div>
      </q-img>

      <!-- MENÚ LATERAL -->
      <q-scroll-area style="height: calc(100% - 130px); margin-top: 130px">
        <q-list padding>
          <!-- 🔹 SECCIÓN ADMINISTRACIÓN -->
          <template v-if="usuario && rutasRol.length">
            <div class="text-subtitle2 text-grey q-px-md q-mb-sm">
              Administración
            </div>

            <q-item
              v-for="r in rutasRol"
              :key="r"
              clickable
              v-ripple
              @click="irA(r)"
            >
              <q-item-section avatar>
                <q-icon :name="iconos[r] || 'folder'" />
              </q-item-section>
              <q-item-section>{{ titulos[r] || r }}</q-item-section>
            </q-item>

            <q-separator spaced />
          </template>

          <!-- 🔹 SECCIÓN CLIENTE -->
          <template v-if="!usuario">
            <div class="text-subtitle2 text-grey q-px-md q-mb-sm">Cliente</div>

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
              <q-item-section>Estatus de Pedido</q-item-section>
            </q-item>

            <q-separator spaced />
          </template>

          <!-- 🔹 CERRAR SESIÓN -->
          <template v-if="usuario">
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

    <!-- CONTENIDO -->
    <q-page-container>
      <router-view />
    </q-page-container>
  </q-layout>
</template>

<script setup>
import { ref, computed } from "vue";
import { useRouter, useRoute } from "vue-router";

const drawer = ref(false);
const router = useRouter();
const route = useRoute();

const usuario = JSON.parse(localStorage.getItem("usuario"));

// 🔹 Rutas según permisos del rol (solo si hay sesión)
const rutasRol = usuario?.rol?.permisos?.map((p) => p.ruta) || [];

// 🔹 Mapas de títulos e íconos
const titulos = {
  "/dashboard": "Dashboard",
  "/registro": "Registro",
  "/pedidos": "Pedidos",
  "/inventario": "Inventario",
  "/pagos": "Pagos",
  "/status": "Estatus",
  "/rol": "Roles",
  "/scan": "Escanear QR",
  "/categorias": "Categorías",
  "/productos": "Productos",
  "/registrousuario": "Usuarios",
  "/": "Menu Comida",
};

const iconos = {
  "/dashboard": "dashboard",
  "/registro": "folder",
  "/pedidos": "shopping_cart",
  "/inventario": "inventory",
  "/pagos": "credit_card",
  "/status": "receipt_long",
  "/rol": "verified_user",
  "/scan": "qr_code_scanner",
  "/categorias": "category",
  "/productos": "inventory_2",
  "/registrousuario": "person_add",
  "/": "restaurant_menu",
};

// 🔹 Título dinámico
const tituloPagina = computed(() => titulos[route.path] || "Inicio");

// 🔹 Navegación
const irA = (ruta) => {
  drawer.value = false;
  router.push(ruta);
};

// 🔹 Cerrar sesión
const cerrarSesion = () => {
  localStorage.removeItem("usuario");
  router.push("/login");
};
</script>

<style scoped lang="sass">
.q-drawer
  background-color: #f5f5f5

.q-avatar img
  object-fit: cover

.text-subtitle2
  font-weight: 600
  text-transform: uppercase
  letter-spacing: 0.5px

.q-item
  border-radius: 8px
  margin: 2px 8px
  transition: background-color 0.2s ease
.q-item:hover
  background-color: #e0e0e0
</style>
