<script lang="ts">
  import { createEventDispatcher, getContext } from 'svelte';
  import { Dimensions } from '@xq/utils/dimensions';
  import Enum from '@xq/utils/enum';
  import type { EnrichedCartesianPoint } from './store.svelte';
  import { getGlyph } from './pieces';

  // Piece Props
  export let index: number;
  export let point: EnrichedCartesianPoint;
  export let nextPosition: [number, number] | undefined;

  // Initialization
  const dispatch = createEventDispatcher();
  const dimensions: Dimensions = getContext('dimensions');
  const {
    pieceScale: scale,
    pieceSize: size,
    pieceBorderRadius: borderRadius,
    pieceOuterRadius: outerRadius,
    pieceInnerRadius: innerRadius,
    pieceStrokeWidth: strokeWidth,
  } = dimensions;

  // Reactive
  $: ({ ch, side, position, grabbing } = point);
  $: glyph = getGlyph(side, ch);
  $: [posY, posX] = position;
  $: computedColor = side === 'red' ? '#cc0000' : 'black';
  $: moved = nextPosition && Enum.strictEquals(nextPosition, position);

  // Locals
  let offset = { y: 0, x: 0 };

  // Event Handlers
  type Event = PointerEvent & { currentTarget: EventTarget & SVGSVGElement };

  function onPointerDown(e: Event) {
    const el = e.target as HTMLElement;
    const bbox = el.getBoundingClientRect();
    el.setPointerCapture(e.pointerId);
    offset = { y: e.clientY - bbox.top, x: e.clientX - bbox.left };
    dispatch('piecegrab', index);
  }

  function onPointerEnter() {
    dispatch('piecefocus', index);
  }

  function onPointerMove(e: Event) {
    const bbox = (e.target as HTMLElement).getBoundingClientRect();
    const [y, x] = [e.clientY - bbox.top, e.clientX - bbox.left];
    const [derivedY, derivedX] = [posY - (offset.y - y), posX - (offset.x - x)];
    const [toRank, toFile] = dimensions.clampCoords(derivedY, derivedX);
    if (grabbing) {
      dispatch('piecemove', { index, point: [toRank, toFile] });
    }
  }

  function onPointerUp() {
    const [y, x] = dimensions.snapCoords(posY, posX);
    dispatch('piecemove', { index, point: [y, x] });
    dispatch('piecedrop', { index, side });
  }
</script>

<svg
  class="piece"
  class:grabbing
  height={size}
  width={size}
  y={posY}
  x={posX}
  on:pointerdown={onPointerDown}
  on:pointerenter={onPointerEnter}
  on:pointermove={onPointerMove}
  on:pointerup={onPointerUp}
>
  <circle
    class="outer"
    class:moved
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

      &.outer {
        fill: #ffddaa;
      }

      &.inner {
        fill: none;
      }

      &.moved {
        stroke: greenyellow;
      }
    }

    path.glyph {
      stroke: none;
    }
  }
</style>
