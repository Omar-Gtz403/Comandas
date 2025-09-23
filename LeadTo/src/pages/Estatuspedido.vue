<template>
  <q-layout view="lHh Lpr lFf">
    <q-page-container class="q-pa-md flex flex-center">
      <div class="row justify-center full-width">
        <div class="col-12" style="max-width: 400px">
          <q-card class="q-pa-lg shadow-3">
            <!-- Título -->
            <q-card-section>
              <div class="text-h6 text-center q-mb-md">
                <q-icon
                  name="fastfood"
                  color="primary"
                  size="32px"
                  class="q-mr-sm"
                />
                Seguimiento de Pedido
              </div>
            </q-card-section>

            <q-separator />

            <!-- Entrada de folio del pedido -->
            <q-card-section class="q-gutter-md">
              <q-input
                v-model="folio"
                label="Ingresa tu folio de pedido"
                outlined
                type="text"
              />
              <q-btn
                color="primary"
                class="full-width"
                size="lg"
                label="Consultar estado"
                @click="consultarPedido"
              />
            </q-card-section>

            <!-- Timeline -->
            <q-card-section v-if="pedido">
              <q-timeline color="primary">
                <!-- Etapas completadas con animación -->
                <transition-group name="fade-slide" tag="div">
                  <q-timeline-entry
                    v-for="(etapa, index) in etapasMostradas"
                    :key="'anim-' + index"
                    :title="etapa.titulo"
                    :subtitle="etapa.subtitulo"
                    :icon="etapa.icono"
                    color="primary"
                  >
                    <div>{{ etapa.descripcion }}</div>
                  </q-timeline-entry>
                </transition-group>

                <!-- Etapas restantes (gris) -->
                <q-timeline-entry
                  v-for="(etapa, index) in etapasRestantes"
                  :key="'gris-' + index"
                  :title="etapa.titulo"
                  :subtitle="etapa.subtitulo"
                  :icon="etapa.icono"
                  color="grey"
                >
                  <div>{{ etapa.descripcion }}</div>
                </q-timeline-entry>
              </q-timeline>
            </q-card-section>

            <!-- Botón de pago si está en "Esperando pago" -->
            <q-card-section v-if="pedido && pedido.status === 0">
              <q-btn
                color="positive"
                label="Pagar con PayPal"
                class="full-width q-mb-md"
                size="lg"
                icon="payment"
                :to="{
                  path: '/pagos',
                  query: { total: pedido.total, folio: pedido.folio },
                }"
              />
            </q-card-section>

            <!-- Botón para ver ticket -->
            <q-card-section v-if="pedido">
              <q-btn
                color="secondary"
                label="Ver Ticket"
                icon="receipt_long"
                class="full-width q-mb-md"
                size="lg"
                :to="{ path: '/ticket', query: { folio: pedido.folio } }"
              />
            </q-card-section>

            <!-- Mensaje si no existe pedido -->
            <q-card-section v-else-if="folio && !cargando && !pedido">
              <div class="text-negative text-center">Pedido no encontrado</div>
            </q-card-section>
          </q-card>
        </div>
      </div>
    </q-page-container>
  </q-layout>
</template>

<script>
import { ref, computed, onMounted } from "vue";
import { useRoute } from "vue-router";
import { api } from "src/boot/axios";

export default {
  name: "EstatusPedido",
  setup() {
    const route = useRoute();
    const folio = ref("");
    const pedido = ref(null);
    const cargando = ref(false);

    const etapas = [
      {
        titulo: "Esperando pago",
        subtitulo: "Aún no recibimos tu pago",
        descripcion: "En cuanto se confirme podrás seguir el pedido",
        icono: "hourglass_empty",
      },
      {
        titulo: "Pago confirmado",
        subtitulo: "Tu pago fue recibido",
        descripcion: "Estamos validando tu pedido",
        icono: "payment",
      },
      {
        titulo: "Preparando",
        subtitulo: "El restaurante está trabajando en tu pedido",
        descripcion: "Cocinando con cuidado tu orden",
        icono: "restaurant",
      },
      {
        titulo: "Listo para recoger",
        subtitulo: "Puedes venir al mostrador",
        descripcion: "Tu pedido está esperando por ti",
        icono: "shopping_bag",
      },
      {
        titulo: "Entregado",
        subtitulo: "Pedido completado",
        descripcion: "¡Disfruta tu comida!",
        icono: "done_all",
      },
    ];

    const etapasMostradas = ref([]);
    const etapasRestantes = computed(() => {
      if (!pedido.value) return [];
      return etapas.slice(pedido.value.status + 1);
    });

    const consultarPedido = async () => {
      if (!folio.value) return;
      cargando.value = true;
      try {
        const res = await api.get(`ventas/folio/${folio.value}`);
        pedido.value = res.data;

        // Animación secuencial solo para etapas completadas
        etapasMostradas.value = [];
        for (let i = 0; i <= pedido.value.status; i++) {
          setTimeout(() => {
            etapasMostradas.value.push(etapas[i]);
          }, i * 400);
        }
      } catch (error) {
        console.error("Error al consultar pedido:", error);
        pedido.value = null;
        etapasMostradas.value = [];
      } finally {
        cargando.value = false;
      }
    };

    onMounted(() => {
      const folioQuery = route.query.folio;
      if (folioQuery) {
        folio.value = folioQuery;
        consultarPedido();
      }
    });

    return {
      folio,
      pedido,
      etapasMostradas,
      etapasRestantes,
      consultarPedido,
      cargando,
    };
  },
};
</script>

<style scoped>
.q-timeline__entry-title {
  font-weight: bold;
}

/* Animación solo para etapas azules */
.fade-slide-enter-active,
.fade-slide-leave-active {
  transition: all 0.5s ease;
}
.fade-slide-enter-from {
  opacity: 0;
  transform: translateX(-20px);
}
.fade-slide-enter-to {
  opacity: 1;
  transform: translateX(0);
}
.fade-slide-leave-from {
  opacity: 1;
  transform: translateX(0);
}
.fade-slide-leave-to {
  opacity: 0;
  transform: translateX(-20px);
}
</style>
