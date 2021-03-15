<script lang="ts">
  import {
    Loading,
    StructuredList,
    StructuredListCell,
    StructuredListBody,
    StructuredListRow,
  } from 'carbon-components-svelte';
  import Enum from '@xq/utils/enum';
  import MoveCell from './MoveCell.svelte';
  import type { Move } from './MoveCell.svelte';

  // Props
  export let currentTurnIndex: number;
  export let maxTurnIndex: number;
  export let moves: string[];
  export let gotoTurn: (turnIndex: number) => () => void;

  // Initialization
  const preparedMoves = prepareMoves(moves);
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
  function prepareMoves(moves: string[]): Move[] {
    return Enum.range(0, moves.length, 2).map((i) => ({
      num: i / 2 + 1,
      red: moves[i],
      black: moves[i + 1] ?? '',
    }));
  }
</script>

<div class="move-list" bind:this={movesList}>
  {#if moves}
    <StructuredList>
      <StructuredListBody>
        {#each preparedMoves as move, i}
          <StructuredListRow>
            <StructuredListCell class="move-list-cell">
              <MoveCell
                bind:moveRef={moveRefs[i]}
                {move}
                isRedCurrent={currentTurnIndex - 1 === i * 2}
                isBlackCurrent={currentTurnIndex - 1 === i * 2 + 1}
                onRedClick={gotoTurn(i * 2 + 1)}
                onBlackClick={gotoTurn((i + 1) * 2)}
              />
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
    min-height: 560px;
    height: 560px;

    overflow-y: scroll;

    :global(div.move-list-cell) {
      padding: 0.5rem;
    }
  }
</style>
