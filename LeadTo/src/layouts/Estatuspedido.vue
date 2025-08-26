<template>
  <q-layout view="lHh Lpr lFf">
    <q-page-container class="q-pa-md flex flex-center">
      <q-card class="q-pa-lg shadow-3" style="max-width: 500px; width: 100%">
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

        <!-- Entrada de ID del pedido -->
        <q-card-section>
          <q-input
            v-model="pedidoId"
            label="Ingresa tu ID de pedido"
            outlined
            dense
            type="number"
          />
          <q-btn
            color="primary"
            class="q-mt-md full-width"
            label="Consultar estado"
            @click="consultarPedido"
          />
        </q-card-section>

        <!-- Timeline solo si hay pedido -->
        <q-card-section v-if="pedido">
          <q-timeline color="primary">
            <q-timeline-entry
              v-for="(etapa, index) in etapas"
              :key="index"
              :title="etapa.titulo"
              :subtitle="etapa.subtitulo"
              :icon="etapa.icono"
              :color="pedido.status >= index ? 'primary' : 'grey'"
            >
              <div>{{ etapa.descripcion }}</div>
            </q-timeline-entry>
          </q-timeline>
        </q-card-section>

        <!-- Mensaje si no existe pedido -->
        <q-card-section v-else-if="pedidoId && !cargando">
          <div class="text-negative text-center">Pedido no encontrado</div>
        </q-card-section>
      </q-card>
    </q-page-container>
  </q-layout>
</template>

<script>
import { ref } from "vue";
import axios from "axios";

export default {
  name: "EstatusPedido",
  setup() {
    const pedidoId = ref("");
    const pedido = ref(null);
    const cargando = ref(false);

    // Definimos las etapas que reflejan el status del pedido
    const etapas = [
      {
        titulo: "Pago aceptado",
        subtitulo: "Tu pago fue recibido con éxito",
        descripcion: "Estamos confirmando tu pedido en el sistema.",
        icono: "payment",
      },
      {
        titulo: "Pedido realizado",
        subtitulo: "Confirmación en restaurante",
        descripcion: "Tu pedido fue registrado correctamente.",
        icono: "assignment_turned_in",
      },
      {
        titulo: "En preparación",
        subtitulo: "Los cocineros están trabajando",
        descripcion: "Estamos preparando tu pedido.",
        icono: "restaurant",
      },
      {
        titulo: "Listo para recoger",
        subtitulo: "Puedes venir al mostrador",
        descripcion: "Tu pedido está listo para ser recogido.",
        icono: "shopping_bag",
      },
      {
        titulo: "Entregado",
        subtitulo: "Pedido completado",
        descripcion: "Tu pedido fue entregado. ¡Buen provecho!",
        icono: "done_all",
      },
    ];

    // Método para consultar al backend
    const consultarPedido = async () => {
      if (!pedidoId.value) return;
      cargando.value = true;
      try {
        const res = await axios.get(
          `http://localhost:8082/api/ventas/${pedidoId.value}`
        );
        pedido.value = res.data;
      } catch (error) {
        console.error("Error al consultar pedido:", error);
        pedido.value = null; // si no lo encuentra
      } finally {
        cargando.value = false;
      }
    };

    return {
      pedidoId,
      pedido,
      etapas,
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
</style>
