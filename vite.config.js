import { resolve } from "node:path";
import { defineConfig } from "vite";
import scalePx from "./plugins/postcss-scale-px";
import { nodePolyfills } from "vite-plugin-node-polyfills";

export default defineConfig(async () => ({
  resolve: {
    alias: {
      "@": resolve(__dirname, "src"),
    },
  },
  plugins: [
    nodePolyfills({
      protocolImports: true,
    }),
  ],
  css: {
    preprocessorOptions: {
      scss: {
        api: "modern-compiler",
      },
    },
    postcss: {
      plugins: [scalePx],
    },
  },
  clearScreen: false,
  server: {
    host: "0.0.0.0",
    port: 1420,
    strictPort: true,
    watch: {
      ignored: ["**/src-tauri/**"],
    },
  },
}));
