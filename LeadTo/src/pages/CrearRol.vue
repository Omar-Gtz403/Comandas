<template>
  <q-page class="q-pa-md flex flex-center">
    <div class="w-full max-w-2xl bg-white p-6 rounded-xl shadow-lg">
      <div class="text-h5 text-weight-bold text-primary text-center mb-4">
        Crear Rol
      </div>

      <q-form @submit.prevent="crearRol" class="q-gutter-md">
        <!-- Nombre del rol -->
        <q-input
          v-model="rol.nombre"
          label="Nombre del Rol"
          outlined
          dense
          required
          clearable
          prepend-icon="badge"
        />

        <!-- Permisos disponibles -->
        <div class="q-mt-md">
          <div class="text-subtitle1 text-weight-medium text-grey-8 q-mb-sm">
            Permisos disponibles
          </div>

          <!-- Contenedor de permisos en cuadrícula -->
          <div class="permisos-grid">
            <q-card
              v-for="permiso in permisos"
              :key="permiso.id"
              class="permiso-card"
              flat
              bordered
            >
              <q-card-section class="q-pa-sm flex items-center">
                <q-checkbox
                  v-model="rol.permisosIds"
                  :val="permiso.id"
                  :label="permiso.nombre"
                  dense
                  size="sm"
                />
              </q-card-section>
            </q-card>
          </div>
        </div>

        <!-- Botón crear -->
        <q-btn
          label="Crear Rol"
          type="submit"
          color="primary"
          class="w-full q-mt-md"
          unelevated
          icon="add_circle"
        />
      </q-form>

      <q-separator spaced class="q-my-md" />

      <!-- Lista de roles existentes -->
      <div>
        <div class="text-subtitle1 text-weight-medium text-grey-8 q-mb-sm">
          Roles existentes
        </div>

        <q-list bordered padding>
          <q-item v-for="r in roles" :key="r.id" class="rounded-borders">
            <q-item-section>
              <div class="text-weight-bold text-primary">{{ r.nombre }}</div>
              <div class="text-caption text-grey">
                Permisos:
                <span class="text-grey-8">
                  {{ r.permisosList?.join(", ") || "Sin permisos" }}
                </span>
              </div>
            </q-item-section>
          </q-item>
        </q-list>
      </div>
    </div>
  </q-page>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { api } from "boot/axios";
import { Notify } from "quasar";

const rol = ref({
  nombre: "",
  permisosIds: [],
});

const roles = ref([]);
const permisos = ref([]);

const cargarRoles = async () => {
  try {
    const { data } = await api.get("/roles");
    roles.value = data.map((r) => ({
      ...r,
      permisosList:
        r.rolPermisos?.map((rp) => rp.permiso?.nombre) || r.permisosList || [],
    }));
  } catch {
    Notify.create({ type: "negative", message: "Error al cargar roles" });
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
  if (!rol.value.nombre) {
    return Notify.create({
      type: "warning",
      message: "Ingrese un nombre para el rol",
    });
  }

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
  }
};
</script>

<style scoped>
.w-full {
  width: 100%;
}

.permisos-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
  gap: 8px;
}

.permiso-card {
  transition: all 0.2s ease;
  cursor: pointer;
}

.permiso-card:hover {
  background-color: #f0f4ff;
  border-color: #2196f3;
}
</style>
