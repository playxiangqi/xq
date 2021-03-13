<script lang="ts">
  import { setContext } from 'svelte';
  import { createBoardState, Dimensions, Board } from '@xq/core/board';
  import { createAuthStore } from '@xq/services/auth/store';
  import type { PhoenixPayload } from '@xq/utils/channel';
  import EngineAnalysisPanel from './EngineAnalysisPanel.svelte';
  import GameInfoPanel from './GameInfoPanel.svelte';

  export let gameID: number | string;

  // TODO: Derive dimensions and scale from viewport and set globally
  const DEFAULT_SCALE = 1.0;
  const dimensions = new Dimensions(DEFAULT_SCALE);
  const boardState = createBoardState(dimensions);
  const { store: authStore } = createAuthStore();

  let currentTurnIndex = 0;
  let pushAnalysis = (payload: PhoenixPayload) => {};

  let audio: HTMLAudioElement;
  function playSound() {
    audio.currentTime = 0;
    audio.play();
  }
  setContext('audio', { playSound });
</script>

<div class="game-review">
  <div class="col-1">
    <EngineAnalysisPanel
      {currentTurnIndex}
      username={$authStore.username}
      bind:pushAnalysis
    />
  </div>
  <div class="col-2">
    <!-- svelte-ignore a11y-media-has-caption -->
    <audio
      bind:this={audio}
      src="/sounds/drop-piece.wav"
      type="audio/wav"
      hidden
      loop={false}
    />
    <Board {dimensions} {boardState} />
  </div>
  <div class="col-3">
    <GameInfoPanel
      bind:currentTurnIndex
      {gameID}
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

      padding-left: 2%;
    }
  }
</style>
