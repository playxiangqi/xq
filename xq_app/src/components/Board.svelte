<script lang="ts">
  // Board Dimensions
  const apsectRatio = 1.1;
  const height = 800;
  const width = height / apsectRatio;

  // Frame Dimensions
  const frameRatio = 0.96;
  const [frameHeight, frameWidth] = [height * frameRatio, width * frameRatio];
  const innerFrameRatio = 0.85;
  const [innerFrameHeight, innerFrameWidth] = [
    height * innerFrameRatio,
    width * innerFrameRatio,
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

  const [maxFile, maxRank] = [8, 9];
  const [fileEnd, rankEnd] = [
    innerFrameRatio * width,
    innerFrameRatio * height,
  ];
  const [fileSpacing, rankSpacing] = [fileEnd / maxFile, rankEnd / maxRank];

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
      <path d={generateLinePath([3, maxRank], [5, maxRank - 2])} />
      <path d={generateLinePath([5, maxRank], [3, maxRank - 2])} />

      <!-- Ranks & Files -->
      {#each Array(maxFile - 1) as _, i}
        <path d={generateLinePath([i + 1, 0], [i + 1, 4])} />
        <path d={generateLinePath([i + 1, maxRank], [i + 1, 5])} />
      {/each}
      {#each Array(maxRank - 1) as _, i}
        <path d={generateLinePath([0, i + 1], [maxFile, i + 1])} />
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
