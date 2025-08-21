<template>
  <q-layout view="lHh Lpr lFf">
    <q-header elevated class="bg-primary text-white">
      <q-toolbar>
        <q-toolbar-title class="text-h6 text-center text-uppercase">
          Pagos
        </q-toolbar-title>
      </q-toolbar>
    </q-header>

    <q-page-container>
      <div class="q-pa-md flex flex-center column">
        <q-card class="q-pa-lg shadow-2" style="max-width: 420px; width: 100%;">
          <q-card-section>
            <div class="text-h6 text-center q-mb-md">
              <q-icon name="payment" color="blue" size="28px" class="q-mr-sm" />
              Pago con PayPal
            </div>
            <div class="text-subtitle2 text-center q-mb-lg">
              Total a pagar: <span class="text-primary text-bold">${{ total.toFixed(2) }}</span>
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

export default {
  setup() {
    const $q = useQuasar();
    const route = useRoute();
    const total = ref(Number(route.query.total) || 0);

    // Integración de PayPal
    onMounted(() => {
      if (!window.paypal) {
        const script = document.createElement("script");
        script.src = "https://www.paypal.com/sdk/js?client-id=AbIF1bjrsqCAcyqb3Hh9rBgsUX8NArLpGhzSRMdLtJHUg531mh9Y9Fme8RjJU07ncNI7z4mcjlY8jQrw&currency=MXN";
        script.onload = renderPayPalButton;
        document.body.appendChild(script);
      } else {
        renderPayPalButton();
      }
    });

    function renderPayPalButton() {
      window.paypal.Buttons({
        createOrder: function(data, actions) {
          return actions.order.create({
            purchase_units: [{
              amount: {
                value: total.value.toFixed(2)
              }
            }]
          });
        },
        onApprove: function(data, actions) {
          return actions.order.capture().then(function(details) {
            $q.notify({
              type: "positive",
              message: `Pago realizado por ${details.payer.name.given_name}`,
              position: "top",
            });
          });
        },
        onError: function(err) {
          $q.notify({
            type: "negative",
            message: "Error en el pago con PayPal",
            position: "top",
          });
        }
      }).render("#paypal-button-container");
    }

    return {
      total,
    };
  },
};
</script>
