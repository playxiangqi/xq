<script lang="ts">
  // Components
  import Board from '../../components/board/Board.svelte';
  import EngineAnalysisPanel from './EngineAnalysisPanel.svelte';
  import GameInfoPanel from './GameInfoPanel.svelte';

  // Modules
  // TODO: Move dimensions to utilities and rebrand boardState into matchState
  import { createBoardState, Dimensions } from 'components/board';
  import { createChannel } from 'utils/channels';

  export let params: { id: number | string };

  // TODO: Derive dimensions and scale from viewport and set globally
  const DEFAULT_SCALE = 1.0;
  const dimensions = new Dimensions(DEFAULT_SCALE);
  const boardState = createBoardState(dimensions);

  const analysisChannel = createChannel('analysis:*', analysisChannelHandler);

  let moves: string;
  function analysisChannelHandler(event: string, payload: Record<string, any>) {
    switch (event) {
      case 'analysis:moves': {
        moves = payload.moves;
      }
    }
  }
</script>

<div class="game-review">
  <div class="col-1">
    <EngineAnalysisPanel {moves} />
  </div>
  <div class="col-2">
    <Board {dimensions} {boardState} />
  </div>
  <div class="col-3">
    <GameInfoPanel gameID={params.id} {boardState} />
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
