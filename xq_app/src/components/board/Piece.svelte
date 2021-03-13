<script lang="ts">
  import { getContext } from 'svelte';
  import Enum from '@xq/utils/enum';
  import { Dimensions } from './dimensions';
  import { getGlyph } from './pieces';
  import type { Character, Side } from './pieces';

  // Piece Props
  export let index: number;
  export let side: Side;
  export let ch: Character;
  export let position: [number, number];
  export let nextPosition: [number, number] | undefined;
  export let grabbing: boolean;
  export let dimensions: Dimensions;

  const { playSound } = getContext('audio');
  const {
    pieceScale: scale,
    pieceSize: size,
    pieceBorderRadius: borderRadius,
    pieceOuterRadius: outerRadius,
    pieceInnerRadius: innerRadius,
    pieceStrokeWidth: strokeWidth,
  } = dimensions;

  let offset = { y: 0, x: 0 };
  // Reactive
  $: glyph = getGlyph(side, ch);
  $: [posY, posX] = position;
  $: computedColor = side === 'red' ? '#cc0000' : 'black';
  $: moved = nextPosition && Enum.strictEquals(nextPosition, position);

  // Event Props
  export let dropPiece: (index: number, side: Side) => boolean;
  export let focusPiece: (index: number) => void;
  export let grabPiece: (index: number) => void;
  export let movePiece: (index: number, position: [number, number]) => void;

  // Events
  type Event = PointerEvent & { currentTarget: EventTarget & SVGSVGElement };

  function onPointerDown(e: Event) {
    const el = e.target as HTMLElement;
    const bbox = el.getBoundingClientRect();
    el.setPointerCapture(e.pointerId);
    offset = { y: e.clientY - bbox.top, x: e.clientX - bbox.left };
    grabPiece(index);
  }

  function onPointerEnter() {
    focusPiece(index);
  }

  function onPointerMove(e: Event) {
    const bbox = (e.target as HTMLElement).getBoundingClientRect();
    const [y, x] = [e.clientY - bbox.top, e.clientX - bbox.left];
    const [derivedY, derivedX] = [posY - (offset.y - y), posX - (offset.x - x)];
    const [toRank, toFile] = dimensions.clampCoords(derivedY, derivedX);
    if (grabbing) {
      movePiece(index, [toRank, toFile]);
    }
  }

  function onPointerUp() {
    const [y, x] = dimensions.snapCoords(posY, posX);
    movePiece(index, [y, x]);
    if (dropPiece(index, side)) {
      playSound();
    }
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
