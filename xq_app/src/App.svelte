<script lang="ts">
  import 'bulma/bulma.sass';

  // GraphQL Client
  import { initClient } from '@urql/svelte';
  initClient({ url: '/graphql' });

  // Components
  import Demo from './views/Demo.svelte';

  // Routes
  import Router, { link } from 'svelte-spa-router';
  import { wrap } from 'svelte-spa-router/wrap';
  const routes = {
    '/': Demo,
    '/analysis/explorer': wrap({
      asyncComponent: () => import('./views/analysis/DatabaseExplorer.svelte'),
    }),
  };
</script>

<div class="app">
  <nav class="navbar" role="navigation" aria-label="main navigation">
    <div class="navbar-brand">
      <a class="navbar-item" href="https://github.com/playxiangqi">
        Play XiangQi
      </a>
    </div>
    <div class="navbar-menu">
      <div class="navbar-start">
        <a class="navbar-item" href="/" use:link>Demo</a>
        <div class="navbar-item has-dropdown is-hoverable">
          <div class="navbar-link">Analysis</div>
          <div class="navbar-dropdown">
            <a class="navbar-item" href="/analysis/explorer" use:link>
              Database Explorer
            </a>
          </div>
        </div>
      </div>
    </div>
  </nav>
  <div class="view-container">
    <Router {routes} />
  </div>
</div>

<style lang="scss">
  :global(html, body) {
    margin: 0;
    padding: 0;
  }

  :global(html) {
    height: -moz-available;
    height: -webkit-fill-available;
    height: stretch;

    * {
      box-sizing: border-box;
    }
  }

  :global(body) {
    height: 100%;
  }

  .app {
    height: 100%;
    width: 100%;

    .navbar {
    }

    .view-container {
      height: 80%;
    }
  }
</style>
