<template>
  <q-layout view="lHh Lpr lFf">
    <q-page-container class="q-pa-md flex flex-center">
      <div class="row justify-center full-width">
        <div class="col-12 col-sm-8 col-md-5">
          <q-card class="q-pa-lg shadow-6 pedido-card">
            <!-- TÍTULO -->
            <q-card-section class="text-center">
              <q-icon
                name="fastfood"
                size="36px"
                color="primary"
                class="q-mb-sm"
              />
              <div class="text-h6 text-primary text-weight-bold">
                Seguimiento de Pedido
              </div>
            </q-card-section>

            <q-separator />

            <!-- INPUT -->
            <q-card-section class="q-gutter-md">
              <q-input
                v-model="folio"
                label="Ingresa tu folio"
                persistent-hint
                outlined
                dense
                clearable
                color="primary"
                :disable="cargando"
              />

              <q-btn
                label="Consultar estado"
                color="primary"
                icon="search"
                unelevated
                class="full-width"
                :loading="cargando"
                :disable="folio.length < 6"
                @click="consultarPedido"
              />
            </q-card-section>

            <!-- SPINNER -->
            <q-card-section v-if="cargando" class="flex flex-center column">
              <q-spinner-dots size="40px" color="primary" />
              <div class="text-grey-7 q-mt-sm">Buscando tu pedido...</div>
            </q-card-section>

            <!-- TIMELINE -->
            <q-card-section v-if="pedido && !cargando">
              <q-timeline>
                <transition-group name="etapa-pro" tag="div">
                  <q-timeline-entry
                    v-for="etapa in etapasAnimadas"
                    :key="etapa.titulo"
                    :title="etapa.titulo"
                    :subtitle="etapa.subtitulo"
                    :icon="etapa.icono"
                    :color="etapa.color"
                  >
                    <div>{{ etapa.descripcion }}</div>
                  </q-timeline-entry>
                </transition-group>

                <q-timeline-entry
                  v-for="(etapa, index) in etapasPendientes"
                  :key="'pend-' + index"
                  :title="etapa.titulo"
                  :subtitle="etapa.subtitulo"
                  :icon="etapa.icono"
                  color="grey-5"
                  class="etapa-pendiente"
                />
              </q-timeline>
            </q-card-section>

            <!-- PAGAR -->
            <q-card-section v-if="pedido?.status === 0">
              <q-btn
                label="Pagar con PayPal"
                icon="payment"
                color="positive"
                unelevated
                size="lg"
                class="full-width"
                :to="{
                  path: '/pagos',
                  query: { folio: pedido.folio, total: pedido.total },
                }"
              />
            </q-card-section>

            <!-- TICKET -->
            <q-card-section v-if="pedido && ![0, 5].includes(pedido.status)">
              <q-btn
                label="Ver ticket"
                icon="receipt_long"
                color="secondary"
                outline
                class="full-width"
                :to="{ path: '/ticket', query: { folio: pedido.folio } }"
              />
            </q-card-section>

            <!-- CANCELAR -->
            <q-card-section
              v-if="
                pedido && pedido.status !== 5 && [0, 1].includes(pedido.status)
              "
            >
              <q-btn
                label="Cancelar pedido"
                icon="cancel"
                color="negative"
                unelevated
                class="full-width"
                @click="cancelarPedido"
              />
            </q-card-section>

            <!-- NO ENCONTRADO -->
            <q-card-section
              v-if="busquedaRealizada && folio && !pedido && !cargando"
            >
              <div class="text-center text-negative">Pedido no encontrado</div>
            </q-card-section>
          </q-card>
        </div>
      </div>
    </q-page-container>

    <!-- DIALOGO CANCELAR -->
    <q-dialog v-model="dialogCancelar" persistent>
      <q-card class="q-pa-lg dialog-cancelar">
        <q-card-section class="text-center">
          <q-icon name="warning" size="56px" color="negative" />
          <div class="text-h6 q-mt-md text-weight-bold">¿Cancelar pedido?</div>
          <div class="text-grey-7 q-mt-sm">
            Espera {{ contador }} segundos para confirmar
          </div>
        </q-card-section>

        <q-card-actions align="center">
          <q-btn flat label="No" color="primary" v-close-popup />
          <q-btn
            flat
            label="Sí, cancelar"
            color="negative"
            :disable="contador > 0"
            @click="confirmarCancelar"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-layout>
</template>

<script setup>
defineOptions({ name: "EstatusPedidoPage" });

import { ref, computed, onMounted, onBeforeUnmount, watch } from "vue";
import { useRoute } from "vue-router";
import { api } from "src/boot/axios";

const route = useRoute();

const folio = ref("");
const pedido = ref(null);
const cargando = ref(false);
const busquedaRealizada = ref(false);

/* ANIMACIÓN */
const etapasAnimadas = ref([]);
let animTimer = null;

/* CANCELAR */
const dialogCancelar = ref(false);
const contador = ref(5);
let timer = null;
let refreshTimer = null;

/* ETAPAS */
const etapas = [
  {
    titulo: "Esperando pago",
    subtitulo: "Pendiente",
    descripcion: "Esperando tu pago",
    icono: "hourglass_empty",
    color: "warning",
  },
  {
    titulo: "Pago confirmado",
    subtitulo: "Confirmado",
    descripcion: "Validando pedido",
    icono: "payment",
    color: "info",
  },
  {
    titulo: "Preparando",
    subtitulo: "En cocina",
    descripcion: "Preparando tu orden",
    icono: "restaurant",
    color: "primary",
  },
  {
    titulo: "Listo",
    subtitulo: "Para recoger",
    descripcion: "Pedido listo",
    icono: "shopping_bag",
    color: "positive",
  },
  {
    titulo: "Entregado",
    subtitulo: "Completado",
    descripcion: "Buen provecho",
    icono: "done_all",
    color: "positive",
  },
  {
    titulo: "Cancelado",
    subtitulo: "Cancelado",
    descripcion: "Pedido cancelado",
    icono: "cancel",
    color: "negative",
  },
];

const etapasPendientes = computed(() => {
  if (!pedido.value || pedido.value.status === 5) return [];
  return etapas.slice(pedido.value.status + 1, 5);
});

/* ANIMAR */
const animarEtapas = () => {
  etapasAnimadas.value = [];
  clearTimeout(animTimer);

  if (!pedido.value) return;

  const lista =
    pedido.value.status === 5
      ? [etapas[5]]
      : etapas.slice(0, pedido.value.status + 1);

  lista.forEach((etapa, i) => {
    animTimer = setTimeout(() => {
      etapasAnimadas.value.push(etapa);
    }, i * 450);
  });
};

/* API */
const consultarPedido = async () => {
  if (!folio.value) return;
  busquedaRealizada.value = true;
  cargando.value = true;

  try {
    const { data } = await api.get(`ventas/folio/${folio.value}`);
    pedido.value = data;
  } catch {
    pedido.value = null;
  } finally {
    cargando.value = false;
  }
};

/* CANCELAR */
const cancelarPedido = () => {
  contador.value = 5;
  dialogCancelar.value = true;
  timer = setInterval(() => {
    if (contador.value > 0) contador.value--;
    else clearInterval(timer);
  }, 1000);
};

const confirmarCancelar = async () => {
  clearInterval(timer);
  cargando.value = true;
  dialogCancelar.value = false;
  await api.put(`ventas/folio/${pedido.value.folio}/status`, { status: 5 });
  pedido.value.status = 5;
  cargando.value = false;
};

/* AUTO REFRESH */
const iniciarAutoRefresh = () => {
  refreshTimer = setInterval(() => {
    if (!pedido.value) return;
    if ([4, 5].includes(pedido.value.status)) {
      clearInterval(refreshTimer);
      return;
    }
    consultarPedido();
  }, 5000);
};

watch(() => pedido.value?.status, animarEtapas);

onMounted(() => {
  if (route.query.folio) {
    folio.value = route.query.folio;
    consultarPedido();
    iniciarAutoRefresh();
  }
});

onBeforeUnmount(() => {
  clearInterval(refreshTimer);
  clearInterval(timer);
  clearTimeout(animTimer);
});
</script>

<style scoped lang="scss">
.pedido-card {
  border-radius: 18px;
}

.dialog-cancelar {
  border-radius: 16px;
  max-width: 360px;
}

.q-timeline__entry-title {
  font-weight: bold;
}

.etapa-pro-enter-active {
  transition: all 0.45s ease;
}

.etapa-pro-enter-from {
  opacity: 0;
  transform: translateY(18px) scale(0.96);
}

.etapa-pendiente {
  opacity: 0.45;
}
</style>
