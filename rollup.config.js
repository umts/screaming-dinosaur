import resolve from '@rollup/plugin-node-resolve';
import {defineConfig} from 'rollup';

export default defineConfig({
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
