<template>
  <q-layout view="lHh Lpr lFf">
    <!-- Contenido -->
    <q-page-container>
      <q-page class="q-pa-lg bg-grey-2">
        <q-card
          flat
          bordered
          class="q-pa-lg"
          style="max-width: 650px; margin: auto"
        >
          <q-card-section class="text-center">
            <div class="text-h5 text-primary q-mb-md">Nuevo Producto</div>
            <q-separator />
          </q-card-section>

          <q-form @submit="registrarProducto" class="q-gutter-md q-pa-md">
            <div class="row q-col-gutter-md">
              <div class="col-12 col-md-6">
                <q-input
                  filled
                  v-model="producto.codigoBarras"
                  label="Código de Barras"
                  clearable
                  dense
                  outlined
                  :rules="[(val) => !!val || 'Requerido']"
                  prepend-icon="barcode"
                />
              </div>

              <div class="col-12 col-md-6">
                <q-input
                  filled
                  v-model="producto.nombreProducto"
                  label="Nombre del Producto"
                  clearable
                  dense
                  outlined
                  :rules="[(val) => !!val || 'Requerido']"
                  prepend-icon="inventory_2"
                />
              </div>

              <div class="col-12 col-md-6">
                <q-input
                  filled
                  v-model="producto.proveedor"
                  label="Proveedor"
                  clearable
                  dense
                  outlined
                  prepend-icon="local_shipping"
                />
              </div>

              <div class="col-12 col-md-6">
                <q-input
                  filled
                  v-model.number="producto.precioCompra"
                  label="Precio Compra"
                  type="number"
                  dense
                  outlined
                  clearable
                  prepend-icon="attach_money"
                />
              </div>

              <div class="col-12 col-md-6">
                <q-input
                  filled
                  v-model.number="producto.precioVenta"
                  label="Precio Venta"
                  type="number"
                  dense
                  outlined
                  clearable
                  prepend-icon="paid"
                />
              </div>

              <div class="col-12 col-md-6">
                <q-input
                  filled
                  v-model.number="producto.cantidadExistente"
                  label="Cantidad Existente"
                  type="number"
                  dense
                  outlined
                  clearable
                  prepend-icon="inventory"
                />
              </div>

              <div class="col-12">
                <q-input
                  filled
                  v-model="producto.descripcion"
                  label="Descripción"
                  type="textarea"
                  dense
                  outlined
                  clearable
                  :rules="[(val) => !!val || 'Requerido']"
                  prepend-icon="description"
                />
              </div>

              <div class="col-12 col-md-6">
                <q-input
                  filled
                  v-model.number="producto.stockMin"
                  label="Stock Mínimo"
                  type="number"
                  dense
                  outlined
                  clearable
                  prepend-icon="signal_cellular_alt"
                />
              </div>

              <div class="col-12 col-md-6">
                <q-input
                  filled
                  v-model.number="producto.stockMax"
                  label="Stock Máximo"
                  type="number"
                  dense
                  outlined
                  clearable
                  prepend-icon="signal_cellular_4_bar"
                />
              </div>

              <!-- Caducidad con calendario y resaltado -->
              <div class="col-12 col-md-6">
                <q-input
                  filled
                  v-model="producto.caducidad"
                  label="Caducidad"
                  dense
                  outlined
                  clearable
                  prepend-icon="event"
                >
                  <template v-slot:append>
                    <q-icon
                      name="event"
                      class="cursor-pointer"
                      @click="dateDialog = true"
                    />
                  </template>
                  <q-popup-proxy
                    v-model="dateDialog"
                    transition-show="scale"
                    transition-hide="scale"
                  >
                    <q-date
                      v-model="producto.caducidad"
                      mask="YYYY-MM-DD"
                      color="primary"
                      header-color="primary"
                      text-color="white"
                      today-btn
                      default-view="Calendar"
                      :options="highlightDates"
                      @update:model-value="dateDialog = false"
                    />
                  </q-popup-proxy>
                </q-input>
              </div>

              <div class="col-12 col-md-6">
                <q-input
                  filled
                  v-model="producto.img"
                  label="URL de Imagen"
                  dense
                  outlined
                  clearable
                  prepend-icon="image"
                />
              </div>
            </div>

            <div class="row justify-end q-gutter-sm q-mt-md">
              <q-btn
                label="Guardar"
                type="submit"
                color="primary"
                icon="save"
              />
              <q-btn
                label="Limpiar"
                flat
                color="secondary"
                @click="resetForm"
                icon="refresh"
              />
            </div>
          </q-form>
        </q-card>
      </q-page>
    </q-page-container>

    <!-- Footer -->
    <q-footer class="bg-grey-2 text-black">
      <q-toolbar class="justify-center">
        <div class="text-center text-subtitle2">Registro de Productos</div>
      </q-toolbar>
    </q-footer>
  </q-layout>
</template>

<script>
import { ref } from "vue";
import { useQuasar } from "quasar";
import axios from "axios";

export default {
  name: "RegistrarProducto",
  setup() {
    const $q = useQuasar();
    const dateDialog = ref(false);

    const producto = ref({
      codigoBarras: "",
      nombreProducto: "",
      proveedor: "",
      descripcion: "",
      precioCompra: 0,
      precioVenta: 0,
      stockMin: 0,
      stockMax: 0,
      caducidad: "",
      cantidadExistente: 0,
      img: "",
    });

    // Función para resaltar fechas próximas a caducar en rojo
    const highlightDates = (date) => {
      if (!date) return true;
      const today = new Date();
      const d = new Date(date);
      const diffDays = (d - today) / (1000 * 60 * 60 * 24);
      if (diffDays >= 0 && diffDays <= 7) {
        return "bg-red text-white"; // días próximos a caducar
      }
      return true; // fechas normales
    };

    const registrarProducto = async () => {
      try {
        await axios.post("http://localhost:8082/api/productos", producto.value);
        $q.notify({
          type: "positive",
          message: "Producto registrado con éxito!",
          position: "top",
        });
        resetForm();
      } catch (err) {
        console.error("Error registrando producto:", err);
        $q.notify({
          type: "negative",
          message: "Error al registrar producto.",
          position: "top",
        });
      }
    };

    const resetForm = () => {
      producto.value = {
        codigoBarras: "",
        nombreProducto: "",
        proveedor: "",
        descripcion: "",
        precioCompra: 0,
        precioVenta: 0,
        stockMin: 0,
        stockMax: 0,
        caducidad: "",
        cantidadExistente: 0,
        img: "",
      };
    };

    return {
      producto,
      registrarProducto,
      resetForm,
      dateDialog,
      highlightDates,
    };
  },
};
</script>

<style scoped lang="sass">
.q-card
  border-radius: 12px
  box-shadow: 0 6px 18px rgba(0, 0, 0, 0.12)

.q-input__control
  transition: all 0.2s ease
  &:focus-within
    border-color: #1976d2
    box-shadow: 0 0 6px rgba(25, 118, 210, 0.3)
</style>
