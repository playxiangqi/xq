<script lang="ts">
  import {
    Loading,
    StructuredList,
    StructuredListCell,
    StructuredListBody,
    StructuredListRow,
  } from 'carbon-components-svelte';

  // Props
  export let currentTurnIndex: number;
  export let maxTurnIndex: number;
  export let moves: string[];
  export let gotoTurn: (turnIndex: number) => () => void;

  // Initialization
  const preparedMoves = prepareMoveNotation(moves);
  const moveRefs = [] as HTMLSpanElement[];

  // API
  export function scrollIntoView(turnIndex: number) {
    const clampedTurnIndex = Math.max(0, Math.min(turnIndex, maxTurnIndex - 1));
    const moveIndex = Math.floor((clampedTurnIndex + 1) / 2);
    const clampedMoveIndex = Math.min(moveIndex, moveRefs.length - 1);
    moveRefs[clampedMoveIndex].scrollIntoView({ block: 'center' });
  }

  // Locals
  let movesList: HTMLDivElement;

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

<div class="move-list" bind:this={movesList}>
  {#if moves}
    <StructuredList>
      <StructuredListBody>
        {#each preparedMoves as { moveNum, moveRed, moveBlack }, i}
          <StructuredListRow>
            <StructuredListCell>
              <span class="move-num">{moveNum}.</span>
              <span
                bind:this={moveRefs[i]}
                class="move-red"
                class:current={currentTurnIndex - 1 === i * 2}
                on:click={gotoTurn(i * 2 + 1)}>{moveRed}</span
              >
              <span
                class="move-black"
                class:current={currentTurnIndex - 1 === i * 2 + 1}
                on:click={gotoTurn((i + 1) * 2)}>{moveBlack}</span
              >
            </StructuredListCell>
          </StructuredListRow>
        {/each}
      </StructuredListBody>
    </StructuredList>
  {:else}
    <Loading />
  {/if}
</div>

<style lang="scss">
  .move-list {
    min-height: 620px;
    height: 620px;

    overflow-y: scroll;

    span.move-num {
      width: 40px;

      margin-right: 10px;
      text-align: right;
    }

    span.move-red,
    span.move-black {
      padding-right: 8px;
      width: 60px;

      font-family: 'IBM Plex Mono', monospace;
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
