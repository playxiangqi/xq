<script lang="ts">
  import { getContext } from 'svelte';
  import { Accordion, AccordionItem, Button } from 'carbon-components-svelte';
  import { operationStore, query } from '@urql/svelte';
  import {
    BLACK,
    Dimensions,
    createBoardState,
    newPoint,
  } from '@xq/core/board';
  import { GameDetails, MoveList } from '@xq/core/game';
  import type { PhoenixPayload } from '@xq/utils/channel';
  import { GET_GAME_BOARD_STATES_QUERY } from './queries';
  import { SettingsAdjust16 } from 'carbon-icons-svelte';

  // Props
  export let currentTurnIndex = 0;
  export let gameID: number | string;
  export let dimensions: Dimensions;
  export let boardState: ReturnType<typeof createBoardState>;
  export let pushAnalysis: (payload: PhoenixPayload) => void;

  // Initialization
  const { playSound } = getContext('audio');
  const { store, loadBoardState, transitionBoardState, flipBoard } = boardState;

  const opStore = operationStore(GET_GAME_BOARD_STATES_QUERY(gameID));
  const resp = query(opStore);

  // Reactive
  $: if (!$opStore.fetching && !$opStore.stale) {
    loadBoardState($opStore.data?.game?.boards);
  }
  $: maxTurnIndex = $store.layouts.length - 1;
  $: gameInfo = $resp.data?.game?.info;
  $: buttons = [
    {
      icon: '🔃',
      iconDescription: 'Flip Board',
      disabled: false,
      onClick: flipBoard,
    },
    {
      icon: '⏮',
      iconDescription: 'Skip to Beginning',
      disabled: currentTurnIndex <= 0,
      onClick: updateTurn(skipToBeginning),
    },
    {
      icon: '◀',
      iconDescription: 'Previous Move',
      disabled: currentTurnIndex <= 0,
      onClick: updateTurn(previousMove),
    },
    {
      icon: '▶️',
      iconDescription: 'Next Move',
      disabled: currentTurnIndex >= maxTurnIndex,
      onClick: updateTurn(nextMove),
    },
    {
      icon: '⏭️',
      iconDescription: 'Skip to End',
      disabled: currentTurnIndex >= maxTurnIndex,
      onClick: updateTurn(skipToEnd),
    },
  ];

  // Locals
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
  <div class="move-buttons">
    {#each buttons as { icon, iconDescription, onClick, disabled }}
      <Button
        class="move-button"
        kind="tertiary"
        {iconDescription}
        tooltipPosition="top"
        {disabled}
        on:click={onClick}>{icon}</Button
      >
    {/each}
    <Button
      class="move-button"
      kind="tertiary"
      hasIconOnly
      icon={SettingsAdjust16}
      iconDescription="Settings"
      tooltipPosition="top"
    />
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
      /* max-width: 100%; */

      position: absolute;
      bottom: 0px;

      :global(.move-button.bx--btn.bx--btn--tertiary) {
        padding-left: 20px;
        padding-right: 20px;
      }
    }
  }
</style>
