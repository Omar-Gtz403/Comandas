<template>
  <q-page class="q-pa-md page-background">
    <div class="row justify-center">
      <div class="col-12 col-md-10 col-lg-8">
        <q-form @submit.prevent="registrarProducto">
          <q-card class="form-card q-mb-xl">
            <!-- LOADING -->
            <q-inner-loading :showing="loading" class="z-top">
              <q-spinner-cube size="50px" color="primary" />
              <div class="text-primary q-mt-sm text-weight-bold">
                Guardando...
              </div>
            </q-inner-loading>

            <q-card-section class="q-pa-lg">
              <div class="text-h6 text-primary q-mb-md">
                <q-icon name="info" class="q-mr-sm" /> Información Básica
              </div>

              <div class="row q-col-gutter-md">
                <div class="col-12 col-sm-6">
                  <q-input
                    v-model="producto.codigoBarras"
                    label="Código de Barras"
                    outlined
                    dense
                    rounded
                    bg-color="grey-1"
                  >
                    <template v-slot:prepend>
                      <q-icon name="qr_code" />
                    </template>
                  </q-input>
                </div>

                <div class="col-12 col-sm-6">
                  <q-input
                    v-model="producto.nombreProducto"
                    label="Nombre del Producto *"
                    outlined
                    dense
                    rounded
                    bg-color="grey-1"
                    :error="!!errors.nombreProducto"
                    :error-message="errors.nombreProducto"
                  >
                    <template v-slot:prepend>
                      <q-icon name="label" />
                    </template>
                  </q-input>
                </div>

                <div class="col-12 col-sm-6">
                  <q-input
                    v-model="producto.proveedor"
                    label="Proveedor"
                    outlined
                    dense
                    rounded
                    bg-color="grey-1"
                  >
                    <template v-slot:prepend>
                      <q-icon name="local_shipping" />
                    </template>
                  </q-input>
                </div>

                <div class="col-12 col-sm-6">
                  <q-select
                    v-model="producto.categoriaId"
                    :options="categorias"
                    option-label="nombre"
                    option-value="id"
                    label="Categoría *"
                    outlined
                    dense
                    rounded
                    bg-color="grey-1"
                    behavior="menu"
                    emit-value
                    map-options
                    :error="!!errors.categoriaId"
                    :error-message="errors.categoriaId"
                  >
                    <template v-slot:prepend>
                      <q-icon name="category" />
                    </template>
                  </q-select>
                </div>

                <div class="col-12">
                  <q-input
                    v-model="producto.descripcion"
                    type="textarea"
                    label="Descripción"
                    outlined
                    dense
                    rounded
                    bg-color="grey-1"
                    autogrow
                    rows="2"
                  >
                    <template v-slot:prepend>
                      <q-icon name="description" />
                    </template>
                  </q-input>
                </div>
              </div>

              <q-separator class="q-my-lg" />

              <div class="text-h6 text-primary q-mb-md">
                <q-icon name="payments" class="q-mr-sm" /> Precios y Stock
              </div>

              <div class="row q-col-gutter-md">
                <div class="col-6 col-md-3">
                  <q-input
                    v-model.number="producto.precioCompra"
                    type="number"
                    label="P. Compra *"
                    outlined
                    dense
                    rounded
                    bg-color="grey-1"
                    prefix="$"
                    :error="!!errors.precioCompra"
                    :error-message="errors.precioCompra"
                  />
                </div>

                <div class="col-6 col-md-3">
                  <q-input
                    v-model.number="producto.precioVenta"
                    type="number"
                    label="P. Venta *"
                    outlined
                    dense
                    rounded
                    bg-color="grey-1"
                    prefix="$"
                    :error="!!errors.precioVenta"
                    :error-message="errors.precioVenta"
                  />
                </div>

                <div class="col-6 col-md-3">
                  <q-input
                    v-model.number="producto.stockMin"
                    type="number"
                    label="Min *"
                    outlined
                    dense
                    rounded
                    bg-color="grey-1"
                    :error="!!errors.stockMin"
                    :error-message="errors.stockMin"
                  >
                    <template v-slot:prepend>
                      <q-icon name="trending_down" size="xs" />
                    </template>
                  </q-input>
                </div>

                <div class="col-6 col-md-3">
                  <q-input
                    v-model.number="producto.stockMax"
                    type="number"
                    label="Max *"
                    outlined
                    dense
                    rounded
                    bg-color="grey-1"
                    :error="!!errors.stockMax"
                    :error-message="errors.stockMax"
                  >
                    <template v-slot:prepend>
                      <q-icon name="trending_up" size="xs" />
                    </template>
                  </q-input>
                </div>

                <div class="col-12 col-sm-6">
                  <q-input
                    v-model="producto.caducidad"
                    label="Caducidad"
                    outlined
                    dense
                    rounded
                    bg-color="grey-1"
                    readonly
                  >
                    <template v-slot:prepend>
                      <q-icon name="event" class="cursor-pointer">
                        <q-popup-proxy
                          cover
                          transition-show="scale"
                          transition-hide="scale"
                        >
                          <q-date
                            v-model="producto.caducidad"
                            mask="YYYY-MM-DD"
                            color="primary"
                          >
                            <div class="row items-center justify-end">
                              <q-btn
                                v-close-popup
                                label="Cerrar"
                                color="primary"
                                flat
                              />
                            </div>
                          </q-date>
                        </q-popup-proxy>
                      </q-icon>
                    </template>
                  </q-input>
                </div>
              </div>

              <q-separator class="q-my-lg" />

              <div class="text-h6 text-primary q-mb-md">
                <q-icon name="image" class="q-mr-sm" /> Multimedia
              </div>

              <div class="row q-col-gutter-md">
                <div class="col-12">
                  <q-file
                    v-model="producto.file"
                    label="Subir Imagen"
                    outlined
                    dense
                    rounded
                    bg-color="grey-1"
                    accept="image/*"
                    clearable
                  >
                    <template v-slot:prepend>
                      <q-icon name="cloud_upload" />
                    </template>
                  </q-file>
                </div>
                <div class="col-12">
                  <q-input
                    v-model="producto.imgUrl"
                    label="O pegar URL de imagen"
                    outlined
                    dense
                    rounded
                    bg-color="grey-1"
                  >
                    <template v-slot:prepend>
                      <q-icon name="link" />
                    </template>
                  </q-input>
                </div>
              </div>
            </q-card-section>

            <q-card-actions align="right" class="q-pa-md bg-grey-1">
              <q-btn
                label="Limpiar"
                flat
                color="grey-7"
                icon="refresh"
                @click="resetForm"
                class="q-mr-sm"
              />
              <q-btn
                label="Guardar Producto"
                type="submit"
                color="primary"
                icon="save"
                push
                class="q-px-lg"
              />
            </q-card-actions>
          </q-card>
        </q-form>
      </div>
    </div>
  </q-page>
</template>

<script>
import { ref, onMounted } from "vue";
import { useQuasar } from "quasar";
import { api } from "src/boot/axios";

export default {
  name: "RegistrarProducto",
  setup() {
    const $q = useQuasar();
    const loading = ref(false);

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

    const errors = ref({
      nombreProducto: "",
      precioCompra: "",
      precioVenta: "",
      stockMin: "",
      stockMax: "",
      categoriaId: "",
    });

    const cargarCategorias = async () => {
      try {
        const res = await api.get("/categorias");
        categorias.value = res.data;
      } catch {
        $q.notify({
          type: "negative",
          message: "No se pudieron cargar las categorías",
        });
      }
    };

    onMounted(cargarCategorias);

    const validarFormulario = () => {
      errors.value = {
        nombreProducto: "",
        precioCompra: "",
        precioVenta: "",
        stockMin: "",
        stockMax: "",
        categoriaId: "",
      };

      let valido = true;

      if (!producto.value.nombreProducto) {
        errors.value.nombreProducto = "Obligatorio";
        valido = false;
      }
      if (producto.value.precioCompra <= 0) {
        errors.value.precioCompra = "> 0";
        valido = false;
      }
      if (producto.value.precioVenta <= 0) {
        errors.value.precioVenta = "> 0";
        valido = false;
      }
      if (producto.value.stockMax < producto.value.stockMin) {
        errors.value.stockMax = "Inválido";
        valido = false;
      }
      if (!producto.value.categoriaId) {
        errors.value.categoriaId = "Seleccione";
        valido = false;
      }

      return valido;
    };

    const subirImagen = async () => {
      if (!producto.value.file) return null;

      const formData = new FormData();
      formData.append("file", producto.value.file);

      try {
        const res = await api.post("/productos/upload", formData);
        return res.data.url;
      } catch {
        $q.notify({ type: "negative", message: "Error al subir imagen" });
        return null;
      }
    };

    const registrarProducto = async () => {
      if (loading.value) return;
      if (!validarFormulario()) {
        $q.notify({
          type: "warning",
          message: "Verifica los campos obligatorios",
        });
        return;
      }

      loading.value = true;

      try {
        let urlImagen = producto.value.imgUrl || null;

        if (producto.value.file) {
          const subida = await subirImagen();
          if (subida) urlImagen = subida;
        }

        await api.post("/productos", {
          ...producto.value,
          img: urlImagen,
          categoria: producto.value.categoriaId,
        });

        $q.notify({
          type: "positive",
          message: "Producto registrado con éxito",
        });

        resetForm();
      } catch {
        $q.notify({
          type: "negative",
          message: "Error al registrar el producto",
        });
      } finally {
        loading.value = false;
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
      // Reset file input component manually if needed
    };

    return {
      producto,
      categorias,
      errors,
      loading,
      registrarProducto,
      resetForm,
    };
  },
};
</script>

<style scoped>
.page-background {
  background-color: #f8f9fa;
  min-height: 100vh;
}

/* Header Gradient */
.header-card {
  border-radius: 20px;
  background: linear-gradient(135deg, #b71c1c 0%, #c62828 50%, #0277bd 100%);
  box-shadow: 0 8px 20px rgba(183, 28, 28, 0.3);
  position: relative;
  overflow: hidden;
}

.header-card::before {
  content: "";
  position: absolute;
  top: -50%;
  left: -50%;
  width: 200%;
  height: 200%;
  background: radial-gradient(
    circle,
    rgba(255, 255, 255, 0.1) 0%,
    transparent 60%
  );
  transform: rotate(30deg);
  pointer-events: none;
}

/* Form Card */
.form-card {
  border-radius: 24px;
  border: none;
  background: white;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
  overflow: hidden;
}
</style>
