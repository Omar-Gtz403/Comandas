<template>
  <q-layout view="lHh Lpr lFf">
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
              <!-- Campos de texto -->
              <div class="col-12 col-md-6">
                <q-input
                  filled
                  v-model="producto.codigoBarras"
                  label="Código de Barras"
                  clearable
                  dense
                  outlined
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
                />
              </div>

              <div class="col-12 col-md-6">
                <q-input
                  filled
                  v-model.number="producto.precioCompra"
                  type="number"
                  label="Precio Compra"
                  dense
                  outlined
                />
              </div>

              <div class="col-12 col-md-6">
                <q-input
                  filled
                  v-model.number="producto.precioVenta"
                  type="number"
                  label="Precio Venta"
                  dense
                  outlined
                />
              </div>

              <div class="col-12 col-md-6">
                <q-input
                  filled
                  v-model.number="producto.cantidadExistente"
                  type="number"
                  label="Cantidad Existente"
                  dense
                  outlined
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
                />
              </div>

              <div class="col-12 col-md-6">
                <q-input
                  filled
                  v-model.number="producto.stockMin"
                  type="number"
                  label="Stock Mínimo"
                  dense
                  outlined
                />
              </div>

              <div class="col-12 col-md-6">
                <q-input
                  filled
                  v-model.number="producto.stockMax"
                  type="number"
                  label="Stock Máximo"
                  dense
                  outlined
                />
              </div>

              <!-- Caducidad con calendario -->
              <div class="col-12 col-md-6">
                <q-input
                  filled
                  v-model="producto.caducidad"
                  label="Caducidad"
                  dense
                  outlined
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
                      today-btn
                      @update:model-value="dateDialog = false"
                    />
                  </q-popup-proxy>
                </q-input>
              </div>

              <!-- 📂 Cargar Imagen -->
              <div class="col-12">
                <q-file
                  v-model="producto.file"
                  label="Seleccionar Imagen"
                  filled
                  dense
                  outlined
                  clearable
                  use-chips
                  accept="image/*"
                  prepend-icon="attach_file"
                />
              </div>
            </div>

            <!-- Botones -->
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
  </q-layout>
</template>

<script>
import { ref } from "vue";
import { useQuasar } from "quasar";
import { api } from "src/boot/axios";

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
      file: null, // 📂 aquí se guarda la imagen
    });

    const registrarProducto = async () => {
      try {
        const formData = new FormData();
        formData.append("codigoBarras", producto.value.codigoBarras);
        formData.append("nombreProducto", producto.value.nombreProducto);
        formData.append("proveedor", producto.value.proveedor);
        formData.append("descripcion", producto.value.descripcion);
        formData.append("precioCompra", producto.value.precioCompra);
        formData.append("precioVenta", producto.value.precioVenta);
        formData.append("stockMin", producto.value.stockMin);
        formData.append("stockMax", producto.value.stockMax);
        formData.append("caducidad", producto.value.caducidad);
        formData.append("cantidadExistente", producto.value.cantidadExistente);
        if (producto.value.file) {
          formData.append("file", producto.value.file);
        }

        await api.post("/productos", formData, {
          headers: { "Content-Type": "multipart/form-data" },
        });

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
        file: null,
      };
    };

    return {
      producto,
      registrarProducto,
      resetForm,
      dateDialog,
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
