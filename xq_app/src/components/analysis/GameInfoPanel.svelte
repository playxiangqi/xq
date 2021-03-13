<script lang="ts">
  import { operationStore, query } from '@urql/svelte';
  import {
    BLACK,
    createBoardState,
    Dimensions,
    newPoint,
  } from '@xq/core/board';
  import type { PhoenixPayload } from '@xq/utils/channel';
  import { GET_GAME_BOARD_STATES_QUERY } from './queries';

  export let currentTurnIndex = 0;
  export let gameID: number | string;
  export let dimensions: Dimensions;
  export let boardState: ReturnType<typeof createBoardState>;
  export let pushAnalysis = (payload: PhoenixPayload) => {};

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

  let movesContainer: HTMLDivElement;

  // Utils
  function prepareMoveNotation(moves: string[]) {
    let turnNum = 0;
    let moveStrs = [];
    for (let i = 0; i < moves.length; i += 2) {
      moveStrs.push({
        moveNum: ++turnNum,
        moveRed: moves[i],
        moveBlack: moves[i + 1] ?? '',
      });
    }
    return moveStrs;
  }

  function scrollIntoView(turnIndex: number) {
    const clampedIndex = Math.max(0, Math.min(turnIndex, maxTurnIndex - 1));
    const moveIndex = Math.floor((clampedIndex + 1) / 2);
    movesContainer.children?.[moveIndex].scrollIntoView({ block: 'center' });
  }

  function prepareBoardState() {
    const { facing, activeLayout: al, activeTransition: at } = $store;
    const invertPoint = newPoint(dimensions, facing === BLACK);
    const state = al.map((l) => invertPoint(l));
    const prev_point = at.prevPoint ? invertPoint(at.prevPoint) : null;
    return { state, prev_point };
  }

  function updateTurn(eventHandler: () => void) {
    let timer: number;

    return () => {
      eventHandler();
      transitionBoardState(currentTurnIndex);
      scrollIntoView(currentTurnIndex);

      // Debounce engine analysis
      clearTimeout(timer);
      timer = setTimeout(() => pushAnalysis(prepareBoardState()), 500);
    };
  }

  // Event Handlers
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

  function gotoMove(turnIndex: number) {
    currentTurnIndex = turnIndex;
  }

  // Sound Effects
  const audio = new Audio('/sounds/drop-piece.wav');

  function playSound() {
    audio.currentTime = 0;
    audio.loop = false;
    audio.play();
  }
</script>

<div class="panel game-info-panel">
  <p class="panel-heading">Details</p>
  {#if $resp.fetching}
    <div class="game-info-section loading p-5">Loading Game...</div>
    <div class="moves-container loading" />
  {:else}
    <div class="game-info-section px-4 py-3">
      <div class="players">
        {gameInfo.redPlayer} vs. {gameInfo.blackPlayer} — {gameInfo.result}
      </div>
      <div class="venue">
        {gameInfo.event}
      </div>
      <div class="date">
        {new Date(gameInfo.date).toDateString()}
      </div>
      <div class="opening-name">
        {gameInfo.openingCode}: {gameInfo.openingName}
      </div>
    </div>
    <div class="moves-container" bind:this={movesContainer}>
      {#each prepareMoveNotation(gameInfo.moves) as { moveNum, moveRed, moveBlack }, i}
        <div class="panel-block move">
          <span class="move-num">{moveNum}.</span>
          <span
            class="move-red"
            class:current={currentTurnIndex - 1 === i * 2}
            on:click={updateTurn(() => gotoMove(i * 2 + 1))}>{moveRed}</span
          >
          <span
            class="move-black"
            class:current={currentTurnIndex - 1 === i * 2 + 1}
            on:click={updateTurn(() => gotoMove((i + 1) * 2))}>{moveBlack}</span
          >
        </div>
      {/each}
      <div class="panel-block move-end-padding" />
    </div>
  {/if}
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
    margin-right: 50px;

    .game-info-section {
      min-height: 120px;
    }

    .moves-container {
      min-height: 560px;
      height: 560px;
      overflow-y: scroll;

      span.move-num {
        width: 40px;

        margin-right: 10px;
        text-align: right;
      }

      span.move-red,
      span.move-black {
        width: 60px;

        font-family: 'Courier Prime', monospace;
        text-align: center;

        &:hover {
          cursor: pointer;
        }
      }

      span.current {
        background-color: #ededed;
      }
    }

    .move-buttons {
      .button:disabled {
        cursor: default;
      }
    }
  }
</style>
