<script lang="ts">
  import type { Side } from './pieces';
  import { grabPiece, focusPiece } from './store';

  // Dimensions
  export let index: number;
  export let side: Side;
  export let glyph: string;
  export let scale = 0.6;
  export let size = 100;
  export let borderRadius = 50;
  export let outerRadius = 48;
  export let innerRadius = 43;
  export let strokeWidth = 2.2;
  export let maxY: number;
  export let maxX: number;
  export let position: readonly [number, number];
  export let grabbing: boolean;

  const computedColor = side === 'red' ? '#cc0000' : 'black';

  let offset = { x: 0, y: 0 };
  const [posY, posX] = position;

  // Events
  type Event = PointerEvent & { currentTarget: EventTarget & SVGSVGElement };

  function onPointerDown(e: Event) {
    const el = e.target as HTMLElement;
    const bbox = el.getBoundingClientRect();
    el.setPointerCapture(e.pointerId);
    offset = { x: e.clientX - bbox.left, y: e.clientY - bbox.top };
    grabPiece(index);
  }

  function onPointerEnter(e: Event) {
    focusPiece(index);
  }

  function onPointerMove(e: Event) {}

  function onPointerUp() {}
</script>

<svg
  class={`piece ${grabbing && 'grabbing'}`}
  height={size}
  width={size}
  x={posX}
  y={posY}
  on:pointerdown={onPointerDown}
  on:pointerenter={onPointerEnter}
  on:pointermove={onPointerMove}
  on:pointerup={onPointerUp}
>
  <circle
    class="outer"
    r={outerRadius}
    cx={borderRadius}
    cy={borderRadius}
    stroke="black"
    stroke-width={strokeWidth}
  />
  <circle
    class="inner"
    r={innerRadius}
    cx={borderRadius}
    cy={borderRadius}
    stroke={computedColor}
    stroke-width={strokeWidth}
  />
  <path
    class="glyph"
    fill={computedColor}
    d={glyph}
    transform={`translate(${15 * scale}, ${14 * scale}) scale(${scale})`}
  />
</svg>

<style lang="scss">
  svg.piece {
    cursor: grab;

    &.grabbing {
      cursor: grabbing;
    }

    circle {
      shape-rendering: geometricPrecision;
    }

    circle.outer {
      fill: #ffddaa;
    }

    circle.inner {
      fill: none;
    }

    path.glyph {
      stroke: none;
    }
  }
</style>
