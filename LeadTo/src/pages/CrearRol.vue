<template>
  <q-page class="q-pa-md flex flex-center">
    <q-card
      flat
      bordered
      class="full-width q-pa-lg shadow-4 card-container bg-white"
      style="max-width: 800px"
    >
      <!-- 🔄 SPINNER GLOBAL -->
      <q-inner-loading :showing="loading">
        <q-spinner-gears size="48px" color="primary" />
        <div class="text-primary q-mt-sm text-weight-medium">
          Procesando información...
        </div>
      </q-inner-loading>

      <!-- Header -->
      <q-card-section class="text-center">
        <div class="text-h5 text-weight-bold text-primary">
          Gestión de Roles
        </div>
        <div class="text-caption text-grey-7">
          Crea roles y asigna permisos al sistema
        </div>
      </q-card-section>

      <q-separator spaced />

      <!-- FORMULARIO -->
      <q-card-section>
        <q-form @submit.prevent="crearRol" class="q-gutter-md">
          <q-input
            v-model="rol.nombre"
            label="Nombre del Rol"
            outlined
            dense
            clearable
            prepend-icon="badge"
            :disable="loading"
            :rules="[(v) => !!v || 'Ingrese un nombre']"
          />

          <div>
            <div class="text-subtitle1 text-weight-medium text-grey-8 q-mb-sm">
              Permisos disponibles
            </div>

            <div class="permisos-grid">
              <q-card
                v-for="permiso in permisos"
                :key="permiso.id"
                flat
                bordered
                class="permiso-card"
                :class="{
                  'permiso-activo': rol.permisosIds.includes(permiso.id),
                }"
              >
                <q-card-section class="q-pa-sm">
                  <q-checkbox
                    v-model="rol.permisosIds"
                    :val="permiso.id"
                    :label="permiso.nombre"
                    dense
                    color="primary"
                  />
                </q-card-section>
              </q-card>
            </div>
          </div>

          <q-btn
            label="Crear Rol"
            type="submit"
            color="primary"
            icon="add_circle"
            unelevated
            class="full-width q-mt-md"
            :loading="loading"
          />
        </q-form>
      </q-card-section>

      <q-separator spaced />

      <!-- LISTA -->
      <q-card-section>
        <div class="text-subtitle1 text-weight-medium text-grey-8 q-mb-sm">
          Roles existentes
        </div>

        <q-list bordered separator>
          <q-item v-for="r in roles" :key="r.id">
            <q-item-section>
              <div class="text-weight-bold text-primary">
                {{ r.nombre }}
              </div>
              <div class="text-caption text-grey-7">
                Permisos:
                <span class="text-grey-9">
                  {{ r.permisosList?.join(", ") || "Sin permisos" }}
                </span>
              </div>
            </q-item-section>
          </q-item>

          <q-item v-if="!loading && roles.length === 0">
            <q-item-section class="text-grey text-center">
              No hay roles registrados
            </q-item-section>
          </q-item>
        </q-list>
      </q-card-section>
    </q-card>
  </q-page>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { api } from "boot/axios";
import { Notify } from "quasar";

const loading = ref(false);

const rol = ref({
  nombre: "",
  permisosIds: [],
});

const roles = ref([]);
const permisos = ref([]);

const cargarRoles = async () => {
  loading.value = true;
  try {
    const { data } = await api.get("/roles");
    roles.value = data.map((r) => ({
      ...r,
      permisosList:
        r.rolPermisos?.map((rp) => rp.permiso?.nombre) || r.permisosList || [],
    }));
  } catch {
    Notify.create({ type: "negative", message: "Error al cargar roles" });
  } finally {
    loading.value = false;
  }
};

const cargarPermisos = async () => {
  try {
    const { data } = await api.get("/permisos");
    permisos.value = data;
  } catch {
    Notify.create({ type: "negative", message: "Error al cargar permisos" });
  }
};

onMounted(() => {
  cargarRoles();
  cargarPermisos();
});

const crearRol = async () => {
  if (!rol.value.nombre) return;

  if (
    roles.value.some(
      (r) => r.nombre.toLowerCase() === rol.value.nombre.toLowerCase()
    )
  ) {
    return Notify.create({
      type: "warning",
      message: "Ya existe un rol con ese nombre",
    });
  }

  loading.value = true;
  try {
    const { data } = await api.post("/roles", {
      nombre: rol.value.nombre,
      permisosIds: rol.value.permisosIds,
    });

    roles.value.push({
      ...data,
      permisosList:
        data.rolPermisos?.map((rp) => rp.permiso?.nombre) ||
        data.permisosList ||
        [],
    });

    rol.value = { nombre: "", permisosIds: [] };
    Notify.create({ type: "positive", message: "Rol creado correctamente" });
  } catch (err) {
    Notify.create({
      type: "negative",
      message: err.response?.data?.message || "Error al crear rol",
    });
  } finally {
    loading.value = false;
  }
};
</script>

<style scoped>
.card-container {
  position: relative;
}

.permisos-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
  gap: 10px;
}

.permiso-card {
  transition: all 0.2s ease;
  cursor: pointer;
}

.permiso-card:hover {
  background-color: var(--q-primary-light);
  border-color: var(--q-primary);
}

.permiso-activo {
  border-color: var(--q-primary);
  background-color: rgba(33, 150, 243, 0.08);
}
</style>
