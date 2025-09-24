<template>
  <q-layout view="lHh Lpr lFf">
    <q-page-container>
      <div class="q-pa-md flex flex-center column">
        <q-card
          v-if="folioValido"
          class="q-pa-lg shadow-2"
          style="max-width: 420px; width: 100%"
        >
          <q-card-section>
            <div class="text-h6 text-center q-mb-md">
              <q-icon name="payment" color="blue" size="28px" class="q-mr-sm" />
              Pago con PayPal
            </div>
            <div class="text-subtitle2 text-center q-mb-lg">
              Total a pagar:
              <span class="text-primary text-bold">
                ${{ total.toFixed(2) }}
              </span>
            </div>
            <div class="text-subtitle2 text-center q-mb-lg">
              ID venta:
              <span class="text-primary text-bold">{{ folio }}</span>
            </div>

            <div class="text-center q-mb-md">
              <div id="paypal-button-container"></div>
            </div>
          </q-card-section>
        </q-card>

        <q-card
          v-else
          class="q-pa-lg shadow-2 bg-negative text-white"
          style="max-width: 420px; width: 100%"
        >
          <q-card-section class="text-center">
            ⚠️ Folio inválido o no encontrado.
          </q-card-section>
        </q-card>
      </div>
    </q-page-container>
  </q-layout>
</template>

<script>
import { ref, onMounted } from "vue";
import { useQuasar } from "quasar";
import { useRoute, useRouter } from "vue-router";
import { api } from "src/boot/axios";

export default {
  name: "PagosComandas",
  setup() {
    const $q = useQuasar();
    const route = useRoute();
    const router = useRouter();

    const folio = ref(route.query.folio || null);
    const total = ref(0);
    const folioValido = ref(false);

    const cargarPedido = async () => {
      if (!folio.value) {
        folioValido.value = false;
        return;
      }
      try {
        const res = await api.get(`/ventas/folio/${folio.value}`);
        if (res.data && res.data.status === 0) {
          // pendiente de pago
          folioValido.value = true;
          total.value = Number(res.data.total) || 0;
        } else {
          folioValido.value = false;
        }
      } catch (err) {
        console.error(err);
        folioValido.value = false;
      }
    };

    const renderPayPalButton = () => {
      if (!window.paypal || !folioValido.value) return;

      window.paypal
        .Buttons({
          createOrder: (data, actions) => {
            return actions.order.create({
              purchase_units: [{ amount: { value: total.value.toFixed(2) } }],
            });
          },
          onApprove: (data, actions) => {
            return actions.order.capture().then(async (details) => {
              $q.notify({
                type: "positive",
                message: `Pago realizado por ${details.payer.name.given_name}`,
                position: "top",
              });

              try {
                await api.put(`/ventas/folio/${folio.value}/status`, {
                  status: 1,
                });
                $q.notify({
                  type: "positive",
                  message: "El pedido se actualizó como pagado ✅",
                  position: "top",
                });
                router.push({ path: "/ticket", query: { folio: folio.value } });
              } catch (err) {
                console.error(err);
                $q.notify({
                  type: "negative",
                  message: "No se pudo actualizar el estado del pedido ❌",
                  position: "top",
                });
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
    };

    onMounted(async () => {
      await cargarPedido();
      if (folioValido.value) {
        if (!window.paypal) {
          const script = document.createElement("script");
          script.src =
            "https://www.paypal.com/sdk/js?client-id=AbIF1bjrsqCAcyqb3Hh9rBgsUX8NArLpGhzSRMdLtJHUg531mh9Y9Fme8RjJU07ncNI7z4mcjlY8jQrw&currency=MXN";
          script.onload = renderPayPalButton;
          document.body.appendChild(script);
        } else {
          renderPayPalButton();
        }
      }
    });

    return { folio, total, folioValido };
  },
};
</script>
