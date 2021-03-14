<script lang="ts">
  // Props
  export let currentTurnIndex: number;
  export let gotoTurn: (turnIndex: number) => () => void;
  export let maxTurnIndex: number;
  export let moves: string[];

  // Exposed bindings
  export function scrollIntoView(turnIndex: number) {
    const clampedIndex = Math.max(0, Math.min(turnIndex, maxTurnIndex - 1));
    const moveIndex = Math.floor((clampedIndex + 1) / 2);
    movesContainer.children?.[moveIndex].scrollIntoView({ block: 'center' });
  }

  // Locals
  let movesContainer: HTMLDivElement;

  // Utils
  function prepareMoveNotation(moves: string[]) {
    let moveStrs = [];
    for (let i = 0; i < moves.length; i += 2) {
      moveStrs.push({
        moveNum: i / 2 + 1,
        moveRed: moves[i],
        moveBlack: moves[i + 1] ?? '',
      });
    }
    return moveStrs;
  }
</script>

<div class="moves" bind:this={movesContainer}>
  {#each prepareMoveNotation(moves) as { moveNum, moveRed, moveBlack }, i}
    <div class="panel-block move">
      <span class="move-num">{moveNum}.</span>
      <span
        class="move-red"
        class:current={currentTurnIndex - 1 === i * 2}
        on:click={gotoTurn(i * 2 + 1)}>{moveRed}</span
      >
      <span
        class="move-black"
        class:current={currentTurnIndex - 1 === i * 2 + 1}
        on:click={gotoTurn((i + 1) * 2)}>{moveBlack}</span
      >
    </div>
  {/each}
  <div class="panel-block move-end-padding" />
</div>

<style lang="scss">
  .moves {
    min-height: 525px;
    height: 525px;
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
</style>
