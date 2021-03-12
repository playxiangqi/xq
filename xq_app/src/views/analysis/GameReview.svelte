<script lang="ts">
  import { writable } from 'svelte/store';

  // Components
  import Board from '../../components/board/Board.svelte';
  import EngineAnalysisPanel from './EngineAnalysisPanel.svelte';
  import GameInfoPanel from './GameInfoPanel.svelte';

  // Modules
  import { createBoardState, Dimensions } from 'components/board';
  import { createAuthStore } from 'services/auth/store';
  import type { PhoenixPayload } from 'utils/channels';
  import { createAnalysisStore } from './store';
  import type { EngineResults } from './types';

  export let params: { id: number | string };

  // TODO: Derive dimensions and scale from viewport and set globally
  const DEFAULT_SCALE = 1.0;
  const dimensions = new Dimensions(DEFAULT_SCALE);
  const boardState = createBoardState(dimensions);

  let analysisStore = writable<EngineResults>({
    best_move: [],
    results: [],
  });
  let pushAnalysis: (payload: PhoenixPayload) => {};

  const { store: authStore } = createAuthStore();
  $: if ($authStore.username !== '') {
    ({ store: analysisStore, pushAnalysis } = createAnalysisStore(
      $authStore.username,
    ));
  }

  let currentTurnIndex = 0;
</script>

<div class="game-review">
  <div class="col-1">
    <EngineAnalysisPanel {analysisStore} {currentTurnIndex} />
  </div>
  <div class="col-2">
    <Board {dimensions} {boardState} />
  </div>
  <div class="col-3">
    <GameInfoPanel
      bind:currentTurnIndex
      gameID={params.id}
      {dimensions}
      {boardState}
      {pushAnalysis}
    />
  </div>
</div>

<style lang="scss">
  .game-review {
    height: 100%;
    width: 100%;

    margin-top: 10px;

    display: grid;
    grid-template-columns: 1fr 1.4fr 1fr;

    .col-2 {
      display: flex;

      padding-left: 3.75%;
    }
  }
</style>
