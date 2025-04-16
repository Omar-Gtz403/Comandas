<template>
  <div class="q-pa-md" style="max-width: 500px">
    <q-form @submit="registrarEvento" @reset="onReset" class="q-gutter-md">
      <q-input
        filled
        v-model="evento.nombre"
        label="Nombre del evento *"
        required
      />
      <q-input
        filled
        v-model="evento.fecha"
        label="Fecha (YYYY-MM-DD) *"
        required
      />
      <q-input filled v-model="evento.lugar" label="Lugar *" required />
      <q-input
        filled
        v-model="evento.horario"
        label="Horario (HH:mm:ss) *"
        required
      />
      <q-input filled v-model="evento.descripcion" label="Descripción *" />
      <q-input filled v-model="evento.imagen" label="URL de la imagen" />
      <q-input
        filled
        v-model.number="evento.idCategoria"
        type="number"
        label="ID Categoría *"
        required
      />

      <div>
        <q-btn label="Registrar evento" type="submit" color="primary" />
        <q-btn
          label="Limpiar"
          type="reset"
          color="secondary"
          flat
          class="q-ml-sm"
        />
      </div>
    </q-form>
  </div>
</template>

<script setup>
import { ref } from "vue";
import { useQuasar } from "quasar";
import axios from "axios";

const $q = useQuasar();

// Registramos el tipo personalizado solo una vez
$q.notify.registerType("evento-registrado", {
  icon: "event_available",
  progress: true,
  color: "green-4",
  textColor: "white",
  classes: "glossy",
});

const evento = ref({
  nombre: "",
  fecha: "",
  lugar: "",
  horario: "",
  descripcion: "",
  imagen: "",
  idCategoria: null,
});

const registrarEvento = () => {
  axios
    .post("http://localhost:8082/api/eventos", evento.value)
    .then(() => {
      $q.notify({
        type: "evento-registrado",
        message: "Evento registrado correctamente",
      });
      onReset();
    })
    .catch((error) => {
      console.error(error);
      $q.notify({
        type: "negative",
        message: "Error al registrar el evento",
      });
    });
};

const onReset = () => {
  evento.value = {
    nombre: "",
    fecha: "",
    lugar: "",
    horario: "",
    descripcion: "",
    imagen: "",
    idCategoria: null,
  };
};
</script>
