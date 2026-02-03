export default () => {
  if (typeof window === "undefined") return;

  const RO = window.ResizeObserver;
  if (!RO) return;

  window.ResizeObserver = class extends RO {
    constructor(callback) {
      super((entries, observer) => {
        window.requestAnimationFrame(() => {
          callback(entries, observer);
        });
      });
    }
  };
};
