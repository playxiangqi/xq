import typescript from '@rollup/plugin-typescript';
import svelte from 'rollup-plugin-svelte';
import sveltePreprocess from 'svelte-preprocess';
import nodeResolve from '@rollup/plugin-node-resolve';
import postcss from 'rollup-plugin-postcss';
import autoprefixer from 'autoprefixer';
import commonjs from '@rollup/plugin-commonjs';
import json from '@rollup/plugin-json';
import nodePollyfills from 'rollup-plugin-polyfill-node';
import svelteSVG from 'rollup-plugin-svelte-svg';
import copy from 'rollup-plugin-copy';
import { terser } from 'rollup-plugin-terser';
import replace from '@rollup/plugin-replace';
import alias from '@rollup/plugin-alias';
import path from 'path';

const production = process.env.MIX_ENV === 'prod';
const STATIC_ASSET_DIR = '../xq_portal/priv/static';
const ROOT_DIR = path.resolve(__dirname);

export default {
  // Main entry point
  input: 'src/main.ts',

  // Output path/format and request sourcemaps
  output: {
    dir: `${STATIC_ASSET_DIR}/js`,
    format: 'es',
    name: 'app',
    sourcemap: true,
  },

  preserveEntrySignatures: 'strict',

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
      extensions: ['.svelte'],
    }),

    alias({
      entries: [{ find: '@xq', replacement: path.resolve(ROOT_DIR, 'src') }],
    }),

    // Resolve node modules
    nodeResolve({
      browser: true,
      preferBuiltins: false,
      extensions: ['.svelte'],
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

    // Node.js builtins and browser globals
    nodePollyfills(),

    // Allow importing svgs as ES modules
    svelteSVG(),

    // Copy assets to dist
    copy({
      targets: [{ src: 'assets/sounds', dest: `${STATIC_ASSET_DIR}/` }],
    }),

    // Minify production builds
    production && terser(),

    // NODE_ENV replacement for bundling urql
    production
      ? replace({ 'process.env.NODE_ENV': JSON.stringify('production') })
      : replace({ 'process.env.NODE_ENV': JSON.stringify('development') }),
  ],
};
