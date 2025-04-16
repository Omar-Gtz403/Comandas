import { ref } from "vue";

export default (await import("vue")).defineComponent({
  setup() {
    return {
      slide: ref("first"),
    };
  },
});
