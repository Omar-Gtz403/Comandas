import { ref } from "vue";

export default (await import("vue")).defineComponent({
  setup() {
    const images = ref([
      {
        id: 1,
        url: require("../assets/hardware.png"),
        name: "image 1",
      },
    ]);
    const columns = [
      {
        name: "name",
        required: true,
        label: "Paquetes",
        align: "left",
        field: (row) => row.name,
        format: (val) => `${val}`,
        sortable: true,
      },
      {
        name: "calories",
        align: "center",
        label: "Colores y estilos",
        field: "calories",
        sortable: true,
      },
      {
        name: "fat",
        align: "center",
        label: "Instalación y configuración",
        field: "fat",
        sortable: true,
      },

      {
        name: "protein",
        align: "center",
        label: "Software",
        field: "protein",
      },
      {
        name: "carbs",
        align: "center",
        label: "Base de datos remota",
        field: "carbs",
      },
      {
        name: "sodium",
        align: "center",
        label: "Servidores Remotos",
        field: "sodium",
      },
      {
        name: "sodium",
        align: "center",
        label: "Precio",
        field: "calcium",
      },
    ];

    const rows = [
      {
        name: "Paquete 1",
        calories: "✔",
        fat: "✔",
        carbs: "X",
        protein: "✔",
        sodium: "X",
        calcium: "$500/Mensual",
        iron: "1%",
      },

      {
        name: "Paquete 2",
        calories: "✔",
        fat: "✔",
        carbs: "✔",
        protein: "✔",
        sodium: "✔",
        calcium: "$1500/Permanente",
        iron: "1%",
      },
    ];
    const columns1 = [
      {
        name: "name",
        required: true,
        label: "Paquetes",
        align: "left",
        field: (row) => row.name,
        format: (val) => `${val}`,
        sortable: true,
      },
      {
        name: "calories",
        align: "center",
        label: "Pc de escritorio",
        field: "calories",
        sortable: true,
      },
      {
        name: "fat",
        align: "center",
        label: "Bascula Digital",
        field: "fat",
        sortable: true,
      },

      {
        name: "protein",
        align: "center",
        label: "Impresora de tickets",
        field: "protein",
      },
      {
        name: "carbs",
        align: "center",
        label: "Scanner de código de barras",
        field: "protein",
      },
      {
        name: "sodium",
        align: "center",
        label: "Caja de Dinero",
        field: "protein",
      },
      {
        name: "sodium",
        align: "center",
        label: "Teclado y mouse",
        field: "protein",
      },
      {
        name: "calcium",
        align: "center",
        label: "Precio",
        field: "calcium",
      },
    ];

    const rows1 = [
      {
        name: "Paquete 1",
        calories: "✔",
        fat: "✔",
        carbs: "X",
        protein: "✔",
        sodium: "X",
        calcium: "$20000",
        iron: "1%",
      },
    ];
    const columns2 = [
      {
        name: "name",
        required: true,
        label: "Paquetes",
        align: "left",
        field: (row) => row.name,
        format: (val) => `${val}`,
        sortable: true,
      },
      {
        name: "calories",
        align: "center",
        label: "Host",
        field: "calories",
        sortable: true,
      },
      {
        name: "fat",
        align: "center",
        label: "Prediseño",
        field: "fat",
        sortable: true,
      },

      {
        name: "protein",
        align: "center",
        label: "Carga de logos",
        field: "protein",
      },
      {
        name: "carbs",
        align: "center",
        label: "Carga de colores",
        field: "carbs",
      },
      {
        name: "sodium",
        align: "center",
        label: "Precio",
        field: "sodium",
      },
    ];

    const rows2 = [
      {
        name: "Paquete 1",
        calories: "✔",
        fat: "✔",
        carbs: "✔",
        protein: "✔",
        sodium: "$500/Mensual",
        calcium: "14%",
        iron: "1%",
      },

      {
        name: "Paquete 2",
        calories: "✔",
        fat: "✔",
        carbs: "✔",
        protein: "✔",
        sodium: "$5000/Anual",
        calcium: "8%",
        iron: "1%",
      },
    ];
    const columns3 = [
      {
        name: "name",
        required: true,
        label: "Paquetes",
        align: "left",
        field: (row) => row.name,
        format: (val) => `${val}`,
        sortable: true,
      },
      {
        name: "calories",
        align: "center",
        label: "Host",
        field: "calories",
        sortable: true,
      },
      {
        name: "fat",
        align: "center",
        label: "Prediseño",
        field: "fat",
        sortable: true,
      },

      {
        name: "protein",
        align: "center",
        label: "Carga de logos",
        field: "protein",
      },
      {
        name: "carbs",
        align: "center",
        label: "Colores",
        field: "carbs",
      },
      {
        name: "sodium",
        align: "center",
        label: "Precio",
        field: "sodium",
      },
    ];

    const rows3 = [
      {
        name: "Paquete 1",
        calories: "✔",
        fat: "✔",
        carbs: "✔",
        protein: "✔",
        sodium: "$1500/Anual",
        calcium: "14%",
        iron: "1%",
      },
    ];
    const columns4 = [
      {
        name: "name",
        required: true,
        label: "Paquetes",
        align: "left",
        field: (row) => row.name,
        format: (val) => `${val}`,
        sortable: true,
      },
      {
        name: "calories",
        align: "center",
        label: "Base de datos remota",
        field: "calories",
        sortable: true,
      },
      {
        name: "fat",
        align: "center",
        label: "Host",
        field: "fat",
        sortable: true,
      },

      {
        name: "protein",
        align: "center",
        label: "Soporte",
        field: "protein",
      },

      {
        name: "sodium",
        align: "center",
        label: "Precio",
        field: "sodium",
      },
    ];

    const rows4 = [
      {
        name: "Paquete 1",
        calories: "✔",
        fat: "✔",
        carbs: "✔",
        protein: "✔",
        sodium: "$5000/Mensual",
        calcium: "14%",
        iron: "1%",
      },
    ];
    const columns5 = [
      {
        name: "name",
        required: true,
        label: "Paquetes",
        align: "left",
        field: (row) => row.name,
        format: (val) => `${val}`,
        sortable: true,
      },
      {
        name: "calories",
        align: "center",
        label: "Host",
        field: "calories",
        sortable: true,
      },
      {
        name: "fat",
        align: "center",
        label: "Prediseño",
        field: "fat",
        sortable: true,
      },

      {
        name: "protein",
        align: "center",
        label: "Carga de logos",
        field: "protein",
      },
      {
        name: "carbs",
        align: "center",
        label: "Colores",
        field: "carbs",
      },
      {
        name: "sodium",
        align: "center",
        label: "Precio",
        field: "sodium",
      },
    ];

    const rows5 = [
      {
        name: "Paquete 1",
        calories: "✔",
        fat: "✔",
        carbs: "✔",
        protein: "✔",
        sodium: "$5000/Mensual",
        calcium: "14%",
        iron: "1%",
      },
    ];
    return {
      images,
      slide: ref(1),
      autoplay: ref(true),
      lorem:
        "✔Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",

      columns,
      rows,
      columns1,
      rows1,
      columns2,
      rows2,
      columns3,
      rows3,
      columns4,
      rows4,
      columns5,
      rows5,
    };
  },
});
function __VLS_template() {
  // @ts-ignore
  [
    slide,
    autoplay,
    rows,
    columns,
    rows1,
    columns1,
    rows2,
    columns2,
    rows3,
    columns3,
    rows4,
    columns4,
  ];
  return {};
}
