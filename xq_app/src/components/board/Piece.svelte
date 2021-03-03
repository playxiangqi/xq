<script lang="ts">
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
  $: justMoved =
    nextPosition &&
    nextPosition[0] === position[0] &&
    nextPosition[1] === position[1];

  // Sound Effects
  const audio = new Audio('./sounds/drop-piece.wav');

  function playSound() {
    audio.currentTime = 0;
    audio.loop = false;
    audio.play();
  }

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
    r={outerRadius}
    cx={borderRadius}
    cy={borderRadius}
    stroke={justMoved ? 'greenyellow' : 'black'}
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
