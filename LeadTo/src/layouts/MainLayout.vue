<template>
  <q-layout view="lHh Lpr lFf" class="layout-root">
    <!-- ================= HEADER ================= -->
    <q-header elevated class="app-header">
      <q-toolbar class="q-px-md">
        <q-btn
          flat
          dense
          round
          icon="menu"
          class="q-mr-sm"
          @click="drawer = !drawer"
        />

        <q-avatar size="42px" class="shadow-4">
          <img src="../assets/logo.jpg" />
        </q-avatar>

        <q-toolbar-title class="q-ml-sm">
          <div class="text-weight-bold text-subtitle1">
            {{ tituloPagina }}
          </div>
          <div class="text-caption header-subtitle">
            {{ subtitulo }}
          </div>
        </q-toolbar-title>

        <q-space />

        <!-- ACCIONES CLIENTE -->
        <template v-if="!usuario">
          <q-btn flat round icon="restaurant_menu" @click="irA('/')" />
          <q-btn flat round icon="receipt_long" @click="irA('/status')">
            <q-badge v-if="pedidoActivo" color="negative" floating rounded />
          </q-btn>
        </template>
      </q-toolbar>
    </q-header>

    <!-- ================= DRAWER ================= -->
    <q-drawer v-model="drawer" show-if-above bordered class="app-drawer">
      <!-- PERFIL -->
      <div class="drawer-header">
        <q-avatar size="76px" class="shadow-6 q-mb-sm">
          <img src="../assets/logo.jpg" />
        </q-avatar>

        <div class="text-subtitle1 text-weight-bold">
          {{ usuario ? usuario.nombreUsuario : "Bienvenido" }}
        </div>

        <div class="text-caption text-secondary">
          {{ usuario ? usuario.rol?.nombre : "Pedido en restaurante" }}
        </div>
      </div>

      <q-separator />

      <q-scroll-area class="drawer-scroll">
        <q-list padding>
          <!-- ================= ADMIN ================= -->
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
          </template>

          <!-- ================= CLIENTE ================= -->
          <template v-if="!usuario">
            <div class="drawer-section">Tu pedido</div>

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
              <q-item-section>
                Mi pedido
                <div class="text-caption text-grey-6">Estado y seguimiento</div>
              </q-item-section>
            </q-item>

            <!-- ===== CONTEXTO DE EXPERIENCIA ===== -->
            <q-separator spaced />

            <div class="drawer-context q-pa-md">
              <div class="text-subtitle2 text-weight-bold q-mb-sm">
                Pedido en local
              </div>

              <div class="row items-center q-mb-xs">
                <q-icon
                  name="check_circle"
                  size="18px"
                  color="positive"
                  class="q-mr-sm"
                />
                <span class="text-caption">Preparado al momento</span>
              </div>

              <div class="row items-center q-mb-xs">
                <q-icon name="schedule" size="18px" class="q-mr-sm" />
                <span class="text-caption">Tiempo estimado 15–25 min</span>
              </div>

              <div class="row items-center">
                <q-icon name="payments" size="18px" class="q-mr-sm" />
                <span class="text-caption">Pago al confirmar</span>
              </div>
            </div>

            <!-- ===== MARCA SUTIL ===== -->
            <div class="drawer-brand q-pa-md text-center">
              <div class="text-caption text-secondary">
                🌊 Solo Veracruz Es Bello
              </div>
            </div>
          </template>

          <!-- ================= LOGOUT ================= -->
          <template v-if="usuario">
            <q-separator spaced />
            <q-item clickable v-ripple @click="cerrarSesion">
              <q-item-section avatar>
                <q-icon name="logout" color="negative" />
              </q-item-section>
              <q-item-section class="text-negative">
                Cerrar sesión
              </q-item-section>
            </q-item>
          </template>
        </q-list>
      </q-scroll-area>
    </q-drawer>

    <!-- ================= CONTENIDO ================= -->
    <q-page-container>
      <router-view />
    </q-page-container>

    <!-- ================= FOOTER ================= -->
    <q-footer class="app-footer">
      <div class="q-pa-sm text-caption text-center">
        © {{ new Date().getFullYear() }} Marisquería · Solo Veracruz Es Bello
      </div>
    </q-footer>
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

const pedidoActivo = computed(() => {
  return !!localStorage.getItem("pedidoActivo");
});

const titulos = {
  "/dashboard": "Dashboard",
  "/registro": "Registrar Productos",
  "/pedidos": "Tablero de Pedidos",
  "/inventario": "Inventario",
  "/pagos": "Pagos",
  "/status": "Mi Pedido",
  "/rol": "Crear Roles",
  "/scan": "Escanear QR",
  "/categorias": "Administrador de Categorías",
  "/productos": "Administrador de Productos",
  "/registrousuario": "Registrar Usuarios",
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
  "/caja": "payments",
};

const tituloPagina = computed(() => titulos[route.path] || "Marisquería");

const subtitulo = computed(() => {
  if (!usuario && route.path === "/") return "Explora nuestros platillos";
  if (!usuario && route.path === "/status")
    return "Sigue tu pedido en tiempo real";
  return "";
});

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

.layout-root
  background: var(--q-grey-1)

.app-header
  background: var(--q-primary)
  color: white

.header-subtitle
  opacity: .9

.app-drawer
  background: var(--q-grey-1)

.drawer-header
  padding: 24px
  text-align: center
  background: linear-gradient(
    180deg,
    rgba(var(--q-secondary-rgb), .18),
    transparent
  )

.drawer-scroll
  height: calc(100% - 220px)

.drawer-section
  font-size: 11px
  font-weight: 700
  letter-spacing: .6px
  text-transform: uppercase
  margin: 18px 16px 8px
  color: var(--q-text-color-secondary)

.drawer-context
  background: rgba(var(--q-secondary-rgb), .08)
  border-radius: var(--q-border-radius)

.drawer-brand
  opacity: .75

.q-item
  border-radius: var(--q-border-radius)
  margin: 6px 10px
  transition: all .2s ease

.q-item:hover
  background: rgba(var(--q-secondary-rgb), .10)
  transform: translateX(4px)

.item-activo
  background: rgba(var(--q-primary-rgb), .18)
  color: var(--q-primary)
  font-weight: 600

.app-footer
  background: var(--q-primary)
  color: white
</style>
