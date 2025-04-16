<template>
  <div class="q-pa-md">
    <q-table
      flat
      bordered
      title="Lista de Eventos"
      :rows="eventos"
      :columns="columns"
      row-key="id"
      color="amber"
    />
  </div>
</template>

<script>
export default {
  name: "PageEventos",
  data() {
    return {
      columns: [
        { name: "id", label: "ID", field: "id", align: "left", sortable: true },
        { name: "nombre", label: "Nombre", field: "nombre", align: "left" },
        { name: "fecha", label: "Fecha", field: "fecha", align: "left" },
        { name: "lugar", label: "Lugar", field: "lugar", align: "left" },
        { name: "horario", label: "Horario", field: "horario", align: "left" },
        {
          name: "descripcion",
          label: "Descripción",
          field: "descripcion",
          align: "left",
        },
        { name: "imagen", label: "Imagen", field: "imagen", align: "left" },
        {
          name: "idCategoria",
          label: "Categoría",
          field: "idCategoria",
          align: "left",
        },
      ],
      eventos: [],
    };
  },
  mounted() {
    this.getEventos();
    this.postEventos();
  },
  methods: {
    getEventos() {
      this.$axios
        .get("http://localhost:8082/api/eventos/")
        .then((res) => {
          this.eventos = res.data;
          console.log("Eventos recibidos:", res.data);
        })
        .catch((err) => {
          console.error("Error al obtener eventos:", err);
        });
    },
    postEventos() {},
  },
};
</script>
