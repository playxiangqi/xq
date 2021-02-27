<script lang="ts">
  // Components
  import AnalysisPanel from '../../components/analysis/AnalysisPanel.svelte';
  import Board from '../../components/board/Board.svelte';

  // Modules
  // TODO: Move dimensions to utilities
  // TODO: Turn boardState into matchState
  import { createBoardState, Dimensions } from 'components/board';

  export let params: { id: number | string };

  const DEFAULT_SCALE = 1.0;
  const dimensions = new Dimensions(DEFAULT_SCALE);
  const boardState = createBoardState(dimensions);
</script>

<div class="game-analysis">
  <div class="col-1" />
  <div class="col-2">
    <Board {dimensions} {boardState} />
  </div>
  <div class="col-3">
    <AnalysisPanel gameID={params.id} {boardState} />
  </div>
</div>

<style lang="scss">
  .game-analysis {
    height: 100%;
    width: 100%;

    display: grid;
    grid-template-columns: 1fr 2fr 2fr;

    .col-2 {
      display: flex;
      align-items: center;
    }
  }
</style>
