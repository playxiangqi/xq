<script lang="ts">
  import { Dimensions } from './dimensions';
  import { getGlyph } from './pieces';
  import type { Character, Side } from './pieces';
  import { debug } from 'svelte/internal';

  // Piece Props
  export let index: number;
  export let side: Side;
  export let ch: Character;
  export let position: [number, number];
  export let grabbing: boolean;
  export let dimensions: Dimensions;

  const {
    pieceScale: scale,
    pieceSize: size,
    pieceBorderRadius: borderRadius,
    pieceOuterRadius: outerRadius,
    pieceInnerRadius: innerRadius,
    pieceStrokeWidth: strokeWidth,
  } = dimensions;

  // let offset = { y: 0, x: 0 };
  // Reactive
  $: glyph = getGlyph(side, ch);
  $: [posY, posX] = position;
  $: computedColor = side === 'red' ? '#cc0000' : 'black';

  // Event Props
  export let dropPiece: (index: number) => void;
  export let focusPiece: (index: number) => void;
  export let grabPiece: (index: number) => void;

  // Events
  type Event = PointerEvent & { currentTarget: EventTarget & SVGSVGElement };

  function onPointerDown(e: Event) {
    const el = e.target as HTMLElement;
    // const bbox = el.getBoundingClientRect();
    el.setPointerCapture(e.pointerId);
    // offset = { y: e.clientY - bbox.top, x: e.clientX - bbox.left };
    grabPiece(index);
  }

  function onPointerEnter() {
    focusPiece(index);
  }

  function onPointerMove() {
    // function onPointerMove(e: Event) {
    // const bbox = (e.target as HTMLElement).getBoundingClientRect();
    // const [x, y] = [e.clientX - bbox.left, e.clientY - bbox.top];
    // const [derivedX, derivedY] = [posX - (offset.x - x), posY - (offset.y - y)];
    // const [toRank, toFile] = dimensions.clampCoords(derivedY, derivedX);
    // if (grabbing) {
    // movePiece(index, dimensions.coordsToPoint(toRank, toFile), [
    //   toRank,
    //   toFile,
    // ]);
    // }
  }

  function onPointerUp() {
    // const [y, x] = dimensions.clampCoords(posY, posX);
    // movePiece(index, [y, x]);
    dropPiece(index);
  }
</script>

<svg
  class={`piece ${grabbing ? 'grabbing' : ''}`}
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
