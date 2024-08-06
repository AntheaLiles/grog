import { defineConfig } from 'vite'

export default defineConfig({
  root: './public', // Assurez-vous que ce chemin pointe vers le répertoire contenant `index.html`
  build: {
    outDir: '../dist', // Chemin de sortie pour les fichiers construits
    rollupOptions: {
      input: './public/index.html', // Chemin vers `index.html`
    },
  },
})