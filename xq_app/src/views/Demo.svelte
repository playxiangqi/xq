<script lang="ts">
  // Components
  import AnalysisPanel from '../components/analysis/AnalysisPanel.svelte';
  import SearchPanel from '../components/analysis/SearchPanel.svelte';
  import Board from '../components/board/Board.svelte';

  // Modules
  // TODO: Move dimensions to utilities
  // TODO: Turn boardState into matchState
  import { createBoardState, Dimensions } from 'components/board';

  const DEFAULT_SCALE = 1.0;
  const dimensions = new Dimensions(DEFAULT_SCALE);
  const boardState = createBoardState(dimensions);
</script>

<div class="demo">
  <div class="col-1">
    <SearchPanel />
  </div>
  <div class="col-2">
    <Board {dimensions} {boardState} />
  </div>
  <div class="col-3">
    <AnalysisPanel {boardState} />
  </div>
</div>

<style lang="scss">
  .demo {
    height: 100%;
    width: 100%;

    display: grid;
    grid-template-columns: 1fr 1.5fr 1fr;
  }
</style>
