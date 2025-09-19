const resolve = require('@rollup/plugin-node-resolve');
const {defineConfig} = require('rollup');

module.exports = defineConfig({
  output: {
    format: 'esm',
    sourcemap: true,
  },
  plugins: [
    resolve(),
    {
      name: 'ignore-css',
      load(id) {
        if (id.endsWith('.css')) {
          return '';
        }
      },
    },
  ],
});
