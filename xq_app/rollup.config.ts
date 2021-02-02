import typescript from '@rollup/plugin-typescript';
import svelte from 'rollup-plugin-svelte';
import sveltePreprocess from 'svelte-preprocess';
import resolve from '@rollup/plugin-node-resolve';
import postcss from 'rollup-plugin-postcss';
import autoprefixer from 'autoprefixer';
import commonjs from '@rollup/plugin-commonjs';
import json from '@rollup/plugin-json';
import svelteSVG from 'rollup-plugin-svelte-svg';
import copy from 'rollup-plugin-copy';
import { terser } from 'rollup-plugin-terser';

const production = process.env.MIX_ENV === 'prod';
const STATIC_ASSET_DIR = '../xq_portal/priv/static';

export default {
  // Main entry point
  input: 'src/main.ts',

  // Output path/format and request sourcemaps
  output: {
    file: `${STATIC_ASSET_DIR}/js/app.js`,
    format: 'iife',
    name: 'app',
    sourcemap: true,
  },

  watch: {
    clearScreen: false,
    include: 'src/**',
  },

  plugins: [
    typescript({ sourceMap: !production }),

    // Converts .svelte files to .js equivalent
    svelte({
      // Enables <style type="scss"> or <script lang="typescript">
      // inside .svelte files
      preprocess: sveltePreprocess({
        sourceMap: !production,
      }),
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
    postcss({
      plugins: [autoprefixer()],
    }),

    // CommonJS import convention
    commonjs(),

    // JSON resolution
    json(),

    // Allow importing svgs as ES modules
    svelteSVG(),

    // Copy assets to dist
    copy({
      targets: [{ src: 'src/assets/sounds', dest: `${STATIC_ASSET_DIR}/` }],
    }),

    // Minify production builds
    production && terser(),
  ],
};
