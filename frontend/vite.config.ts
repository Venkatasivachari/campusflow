import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// In dev/preview, /api is proxied to the Java backend. In Docker, nginx does the same.
const api = { "/api": { target: "http://localhost:8080", changeOrigin: true } };

export default defineConfig({
  plugins: [react()],
  server: { port: 5173, proxy: api },
  preview: { port: 4173, proxy: api },
});
