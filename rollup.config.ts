import typescript from '@rollup/plugin-typescript';
import svelte from 'rollup-plugin-svelte';
import autoPreprocess from 'svelte-preprocess';
import resolve from '@rollup/plugin-node-resolve';
import postcss from 'rollup-plugin-postcss';
import commonjs from '@rollup/plugin-commonjs';
import json from '@rollup/plugin-json';
import { terser } from 'rollup-plugin-terser';

const production = process.env.MIX_ENV === 'prod';
const STATIC_ASSET_DIR = 'xq_portal/priv/static';

export default {
  // Main entry point
  input: 'xq_app/src/main.ts',

  // Output path/format and request sourcemaps
  output: {
    sourcemap: true,
    format: 'iife',
    name: 'app',
    file: `${STATIC_ASSET_DIR}/js/app.js`,
  },

  watch: {
    clearScreen: false,
    include: 'xq_app/src/**',
  },

  plugins: [
    typescript({ sourceMap: !production }),

    // Converts .svelte files to .js equivalent
    svelte({
      // Enables <style type="scss"> or <script lang="typescript">
      // inside .svelte files
      preprocess: autoPreprocess(),
      compilerOptions: {
        // Enable run-time checks in non-production environments
        dev: !production,
        cssOutputFilename: `${STATIC_ASSET_DIR}/css/app.css`,
      },
    }),

    // Resolve node modules
    resolve({
      browser: true,
      dedupe: ['svelte'],
    }),

    // CSS preprocessor
    postcss(),

    // CommonJS import convention
    commonjs(),

    // JSON resolution
    json(),

    // Minify production builds
    production && terser(),
  ],
};
