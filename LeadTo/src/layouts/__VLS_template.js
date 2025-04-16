import { ref } from "vue";

export default (await import("vue")).defineComponent({
  name: "MyLayout",
  setup() {
    const leftDrawerOpen = ref(false);
    function toggleLeftDrawer() {
      leftDrawerOpen.value = !leftDrawerOpen.value;
    }
    return {
      leftDrawerOpen,
      toggleLeftDrawer,
    };
  },
});
const __VLS_template = () => ({});
