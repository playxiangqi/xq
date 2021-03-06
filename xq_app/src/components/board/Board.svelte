<script lang="ts">
  import { getContext } from 'svelte';
  import { Dimensions, FILE_MAX, RANK_MAX } from '@xq/utils/dimensions';
  import Piece from './Piece.svelte';
  import PieceShadow from './PieceShadow.svelte';
  import type { BoardStore } from './store.svelte';

  export let boardStore: BoardStore;

  // Initialization
  const {
    height,
    width,
    frameHeight,
    frameWidth,
    innerFrameHeight,
    innerFrameWidth,
    frameOffsetY,
    frameOffsetX,
    innerFrameOffsetY,
    innerFrameOffsetX,
    rankSpacing,
    fileSpacing,
    pieceSize,
    pieceOuterRadius,
  }: Dimensions = getContext('dimensions');

  $: ({ turn } = $boardStore);
  $: ({ points, prevPoint, nextPoint } = $boardStore.workingLayout);

  // Utils
  function generateLinePath(
    [fromRank, fromFile]: [number, number],
    [toRank, toFile]: [number, number],
  ): string {
    const [startY, startX] = [
      innerFrameOffsetY + rankSpacing * fromRank,
      innerFrameOffsetX + fileSpacing * fromFile,
    ];

    const [deltaY, deltaX] = [
      rankSpacing * (toRank - fromRank),
      fileSpacing * (toFile - fromFile),
    ];

    return `m ${startX},${startY} ${deltaX},${deltaY}`;
  }
</script>

<div class="board-container">
  <svg class="board" {height} {width}>
    <!-- Frame -->
    <rect
      class="frame-outer"
      height={frameHeight}
      width={frameWidth}
      stroke-width="1.5"
      transform={`translate(${frameOffsetX}, ${frameOffsetY})`}
    />
    <rect
      class="frame-inner"
      height={innerFrameHeight}
      width={innerFrameWidth}
      stroke-width="1.5"
      transform={`translate(${innerFrameOffsetX}, ${innerFrameOffsetY})`}
    />
    <g class="lines">
      <!-- Palace -->
      <path d={generateLinePath([0, 3], [2, 5])} />
      <path d={generateLinePath([0, 5], [2, 3])} />
      <path d={generateLinePath([RANK_MAX, 3], [RANK_MAX - 2, 5])} />
      <path d={generateLinePath([RANK_MAX, 5], [RANK_MAX - 2, 3])} />

      <!-- Ranks & Files -->
      {#each Array(RANK_MAX - 1) as _, i}
        <path d={generateLinePath([i + 1, 0], [i + 1, FILE_MAX])} />
      {/each}
      {#each Array(FILE_MAX - 1) as _, i}
        <!-- River disconnected -->
        <path d={generateLinePath([0, i + 1], [4, i + 1])} />
        <path d={generateLinePath([RANK_MAX, i + 1], [5, i + 1])} />
      {/each}
    </g>
    <g class="layout">
      {#if prevPoint && nextPoint}
        <PieceShadow
          size={pieceSize}
          radius={pieceOuterRadius}
          prevPosition={prevPoint.position}
        />
      {/if}
      {#each points as point, index}
        <Piece
          {index}
          {turn}
          {point}
          nextPosition={nextPoint?.position}
          on:piecedrop
          on:piecefocus
          on:piecegrab
          on:piecemove
        />
      {/each}
    </g>
  </svg>
</div>

<style lang="scss">
  .board-container {
    height: 100%;

    display: flex;
    align-items: center;

    * {
      position: absolute;
      color: black;
      fill-opacity: 1;
      stroke: black;
      stroke-opacity: 1;
      stroke-dasharray: none;
      marker: none;
      visibility: visible;
      overflow: visible;
    }

    svg.board {
      shape-rendering: geometricPrecision;
    }

    rect.frame {
      &-outer {
        fill: #ce5c00;
      }
      &-inner {
        fill: #fcaf3e;
      }
    }

    g.lines {
      stroke-width: 1.5;
    }
  }
</style>
