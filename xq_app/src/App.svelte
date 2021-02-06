<script lang="ts">
  import 'bulma/bulma.sass';

  // Components
  import AnalysisPanel from './components/analysis/AnalysisPanel.svelte';
  import Board from './components/board/Board.svelte';
  import Navbar from './components/nav/Navbar.svelte';

  // Modules
  // TODO: Move dimensions to utilities
  // TODO: Turn boardState into matchState
  import { createBoardState, Dimensions } from 'components/board';

  const DEFAULT_SCALE = 1.0;
  const dimensions = new Dimensions(DEFAULT_SCALE);
  const boardState = createBoardState(dimensions);

  const { store } = boardState;
</script>

<div class="app">
  <Navbar />
  <div class="content-container">
    <div class="col-1" />
    <div class="col-2">
      <Board {dimensions} {boardState} />
    </div>
    <div class="col-3">
      <AnalysisPanel {dimensions} moves={$store.moves} />
    </div>
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
    .content-container {
      display: grid;
      grid-template-columns: 1fr 1.5fr 1fr;
    }
  }
</style>
