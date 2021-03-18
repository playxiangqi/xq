<script context="module" lang="ts">
  import { createAuthStore } from '@xq/services/auth/store';
  import {
    createBoardState,
    createBoardStore,
    Dimensions,
    Board,
  } from '@xq/core/board';
  import { createGameStore } from '@xq/core/game';
  import { userSettingsStore, updateGameSettings } from '@xq/services/user';

  // TODO: Derive dimensions and scale from viewport and set globally
  const DEFAULT_SCALE = 1.0;
  const dimensions = new Dimensions(DEFAULT_SCALE);
  const boardState = createBoardState(dimensions);
  const { store: authStore } = createAuthStore();

  const { gameStore, loadGameLayouts } = createGameStore();
</script>

<script lang="ts">
  import { setContext } from 'svelte';
  import type { LayoutWithTransitions } from '@xq/core/board';
  import EngineAnalysisPanel from './EngineAnalysisPanel.svelte';
  import GameInfoPanel from './GameInfoPanel.svelte';
  import type { GameSettings } from './GameInfoPanel.svelte';
  import type { PhoenixPayload } from '@xq/utils/channel';

  export let gameID: number | string;

  let currentTurnIndex = 0;
  let pushAnalysis = (_: PhoenixPayload) => {};

  let audio: HTMLAudioElement;
  function playSound() {
    audio.currentTime = 0;
    audio.play();
  }
  setContext('audio', { playSound });
  setContext('dimensions', dimensions);

  $: ({ gameSettings } = $userSettingsStore);
  // $: ({ currentTurnIndex } = $gameStore);

  function handleReceiptBoardStates(event: CustomEvent<LayoutWithTransitions>) {
    console.log('data: ', event.detail);
  }

  function handleSaveGameSettings(event: CustomEvent<GameSettings>) {
    updateGameSettings(event.detail);
  }

  function handleUpdateTurn(event: CustomEvent<any>) {
    pushAnalysis(event.detail);
  }
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
    <Board {boardState} />
  </div>
  <div class="col-3">
    <GameInfoPanel
      bind:currentTurnIndex
      on:receipt:board-states={handleReceiptBoardStates}
      on:save:game-settings={handleSaveGameSettings}
      on:update:turn={handleUpdateTurn}
      {gameSettings}
      {gameID}
      {boardState}
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
