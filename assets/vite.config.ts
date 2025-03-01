import react from "@vitejs/plugin-react";
import path from "node:path";
import { defineConfig } from "vite";
import type { Plugin, ConfigEnv } from "vite";

interface TopbarPlugin extends Plugin {
  name: string;
  transform(
    code: string,
    id: string,
  ):
    | {
        code: string;
        map: null;
      }
    | undefined;
}

const createTopbarPlugin = (): TopbarPlugin => ({
  name: "topbar-module",
  transform(code, id) {
    if (id.endsWith("vendor/topbar.js")) {
      return {
        code: `
          let topbar;
          (function(window, document) {
            ${code}
          })(window, document);
          export default window.topbar;
        `,
        map: null,
      };
    }
  },
});

export default defineConfig(({ command }: ConfigEnv) => {
  const isDev = command !== "build";

  if (isDev) {
    // Terminate the watcher when Phoenix quits
    process.stdin.on("close", () => {
      process.exit(0);
    });

    process.stdin.resume();
  }

  const config = {
    publicDir: "static",
    plugins: [react(), createTopbarPlugin()],
    resolve: {
      alias: {
        "@": path.resolve(__dirname, "./js"),
      },
    },
    build: {
      target: "esnext",
      emptyOutDir: false,
      polyfillDynamicImport: true,
      outDir: "../priv/static",
      sourcemap: isDev,
      manifest: "vite_manifest.json",
      rollupOptions: {
        input: {
          app: "./js/app.js",
          inertia: "./js/inertia.tsx",
        },
        output: {
          entryFileNames: "assets/[name].[hash].js",
          chunkFileNames: "assets/[name].[hash].js",
          assetFileNames: "assets/[name].[hash][extname]",
        },
        external: ["/fonts/*", "/images/*"],
      },
    },
  };

  return config;
});
