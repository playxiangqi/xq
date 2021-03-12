<script lang="ts">
  // Components
  import Board from '../../components/board/Board.svelte';
  import EngineAnalysisPanel from './EngineAnalysisPanel.svelte';
  import GameInfoPanel from './GameInfoPanel.svelte';

  // Modules
  // TODO: Move dimensions to utilities and rebrand boardState into matchState
  import { createBoardState, Dimensions } from 'components/board';
  import { createAuthStore } from 'services/auth/store';
  import { createChannel } from 'utils/channels';
  import type { PhoenixPayload } from 'utils/channels';
  import type { EngineMove, EngineMetadata, EngineResults } from './types';

  export let params: { id: number | string };

  // TODO: Derive dimensions and scale from viewport and set globally
  const DEFAULT_SCALE = 1.0;
  const dimensions = new Dimensions(DEFAULT_SCALE);
  const boardState = createBoardState(dimensions);

  const { store: authStore } = createAuthStore();
  let pushAnalysis: (payload: PhoenixPayload) => void;

  $: if ($authStore.username !== '') {
    function dispatcher(event: string, payload: PhoenixPayload) {
      const dispatch: {
        [event: string]: (payload: PhoenixPayload) => void;
      } = {
        [`analysis:${$authStore.username}`]: handleEngineResults,
      };

      return dispatch[event]?.(payload);
    }

    const { broadcast } = createChannel(
      `analysis:${$authStore.username}`,
      dispatcher,
    );
    pushAnalysis = (payload: PhoenixPayload) =>
      broadcast('analysis:board_state', payload);
  }

  let currentTurnIndex = 0;
  let metadata: EngineMetadata[];
  let lines: EngineMove[][];

  function handleEngineResults(payload: PhoenixPayload) {
    const { results } = payload as EngineResults;
    lines = results.map((v) => v.lines);
    metadata = results.map((v) => v.metadata);
  }
</script>

<div class="game-review">
  <div class="col-1">
    <EngineAnalysisPanel {lines} {metadata} {currentTurnIndex} />
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
