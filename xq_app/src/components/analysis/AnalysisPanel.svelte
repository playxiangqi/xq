<script lang="ts">
  import { createBoardState, notationToMove, toHanzi } from 'components/board';
  import type { Dimensions, Move } from 'components/board';
  import { createAuthStore } from 'services/auth/store';

  const { store: authStore, broadcast: sendAuthRequest } = createAuthStore();
  // TODO: moves history in boardstate

  export let dimensions: Dimensions;
  export let boardState: ReturnType<typeof createBoardState>;

  const { store, slidePiece } = boardState;

  $: moveEndIndex = $store.moves.length;

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

  function nextMove() {
    currentTurnIndex = Math.min(58, currentTurnIndex + 1);
    const move = notationToMove(historicalGame.moves[currentTurnIndex]);
    slidePiece(move);
    playSound();
  }

  function skipToEnd() {
    currentTurnIndex = 58;
  }

  // Hard-coded snippet, to be pulled from database with normalized key-values
  const historicalGame = {
    'Play Count': '59',
    Result: 'Red DRAW',
    Opening: 'Adviser opening',
    'Last Modify': '2011/10/30 12:52:26',
    'game index': '34561',
    Hits: '5385',
    Event: '2011 China Individual Xiangqi Championship Men',
    Date: '2011-10-25',
    Round: 'Round 11',
    'Red Club': 'HuBei',
    'Red player': 'Li XueSong',
    'Black Club': 'BeiJing',
    'Black player': 'Sun Bo',
    moves: [
      'A4+5',
      'p7+1',
      'C2=3',
      'b7+5',
      'N2+1',
      'n8+7',
      'R1=2',
      'r9=8',
      'C8=4',
      'n2+1',
      'N8+7',
      'r1=2',
      'R9=8',
      'c8+4',
      'R8+4',
      'c2=3',
      'R8=4',
      'r2+1',
      'B7+5',
      'r2=8',
      'P7+1',
      'c8+1',
      'P1+1',
      'p1+1',
      'P3+1',
      'c8=6',
      'R2+8',
      'r8+1',
      'A5+4',
      'r8+3',
      'N7+6',
      'c3=2',
      'A6+5',
      'c2+3',
      'P3+1',
      'r8=7',
      'B5+3',
      'r7=4',
      'C3+5',
      'r4+1',
      'R4=6',
      'c2=4',
      '+B-5',
      'n1+2',
      'C3-4',
      'p1+1',
      'C3=1',
      'n2+1',
      'C1=9',
      'p1+1',
      'N1+2',
      'c4=9',
      'N2+1',
      'p1=2',
      'P5+1',
      'p2=3',
      'N1+3',
      '+p=4',
      'N3-5',
    ],
  };

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
  <div class="game-info">
    <div class="players">
      {historicalGame['Red player']} vs. {historicalGame['Black player']}
    </div>
    <div class="venue">
      {historicalGame.Event}, {historicalGame.Date}
    </div>
    <div class="opening-name">{historicalGame.Opening}</div>
  </div>
  <div class="moves-container">
    <!-- {#each moves.slice(0, moveEndIndex) as move, i} -->
    {#each generateMoveNotationClassical(historicalGame.moves) as { moveNum, moveRed, moveBlack }, i}
      <div class="panel-block move">
        <!-- {generateMoveNotation(move, i)} -->
        <span class="move-num">{moveNum}.</span>
        <span class="move-red" class:current={currentTurnIndex === i * 2}
          >{moveRed}</span
        >
        <span class="move-black" class:current={currentTurnIndex === i * 2 + 1}
          >{moveBlack}</span
        >
      </div>
    {/each}
  </div>
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
