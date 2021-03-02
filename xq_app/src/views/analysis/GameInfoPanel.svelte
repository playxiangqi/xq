<script lang="ts">
  import { operationStore, query } from '@urql/svelte';
  import { createBoardState } from 'components/board';
  import { GET_GAME_BOARD_STATES_QUERY } from './queries';

  export let gameID: number | string;
  export let boardState: ReturnType<typeof createBoardState>;

  const {
    store,
    updateBoardState,
    transitionBoardState,
    flipBoard,
  } = boardState;

  const opStore = operationStore(GET_GAME_BOARD_STATES_QUERY(gameID));
  const resp = query(opStore);
  opStore.subscribe((store) => {
    if (!store.fetching && !store.stale) {
      updateBoardState(store.data?.game?.boardStates);
    }
  });

  $: maxTurnIndex = $store.layouts.length - 1;
  $: gameInfo = $resp.data?.game?.info;

  let currentTurnIndex = 0;

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

  // Event Handlers
  function skipToBeginning() {
    currentTurnIndex = 0;
    playSound();
    transitionBoardState(0);
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
    transitionBoardState(currentTurnIndex);
  }

  function nextMove() {
    currentTurnIndex = Math.min(maxTurnIndex, currentTurnIndex + 1);
    playSound();
    transitionBoardState(currentTurnIndex);
  }

  function skipToEnd() {
    currentTurnIndex = maxTurnIndex;
    playSound();
    transitionBoardState(currentTurnIndex);
  }

  function gotoMove(turnIndex: number) {
    currentTurnIndex = turnIndex;
    transitionBoardState(currentTurnIndex);
  }

  // Sound Effects
  const audio = new Audio('./sounds/drop-piece.wav');

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
    <div class="moves-container">
      {#each prepareMoveNotation(gameInfo.moves) as { moveNum, moveRed, moveBlack }, i}
        <div class="panel-block move">
          <span class="move-num">{moveNum}.</span>
          <span
            class="move-red"
            class:current={currentTurnIndex - 1 === i * 2}
            on:click={() => gotoMove(i * 2 + 1)}>{moveRed}</span
          >
          <span
            class="move-black"
            class:current={currentTurnIndex - 1 === i * 2 + 1}
            on:click={() => gotoMove((i + 1) * 2)}>{moveBlack}</span
          >
        </div>
      {/each}
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
      on:click={skipToBeginning}
      disabled={currentTurnIndex <= 0}>{'⏮'}</button
    >
    <button
      class="button"
      on:click={previousMove}
      disabled={currentTurnIndex <= 0}>{'◀️'}</button
    >
    <button
      class="button"
      on:click={nextMove}
      disabled={currentTurnIndex >= maxTurnIndex}>{'▶️'}</button
    >
    <button
      class="button"
      on:click={skipToEnd}
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
        padding-right: 10px;
        text-align: right;

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
