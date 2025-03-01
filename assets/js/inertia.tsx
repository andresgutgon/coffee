import axios from "axios";
import { createInertiaApp } from "@inertiajs/react";
import { createRoot } from "react-dom/client";

axios.defaults.xsrfHeaderName = "x-csrf-token";

createInertiaApp({
  resolve: async (name) => {
    const pages = import.meta.glob("./pages/**/*.tsx");
    const page = pages[`./pages/${name}.tsx`];

    if (!page) {
      throw new Error(`Page ${name} not found.`);
    }

    return page();
  },
  setup({ App, el, props }) {
    createRoot(el).render(<App {...props} />);
  },
});
