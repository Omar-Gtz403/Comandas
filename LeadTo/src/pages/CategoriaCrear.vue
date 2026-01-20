<template>
  <q-page class="q-pa-md flex flex-center">
    <q-card
      flat
      bordered
      class="q-pa-lg shadow-3 full-width card-container"
      style="max-width: 700px"
    >
      <!-- 🔄 SPINNER GLOBAL -->
      <q-inner-loading :showing="loading">
        <q-spinner-gears size="50px" color="primary" />
        <div class="text-primary q-mt-sm">Procesando...</div>
      </q-inner-loading>

      <!-- Header -->
      <q-card-section class="text-center">
        <div class="text-h5 text-primary">Gestión de Categorías</div>
        <div class="text-subtitle2 text-grey">
          Organiza, activa/pausa o agrega nuevas categorías
        </div>
      </q-card-section>

      <q-separator spaced />

      <!-- 🔍 Buscador -->
      <q-card-section>
        <q-input
          v-model="busqueda"
          dense
          outlined
          clearable
          debounce="300"
          placeholder="Buscar categoría..."
          prepend-icon="search"
        />
      </q-card-section>

      <!-- Formulario nueva categoría -->
      <q-card-section>
        <q-form @submit.prevent="crearCategoria" class="row q-col-gutter-sm">
          <q-input
            v-model="nuevaCategoria"
            outlined
            dense
            label="Nombre de la categoría"
            class="col-12 col-sm"
            :disable="loading"
            :rules="[(val) => !!val || 'Ingrese un nombre']"
          />
          <div class="col-12 col-sm-auto">
            <q-btn
              color="primary"
              label="Agregar"
              type="submit"
              class="full-width"
              :loading="loading"
            />
          </div>
        </q-form>
      </q-card-section>

      <q-separator spaced />

      <!-- Lista de categorías -->
      <q-card-section>
        <div class="text-subtitle1 text-primary q-mb-sm">
          Categorías Existentes
        </div>

        <q-list bordered separator>
          <transition-group name="fade" tag="div">
            <q-item
              v-for="(categoria, index) in categoriasFiltradas"
              :key="categoria.id"
              class="q-py-sm"
            >
              <q-item-section avatar>
                <q-avatar color="primary" text-color="white">
                  {{ index + 1 }}
                </q-avatar>
              </q-item-section>

              <q-item-section>
                <div class="text-subtitle2">{{ categoria.nombre }}</div>
                <div
                  class="text-caption"
                  :class="categoria.activo ? 'text-green' : 'text-grey'"
                >
                  {{ categoria.activo ? "Activa" : "Pausada" }}
                </div>
              </q-item-section>

              <q-item-section side class="row items-center q-gutter-xs">
                <q-btn
                  size="sm"
                  flat
                  round
                  icon="arrow_upward"
                  :disable="index === 0 || loading"
                  @click="moverArriba(index)"
                />
                <q-btn
                  size="sm"
                  flat
                  round
                  icon="arrow_downward"
                  :disable="index === categorias.length - 1 || loading"
                  @click="moverAbajo(index)"
                />
                <q-btn
                  size="sm"
                  flat
                  round
                  icon="edit"
                  color="primary"
                  @click="abrirModalEditar(categoria)"
                />
                <q-btn
                  size="sm"
                  flat
                  round
                  :icon="categoria.activo ? 'pause_circle' : 'play_circle'"
                  :color="categoria.activo ? 'orange' : 'green'"
                  @click="toggleCategoria(categoria)"
                />
              </q-item-section>
            </q-item>
          </transition-group>

          <q-item v-if="!loading && categoriasFiltradas.length === 0">
            <q-item-section class="text-grey text-center">
              No hay categorías
            </q-item-section>
          </q-item>
        </q-list>
      </q-card-section>

      <q-separator spaced />

      <!-- Guardar orden -->
      <q-card-section class="text-center">
        <q-btn
          label="Guardar Orden"
          color="primary"
          icon="save"
          :loading="loading"
          @click="guardarOrden"
        />
      </q-card-section>
    </q-card>

    <!-- ✨ MODAL EDITAR -->
    <q-dialog v-model="modalEditar">
      <q-card style="min-width: 320px">
        <q-card-section class="text-h6"> Editar Categoría </q-card-section>

        <q-card-section>
          <q-input
            v-model="categoriaEdit.nombre"
            label="Nombre"
            outlined
            dense
          />
          <q-toggle
            v-model="categoriaEdit.activo"
            label="Activa"
            color="green"
            class="q-mt-md"
          />
        </q-card-section>

        <q-card-actions align="right">
          <q-btn flat label="Cancelar" v-close-popup />
          <q-btn
            label="Guardar"
            color="primary"
            :loading="loading"
            @click="guardarEdicion"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script>
import { ref, computed, onMounted } from "vue";
import { useQuasar } from "quasar";
import { api } from "src/boot/axios";

export default {
  setup() {
    const $q = useQuasar();

    const categorias = ref([]);
    const nuevaCategoria = ref("");
    const busqueda = ref("");
    const loading = ref(false);

    const modalEditar = ref(false);
    const categoriaEdit = ref({});

    const categoriasFiltradas = computed(() => {
      if (!busqueda.value) return categorias.value;
      return categorias.value.filter((c) =>
        c.nombre.toLowerCase().includes(busqueda.value.toLowerCase())
      );
    });

    const cargarCategorias = async () => {
      loading.value = true;
      try {
        const res = await api.get("/categorias");
        categorias.value = res.data
          .filter((c) => c.nombre !== "Insumos")
          .sort((a, b) => a.orden - b.orden);
      } finally {
        loading.value = false;
      }
    };

    const crearCategoria = async () => {
      loading.value = true;
      try {
        await api.post("/categorias", {
          nombre: nuevaCategoria.value,
          activo: true,
          orden: categorias.value.length + 1,
        });
        nuevaCategoria.value = "";
        cargarCategorias();
      } finally {
        loading.value = false;
      }
    };

    const abrirModalEditar = (categoria) => {
      categoriaEdit.value = { ...categoria };
      modalEditar.value = true;
    };

    const guardarEdicion = async () => {
      loading.value = true;
      try {
        await api.put(
          `/categorias/${categoriaEdit.value.id}`,
          categoriaEdit.value
        );
        modalEditar.value = false;
        cargarCategorias();
        $q.notify({ type: "positive", message: "Categoría actualizada" });
      } finally {
        loading.value = false;
      }
    };

    const toggleCategoria = async (categoria) => {
      loading.value = true;
      await api.put(`/categorias/${categoria.id}/toggle`);
      cargarCategorias();
    };

    const moverArriba = (i) => {
      categorias.value.splice(i - 1, 0, categorias.value.splice(i, 1)[0]);
    };

    const moverAbajo = (i) => {
      categorias.value.splice(i + 1, 0, categorias.value.splice(i, 1)[0]);
    };

    const guardarOrden = async () => {
      loading.value = true;
      await api.put(
        "/categorias/orden",
        categorias.value.map((c, i) => ({ id: c.id, orden: i + 1 }))
      );
      loading.value = false;
      $q.notify({ type: "positive", message: "Orden guardado" });
    };

    onMounted(cargarCategorias);

    return {
      categorias,
      categoriasFiltradas,
      nuevaCategoria,
      busqueda,
      loading,
      modalEditar,
      categoriaEdit,
      crearCategoria,
      abrirModalEditar,
      guardarEdicion,
      moverArriba,
      moverAbajo,
      guardarOrden,
      toggleCategoria,
    };
  },
};
</script>

<style scoped>
.card-container {
  position: relative;
}
.fade-enter-active,
.fade-leave-active {
  transition: all 0.25s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
  transform: translateY(6px);
}
.text-h5 {
  font-weight: bold;
}
</style>
