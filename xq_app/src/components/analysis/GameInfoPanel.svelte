<script lang="ts">
  import { getContext } from 'svelte';
  import { Accordion, AccordionItem } from 'carbon-components-svelte';
  import { operationStore, query } from '@urql/svelte';
  import {
    BLACK,
    Dimensions,
    MoveList,
    createBoardState,
    newPoint,
  } from '@xq/core/board';
  import GameDetails from '@xq/core/game/GameDetails.svelte';
  import type { PhoenixPayload } from '@xq/utils/channel';
  import { GET_GAME_BOARD_STATES_QUERY } from './queries';

  // Props
  export let currentTurnIndex = 0;
  export let gameID: number | string;
  export let dimensions: Dimensions;
  export let boardState: ReturnType<typeof createBoardState>;
  export let pushAnalysis: (payload: PhoenixPayload) => void;

  const { playSound } = getContext('audio');
  const { store, loadBoardState, transitionBoardState, flipBoard } = boardState;

  const opStore = operationStore(GET_GAME_BOARD_STATES_QUERY(gameID));
  const resp = query(opStore);
  opStore.subscribe((store) => {
    if (!store.fetching && !store.stale) {
      loadBoardState(store.data?.game?.boards);
    }
  });

  $: maxTurnIndex = $store.layouts.length - 1;
  $: gameInfo = $resp.data?.game?.info;

  let moveList: MoveList;

  // Utils
  function prepareBoardState() {
    const { facing, activeLayout: al, activeTransition: at } = $store;
    const invertPoint = newPoint(dimensions, facing === BLACK);
    const state = al.map((l) => invertPoint(l));
    const prev_point = at.prevPoint ? invertPoint(at.prevPoint) : null;
    return { state, prev_point };
  }

  // Event Handlers
  function updateTurn(eventHandler: () => void) {
    let timer: number;

    return () => {
      // Run turn-based handler
      eventHandler();

      // Update board state
      transitionBoardState(currentTurnIndex);

      // Update UI
      moveList.scrollIntoView(currentTurnIndex);

      // Debounce engine analysis
      clearTimeout(timer);
      timer = setTimeout(() => pushAnalysis(prepareBoardState()), 500);
    };
  }

  function skipToBeginning() {
    currentTurnIndex = 0;
    playSound();
    // TODO: reset turn to red, because grabbing pieces while using the
    //       move replay puts things out of sync
  }

  // TODO: in prevMove and nextMove, need to toggle turns as well
  //       also need to support grab/drop piece actions that generate
  //       separate moves/board state array that branches off from the
  //       prepared game analysis board state
  function previousMove() {
    currentTurnIndex = Math.max(0, currentTurnIndex - 1);
    playSound();
  }

  function nextMove() {
    currentTurnIndex = Math.min(maxTurnIndex, currentTurnIndex + 1);
    playSound();
  }

  function skipToEnd() {
    currentTurnIndex = maxTurnIndex;
    playSound();
  }

  function gotoTurn(turnIndex: number) {
    return updateTurn(() => {
      currentTurnIndex = turnIndex;
    });
  }
</script>

<div class="game-info-panel">
  <div class="game-details-container">
    {#if $resp.fetching}
      <Accordion skeleton count={2} />
    {:else}
      <Accordion>
        <AccordionItem open={true}>
          <h5 slot="title">Game Details</h5>
          <GameDetails {gameInfo} />
        </AccordionItem>
        <AccordionItem open={true}>
          <h5 slot="title">Moves</h5>
          <MoveList
            bind:this={moveList}
            {currentTurnIndex}
            {maxTurnIndex}
            moves={gameInfo.moves}
            {gotoTurn}
          />
        </AccordionItem>
      </Accordion>
    {/if}
  </div>
  <div class="panel-block move-buttons">
    <button class="button" on:click={flipBoard}>
      <span class="icon">
        <i class="fas fa-repeat" />
      </span>
    </button>
    <button
      class="button"
      on:click={updateTurn(skipToBeginning)}
      disabled={currentTurnIndex <= 0}>{'⏮'}</button
    >
    <button
      class="button"
      on:click={updateTurn(previousMove)}
      disabled={currentTurnIndex <= 0}>{'◀️'}</button
    >
    <button
      class="button"
      on:click={updateTurn(nextMove)}
      disabled={currentTurnIndex >= maxTurnIndex}>{'▶️'}</button
    >
    <button
      class="button"
      on:click={updateTurn(skipToEnd)}
      disabled={currentTurnIndex >= maxTurnIndex}>{'⏭️'}</button
    >
  </div>
</div>

<style lang="scss">
  .game-info-panel {
    position: relative;
    height: 100%;

    .game-details-container {
      max-height: 600px;
    }

    .move-buttons {
      position: absolute;
      bottom: 0px;

      .button:disabled {
        cursor: default;
      }
    }
  }
</style>
