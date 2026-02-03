<template>
  <q-layout view="lHh Lpr lFf">
    <q-page-container>
      <q-page class="q-pa-md flex flex-center">
        <q-card flat bordered class="full-width" style="max-width: 720px">
          <!-- LOADING -->
          <q-inner-loading :showing="loading">
            <q-spinner size="50px" color="primary" />
            <div class="text-primary q-mt-sm text-weight-medium">
              Guardando producto...
            </div>
          </q-inner-loading>

          <!-- HEADER -->
          <q-card-section class="text-center">
            <div class="text-h6 text-primary text-weight-bold">
              Nuevo Producto
            </div>
            <div class="text-caption text-grey-7">
              Completa la información del producto
            </div>
          </q-card-section>

          <q-separator />

          <!-- FORM -->
          <q-card-section>
            <q-form @submit.prevent="registrarProducto" class="q-gutter-md">
              <div class="row q-col-gutter-md">
                <div class="col-12 col-sm-6">
                  <q-input
                    v-model="producto.codigoBarras"
                    label="Código de barras"
                    outlined
                    dense
                    clearable
                  />
                </div>

                <div class="col-12 col-sm-6">
                  <q-input
                    v-model="producto.nombreProducto"
                    label="Nombre del producto"
                    outlined
                    dense
                    clearable
                    :error="!!errors.nombreProducto"
                    :error-message="errors.nombreProducto"
                  />
                </div>

                <div class="col-12 col-sm-6">
                  <q-input
                    v-model="producto.proveedor"
                    label="Proveedor"
                    outlined
                    dense
                    clearable
                  />
                </div>

                <div class="col-6 col-sm-3">
                  <q-input
                    v-model.number="producto.precioCompra"
                    type="number"
                    inputmode="decimal"
                    label="Compra"
                    outlined
                    dense
                    :error="!!errors.precioCompra"
                    :error-message="errors.precioCompra"
                  />
                </div>

                <div class="col-6 col-sm-3">
                  <q-input
                    v-model.number="producto.precioVenta"
                    type="number"
                    inputmode="decimal"
                    label="Venta"
                    outlined
                    dense
                    :error="!!errors.precioVenta"
                    :error-message="errors.precioVenta"
                  />
                </div>

                <div class="col-6 col-sm-3">
                  <q-input
                    v-model.number="producto.stockMin"
                    type="number"
                    inputmode="numeric"
                    label="Stock mín"
                    outlined
                    dense
                    :error="!!errors.stockMin"
                    :error-message="errors.stockMin"
                  />
                </div>

                <div class="col-6 col-sm-3">
                  <q-input
                    v-model.number="producto.stockMax"
                    type="number"
                    inputmode="numeric"
                    label="Stock máx"
                    outlined
                    dense
                    :error="!!errors.stockMax"
                    :error-message="errors.stockMax"
                  />
                </div>

                <!-- CALENDARIO EN ESPAÑOL -->
                <div class="col-12 col-sm-6">
                  <q-input
                    v-model="producto.caducidad"
                    label="Caducidad"
                    outlined
                    dense
                    readonly
                    input-class="cursor-pointer"
                  >
                    <template #append>
                      <q-icon name="event" class="cursor-pointer" />
                    </template>

                    <q-popup-proxy transition-show="scale">
                      <q-date
                        v-model="producto.caducidad"
                        mask="YYYY-MM-DD"
                        color="primary"
                        today-btn
                        locale="es"
                      />
                    </q-popup-proxy>
                  </q-input>
                </div>

                <div class="col-12 col-sm-6">
                  <q-select
                    v-model="producto.categoriaId"
                    :options="categorias"
                    option-label="nombre"
                    option-value="id"
                    label="Categoría"
                    outlined
                    dense
                    clearable
                    :error="!!errors.categoriaId"
                    :error-message="errors.categoriaId"
                  />
                </div>

                <div class="col-12">
                  <q-input
                    v-model="producto.descripcion"
                    type="textarea"
                    label="Descripción"
                    outlined
                    dense
                    clearable
                    autogrow
                  />
                </div>

                <div class="col-12">
                  <q-file
                    v-model="producto.file"
                    label="Imagen del producto"
                    outlined
                    dense
                    accept="image/*"
                    clearable
                    prepend-icon="image"
                  />
                </div>

                <div class="col-12">
                  <q-input
                    v-model="producto.imgUrl"
                    label="O URL de imagen"
                    outlined
                    dense
                    clearable
                  />
                </div>
              </div>

              <!-- ACTIONS -->
              <div class="row q-col-gutter-sm q-mt-lg">
                <div class="col-12 col-sm-auto">
                  <q-btn
                    label="Guardar"
                    type="submit"
                    color="primary"
                    icon="save"
                    class="full-width q-py-sm"
                    :disable="loading"
                  />
                </div>

                <div class="col-12 col-sm-auto">
                  <q-btn
                    label="Limpiar"
                    flat
                    color="secondary"
                    icon="refresh"
                    class="full-width q-py-sm"
                    :disable="loading"
                    @click="resetForm"
                  />
                </div>
              </div>
            </q-form>
          </q-card-section>
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
        errors.value.nombreProducto = "El nombre es obligatorio";
        valido = false;
      }
      if (producto.value.precioCompra <= 0) {
        errors.value.precioCompra = "Debe ser mayor a 0";
        valido = false;
      }
      if (producto.value.precioVenta <= 0) {
        errors.value.precioVenta = "Debe ser mayor a 0";
        valido = false;
      }
      if (producto.value.stockMax < producto.value.stockMin) {
        errors.value.stockMax = "Debe ser mayor al stock mínimo";
        valido = false;
      }
      if (!producto.value.categoriaId) {
        errors.value.categoriaId = "Selecciona una categoría";
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
      if (!validarFormulario()) return;

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
