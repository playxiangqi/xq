<script>
  import Board from './components/board/Board.svelte';
  import { createAuthStore } from './services/auth/store';

  const { store: authStore, broadcast: sendAuthRequest } = createAuthStore();
</script>

<div class="app">
  <div class="col-1" />
  <div class="col-2">
    <Board />
  </div>
  <div class="col-3" />
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

    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
  }
</style>
