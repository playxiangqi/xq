<script lang="ts">
  import { onDestroy } from 'svelte';
  import Piece from './Piece.svelte';
  import { Dimensions, FILE_MAX, RANK_MAX } from './dimensions';
  import { Point, store } from './store';
  import App from 'App.svelte';

  // State + Lifecycle
  let layout: Point[] = [];
  const unsubscribe = store.subscribe((state) => {
    layout = state.layout;
  });
  onDestroy(unsubscribe);

  // Dimensions
  const DEFAULT_SCALE = 1.0;
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
    maxY,
    maxX,
    pieceScale: scale,
    pieceSize: size,
    pieceBorderRadius: borderRadius,
    pieceOuterRadius: outerRadius,
    pieceInnerRadius: innerRadius,
    pieceStrokeWidth: strokeWidth,
    instance: dimensions,
  } = new Dimensions(DEFAULT_SCALE);

  // Utils
  function generateLinePath(
    [fromRank, fromFile]: [number, number],
    [toRank, toFile]: [number, number]
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
      {#each layout as { side, glyph, grabbing, rank, file }, i}
        <Piece
          index={i}
          {side}
          {glyph}
          {scale}
          {size}
          {borderRadius}
          {outerRadius}
          {innerRadius}
          {strokeWidth}
          {maxY}
          {maxX}
          position={dimensions.pointToCoords(rank, file)}
          {grabbing}
        />
      {/each}
    </g>
  </svg>
</div>

<style lang="scss">
  .board-container {
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
