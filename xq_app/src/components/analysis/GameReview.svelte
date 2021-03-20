<script context="module" lang="ts">
  import { createAuthStore } from '@xq/services/auth/store';
  import { createBoardStore, Board } from '@xq/core/board';
  import type { EnrichedCartesianPoint } from '@xq/core/board';
  import { userSettingsStore, updateGameSettings } from '@xq/services/user';
  import { Dimensions } from '@xq/utils/dimensions';
  import { enrichPoint } from '@xq/utils/xq';
  import { createAnalysisStore } from './store.svelte';
  import type { Line } from './store.svelte';

  // TODO: Derive dimensions and scale from viewport and set globally
  const DEFAULT_SCALE = 1.0;
  const dimensions = new Dimensions(DEFAULT_SCALE);
  const { store: authStore } = createAuthStore();
  const analysisStore = createAnalysisStore();
  const boardStore = createBoardStore(dimensions);
</script>

<script lang="ts">
  import { setContext, onDestroy } from 'svelte';
  import type { PhoenixPayload } from '@xq/utils/channel';
  import type { Layout } from '@xq/utils/xq';
  import EngineAnalysisPanel from './EngineAnalysisPanel.svelte';
  import GameInfoPanel from './GameInfoPanel.svelte';
  import type { GameSettings } from './GameInfoPanel.svelte';

  export let gameID: number | string;

  // Lifecycle
  const unsubscribeAnalysis = analysisStore.subscribe((state) => {
    const { points, prevPoint, nextPoint } = state.primaryLine[
      state.currentTurnIndex
    ];
    const { flipped } = $boardStore;
    const activeLayout = {
      points: points.map((p) => ({
        ...enrichPoint(p, dimensions, flipped),
        grabbing: false,
      })),
      prevPoint: prevPoint
        ? enrichPoint(prevPoint, dimensions, flipped)
        : prevPoint,
      nextPoint: nextPoint
        ? enrichPoint(nextPoint, dimensions, flipped)
        : nextPoint,
    } as Layout<EnrichedCartesianPoint>;

    $boardStore.workingLayout = activeLayout;
  });

  onDestroy(unsubscribeAnalysis);

  // Initialization
  const { loadLine } = analysisStore;
  const { dropPiece, focusPiece, grabPiece, movePiece } = boardStore;

  // Locals
  let currentTurnIndex = 0;
  let pushAnalysis = (_: PhoenixPayload) => {};

  let audio: HTMLAudioElement;
  function playSound() {
    audio.currentTime = 0;
    audio.play();
  }
  setContext('audio', { playSound });
  setContext('dimensions', dimensions);

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
    <Board
      {boardStore}
      on:piecedrop={(e) => {
        if (dropPiece(e.detail.index, e.detail.side)) {
          playSound();
        }
      }}
      on:piecefocus={(e) => focusPiece(e.detail)}
      on:piecegrab={(e) => grabPiece(e.detail)}
      on:piecemove={(e) => movePiece(e.detail.index, e.detail.point)}
    />
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
      display: flex;

      padding-left: 2%;
    }
  }
</style>
