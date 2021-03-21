<script context="module" lang="ts">
  import { createAuthStore } from '@xq/services/auth/store';
  import { Board } from '@xq/core/board';
  import type { EnrichedCartesianPoint } from '@xq/core/board';
  import { userSettingsStore, updateGameSettings } from '@xq/services/user';
  import { enrichPoint } from '@xq/utils/xq';
  import { createAnalysisStore } from './store.svelte';
  import type { Line } from './store.svelte';

  const { store: authStore } = createAuthStore();
  const analysisStore = createAnalysisStore();
</script>

<script lang="ts">
  import { setContext, onDestroy } from 'svelte';
  import { createBoardStore, createDimensionStore } from '@xq/core/board';
  import type { PhoenixPayload } from '@xq/utils/channel';
  import type { Layout } from '@xq/utils/xq';
  import EngineAnalysisPanel from './EngineAnalysisPanel.svelte';
  import GameInfoPanel from './GameInfoPanel.svelte';
  import type { GameSettings } from './GameInfoPanel.svelte';
  import { AspectRatio } from 'carbon-components-svelte';

  export let gameID: number | string;

  // Initialization
  const { loadLine } = analysisStore;
  let boardHeight = 800;
  const dimensions = createDimensionStore();
  const { pointToCoords } = dimensions;
  $: {
    dimensions.set(boardHeight);
  }
  let boardStore = createBoardStore(dimensions);

  // Lifecycle
  const unsubscribeAnalysis = analysisStore.subscribe((state) => {
    const { points, prevPoint, nextPoint } = state.primaryLine[
      state.currentTurnIndex
    ];
    const { flipped } = $boardStore;

    $boardStore.workingLayout = {
      points: points.map((p) => ({
        ...enrichPoint(p, pointToCoords, flipped),
        grabbing: false,
      })),
      prevPoint: prevPoint
        ? enrichPoint(prevPoint, pointToCoords, flipped)
        : prevPoint,
      nextPoint: nextPoint
        ? enrichPoint(nextPoint, pointToCoords, flipped)
        : nextPoint,
    } as Layout<EnrichedCartesianPoint>;
  });

  onDestroy(unsubscribeAnalysis);

  // Locals
  let currentTurnIndex = 0;
  let pushAnalysis = (_: PhoenixPayload) => {};

  let audio: HTMLAudioElement;
  function playSound() {
    audio.currentTime = 0;
    audio.play();
  }
  setContext('audio', { playSound });

  // Reactive
  $: ({ gameSettings } = $userSettingsStore);
  $: ({ currentTurnIndex } = $analysisStore);

  // Event Handlers
  function handleReceiptBoardStates(event: CustomEvent<Line>) {
    loadLine(event.detail);
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
    <AspectRatio ratio="1x1">
      <div class="dimension-container" bind:clientHeight={boardHeight}>
        <Board {boardStore} {dimensions} />
      </div>
    </AspectRatio>
  </div>
  <div class="col-3">
    <GameInfoPanel
      bind:currentTurnIndex
      on:receipt:board-states={handleReceiptBoardStates}
      on:save:game-settings={handleSaveGameSettings}
      on:update:turn={handleUpdateTurn}
      {gameSettings}
      {gameID}
      {analysisStore}
      {boardStore}
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
      display: block;

      .dimension-container {
        height: 100%;
        width: 100%;
      }
    }
  }
</style>
