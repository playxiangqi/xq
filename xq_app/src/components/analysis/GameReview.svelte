<script context="module" lang="ts">
  import { createAuthStore } from '@xq/services/auth/store';
  import { createBoardState, Dimensions, Board } from '@xq/core/board';
  import { createGameStore } from '@xq/core/game';
  import { userSettingsStore, updateGameSettings } from '@xq/services/user';

  // TODO: Derive dimensions and scale from viewport and set globally
  const DEFAULT_SCALE = 1.0;
  const dimensions = new Dimensions(DEFAULT_SCALE);
  const boardState = createBoardState(dimensions);
  const { store: authStore } = createAuthStore();

  const { gameStore, loadGameLayouts } = createGameStore();
  const { boardStore } = createBoardStore(gameStore, dimensions);
</script>

<script lang="ts">
  import { setContext } from 'svelte';
  import { createBoardStore } from '../board/store.svelte';
  import EngineAnalysisPanel from './EngineAnalysisPanel.svelte';
  import GameInfoPanel from './GameInfoPanel.svelte';

  export let gameID: number | string;

  let pushAnalysis = () => {};

  let audio: HTMLAudioElement;
  function playSound() {
    audio.currentTime = 0;
    audio.play();
  }
  setContext('audio', { playSound });

  $: ({ gameSettings } = $userSettingsStore);
  $: ({ currentTurnIndex } = $gameStore);
</script>

<div class="game-review">
  <div class="col-1">
    <EngineAnalysisPanel
      bind:pushAnalysis
      {currentTurnIndex}
      username={$authStore.username}
    />
  </div>
  <div class="col-2">
    <!-- svelte-ignore a11y-media-has-caption -->
    <!-- TODO: Create a SoundEffect component that exports playSound -->
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
      on:data={(e) => {
        console.log(e);
      }}
      {gameSettings}
      {gameID}
      {dimensions}
      {boardState}
      {pushAnalysis}
      {updateGameSettings}
    />
  </div>
</div>

<style lang="scss">
  .game-review {
    height: 100%;
    width: 100%;

    margin-top: 10px;

    display: grid;
    grid-template-columns: 1fr 1.5fr 1fr;

    .col-2 {
      display: flex;

      padding-left: 2%;
    }
  }
</style>
