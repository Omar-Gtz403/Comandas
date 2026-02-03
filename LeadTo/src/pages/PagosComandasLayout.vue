<template>
  <q-layout view="lHh Lpr lFf">
    <q-page-container>
      <q-page class="flex flex-center">
        <!-- CARD PRINCIPAL -->
        <q-card
          v-if="folioValido"
          class="q-pa-lg shadow-2"
          style="max-width: 420px; width: 100%"
        >
          <q-card-section>
            <div class="text-h6 text-center q-mb-md">
              <q-icon name="payment" color="primary" size="28px" />
              Métodos de pago
            </div>

            <div class="text-center q-mb-sm">
              Total:
              <span class="text-primary text-bold">
                ${{ total.toFixed(2) }} MXN
              </span>
            </div>

            <div class="text-center q-mb-md">
              Folio:
              <span class="text-bold">{{ folio }}</span>
            </div>

            <!-- PAYPAL -->
            <div class="q-mb-md">
              <div id="paypal-button-container"></div>
            </div>

            <!-- EFECTIVO -->
            <div v-if="puedePagarEfectivo">
              <q-separator spaced />
              <q-btn
                class="full-width"
                color="positive"
                icon="attach_money"
                label="Marcar como pagado en efectivo"
                @click="pagarEfectivo"
              />
            </div>
          </q-card-section>
        </q-card>

        <!-- ERROR -->
        <q-card v-else class="q-pa-lg bg-negative text-white">
          <q-card-section class="text-center">
            ⚠️ Folio inválido o ya pagado
          </q-card-section>
        </q-card>
      </q-page>
    </q-page-container>
  </q-layout>
</template>

<script>
import { ref, onMounted, nextTick } from "vue";
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

    const usuario = JSON.parse(localStorage.getItem("usuario"));
    const puedePagarEfectivo =
      usuario?.rol?.permisos?.some((p) => p.ruta === "/pagos") || false;

    /* ===============================
       CARGAR VENTA
    =============================== */
    const cargarPedido = async () => {
      try {
        const res = await api.get(`/ventas/folio/${folio.value}`);

        if (res.data && res.data.status === 0) {
          folioValido.value = true;
          total.value = Number(res.data.total);
        } else {
          folioValido.value = false;
        }
      } catch {
        folioValido.value = false;
      }
    };

    /* ===============================
       PAGO EN EFECTIVO
    =============================== */
    const pagarEfectivo = async () => {
      await api.put(`/ventas/folio/${folio.value}/status`, { status: 1 });

      $q.notify({
        type: "positive",
        message: "Pago en efectivo registrado ✅",
      });

      router.push({ path: "/ticket", query: { folio: folio.value } });
    };

    /* ===============================
       PAYPAL
    =============================== */
    const renderPayPal = async () => {
      await nextTick();

      // 📦 Contenedor
      const container = document.getElementById("paypal-button-container");
      if (!container) return;

      // 🛑 Evita render doble (causa principal del ResizeObserver error)
      if (container.hasChildNodes()) return;

      // 🛑 Validaciones básicas
      if (!window.paypal) {
        console.warn("PayPal SDK no cargado");
        return;
      }

      if (!folio.value || !total.value || total.value <= 0) {
        console.warn("Folio o total inválido", folio.value, total.value);
        return;
      }

      try {
        window.paypal
          .Buttons({
            style: {
              layout: "vertical",
              color: "blue",
              shape: "rect",
              label: "paypal",
            },

            /* 🔐 CREAR ORDEN */
            createOrder: async (data, actions) => {
              const orderId = await actions.order.create({
                intent: "CAPTURE",
                application_context: {
                  shipping_preference: "NO_SHIPPING",
                  locale: "es-MX",
                },
                purchase_units: [
                  {
                    amount: {
                      currency_code: "MXN",
                      value: total.value.toFixed(2),
                    },
                  },
                ],
              });

              // 💾 Guardar orderId + folio en backend
              await api.post("/paypal/guardar-order", {
                folio: folio.value,
                orderId,
              });

              return orderId;
            },

            /* ✅ APROBADO */
            onApprove: async (data, actions) => {
              await actions.order.capture();

              await api.post("/paypal/confirmar-pago", {
                folio: folio.value,
                orderId: data.orderID,
              });

              $q.notify({
                type: "positive",
                message: "Pago con PayPal confirmado ✅",
              });

              router.push({
                path: "/ticket",
                query: { folio: folio.value },
              });
            },

            /* ❌ ERROR */
            onError: (err) => {
              console.error("PayPal error:", err);
              $q.notify({
                type: "negative",
                message: "Error en el pago con PayPal ❌",
              });
            },
          })
          .render("#paypal-button-container");
      } catch (err) {
        console.error("Error renderizando PayPal:", err);
      }
    };

    /* ===============================
       INIT
    =============================== */
    onMounted(async () => {
      await cargarPedido();
      if (!folioValido.value) return;

      if (!window.paypal) {
        const script = document.createElement("script");
        script.src =
          "https://www.paypal.com/sdk/js" +
          "?client-id=AX1HOr8C4RgFEg8-9hl0uLRu2cyTyi0ZMrU8avP3u4MwTYBdO6Qi1WkOUaHWAxTKO-oQ6EUKOhIqy19b" +
          "&currency=MXN" +
          "&locale=es_MX";

        script.onload = renderPayPal;
        document.body.appendChild(script);
      } else {
        renderPayPal();
      }
    });

    return {
      folio,
      total,
      folioValido,
      puedePagarEfectivo,
      pagarEfectivo,
    };
  },
};
</script>
