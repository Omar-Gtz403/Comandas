<template>
  <q-page class="q-pa-md page-background">
    <div class="row justify-center">
      <div class="col-12 col-xl-10">
        <!-- 🟦 HEADER -->
        <div class="header-card q-pa-lg q-mb-lg text-white">
          <div class="row items-center justify-between">
            <div class="row items-center">
              <div class="bg-white q-pa-sm rounded-borders q-mr-md">
                <q-icon name="inventory" size="32px" color="primary" />
              </div>
              <div>
                <div class="text-h5 text-weight-bold">
                  Administrador de productos
                </div>
                <div class="text-subtitle2 text-grey-2">
                  Gestión de inventario y precios
                </div>
              </div>
            </div>
            <q-btn
              color="white"
              text-color="primary"
              icon="add"
              label="Nuevo"
              class="q-px-md gt-xs"
              rounded
              unelevated
              to="/registro"
            />
            <q-btn
              color="white"
              text-color="primary"
              icon="add"
              round
              unelevated
              class="lt-sm"
              to="/registro"
            />
          </div>
        </div>

        <!-- 🔍 FILTROS -->
        <q-card class="filter-card q-mb-md q-pa-sm">
          <div class="row q-col-gutter-sm items-center">
            <div class="col-12 col-sm-4 col-md-3">
              <q-select
                v-model="filtroCategoria"
                :options="categoriasOptions"
                label="Categoría"
                outlined
                dense
                rounded
                bg-color="grey-1"
                emit-value
                map-options
                clearable
              >
                <template v-slot:prepend>
                  <q-icon name="category" />
                </template>
              </q-select>
            </div>
            <div class="col-12 col-sm text-right">
              <q-input
                v-model="busqueda"
                placeholder="Buscar por nombre o código..."
                outlined
                dense
                rounded
                bg-color="grey-1"
                debounce="300"
              >
                <template v-slot:prepend>
                  <q-icon name="search" />
                </template>
                <template v-slot:append v-if="busqueda">
                  <q-icon
                    name="close"
                    class="cursor-pointer"
                    @click="busqueda = ''"
                  />
                </template>
              </q-input>
            </div>
            <div class="col-auto">
              <q-btn
                icon="refresh"
                round
                flat
                color="primary"
                @click="cargarProductos"
              >
                <q-tooltip>Recargar</q-tooltip>
              </q-btn>
            </div>
          </div>
        </q-card>

        <!-- 📋 TABLA / GRID -->
        <q-table
          :rows="productosFiltrados"
          :columns="columns"
          row-key="codigoBarras"
          class="sticky-header-table shadow-0 bg-transparent"
          :loading="loading"
          :grid="$q.screen.lt.md"
          :pagination="{ rowsPerPage: 12 }"
        >
          <!-- SPINNER -->
          <template v-slot:loading>
            <q-inner-loading showing color="primary" />
          </template>

          <template v-slot:no-data>
            <div class="full-width row flex-center q-pa-xl text-grey pro-font">
              <q-icon name="search_off" size="md" class="q-mr-sm" />
              No se encontraron productos
            </div>
          </template>

          <!-- 📱 MOBILE GRID ITEM -->
          <template v-slot:item="props">
            <div class="col-12 col-sm-6 col-md-4 q-pa-sm">
              <q-card class="product-card full-height column">
                <q-img
                  :src="
                    props.row.img ||
                    'https://cdn.quasar.dev/img/image-assets.png'
                  "
                  :ratio="16 / 9"
                  class="bg-grey-2"
                >
                  <div class="absolute-top-right bg-transparent q-pa-none">
                    <q-badge
                      :color="props.row.activo ? 'positive' : 'grey'"
                      :label="props.row.activo ? 'Activo' : 'Pausado'"
                      floating
                      rounded
                    />
                  </div>
                  <template v-slot:error>
                    <div class="absolute-full flex flex-center text-white">
                      Sin Imagen
                    </div>
                  </template>
                </q-img>

                <q-card-section class="col q-pt-sm">
                  <div class="text-overline text-grey-7">
                    {{ props.row.categoria?.nombre || "Sin Categoría" }}
                  </div>
                  <div
                    class="text-subtitle1 text-weight-bold ellipsis-2-lines line-height-tight"
                  >
                    {{ props.row.nombreProducto }}
                  </div>
                  <div class="row items-center justify-between q-mt-sm">
                    <div class="text-h6 text-primary">
                      ${{ props.row.precioVenta }}
                    </div>
                    <div
                      :class="getClassStock(props.row)"
                      class="text-caption text-weight-bold border-stock q-px-sm rounded-borders"
                    >
                      Stock: {{ props.row.cantidadExistente }}
                    </div>
                  </div>
                </q-card-section>

                <q-separator />

                <q-card-actions align="right" class="bg-grey-1">
                  <q-btn
                    flat
                    round
                    color="grey-7"
                    icon="edit"
                    size="sm"
                    @click="abrirEditar(props.row)"
                  />
                  <q-btn
                    flat
                    round
                    :color="props.row.activo ? 'warning' : 'positive'"
                    :icon="props.row.activo ? 'pause' : 'play_arrow'"
                    size="sm"
                    @click="toggleActivo(props.row)"
                  />
                  <q-btn
                    flat
                    round
                    color="negative"
                    icon="delete_outline"
                    size="sm"
                    @click="abrirEliminar(props.row)"
                  />
                </q-card-actions>
              </q-card>
            </div>
          </template>

          <!-- 🖥️ DESKTOP BODY -->
          <template v-slot:body-cell-nombreProducto="props">
            <q-td :props="props">
              <div class="row items-center">
                <q-avatar rounded size="42px" class="q-mr-sm bg-grey-3">
                  <img
                    v-if="props.row.img"
                    :src="props.row.img"
                    style="object-fit: cover"
                  />
                  <q-icon v-else name="image" color="grey" />
                </q-avatar>
                <div>
                  <div class="text-weight-bold">
                    {{ props.row.nombreProducto }}
                  </div>
                  <div class="text-caption text-grey-7">
                    {{ props.row.codigoBarras }}
                  </div>
                </div>
              </div>
            </q-td>
          </template>

          <template v-slot:body-cell-cantidadExistente="props">
            <q-td :props="props" align="right">
              <q-badge
                :color="getColorStock(props.row)"
                text-color="white"
                rounded
                class="q-px-sm text-weight-bold"
              >
                {{ props.row.cantidadExistente }}
              </q-badge>
            </q-td>
          </template>

          <template v-slot:body-cell-precioVenta="props">
            <q-td
              :props="props"
              align="right"
              class="text-primary text-weight-bold"
            >
              ${{ props.row.precioVenta.toFixed(2) }}
            </q-td>
          </template>

          <template v-slot:body-cell-activo="props">
            <q-td :props="props" align="center">
              <q-toggle
                v-model="props.row.activo"
                color="positive"
                keep-color
                dense
                @update:model-value="toggleActivo(props.row)"
              />
            </q-td>
          </template>

          <template v-slot:body-cell-acciones="props">
            <q-td :props="props" align="center">
              <div class="row justify-center q-gutter-x-sm">
                <q-btn
                  flat
                  round
                  color="grey-7"
                  icon="edit"
                  size="sm"
                  @click="abrirEditar(props.row)"
                >
                  <q-tooltip>Editar</q-tooltip>
                </q-btn>
                <q-btn
                  flat
                  round
                  color="negative"
                  icon="delete"
                  size="sm"
                  @click="abrirEliminar(props.row)"
                >
                  <q-tooltip>Eliminar</q-tooltip>
                </q-btn>
              </div>
            </q-td>
          </template>
        </q-table>

        <!-- MODAL EDITAR -->
        <q-dialog v-model="dialogEditar">
          <q-card class="dialog-card">
            <q-card-section class="dialog-header row items-center">
              <div class="text-h6 text-white text-weight-bold">
                Editar Producto
              </div>
              <q-space />
              <q-btn
                icon="close"
                flat
                round
                dense
                color="white"
                v-close-popup
              />
            </q-card-section>

            <q-card-section class="q-pa-md scroll" style="max-height: 70vh">
              <q-form @submit.prevent="actualizarProducto" class="q-gutter-md">
                <div class="row q-col-gutter-sm">
                  <div class="col-12">
                    <q-input
                      v-model="productoEditar.nombreProducto"
                      label="Nombre"
                      outlined
                      dense
                      rounded
                    />
                  </div>
                  <div class="col-6">
                    <q-input
                      v-model="productoEditar.proveedor"
                      label="Proveedor"
                      outlined
                      dense
                      rounded
                    />
                  </div>
                  <div class="col-6">
                    <q-input
                      v-model="productoEditar.caducidad"
                      type="date"
                      label="Caducidad"
                      outlined
                      dense
                      rounded
                      stack-label
                    />
                  </div>
                </div>

                <div class="bg-grey-1 q-pa-md rounded-borders">
                  <div class="text-caption text-bold q-mb-sm text-primary">
                    PRECIOS & STOCK
                  </div>
                  <div class="row q-col-gutter-sm">
                    <div class="col-6">
                      <q-input
                        v-model.number="productoEditar.precioCompra"
                        label="Compra"
                        type="number"
                        prefix="$"
                        outlined
                        dense
                        bg-color="white"
                      />
                    </div>
                    <div class="col-6">
                      <q-input
                        v-model.number="productoEditar.precioVenta"
                        label="Venta"
                        type="number"
                        prefix="$"
                        outlined
                        dense
                        bg-color="white"
                      />
                    </div>
                    <div class="col-6">
                      <q-input
                        v-model="productoEditar.cantidadExistente"
                        label="Actual"
                        readonly
                        outlined
                        dense
                        bg-color="grey-3"
                      />
                    </div>
                    <div class="col-6">
                      <q-input
                        v-model.number="stockIncremento"
                        label="+ / - Ajuste"
                        type="number"
                        outlined
                        dense
                        bg-color="white"
                        placeholder="0"
                      />
                    </div>
                  </div>
                </div>

                <q-file
                  v-model="archivoImagen"
                  label="Actualizar Imagen"
                  outlined
                  dense
                  rounded
                  accept="image/*"
                  clearable
                >
                  <template v-slot:prepend
                    ><q-icon name="cloud_upload"
                  /></template>
                </q-file>

                <div
                  v-if="productoEditar.img || archivoImagen"
                  class="row justify-center"
                >
                  <q-img
                    :src="productoEditar.img"
                    class="rounded-borders shadow-2"
                    style="width: 120px; height: 120px; object-fit: cover"
                  />
                </div>

                <div class="row justify-end q-mt-lg">
                  <q-btn
                    label="Cancelar"
                    flat
                    color="grey"
                    v-close-popup
                    class="q-mr-sm"
                  />
                  <q-btn
                    label="Guardar Cambios"
                    type="submit"
                    color="primary"
                    unelevated
                    rounded
                    :loading="saving"
                  />
                </div>
              </q-form>
            </q-card-section>
          </q-card>
        </q-dialog>

        <!-- MODAL ELIMINAR -->
        <q-dialog v-model="dialogEliminar">
          <q-card style="border-radius: 16px">
            <q-card-section class="row items-center q-pb-none">
              <q-avatar
                icon="warning"
                color="negative"
                text-color="white"
                size="md"
              />
              <div class="text-h6 q-ml-sm">Confirmar eliminación</div>
            </q-card-section>

            <q-card-section class="q-pt-md">
              ¿Estás seguro de eliminar
              <b>{{ productoEliminar.nombreProducto }}</b
              >?
              <div class="text-caption text-grey q-mt-xs">
                Esta acción no se puede deshacer.
              </div>
            </q-card-section>

            <q-card-actions align="right">
              <q-btn flat label="Cancelar" color="grey" v-close-popup />
              <q-btn
                flat
                label="Eliminar"
                color="negative"
                @click="eliminarProducto"
                :loading="saving"
              />
            </q-card-actions>
          </q-card>
        </q-dialog>
      </div>
    </div>
  </q-page>
</template>

<script setup>
import { ref, onMounted, computed } from "vue";
import { useQuasar } from "quasar";
import { api } from "src/boot/axios";

const $q = useQuasar();

/* ================= STATE ================= */
const productos = ref([]);
const categorias = ref([]);
const loading = ref(true);
const saving = ref(false);

// Filtros
const busqueda = ref("");
const filtroCategoria = ref(null);

// Modals
const dialogEditar = ref(false);
const dialogEliminar = ref(false);

// Edit Objects
const productoEditar = ref({});
const productoEliminar = ref({});
const stockIncremento = ref(0);
const archivoImagen = ref(null);

/* ================= COLUMNS ================= */
const columns = [
  {
    name: "nombreProducto",
    label: "Producto",
    field: "nombreProducto",
    align: "left",
    sortable: true,
  },
  {
    name: "categoria",
    label: "Categoría",
    field: (row) => row.categoria?.nombre || " - ",
    align: "left",
    sortable: true,
  },
  {
    name: "precioVenta",
    label: "Precio",
    field: "precioVenta",
    align: "right",
    sortable: true,
  },
  {
    name: "cantidadExistente",
    label: "Stock",
    field: "cantidadExistente",
    align: "right",
    sortable: true,
  },
  {
    name: "activo",
    label: "Visible",
    field: "activo",
    align: "center",
    sortable: true,
  },
  { name: "acciones", label: "", align: "center" },
];

/* ================= COMPUTED ================= */
const categoriasOptions = computed(() => {
  return categorias.value.map((c) => ({ label: c.nombre, value: c.id }));
});

const productosFiltrados = computed(() => {
  let res = productos.value;

  // 1. Filtro Categoria
  if (filtroCategoria.value) {
    res = res.filter((p) => p.categoria?.id === filtroCategoria.value);
  }

  // 2. Busqueda Texto
  if (busqueda.value) {
    const t = busqueda.value.toLowerCase();
    res = res.filter(
      (p) =>
        p.nombreProducto.toLowerCase().includes(t) ||
        String(p.codigoBarras).includes(t)
    );
  }

  return res;
});

/* ================= HELPERS UI ================= */
function getClassStock({ cantidadExistente, stockMin }) {
  if (cantidadExistente <= stockMin) return "text-negative bg-red-1";
  if (cantidadExistente <= stockMin * 1.5) return "text-warning bg-orange-1";
  return "text-positive bg-green-1";
}

function getColorStock({ cantidadExistente, stockMin }) {
  if (cantidadExistente <= stockMin) return "negative";
  if (cantidadExistente <= stockMin * 1.5) return "warning";
  return "positive";
}

/* ================= API ================= */
const init = async () => {
  loading.value = true;
  try {
    const [pRes, cRes] = await Promise.all([
      api.get("/productos"),
      api.get("/categorias"),
    ]);
    productos.value = pRes.data;
    categorias.value = cRes.data;
  } catch (e) {
    $q.notify({ type: "negative", message: "Error cargando datos" });
  } finally {
    loading.value = false;
  }
};

const cargarProductos = async () => {
  loading.value = true;
  try {
    const res = await api.get("/productos");
    productos.value = res.data;
  } finally {
    loading.value = false;
  }
};

/* ================= ACCIONES ================= */
const abrirEditar = (row) => {
  productoEditar.value = { ...row };
  // Asegurar fecha input (YYYY-MM-DD)
  if (productoEditar.value.caducidad) {
    productoEditar.value.caducidad =
      productoEditar.value.caducidad.split("T")[0];
  }
  stockIncremento.value = 0;
  archivoImagen.value = null;
  dialogEditar.value = true;
};

const actualizarProducto = async () => {
  saving.value = true;
  try {
    let img = productoEditar.value.img;

    if (archivoImagen.value) {
      const fd = new FormData();
      fd.append("file", archivoImagen.value);
      const res = await api.post("/productos/upload", fd);
      img = res.data.url;
    }

    // Ajuste stock
    const nuevoStock =
      (productoEditar.value.cantidadExistente || 0) +
      (stockIncremento.value || 0);

    await api.put(`/productos/${productoEditar.value.codigoBarras}`, {
      ...productoEditar.value,
      cantidadExistente: nuevoStock,
      img,
      categoria: {
        id: productoEditar.value.categoria?.id,
      },
    });

    $q.notify({ type: "positive", message: "Producto actualizado" });
    dialogEditar.value = false;
    cargarProductos();
  } catch {
    $q.notify({ type: "negative", message: "Error al guardar" });
  } finally {
    saving.value = false;
  }
};

const toggleActivo = async (row) => {
  try {
    // Optimistic UI update could be done here, but usually safer to wait
    await api.put(`/productos/${row.codigoBarras}`, {
      ...row,
      activo: !row.activo,
      categoria: {
        id: row.categoria?.id,
      },
    });

    row.activo = !row.activo; // update local
    $q.notify({
      type: "positive",
      message: row.activo ? "Producto activado" : "Producto pausado",
      timeout: 1000,
    });
  } catch {
    $q.notify({ type: "negative", message: "Error cambiando estado" });
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
    // Eliminar localmente para rapida respuesta
    productos.value = productos.value.filter(
      (p) => p.codigoBarras !== productoEliminar.value.codigoBarras
    );
  } catch {
    $q.notify({ type: "negative", message: "Error al eliminar" });
  } finally {
    saving.value = false;
  }
};

onMounted(init);
</script>

<style scoped>
.page-background {
  background-color: #f8f9fa;
  min-height: 100vh;
}

/* Header */
.header-card {
  border-radius: 20px;
  background: #b71c1c;
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
    rgba(255, 255, 255, 0.15) 0%,
    transparent 60%
  );
  transform: rotate(30deg);
  pointer-events: none;
}

/* Filter Card */
.filter-card {
  border-radius: 16px;
  border: none;
  background: white;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.03);
}

/* Product Cards (Mobile) */
.product-card {
  border-radius: 16px;
  border: none;
  background: white;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
  transition: transform 0.2s ease;
  overflow: hidden;
}

.product-card:active {
  transform: scale(0.98);
}

.line-height-tight {
  line-height: 1.2;
}

.border-stock {
  border: 1px solid currentColor;
}

/* Dialog */
.dialog-card {
  min-width: 450px;
  border-radius: 20px;
  overflow: hidden;
}

.dialog-header {
  background: var(--q-primary);
  padding: 16px;
}

@media (max-width: 600px) {
  .dialog-card {
    min-width: 100%;
    border-radius: 0;
    height: 100vh;
    max-height: 100vh;
  }
}
</style>
