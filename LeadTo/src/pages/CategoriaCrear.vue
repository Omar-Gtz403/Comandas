<template>
  <q-page class="q-pa-md flex flex-center">
    <q-card
      flat
      bordered
      class="q-pa-lg shadow-3 full-width"
      style="max-width: 700px"
    >
      <!-- Header -->
      <q-card-section class="text-center">
        <div class="text-h5 text-primary">Gestión de Categorías</div>
        <div class="text-subtitle2 text-grey">
          Organiza, activa/pausa o agrega nuevas categorías
        </div>
      </q-card-section>

      <q-separator spaced />

      <!-- Formulario nueva categoría -->
      <q-card-section>
        <q-form
          @submit.prevent="crearCategoria"
          class="row items-center q-gutter-sm"
        >
          <q-input
            v-model="nuevaCategoria"
            outlined
            dense
            label="Nombre de la categoría"
            class="col-grow"
            :rules="[(val) => !!val || 'Ingrese un nombre']"
          />
          <q-btn color="primary" label="Agregar" type="submit" />
        </q-form>
      </q-card-section>

      <q-separator spaced />

      <!-- Lista de categorías -->
      <q-card-section>
        <div class="text-subtitle1 text-primary q-mb-sm">
          Categorías Existentes
        </div>

        <q-list bordered separator>
          <q-item
            v-for="(categoria, index) in categorias"
            :key="categoria.id"
            clickable
            v-ripple
          >
            <q-item-section avatar>
              <q-avatar color="primary" text-color="white">
                {{ index + 1 }}
              </q-avatar>
            </q-item-section>

            <q-item-section>
              <div class="text-subtitle2">{{ categoria.nombre }}</div>
              <div class="text-caption text-grey">
                {{ categoria.activo ? "Activa" : "Pausada" }}
              </div>
            </q-item-section>

            <q-item-section side class="row items-center q-gutter-xs">
              <!-- Botones de mover -->
              <q-btn
                size="sm"
                flat
                round
                icon="arrow_upward"
                :disable="index === 0"
                @click="moverArriba(index)"
              />
              <q-btn
                size="sm"
                flat
                round
                icon="arrow_downward"
                :disable="index === categorias.length - 1"
                @click="moverAbajo(index)"
              />

              <!-- Acciones -->
              <q-btn
                size="sm"
                flat
                round
                icon="edit"
                color="primary"
                @click="editarCategoria(categoria)"
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

          <q-item v-if="categorias.length === 0">
            <q-item-section class="text-grey text-center">
              No hay categorías disponibles
            </q-item-section>
          </q-item>
        </q-list>
      </q-card-section>

      <!-- Guardar orden -->
      <q-separator spaced />
      <q-card-section class="text-center">
        <q-btn label="Guardar Orden" color="primary" @click="guardarOrden" />
      </q-card-section>
    </q-card>
  </q-page>
</template>

<script>
import { ref, onMounted } from "vue";
import { useQuasar } from "quasar";
import { api } from "src/boot/axios";

export default {
  setup() {
    const $q = useQuasar();
    const categorias = ref([]);
    const nuevaCategoria = ref("");

    const cargarCategorias = async () => {
      try {
        const res = await api.get("/categorias");
        categorias.value = res.data
          .filter((c) => c.nombre !== "Insumos") // 🚫 nunca mostrar Insumos
          .sort((a, b) => a.orden - b.orden);
      } catch (err) {
        console.error(err);
        $q.notify({ type: "negative", message: "Error al cargar categorías" });
      }
    };

    const crearCategoria = async () => {
      if (!nuevaCategoria.value) return;
      try {
        await api.post("/categorias", {
          nombre: nuevaCategoria.value,
          activo: true,
          orden: categorias.value.length + 1,
        });
        $q.notify({ type: "positive", message: "Categoría creada" });
        nuevaCategoria.value = "";
        cargarCategorias();
      } catch (err) {
        console.error(err);
        $q.notify({ type: "negative", message: "Error al crear categoría" });
      }
    };

    const guardarOrden = async () => {
      try {
        const payload = categorias.value.map((cat, index) => ({
          id: cat.id,
          orden: index + 1,
        }));
        await api.put("/categorias/orden", payload);
        $q.notify({ type: "positive", message: "Orden guardado" });
      } catch (err) {
        console.error(err);
        $q.notify({ type: "negative", message: "Error al guardar orden" });
      }
    };

    const moverArriba = (index) => {
      if (index > 0) {
        const temp = categorias.value[index];
        categorias.value.splice(index, 1);
        categorias.value.splice(index - 1, 0, temp);
      }
    };

    const moverAbajo = (index) => {
      if (index < categorias.value.length - 1) {
        const temp = categorias.value[index];
        categorias.value.splice(index, 1);
        categorias.value.splice(index + 1, 0, temp);
      }
    };

    const editarCategoria = (categoria) => {
      console.log("Editar categoría:", categoria);
    };

    const toggleCategoria = async (categoria) => {
      if (categoria.nombre === "Insumos") {
        $q.notify({
          type: "warning",
          message: 'La categoría "Insumos" no se puede pausar',
        });
        return;
      }
      try {
        await api.put(`/categorias/${categoria.id}/toggle`);
        $q.notify({
          type: "positive",
          message: `Categoría ${categoria.activo ? "pausada" : "activada"}`,
        });
        cargarCategorias();
      } catch (err) {
        console.error(err);
        $q.notify({ type: "negative", message: "Error al cambiar estado" });
      }
    };

    onMounted(() => cargarCategorias());

    return {
      categorias,
      nuevaCategoria,
      moverArriba,
      moverAbajo,
      guardarOrden,
      crearCategoria,
      editarCategoria,
      toggleCategoria,
    };
  },
};
</script>

<style scoped>
.q-page {
  max-width: 800px;
  margin: auto;
}
.text-h5 {
  font-weight: bold;
}
.q-btn {
  min-width: 36px;
}
</style>
