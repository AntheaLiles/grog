import { defineConfig } from 'vite'
import { glob } from 'glob'

export default defineConfig({
  base: '',
  root: './public',
  build: {
    outDir: '../dist',
    emptyOutDir: true,
    rollupOptions: {
      input: ['./public/index.html', ...glob.sync('./public/**/*.html')],
    },
  },
})