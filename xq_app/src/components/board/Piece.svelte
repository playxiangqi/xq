<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import Enum from '@xq/utils/enum';
  import type { Side } from '@xq/utils/xq';
  import { getGlyph } from './pieces';
  import type { EnrichedCartesianPoint } from './store.svelte';
  import type { DimensionStore } from './dimensions.svelte';

  // Piece Props
  export let index: number;
  export let dimensions: DimensionStore;
  export let turn: Side;
  export let point: EnrichedCartesianPoint;
  export let nextPosition: [number, number] | undefined;

  // Initialization
  const dispatch = createEventDispatcher();

  // Reactive
  $: ({
    pieceScale,
    pieceSize,
    pieceBorderRadius,
    pieceOuterRadius,
    pieceInnerRadius,
    pieceStrokeWidth,
  } = $dimensions);
  $: ({ ch, side, position, prevPosition, grabbing } = point);
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

    const isValidMove = (movingSide: Side, turn: Side) => {
      return movingSide === turn;
    };
    const movedFromPrev =
      isValidMove(side, turn) && !Enum.strictEquals(position, prevPosition);

    dispatch('piecedrop', { index, movedFromPrev });
  }
</script>

<svg
  class="piece"
  class:grabbing
  height={pieceSize}
  width={pieceSize}
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
    r={pieceOuterRadius}
    cx={pieceBorderRadius}
    cy={pieceBorderRadius}
    stroke="black"
    stroke-width={pieceStrokeWidth}
  />
  <circle
    class="inner"
    r={pieceInnerRadius}
    cx={pieceBorderRadius}
    cy={pieceBorderRadius}
    stroke={computedColor}
    stroke-width={pieceStrokeWidth}
  />
  <path
    class="glyph"
    fill={computedColor}
    d={glyph}
    transform={`translate(${15 * pieceScale}, ${
      14 * pieceScale
    }) scale(${pieceScale})`}
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
