<template>
  <q-layout view="lHh Lpr lFf">
    <q-page-container>
      <div class="q-pa-md flex flex-center column">
        <q-card class="q-pa-lg shadow-2" style="max-width: 420px; width: 100%">
          <q-card-section>
            <div class="text-h6 text-center q-mb-md">
              <q-icon name="payment" color="blue" size="28px" class="q-mr-sm" />
              Pago con PayPal
            </div>
            <div class="text-subtitle2 text-center q-mb-lg">
              Total a pagar:

              <span class="text-primary text-bold"
                >${{ total.toFixed(2) }}</span
              >
            </div>
            <div class="text-subtitle2 text-center q-mb-lg">
              id venta:
              <span class="text-primary text-bold">{{ idVenta }}</span>
            </div>

            <div class="text-center q-mb-md">
              <div id="paypal-button-container"></div>
            </div>
          </q-card-section>
        </q-card>
      </div>
    </q-page-container>

    <q-footer class="bg-grey-2 text-black q-py-md" elevated>
      <q-toolbar class="justify-center">
        <div class="text-center text-subtitle2">Pagos</div>
      </q-toolbar>
    </q-footer>
  </q-layout>
</template>

<script>
import { ref, onMounted } from "vue";
import { useQuasar } from "quasar";
import { useRoute } from "vue-router";
import axios from "axios";

export default {
  setup() {
    const $q = useQuasar();
    const route = useRoute();
    const total = ref(Number(route.query.total) || 0);
    const idVenta = ref(route.query.idVenta || null); // ✅ ahora es ref

    // Integración de PayPal
    onMounted(() => {
      if (!window.paypal) {
        const script = document.createElement("script");
        script.src =
          "https://www.paypal.com/sdk/js?client-id=AbIF1bjrsqCAcyqb3Hh9rBgsUX8NArLpGhzSRMdLtJHUg531mh9Y9Fme8RjJU07ncNI7z4mcjlY8jQrw&currency=MXN";
        script.onload = renderPayPalButton;
        document.body.appendChild(script);
      } else {
        renderPayPalButton();
      }
    });

    function renderPayPalButton() {
      window.paypal
        .Buttons({
          createOrder: (data, actions) => {
            return actions.order.create({
              purchase_units: [
                {
                  amount: { value: total.value.toFixed(2) },
                },
              ],
            });
          },
          onApprove: (data, actions) => {
            return actions.order.capture().then(async (details) => {
              $q.notify({
                type: "positive",
                message: `Pago realizado por ${details.payer.name.given_name}`,
                position: "top",
              });

              // 🔹 Marcar la venta como pagada en backend
              if (idVenta.value) {
                try {
                  // Actualizar el status de la venta a "Pago confirmado" (1)
                  await axios.put(
                    `http://localhost:8082/api/ventas/${idVenta.value}/status`,
                    { status: 1 }, // 👈 este es el campo que espera tu backend
                    { headers: { "Content-Type": "application/json" } }
                  );

                  $q.notify({
                    type: "positive",
                    message: "El pedido se actualizó como pagado ✅",
                    position: "top",
                  });
                } catch (err) {
                  console.error(err);
                  $q.notify({
                    type: "negative",
                    message: "No se pudo actualizar el estado del pedido ❌",
                    position: "top",
                  });
                }
              }
            });
          },

          onError: (err) => {
            console.error(err);
            $q.notify({
              type: "negative",
              message: "Error en el pago con PayPal ❌",
              position: "top",
            });
          },
        })
        .render("#paypal-button-container");
    }

    return {
      total,
      idVenta, // ✅ expuesto a la vista
    };
  },
};
</script>
