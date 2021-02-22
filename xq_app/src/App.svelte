<script lang="ts">
  import 'bulma/bulma.sass';

  // GraphQL Client
  import { initClient } from '@urql/svelte';
  initClient({ url: '/graphql' });

  // Components
  import SearchPanel from './components/analysis/SearchPanel.svelte';
  import Demo from './views/Demo.svelte';

  // Routes
  import Router, { link } from 'svelte-spa-router';
  const routes = {
    '/': Demo,
    '/analysis/database-explorer': SearchPanel,
  };

  // Modules
  // TODO: Move dimensions to utilities
  // TODO: Turn boardState into matchState
  import { createBoardState, Dimensions } from 'components/board';

  const DEFAULT_SCALE = 1.0;
  const dimensions = new Dimensions(DEFAULT_SCALE);
  const boardState = createBoardState(dimensions);
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
        <a class="navbar-item" href="/analysis/database-explorer" use:link>
          Analysis
        </a>
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
    }
  }
</style>
