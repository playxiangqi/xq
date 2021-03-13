<script lang="ts">
  import {
    Content,
    Header,
    HeaderNav,
    HeaderNavItem,
    SkipToContent,
  } from 'carbon-components-svelte';

  // GraphQL Client
  import { initClient, dedupExchange, fetchExchange } from '@urql/svelte';
  import { absintheExchange } from '@xq/utils/channel';
  initClient({
    url: '/graphql',
    exchanges: [dedupExchange, fetchExchange, absintheExchange],
  });

  // Routes
  import { Router } from '@roxi/routify';
  import { routes } from '../.routify/routes';

  let theme = 'g10';
  let isSideNavOpen = false;

  $: document.documentElement.setAttribute('theme', theme);
</script>

<div class="app">
  <div class="nav-container" role="navigation" aria-label="main navigation">
    <Header platformName="Play XiangQi" bind:isSideNavOpen>
      <div slot="skip-to-content">
        <SkipToContent />
      </div>
      <HeaderNav>
        <HeaderNavItem href="/" text="Demo" />
      </HeaderNav> -->
    </Header>
  </div>

  <div class="content-container">
    <Content>
      <Router {routes} />
    </Content>
  </div>
</div>

<style lang="scss" global>
  html,
  body {
    margin: 0;
    padding: 0;
  }

  html {
    height: -moz-available;
    height: -webkit-fill-available;
    height: stretch;

    * {
      box-sizing: border-box;
    }
  }

  body {
    height: 100%;
  }

  .app {
    height: 100%;
    width: 100%;

    .content-container {
      height: 80%;
    }
  }
</style>
