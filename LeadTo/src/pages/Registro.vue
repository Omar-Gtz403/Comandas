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

          <q-form
            @submit.prevent="registrarProducto"
            class="q-gutter-md q-pa-md"
          >
            <div class="row q-col-gutter-md">
              <!-- Código y nombre -->
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

              <!-- Proveedor y precios -->
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

              <!-- Stock -->
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

              <!-- Caducidad -->
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

              <!-- Descripción -->
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

              <!-- Categoría -->
              <div class="col-12 col-md-6">
                <q-select
                  filled
                  v-model="producto.categoriaId"
                  :options="categorias"
                  option-label="nombre"
                  option-value="id"
                  label="Categoría"
                  dense
                  outlined
                  clearable
                />
              </div>

              <!-- Imagen -->
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
              <div class="col-12">
                <q-input
                  filled
                  v-model="producto.imgUrl"
                  label="O URL de Imagen (Opcional)"
                  clearable
                  dense
                  outlined
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
import { ref, onMounted } from "vue";
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
      categoriaId: null,
      imgUrl: "",
      file: null,
    });

    const categorias = ref([]);

    // Cargar categorías desde API
    const cargarCategorias = async () => {
      try {
        const res = await api.get("/categorias");
        categorias.value = res.data;
      } catch (err) {
        console.error("Error cargando categorías:", err);
      }
    };

    onMounted(cargarCategorias);

    // Subir imagen antes de registrar
    const subirImagen = async () => {
      if (!producto.value.file) return null;

      const formData = new FormData();
      formData.append("file", producto.value.file);

      try {
        const res = await api.post("/productos/upload", formData, {
          headers: { "Content-Type": "multipart/form-data" },
        });
        return res.data.url; // backend devuelve { "url": "https://..." }
      } catch (err) {
        console.error("Error subiendo imagen:", err);
        $q.notify({
          type: "negative",
          message: "Error al subir imagen.",
          position: "top",
        });
        return null;
      }
    };

    const registrarProducto = async () => {
      try {
        let urlImagen = producto.value.imgUrl;

        // Si el usuario seleccionó un archivo, subimos la imagen
        if (producto.value.file) {
          const subida = await subirImagen();
          if (subida) {
            urlImagen = subida;
          }
        }

        const payload = {
          codigoBarras: producto.value.codigoBarras,
          nombreProducto: producto.value.nombreProducto,
          proveedor: producto.value.proveedor,
          descripcion: producto.value.descripcion,
          precioCompra: producto.value.precioCompra,
          precioVenta: producto.value.precioVenta,
          stockMin: producto.value.stockMin,
          stockMax: producto.value.stockMax,
          caducidad: producto.value.caducidad,
          cantidadExistente: producto.value.cantidadExistente,
          img: urlImagen,
          categoria: producto.value.categoriaId,
        };

        await api.post("/productos", payload);

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
        categoriaId: null,
        imgUrl: "",
        file: null,
      };
    };

    return { producto, registrarProducto, resetForm, dateDialog, categorias };
  },
};
</script>
