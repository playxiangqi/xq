<script lang="ts">
  import {
    Content,
    Header,
    HeaderNav,
    HeaderNavItem,
    HeaderNavMenu,
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

  let theme = 'white';
  let isSideNavOpen = false;

  $: document.documentElement.setAttribute('theme', theme);
</script>

<div class="app">
  <div class="nav-container" role="navigation" aria-label="main navigation">
    <Header
      platformName="Play XiangQi"
      uiShellAriaLabel="main navigation header"
      href="https://github.com/playxiangqi"
      bind:isSideNavOpen
    >
      <div slot="skip-to-content">
        <SkipToContent />
      </div>
      <HeaderNav>
        <HeaderNavItem href="/" text="Demo" />
        <HeaderNavItem href="/play" text="Play" />
        <HeaderNavMenu text="Analysis">
          <HeaderNavItem href="/analysis/explorer" text="Database Explorer" />
        </HeaderNavMenu>
      </HeaderNav>
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

    overflow: auto;

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

    display: grid;
    grid-template-rows: 5% 95%;
  }
</style>
