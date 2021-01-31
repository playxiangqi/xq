<script lang="ts">
  type Side = 'red' | 'black';

  // Dimensions
  export let side: Side;
  export let glyph: string;
  export let scale = 1.0;
  export let size = 100;
  export let borderRadius = 50;
  export let outerRadius = 48;
  export let innerRadius = 43;
  export let strokeWidth = 2.2;

  const computedSize = size * scale;
  const computedBorder = borderRadius * scale;
  const computedOuter = outerRadius * scale;
  const computedInner = innerRadius * scale;
  const computedStrokeWidth = strokeWidth * scale;
  const computedColor = side === 'red' ? '#cc0000' : 'black';

  // Events
  function onPointerDown() {}

  function onPointerEnter() {}

  function onPointerMove() {}

  function onPointerUp() {}
</script>

<svg
  height={computedSize}
  width={computedSize}
  on:pointerdown={onPointerDown}
  on:pointerenter={onPointerEnter}
  on:pointermove={onPointerMove}
  on:pointerup={onPointerUp}
>
  <circle
    class="outer"
    r={computedOuter}
    cx={computedBorder}
    cy={computedBorder}
    stroke="black"
    stroke-width={computedStrokeWidth}
  />
  <circle
    class="inner"
    r={computedInner}
    cx={computedBorder}
    cy={computedBorder}
    stroke={computedColor}
    stroke-width={computedStrokeWidth}
  />
  <path
    fill={computedColor}
    d={glyph}
    transform={`translate(15, 15) scale(1.0)`}
  />
</svg>

<style lang="scss">
  circle {
    shape-rendering: geometricPrecision;
  }

  circle.outer {
    fill: #ffddaa;
  }

  circle.inner {
    fill: none;
  }
</style>
