<script lang="ts">
  import {
    createBoardState,
    fetchBoardState,
    notationToMove,
    toHanzi,
  } from 'components/board';
  import type { Dimensions, Move } from 'components/board';

  export let dimensions: Dimensions;
  export let boardState: ReturnType<typeof createBoardState>;

  const { store, slidePiece } = boardState;

  let promise = fetchBoardState();
  let currentTurnIndex = -1;

  type Notation = 'algebraic';

  function numberToLetter(num: number) {
    let letters = '';
    while (num >= 0) {
      letters = 'abcdefghijklmnopqrstuvwxyz'[num % 26] + letters;
      num = Math.floor(num / 26) - 1;
    }
    return letters;
  }

  // TODO: move to piece utils
  function generateMoveNotation(
    move: Move,
    index: number,
    notation = 'algebraic'
  ) {
    const [prevY, prevX] = move.prevPosition;
    const [y, x] = move.position;
    const [rank, file] = dimensions.coordsToPoint(y, x);
    const abbrev = toHanzi[move.ch][move.side];
    return `${index + 1}. ${abbrev}${numberToLetter(file)}${10 - rank}`;
  }

  function generateMoveNotationClassical(moves: string[]) {
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
    currentTurnIndex = -1;
  }

  function previousMove() {
    currentTurnIndex = Math.max(-1, currentTurnIndex - 1);
  }

  async function nextMove() {
    currentTurnIndex = Math.min(58, currentTurnIndex + 1);
    const {
      game: { moves },
    } = await promise;

    const move = notationToMove(moves[currentTurnIndex]);
    slidePiece(move);
    playSound();
  }

  function skipToEnd() {
    currentTurnIndex = 58;
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
  {#await promise}
    <div class="game-info loading">Loading Game...</div>
    <div class="moves-container loading" />
  {:then { game }}
    <div class="game-info">
      <div class="players">
        {game.redPlayer} vs. {game.blackPlayer}
      </div>
      <div class="venue">
        {game.event}
      </div>
      <div class="date">
        {new Date(game.date).toDateString()}
      </div>
      <div class="opening-name">{game.data.opening}</div>
    </div>
    <div class="moves-container">
      <!-- {#each moves.slice(0, moveEndIndex) as move, i} -->
      {#each generateMoveNotationClassical(game.moves) as { moveNum, moveRed, moveBlack }, i}
        <div class="panel-block move">
          <!-- {generateMoveNotation(move, i)} -->
          <span class="move-num">{moveNum}.</span>
          <span class="move-red" class:current={currentTurnIndex === i * 2}
            >{moveRed}</span
          >
          <span
            class="move-black"
            class:current={currentTurnIndex === i * 2 + 1}>{moveBlack}</span
          >
        </div>
      {/each}
    </div>
  {/await}
  <div class="panel-block move-buttons">
    <button
      class="button"
      on:click={skipToBeginning}
      disabled={currentTurnIndex < 0}>{'⏮'}</button
    >
    <button
      class="button"
      on:click={previousMove}
      disabled={currentTurnIndex < 0}>{'◀️'}</button
    >
    <button class="button" on:click={nextMove} disabled={currentTurnIndex >= 58}
      >{'▶️'}</button
    >
    <button
      class="button"
      on:click={skipToEnd}
      disabled={currentTurnIndex >= 58}>{'⏭️'}</button
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
  }
</style>
