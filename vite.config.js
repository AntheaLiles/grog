const { defineConfig } = require('vite')

module.exports = defineConfig({
  root: './public',
  build: {
    outDir: '../dist',
    emptyOutDir: true,
    rollupOptions: {
      input: './public/index.html',
    },
  },
})