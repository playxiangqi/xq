<script lang="ts">
  import Piece from './Piece.svelte';
  import { Point, store } from './store';

  let layout: Point[];
  const unsubscribe = store.subscribe((state) => {
    layout = state.layout;
  });

  // Board Dimensions
  const ASPECT_RATIO = 1.1;
  export let height = 800;
  const width = height / ASPECT_RATIO;

  // Frame Dimensions
  const FRAME_RATIO = 0.96;
  const [frameHeight, frameWidth] = [height * FRAME_RATIO, width * FRAME_RATIO];
  const INNER_FRAME_RATIO = 0.85;
  const [innerFrameHeight, innerFrameWidth] = [
    height * INNER_FRAME_RATIO,
    width * INNER_FRAME_RATIO,
  ];

  // Positions
  const [frameOffsetX, frameOffsetY] = [
    (width - frameWidth) / 2,
    (height - frameHeight) / 2,
  ];
  const [innerFrameOffsetX, innerFrameOffsetY] = [
    (frameWidth - innerFrameWidth) / 2 + frameOffsetX,
    (frameHeight - innerFrameHeight) / 2 + frameOffsetY,
  ];

  const [FILE_MAX, RANK_MAX] = [8, 9];
  const [fileEnd, rankEnd] = [
    INNER_FRAME_RATIO * width,
    INNER_FRAME_RATIO * height,
  ];
  const [fileSpacing, rankSpacing] = [fileEnd / FILE_MAX, rankEnd / RANK_MAX];

  // Utils
  function generateLinePath(
    [fromFile, fromRank]: [number, number],
    [toFile, toRank]: [number, number]
  ): string {
    const [startX, startY] = [
      innerFrameOffsetX + fileSpacing * fromFile,
      innerFrameOffsetY + rankSpacing * fromRank,
    ];

    const [deltaX, deltaY] = [
      fileSpacing * (toFile - fromFile),
      rankSpacing * (toRank - fromRank),
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
      <path d={generateLinePath([3, 0], [5, 2])} />
      <path d={generateLinePath([5, 0], [3, 2])} />
      <path d={generateLinePath([3, RANK_MAX], [5, RANK_MAX - 2])} />
      <path d={generateLinePath([5, RANK_MAX], [3, RANK_MAX - 2])} />

      <!-- Ranks & Files -->
      {#each Array(FILE_MAX - 1) as _, i}
        <path d={generateLinePath([i + 1, 0], [i + 1, 4])} />
        <path d={generateLinePath([i + 1, RANK_MAX], [i + 1, 5])} />
      {/each}
      {#each Array(RANK_MAX - 1) as _, i}
        <path d={generateLinePath([0, i + 1], [FILE_MAX, i + 1])} />
      {/each}
    </g>
    <g class="layout">
      {#each layout as point}
        <Piece side={point.side} glyph={point.glyph} />
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
