<script lang="ts">
  import { operationStore, query } from '@urql/svelte';
  import { createBoardState } from 'components/board';

  export let gameID: number | string;
  export let boardState: ReturnType<typeof createBoardState>;

  const { store, updateBoardState, transitionBoardState } = boardState;

  const opStore = operationStore(`
    query getGameBoardStates {
      game(id: "${gameID}") {
        info {
          redPlayer
          blackPlayer
          result
          event
          date
          openingCode
          openingName
          moves
        }
        boardStates {
          ch
          side
          rank
          file
        }
      }
    }
  `);
  const resp = query(opStore);
  opStore.subscribe((store) => {
    if (!store.fetching && !store.stale) {
      updateBoardState(store.data?.game?.boardStates);
    }
  });

  $: maxTurnIndex = $store.layouts.length - 1;

  let currentTurnIndex = 0;

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

  // Sound Effects
  const audio = new Audio('./sounds/drop-piece.wav');

  function playSound() {
    audio.currentTime = 0;
    audio.loop = false;
    audio.play();
  }
</script>

<div class="panel game-info-panel">
  <p class="panel-heading">Game Details</p>
  {#if $resp.fetching}
    <div class="game-info-section loading p-5">Loading Game...</div>
    <div class="moves-container loading" />
  {:else}
    <div class="game-info-section px-4 py-3">
      <div class="players">
        {resp.data.game.info.redPlayer} vs. {resp.data.game.info.blackPlayer} — {resp
          .data.game.info.result}
      </div>
      <div class="venue">
        {resp.data.game.info.event}
      </div>
      <div class="date">
        {new Date(resp.data.game.info.date).toDateString()}
      </div>
      <div class="opening-name">
        {resp.data.game.info.openingCode}: {resp.data.game.info.openingName}
      </div>
    </div>
    <div class="moves-container">
      {#each prepareMoveNotation(resp.data.game.info.moves) as { moveNum, moveRed, moveBlack }, i}
        <div class="panel-block move">
          <span class="move-num">{moveNum}.</span>
          <span class="move-red" class:current={currentTurnIndex - 1 === i * 2}
            >{moveRed}</span
          >
          <span
            class="move-black"
            class:current={currentTurnIndex - 1 === i * 2 + 1}>{moveBlack}</span
          >
        </div>
      {/each}
    </div>
  {/if}
  <div class="panel-block move-buttons">
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
      min-height: 550px;
      height: 550px;
      overflow-y: scroll;

      span.move-num {
        width: 30px;
        text-align: right;
      }

      span.move-red,
      span.move-black {
        width: 60px;
        text-align: right;
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
