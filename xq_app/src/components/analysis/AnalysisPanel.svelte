<script lang="ts">
  import { toHanzi } from 'components/board';
  import type { Dimensions, Move } from 'components/board';
  import { createAuthStore } from 'services/auth/store';

  const { store: authStore, broadcast: sendAuthRequest } = createAuthStore();
  // TODO: moves history in boardstate

  export let dimensions: Dimensions;
  export let moves: Move[];

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
</script>

<div class="panel analysis-panel">
  <!-- <p>Joined lobby as: {$authStore.username}</p> -->
  <p class="panel-heading">Openings Database</p>
  <div class="panel-block opening-name">Elephant Opening</div>
  {#each moves as move, i}
    <div class="panel-block">
      <div>
        {generateMoveNotation(move, i)}
      </div>
    </div>
  {/each}
</div>

<style lang="scss">
  .analysis-panel {
    margin-right: 15px;
  }
</style>
