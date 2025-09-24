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
            <q-card-section v-if="pedido && ![0, 5].includes(pedido.status)">
              <q-btn
                color="secondary"
                label="Ver Ticket"
                icon="receipt_long"
                class="full-width q-mb-md"
                size="lg"
                :to="{ path: '/ticket', query: { folio: pedido.folio } }"
              />
            </q-card-section>

            <!-- Botón de cancelar pedido -->
            <q-card-section v-if="pedido && [0, 1].includes(pedido.status)">
              <q-btn
                color="negative"
                label="Cancelar Pedido"
                icon="cancel"
                class="full-width"
                @click="cancelarPedido"
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

    <!-- Dialogo persuasivo de cancelación -->
    <q-dialog v-model="dialogCancelar" persistent>
      <q-card class="dialog-persuasivo">
        <q-card-section class="text-center">
          <q-icon name="warning" size="64px" class="icon-warning" />
          <div class="text-h6 q-mt-md mensaje-persuasivo">
            ⚠️ ¡Espera! Antes de cancelar...
          </div>
          <div class="q-mt-sm mensaje-secundario">
            Tu pedido está en proceso y cancelarlo ahora puede retrasar tu
            comida o perder tu lugar en la preparación.
            <br />
            ¡Considera pagar o esperar un momento para evitar molestias!
          </div>
          <div
            v-if="contador > 0"
            class="q-mt-md text-weight-bold text-negative contador-animado"
          >
            Espera {{ contador }} segundos antes de poder cancelar
          </div>
        </q-card-section>

        <q-card-actions align="center" class="q-mt-md">
          <q-btn flat label="No cancelar" color="primary" v-close-popup />
          <q-btn
            flat
            label="Cancelar pedido"
            color="negative"
            :disable="contador > 0"
            class="fade-in"
            @click="confirmarCancelar"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>
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

    const dialogCancelar = ref(false);
    const contador = ref(5);
    let timer = null;

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
      {
        titulo: "Cancelado",
        subtitulo: "Pedido cancelado",
        descripcion: "Esperamos verte pronto de nuevo",
        icono: "cancel",
      },
    ];

    const etapasMostradas = ref([]);
    const etapasRestantes = computed(() => {
      if (!pedido.value) return [];
      // Si está cancelado, no mostrar etapas futuras
      if (pedido.value.status === 5) return [];
      // Si está en esperando pago o pago confirmado, bloquear etapas posteriores
      if ([0, 1].includes(pedido.value.status))
        return etapas
          .slice(pedido.value.status + 1)
          .map((e) => ({ ...e, bloqueado: true }));
      return etapas.slice(pedido.value.status + 1);
    });

    const consultarPedido = async () => {
      if (!folio.value) return;
      cargando.value = true;
      try {
        const res = await api.get(`ventas/folio/${folio.value}`);
        pedido.value = res.data;

        // Limpiar etapas
        etapasMostradas.value = [];

        // Si está cancelado, mostrar solo etapa cancelada
        if (pedido.value.status === 5) {
          etapasMostradas.value.push(etapas[5]);
        } else if ([0, 1].includes(pedido.value.status)) {
          // Solo mostrar etapas hasta la actual
          for (let i = 0; i <= pedido.value.status; i++) {
            setTimeout(() => {
              etapasMostradas.value.push(etapas[i]);
            }, i * 400);
          }
        } else {
          // Mostrar todas las etapas hasta la actual
          for (let i = 0; i <= pedido.value.status; i++) {
            setTimeout(() => {
              etapasMostradas.value.push(etapas[i]);
            }, i * 400);
          }
        }
      } catch (error) {
        console.error("Error al consultar pedido:", error);
        pedido.value = null;
        etapasMostradas.value = [];
      } finally {
        cargando.value = false;
      }
    };

    const cancelarPedido = () => {
      contador.value = 5;
      dialogCancelar.value = true;
      timer = setInterval(() => {
        if (contador.value > 0) {
          contador.value--;
        } else {
          clearInterval(timer);
        }
      }, 1000);
    };

    const confirmarCancelar = async () => {
      clearInterval(timer);
      dialogCancelar.value = false;
      if (!pedido.value) return;
      cargando.value = true;
      try {
        await api.put(`ventas/folio/${pedido.value.folio}/status`, {
          status: 5,
        });
        pedido.value.status = 5;
        etapasMostradas.value = [etapas[5]]; // Mostrar solo cancelado
      } catch (error) {
        console.error("No se pudo cancelar el pedido:", error);
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
      dialogCancelar,
      contador,
      cancelarPedido,
      confirmarCancelar,
    };
  },
};
</script>

<style scoped>
.q-timeline__entry-title {
  font-weight: bold;
}

/* Animación de timeline */
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

/* Dialogo persuasivo */
.dialog-persuasivo {
  border-radius: 16px;
  max-width: 420px;
  background: linear-gradient(135deg, #ffcc80, #ff8a65);
  animation: pulseDialog 1.5s infinite alternate;
}

.icon-warning {
  animation: pulseIcon 1.2s infinite alternate;
}

@keyframes pulseIcon {
  0% {
    transform: scale(1);
    color: #d32f2f;
  }
  50% {
    transform: scale(1.2);
    color: #ff5252;
  }
  100% {
    transform: scale(1);
    color: #d32f2f;
  }
}

.mensaje-persuasivo {
  font-weight: bold;
  animation: fadeInText 1s ease forwards;
}

.mensaje-secundario {
  animation: fadeInText 2s ease forwards;
}

.contador-animado {
  font-size: 1.1rem;
  animation: blinkText 1s infinite;
}

.fade-in {
  animation: fadeInText 1s ease forwards;
}

@keyframes pulseDialog {
  0% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.02);
  }
  100% {
    transform: scale(1);
  }
}

@keyframes fadeInText {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes blinkText {
  0%,
  100% {
    opacity: 1;
  }
  50% {
    opacity: 0;
  }
}
</style>
