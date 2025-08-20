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
        <div class="text-h5 q-mb-md">
          Total a pagar: <span class="text-primary">${{ total.toFixed(2) }}</span>
        </div>
        <q-form @submit.prevent="generarPago">
          <q-input
            filled
            v-model="nombre"
            label="Nombre en la tarjeta"
            class="q-mb-md"
            :rules="[val => !!val || 'Campo requerido']"
          />
          <q-input
            filled
            v-model="numero"
            label="Número de tarjeta"
            mask="#### #### #### ####"
            class="q-mb-md"
            :rules="[val => val && val.length === 19 || 'Número inválido']"
          />
          <div class="row q-col-gutter-md q-mb-md">
            <div class="col">
              <q-input
                filled
                v-model="expiracion"
                label="Expiración (MM/AA)"
                mask="##/##"
                :rules="[val => val && val.length === 5 || 'Formato inválido']"
              />
            </div>
            <div class="col">
              <q-input
                filled
                v-model="cvv"
                label="CVV"
                mask="###"
                :rules="[val => val && val.length === 3 || 'CVV inválido']"
              />
            </div>
          </div>
          <q-btn
            label="Generar Pago"
            color="primary"
            size="lg"
            type="submit"
            class="full-width"
          />
        </q-form>
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
import { ref } from "vue";
import { useQuasar } from "quasar";

export default {
  setup() {
    const $q = useQuasar();
    const total = ref(250.00);

    const nombre = ref("");
    const numero = ref("");
    const expiracion = ref("");
    const cvv = ref("");

    const generarPago = () => {
      if (!nombre.value || !numero.value || !expiracion.value || !cvv.value) {
        $q.notify({
          type: "negative",
          message: "Por favor, completa todos los campos.",
          position: "top",
        });
        return;
      }
      $q.notify({
        type: "positive",
        message: "Pago generado correctamente",
        position: "top",
      });
      // Aquí puedes agregar la lógica para enviar los datos al backend
    };

    return {
      total,
      nombre,
      numero,
      expiracion,
      cvv,
      generarPago,
    };
  },
};
</script>
