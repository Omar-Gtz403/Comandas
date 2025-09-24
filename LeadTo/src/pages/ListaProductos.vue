<template>
  <q-page class="q-pa-md">
    <q-card>
      <q-card-section>
        <div class="text-h5 text-primary">Gestión de Productos</div>
      </q-card-section>

      <q-separator />

      <q-table
        :rows="productos"
        :columns="columns"
        row-key="codigoBarras"
        flat
        bordered
      >
        <template v-slot:body-cell-acciones="props">
          <q-td align="center">
            <q-btn flat round color="primary" icon="edit" @click="abrirEditar(props.row)" />
            <q-btn
              flat
              round
              :color="props.row.activo ? 'warning' : 'positive'"
              :icon="props.row.activo ? 'pause' : 'play_arrow'"
              @click="toggleActivo(props.row)"
            />
            <q-btn flat round color="negative" icon="delete" @click="abrirEliminar(props.row)" />
          </q-td>
        </template>
      </q-table>
    </q-card>

    <!-- Modal Editar -->
    <q-dialog v-model="dialogEditar">
      <q-card style="min-width: 450px">
        <q-card-section class="text-h6">Editar Producto</q-card-section>
        <q-card-section class="q-gutter-md">
          <q-input v-model="productoEditar.nombreProducto" label="Nombre" filled />
          <q-input v-model="productoEditar.proveedor" label="Proveedor" filled />
          <q-input v-model.number="productoEditar.precioCompra" label="Precio Compra" type="number" filled />
          <q-input v-model.number="productoEditar.precioVenta" label="Precio Venta" type="number" filled />
          <q-input v-model="productoEditar.descripcion" label="Descripción" type="textarea" filled />

          <q-input v-model="productoEditar.caducidad" type="date" label="Fecha de caducidad" filled />
          <q-input v-model="productoEditar.cantidadExistente" label="Stock actual" type="number" filled readonly />
          <q-input v-model.number="stockIncremento" type="number" label="Aumentar stock" filled />

          <!-- Imagen -->
          <div>
            <q-file v-model="archivoImagen" label="Seleccionar nueva imagen" filled accept="image/*" clearable />
            <div v-if="productoEditar.img" class="q-mt-sm">
              <q-img :src="productoEditar.img" style="max-height: 150px; border-radius: 8px" />
            </div>
          </div>
        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Cancelar" color="secondary" v-close-popup />
          <q-btn label="Guardar" color="primary" @click="actualizarProducto" />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- Confirmación Eliminar -->
    <q-dialog v-model="dialogEliminar">
      <q-card>
        <q-card-section class="text-h6">¿Eliminar este producto?</q-card-section>
        <q-card-actions align="right">
          <q-btn flat label="Cancelar" color="secondary" v-close-popup />
          <q-btn label="Eliminar" color="negative" @click="eliminarProducto" />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script>
import { ref, onMounted } from "vue";
import { api } from "src/boot/axios";
import { useQuasar } from "quasar";

export default {
  name: "ListaProductos",
  setup() {
    const $q = useQuasar();
    const productos = ref([]);
    const dialogEditar = ref(false);
    const dialogEliminar = ref(false);
    const productoEditar = ref({});
    const productoEliminar = ref({});
    const stockIncremento = ref(0);
    const archivoImagen = ref(null);

    const columns = [
      { name: "codigoBarras", label: "Código", field: "codigoBarras", align: "left" },
      { name: "nombreProducto", label: "Nombre", field: "nombreProducto", align: "left" },
      { name: "precioVenta", label: "Precio Venta", field: "precioVenta", align: "right" },
      { name: "cantidadExistente", label: "Stock", field: "cantidadExistente", align: "right" },
      { name: "activo", label: "Estado", field: (row) => (row.activo ? "Activo" : "Pausado"), align: "center" },
      { name: "acciones", label: "Acciones", field: "acciones", align: "center" },
    ];

    const cargarProductos = async () => {
      const res = await api.get("/productos");
      productos.value = res.data;
    };

    const abrirEditar = (row) => {
      productoEditar.value = { ...row };
      stockIncremento.value = 0;
      archivoImagen.value = null;
      dialogEditar.value = true;
    };

    const actualizarProducto = async () => {
      try {
        if (stockIncremento.value < 0) {
          $q.notify({ type: "warning", message: "Solo puedes aumentar el stock." });
          return;
        }

        const nuevoStock =
          productoEditar.value.cantidadExistente + (stockIncremento.value || 0);

        let urlImagen = productoEditar.value.img;

        if (archivoImagen.value) {
          const formData = new FormData();
          formData.append("file", archivoImagen.value);

          const resImg = await api.post("/productos/upload", formData, {
            headers: { "Content-Type": "multipart/form-data" },
          });
          urlImagen = resImg.data.url;
        }

        const dataActualizar = {
          ...productoEditar.value,
          cantidadExistente: nuevoStock,
          img: urlImagen,
        };

        await api.put(`/productos/${productoEditar.value.codigoBarras}`, dataActualizar);
        $q.notify({ type: "positive", message: "Producto actualizado!" });
        dialogEditar.value = false;
        cargarProductos();
      } catch (err) {
        console.error(err);
        $q.notify({ type: "negative", message: "Error al actualizar." });
      }
    };

    const abrirEliminar = (row) => {
      productoEliminar.value = row;
      dialogEliminar.value = true;
    };

    const eliminarProducto = async () => {
      try {
        await api.delete(`/productos/${productoEliminar.value.codigoBarras}`);
        $q.notify({ type: "positive", message: "Producto eliminado!" });
        dialogEliminar.value = false;
        cargarProductos();
      } catch (err) {
        console.error(err);
        $q.notify({ type: "negative", message: "Error al eliminar." });
      }
    };

    const toggleActivo = async (row) => {
      try {
        const actualizado = { ...row, activo: !row.activo };
        await api.put(`/productos/${row.codigoBarras}`, actualizado);
        $q.notify({
          type: actualizado.activo ? "positive" : "warning",
          message: actualizado.activo ? "Producto activado" : "Producto pausado",
        });
        cargarProductos();
      } catch (err) {
        $q.notify({ type: "negative", message: "Error al cambiar estado." });
      }
    };

    onMounted(cargarProductos);

    return {
      productos,
      columns,
      dialogEditar,
      dialogEliminar,
      productoEditar,
      productoEliminar,
      stockIncremento,
      archivoImagen,
      abrirEditar,
      actualizarProducto,
      abrirEliminar,
      eliminarProducto,
      toggleActivo,
    };
  },
};
</script>
