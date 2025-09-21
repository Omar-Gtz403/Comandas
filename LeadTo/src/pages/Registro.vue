<script>
import { ref, onMounted } from "vue";
import { useQuasar } from "quasar";
import { api } from "src/boot/axios";

export default {
  name: "RegistrarProducto",
  setup() {
    const $q = useQuasar();
    const dateDialog = ref(false);

    const producto = ref({
      codigoBarras: "",
      nombreProducto: "",
      proveedor: "",
      descripcion: "",
      precioCompra: 0,
      precioVenta: 0,
      stockMin: 0,
      stockMax: 0,
      caducidad: "",
      cantidadExistente: 0,
      categoriaId: null,
      file: null, // archivo de imagen
      imgUrl: "", // url opcional
    });

    const categorias = ref([]);

    // Cargar categorías desde API
    const cargarCategorias = async () => {
      try {
        const res = await api.get("/productos/categorias"); // <-- ojo, tu backend expone /productos/categorias
        categorias.value = res.data;
      } catch (err) {
        console.error("Error cargando categorías:", err);
      }
    };

    onMounted(cargarCategorias);

    // Registrar producto con FormData
    const registrarProducto = async () => {
      try {
        const formData = new FormData();

        // Añadir todos los campos
        formData.append("codigoBarras", producto.value.codigoBarras);
        formData.append("nombreProducto", producto.value.nombreProducto);
        formData.append("proveedor", producto.value.proveedor);
        formData.append("descripcion", producto.value.descripcion);
        formData.append("precioCompra", producto.value.precioCompra);
        formData.append("precioVenta", producto.value.precioVenta);
        formData.append("stockMin", producto.value.stockMin);
        formData.append("stockMax", producto.value.stockMax);
        formData.append("caducidad", producto.value.caducidad);
        formData.append("cantidadExistente", producto.value.cantidadExistente);
        formData.append("categoriaId", producto.value.categoriaId);

        if (producto.value.file) {
          formData.append("file", producto.value.file); // archivo imagen
        }
        if (producto.value.imgUrl) {
          formData.append("imgUrl", producto.value.imgUrl); // url alternativa
        }

        await api.post("/productos/subir", formData, {
          headers: { "Content-Type": "multipart/form-data" },
        });

        $q.notify({
          type: "positive",
          message: "Producto registrado con éxito!",
          position: "top",
        });
        resetForm();
      } catch (err) {
        console.error("Error registrando producto:", err);
        $q.notify({
          type: "negative",
          message: "Error al registrar producto.",
          position: "top",
        });
      }
    };

    const resetForm = () => {
      producto.value = {
        codigoBarras: "",
        nombreProducto: "",
        proveedor: "",
        descripcion: "",
        precioCompra: 0,
        precioVenta: 0,
        stockMin: 0,
        stockMax: 0,
        caducidad: "",
        cantidadExistente: 0,
        categoriaId: null,
        file: null,
        imgUrl: "",
      };
    };

    return { producto, registrarProducto, resetForm, dateDialog, categorias };
  },
};
</script>

<style scoped lang="sass">
.q-card
  border-radius: 12px
  box-shadow: 0 6px 18px rgba(0, 0, 0, 0.12)

.q-input__control
  transition: all 0.2s ease
  &:focus-within
    border-color: #1976d2
    box-shadow: 0 0 6px rgba(25, 118, 210, 0.3)
</style>
