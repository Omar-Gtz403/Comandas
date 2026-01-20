<template>
  <q-page class="q-pa-md bg-grey-2">
    <!-- HEADER -->
    <q-card class="q-mb-md shadow-2">
      <q-card-section class="row items-center justify-between">
        <div class="text-h5 text-primary text-weight-bold">
          Gestión de Productos
        </div>

        <q-btn
          icon="refresh"
          round
          flat
          color="primary"
          @click="cargarProductos"
        />
      </q-card-section>
    </q-card>

    <!-- TABLA -->
    <q-card class="shadow-2">
      <q-table
        :rows="productos"
        :columns="columns"
        row-key="codigoBarras"
        flat
        bordered
        :loading="loading"
        loading-label="Cargando productos..."
        :grid="$q.screen.lt.md"
        separator="horizontal"
      >
        <!-- SPINNER -->
        <template v-slot:loading>
          <div class="row justify-center q-pa-lg">
            <q-spinner-dots color="primary" size="40px" />
          </div>
        </template>

        <!-- ESTADO -->
        <template v-slot:body-cell-activo="props">
          <q-td align="center">
            <q-badge :color="props.row.activo ? 'positive' : 'warning'" outline>
              {{ props.row.activo ? "Activo" : "Pausado" }}
            </q-badge>
          </q-td>
        </template>

        <!-- ACCIONES -->
        <template v-slot:body-cell-acciones="props">
          <q-td align="center" class="q-gutter-xs">
            <q-btn
              round
              dense
              icon="edit"
              color="primary"
              @click="abrirEditar(props.row)"
            />
            <q-btn
              round
              dense
              :icon="props.row.activo ? 'pause' : 'play_arrow'"
              :color="props.row.activo ? 'warning' : 'positive'"
              @click="toggleActivo(props.row)"
            />
            <q-btn
              round
              dense
              icon="delete"
              color="negative"
              @click="abrirEliminar(props.row)"
            />
          </q-td>
        </template>
      </q-table>
    </q-card>

    <!-- MODAL EDITAR -->
    <q-dialog v-model="dialogEditar" persistent>
      <q-card class="full-width" style="max-width: 500px">
        <q-card-section class="text-h6 text-primary">
          Editar Producto
        </q-card-section>

        <q-card-section class="q-gutter-md">
          <q-input
            v-model="productoEditar.nombreProducto"
            label="Nombre"
            filled
          />
          <q-input
            v-model="productoEditar.proveedor"
            label="Proveedor"
            filled
          />

          <div class="row q-col-gutter-sm">
            <div class="col-6">
              <q-input
                v-model.number="productoEditar.precioCompra"
                label="Precio Compra"
                type="number"
                filled
              />
            </div>
            <div class="col-6">
              <q-input
                v-model.number="productoEditar.precioVenta"
                label="Precio Venta"
                type="number"
                filled
              />
            </div>
          </div>

          <q-input
            v-model="productoEditar.descripcion"
            label="Descripción"
            type="textarea"
            filled
          />

          <q-input
            v-model="productoEditar.caducidad"
            type="date"
            label="Fecha de caducidad"
            filled
          />

          <q-input
            v-model="productoEditar.cantidadExistente"
            label="Stock actual"
            filled
            readonly
          />

          <q-input
            v-model.number="stockIncremento"
            type="number"
            label="Aumentar stock"
            filled
          />

          <!-- IMAGEN -->
          <q-file
            v-model="archivoImagen"
            label="Cambiar imagen"
            filled
            accept="image/*"
            clearable
          />

          <q-img
            v-if="productoEditar.img"
            :src="productoEditar.img"
            ratio="1"
            class="rounded-borders"
          />
        </q-card-section>

        <q-card-actions align="right">
          <q-btn flat label="Cancelar" color="secondary" v-close-popup />
          <q-btn
            label="Guardar"
            color="primary"
            :loading="saving"
            @click="actualizarProducto"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- MODAL ELIMINAR -->
    <q-dialog v-model="dialogEliminar">
      <q-card>
        <q-card-section class="text-h6">
          ¿Eliminar este producto?
        </q-card-section>

        <q-card-actions align="right">
          <q-btn flat label="Cancelar" color="secondary" v-close-popup />
          <q-btn
            label="Eliminar"
            color="negative"
            :loading="saving"
            @click="eliminarProducto"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { useQuasar } from "quasar";
import { api } from "src/boot/axios";

const $q = useQuasar();

const productos = ref([]);
const loading = ref(false);
const saving = ref(false);

const dialogEditar = ref(false);
const dialogEliminar = ref(false);

const productoEditar = ref({});
const productoEliminar = ref({});
const stockIncremento = ref(0);
const archivoImagen = ref(null);

const columns = [
  {
    name: "codigoBarras",
    label: "Código",
    field: "codigoBarras",
    align: "left",
  },
  { name: "nombreProducto", label: "Nombre", field: "nombreProducto" },
  {
    name: "precioVenta",
    label: "Precio",
    field: "precioVenta",
    align: "right",
  },
  {
    name: "cantidadExistente",
    label: "Stock",
    field: "cantidadExistente",
    align: "right",
  },
  { name: "activo", label: "Estado", field: "activo", align: "center" },
  { name: "acciones", label: "Acciones", align: "center" },
];

const cargarProductos = async () => {
  loading.value = true;
  try {
    const res = await api.get("/productos");
    productos.value = res.data;
  } catch {
    $q.notify({ type: "negative", message: "Error al cargar productos" });
  } finally {
    loading.value = false;
  }
};

const abrirEditar = (row) => {
  productoEditar.value = { ...row };
  stockIncremento.value = 0;
  archivoImagen.value = null;
  dialogEditar.value = true;
};

const actualizarProducto = async () => {
  saving.value = true;
  try {
    if (stockIncremento.value < 0) {
      $q.notify({ type: "warning", message: "Stock inválido" });
      return;
    }

    let img = productoEditar.value.img;

    if (archivoImagen.value) {
      const fd = new FormData();
      fd.append("file", archivoImagen.value);
      const res = await api.post("/productos/upload", fd);
      img = res.data.url;
    }

    await api.put(`/productos/${productoEditar.value.codigoBarras}`, {
      ...productoEditar.value,
      cantidadExistente:
        productoEditar.value.cantidadExistente + stockIncremento.value,
      img,
    });

    $q.notify({ type: "positive", message: "Producto actualizado" });
    dialogEditar.value = false;
    cargarProductos();
  } catch {
    $q.notify({ type: "negative", message: "Error al actualizar" });
  } finally {
    saving.value = false;
  }
};

const abrirEliminar = (row) => {
  productoEliminar.value = row;
  dialogEliminar.value = true;
};

const eliminarProducto = async () => {
  saving.value = true;
  try {
    await api.delete(`/productos/${productoEliminar.value.codigoBarras}`);
    $q.notify({ type: "positive", message: "Producto eliminado" });
    dialogEliminar.value = false;
    cargarProductos();
  } catch {
    $q.notify({ type: "negative", message: "Error al eliminar" });
  } finally {
    saving.value = false;
  }
};

const toggleActivo = async (row) => {
  try {
    await api.put(`/productos/${row.codigoBarras}`, {
      ...row,
      activo: !row.activo,
    });
    cargarProductos();
  } catch {
    $q.notify({ type: "negative", message: "Error al cambiar estado" });
  }
};

onMounted(cargarProductos);
</script>
