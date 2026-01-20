<template>
  <q-layout view="lHh Lpr lFf">
    <!-- HEADER -->
    <q-header elevated class="bg-primary text-white">
      <q-toolbar>
        <q-btn flat dense round icon="menu" @click="drawer = !drawer" />

        <q-avatar size="42px" class="q-ml-sm">
          <img src="../assets/logo.jpg" />
        </q-avatar>

        <q-toolbar-title class="text-weight-bold q-ml-sm">
          {{ tituloPagina }}
        </q-toolbar-title>
      </q-toolbar>
    </q-header>

    <!-- DRAWER -->
    <q-drawer v-model="drawer" show-if-above bordered class="bg-grey-1">
      <!-- PERFIL -->
      <div class="drawer-header">
        <q-avatar size="72px" class="shadow-3">
          <img src="../assets/logo.jpg" />
        </q-avatar>

        <div class="text-weight-bold q-mt-sm">
          {{ usuario ? usuario.nombreUsuario : "Bienvenido" }}
        </div>

        <div class="text-caption text-grey-7">
          {{
            usuario ? usuario.rol?.nombre : "Mariscos frescos todos los días"
          }}
        </div>
      </div>

      <!-- MENÚ -->
      <q-scroll-area class="drawer-scroll">
        <q-list padding>
          <!-- ADMIN -->
          <template v-if="usuario && rutasRol.length">
            <div class="drawer-section">Administración</div>

            <q-item
              v-for="r in rutasRol"
              :key="r"
              clickable
              v-ripple
              :active="route.path === r"
              active-class="item-activo"
              @click="irA(r)"
            >
              <q-item-section avatar>
                <q-icon :name="iconos[r]" />
              </q-item-section>
              <q-item-section>
                {{ titulos[r] }}
              </q-item-section>
            </q-item>

            <q-separator spaced />
          </template>

          <!-- CLIENTE -->
          <template v-if="!usuario">
            <div class="drawer-section">Cliente</div>

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
              <q-item-section>Mi Pedido</q-item-section>
            </q-item>
          </template>

          <!-- LOGOUT -->
          <template v-if="usuario">
            <q-separator spaced />
            <q-item clickable v-ripple @click="cerrarSesion">
              <q-item-section avatar>
                <q-icon name="logout" />
              </q-item-section>
              <q-item-section>Cerrar sesión</q-item-section>
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

const rutasRol = usuario?.rol?.permisos?.map((p) => p.ruta) || [];

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
  "/": "Menú",
  "/caja": "Caja",
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
  "/registrousuario": "person",
  "/": "restaurant_menu",
  "/caja": "money",
};

const tituloPagina = computed(() => titulos[route.path] || "Marisquería");

const irA = (ruta) => {
  drawer.value = false;
  router.push(ruta);
};

const cerrarSesion = () => {
  localStorage.removeItem("usuario");
  router.push("/login");
};
</script>
<style scoped lang="sass">
/* HEADER */
.q-header
  box-shadow: var(--q-toolbar-shadow)

/* DRAWER */
.drawer-header
  padding: 24px
  text-align: center


.drawer-scroll
  height: calc(100% - 170px)

/* SECCIONES */
.drawer-section
  font-size: 12px
  font-weight: 600
  color: var(--q-text-color-secondary)
  text-transform: uppercase
  margin: 12px 16px 6px

/* ITEMS */
.q-item
  border-radius: var(--q-border-radius)
  margin: 4px 8px
  color: var(--q-text-color)
  transition: background-color .2s ease, color .2s ease

.q-item:hover
  background: rgba(2, 119, 189, 0.08) // secondary suave

/* ITEM ACTIVO */
.item-activo
  background: rgba(198, 40, 40, 0.15) // primary con opacidad
  color: var(--q-primary)
  font-weight: 600

.q-item--active .q-icon
  color: var(--q-primary)
</style>
