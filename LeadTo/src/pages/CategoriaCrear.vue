<template>
  <q-page class="q-pa-md">
    <q-card flat bordered class="q-pa-md">
      <q-card-section>
        <div class="text-h6 text-primary">Administrar Categorías</div>
      </q-card-section>

      <!-- Lista de categorías -->
      <q-list bordered padding>
        <q-item v-for="categoria in categorias" :key="categoria.id" clickable>
          <q-item-section>{{ categoria.nombre }}</q-item-section>
          <q-item-section side>
            <q-btn
              dense
              flat
              icon="edit"
              color="primary"
              @click="editarCategoria(categoria)"
            />
            <q-btn
              dense
              flat
              :icon="categoria.activo ? 'pause_circle' : 'play_circle'"
              :color="categoria.activo ? 'orange' : 'green'"
              @click="toggleCategoria(categoria)"
              :label="categoria.activo ? 'Pausar' : 'Activar'"
            />
          </q-item-section>
        </q-item>
        <q-item v-if="categorias.length === 0">
          <q-item-section class="text-grey"
            >No hay categorías disponibles</q-item-section
          >
        </q-item>
      </q-list>

      <q-separator class="q-my-md" />

      <!-- Formulario para agregar o editar -->
      <q-form @submit.prevent="guardarCategoria">
        <q-input
          filled
          v-model="categoriaForm.nombre"
          label="Nombre de categoría"
          required
        />

        <div class="q-mt-md">
          <q-btn label="Guardar" color="primary" type="submit" />
          <q-btn label="Cancelar" color="secondary" flat @click="resetForm" />
        </div>
      </q-form>
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
    const categoriaForm = ref({ id: null, nombre: "" });

    const cargarCategorias = async () => {
      try {
        const response = await api.get("/categorias");

        categorias.value = response.data;
      } catch (error) {
        console.error(error);
        $q.notify({ type: "negative", message: "Error al cargar categorías" });
      }
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
        await axios.put(`/api/categorias/${categoria.id}/toggle`);
        $q.notify({
          type: "positive",
          message: `Categoría ${categoria.activo ? "pausada" : "activada"}`,
        });
        cargarCategorias();
      } catch (error) {
        console.error(error);
        $q.notify({ type: "negative", message: "Error al cambiar estado" });
      }
    };

    const guardarCategoria = async () => {
      try {
        if (!categoriaForm.value.nombre.trim()) {
          $q.notify({
            type: "warning",
            message: "El nombre no puede estar vacío",
          });
          return;
        }

        if (categoriaForm.value.id) {
          // Editar categoría
          await api.put(
            `categorias/${categoriaForm.value.id}`,
            categoriaForm.value
          );
          $q.notify({ type: "positive", message: "Categoría actualizada" });
        } else {
          // Crear nueva categoría
          await api.post("categorias", categoriaForm.value);
          $q.notify({ type: "positive", message: "Categoría creada" });
        }

        resetForm();
        cargarCategorias();
      } catch (error) {
        console.error(error);
        $q.notify({ type: "negative", message: "Error al guardar categoría" });
      }
    };

    const editarCategoria = (categoria) => {
      categoriaForm.value = { ...categoria };
    };

    const resetForm = () => {
      categoriaForm.value = { id: null, nombre: "" };
    };

    const confirmarEliminar = (categoria) => {
      if (categoria.nombre === "Insumos") {
        $q.notify({
          type: "warning",
          message: 'La categoría "Insumos" no se puede eliminar',
        });
        return; // Bloquea la eliminación
      }

      $q.dialog({
        title: "Confirmar",
        message: `¿Deseas eliminar la categoría "${categoria.nombre}"?`,
        cancel: true,
        persistent: true,
      }).onOk(() => eliminarCategoria(categoria.id));
    };
    const eliminarCategoria = async (id) => {
      try {
        await api.delete(`categorias/${id}`);
        $q.notify({ type: "positive", message: "Categoría eliminada" });
        cargarCategorias();
      } catch (error) {
        console.error(error);
        $q.notify({ type: "negative", message: "Error al eliminar categoría" });
      }
    };

    onMounted(() => {
      cargarCategorias();
    });

    return {
      categorias,
      categoriaForm,
      guardarCategoria,
      editarCategoria,
      resetForm,
      confirmarEliminar,
    };
  },
};
</script>

<style scoped>
.q-page {
  max-width: 600px;
  margin: auto;
}
</style>
