<script lang="ts">
  import { createBoardState } from 'components/board';

  export let boardState: ReturnType<typeof createBoardState>;

  const { store, loadGameAnalysis, transitionBoardState } = boardState;

  $: maxTurnIndex = $store.layouts.length - 1;

  let promisedGameAnalysis = loadGameAnalysis();
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
    transitionBoardState(currentTurnIndex);
    playSound();
  }

  async function nextMove() {
    currentTurnIndex = Math.min(maxTurnIndex, currentTurnIndex + 1);
    console.log(currentTurnIndex);

    transitionBoardState(currentTurnIndex);
    playSound();
  }

  function skipToEnd() {
    currentTurnIndex = maxTurnIndex;
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

<div class="panel analysis-panel">
  <!-- <p>Joined lobby as: {$authStore.username}</p> -->
  <p class="panel-heading">Database Explorer</p>
  {#await promisedGameAnalysis}
    <div class="game-info loading">Loading Game...</div>
    <div class="moves-container loading" />
  {:then game}
    <div class="game-info">
      <div class="players">
        {game.redPlayer} vs. {game.blackPlayer} — {game.result}
      </div>
      <div class="venue">
        {game.event}
      </div>
      <div class="date">
        {new Date(game.date).toDateString()}
      </div>
      <div class="opening-name">{game.openingCode}: {game.openingName}</div>
    </div>
    <div class="moves-container">
      {#each prepareMoveNotation(game.moves) as { moveNum, moveRed, moveBlack }, i}
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
  {/await}
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
  .analysis-panel {
    margin-top: 10px;
    margin-right: 50px;

    .game-info {
      padding: 15px 0px 15px 20px;
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
