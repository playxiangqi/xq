<script context="module" lang="ts">
  import { derived, get, writable } from 'svelte/store';
  import type { Readable } from 'svelte/store';
  import { FILE_MAX, RANK_MAX } from '@xq/utils/xq';

  export type Dimensions = {
    height: number;
    width: number;
    scale: number;

    frameHeight: number;
    frameWidth: number;
    innerFrameHeight: number;
    innerFrameWidth: number;
    frameOffsetX: number;
    frameOffsetY: number;
    innerFrameOffsetY: number;
    innerFrameOffsetX: number;

    rankEnd: number;
    fileEnd: number;
    rankSpacing: number;
    fileSpacing: number;

    maxY: number;
    maxX: number;

    pieceScale: number;
    pieceSize: number;
    pieceBorderRadius: number;
    pieceOuterRadius: number;
    pieceInnerRadius: number;
    pieceStrokeWidth: number;
    pieceOffsetY: number;
    pieceOffsetX: number;
  };

  const DEFAULT_HEIGHT = 800;
  const FRAME_RATIO = 0.975;
  const INNER_FRAME_RATIO = 0.825;
  const ASPECT_RATIO = (RANK_MAX + 1) / (FILE_MAX + 1);

  export interface DimensionStore extends Readable<Dimensions> {
    // Custom Writable
    set(value: number): void;
    update(updater: (value: number) => number): void;

    // Methods
    clampPoint(rank: number, file: number): [number, number];
    clampCoords(y: number, x: number): [number, number];
    coordsToPoint(y: number, x: number): [number, number];
    pointToCoords(rank: number, file: number): [number, number];
    snapCoords(y: number, x: number): [number, number];
  }

  export function createDimensionStore(): DimensionStore {
    const store = writable(DEFAULT_HEIGHT);
    const { set, update } = store;

    const dimensions = derived<typeof store, Dimensions>(store, ($height) => {
      const scale = $height / 800;
      const width = $height / ASPECT_RATIO;
      const frameHeight = $height / FRAME_RATIO;
      const frameWidth = width * FRAME_RATIO;
      const innerFrameHeight = $height * INNER_FRAME_RATIO;
      const innerFrameWidth = width * INNER_FRAME_RATIO;

      const frameOffsetY = ($height - frameHeight) / 2;
      const frameOffsetX = (width - frameWidth) / 2;
      const innerFrameOffsetY =
        (frameHeight - innerFrameHeight) / 2 + frameOffsetY;
      const innerFrameOffsetX =
        (frameWidth - innerFrameWidth) / 2 + frameOffsetX;

      const rankEnd = $height * INNER_FRAME_RATIO;
      const fileEnd = width * INNER_FRAME_RATIO;

      const pieceScale = 0.675 * scale;
      const pieceBorderRadius = 50 * pieceScale;

      return {
        height: $height,
        width,
        scale,
        frameHeight,
        frameWidth,
        innerFrameHeight,
        innerFrameWidth,
        frameOffsetX,
        frameOffsetY,
        innerFrameOffsetY,
        innerFrameOffsetX,
        rankEnd,
        fileEnd,
        rankSpacing: rankEnd / RANK_MAX,
        fileSpacing: fileEnd / FILE_MAX,
        maxY: innerFrameOffsetY + rankEnd,
        maxX: innerFrameOffsetX + fileEnd,
        pieceScale,
        pieceSize: 100 * pieceScale,
        pieceBorderRadius,
        pieceOuterRadius: 48 * pieceScale,
        pieceInnerRadius: 43 * pieceScale,
        pieceStrokeWidth: 2.5 * pieceScale,
        pieceOffsetY: innerFrameOffsetY - pieceBorderRadius * scale,
        pieceOffsetX: innerFrameOffsetX - pieceBorderRadius * scale,
      };
    });
    const { subscribe } = dimensions;

    const $this = get(dimensions);

    function clampPoint(rank: number, file: number): [number, number] {
      return [
        Math.min(RANK_MAX, Math.max(Math.round(rank))),
        Math.min(FILE_MAX, Math.max(0, Math.round(file))),
      ];
    }

    function clampCoords(y: number, x: number): [number, number] {
      return [
        Math.min($this.maxY, Math.max(0, y)),
        Math.min($this.maxX, Math.max(0, x)),
      ];
    }

    function pointToCoords(rank: number, file: number): [number, number] {
      const [clampedRank, clampedFile] = clampPoint(rank, file);
      return [
        $this.pieceOffsetY + $this.rankSpacing * clampedRank,
        $this.pieceOffsetX + $this.fileSpacing * clampedFile,
      ];
    }

    function coordsToPoint(y: number, x: number): [number, number] {
      const [rank, file] = [
        (y - $this.pieceOffsetY) / $this.rankSpacing,
        (x - $this.pieceOffsetX) / $this.fileSpacing,
      ];
      return clampPoint(rank, file);
    }

    function snapCoords(y: number, x: number): [number, number] {
      const [clampedRank, clampedFile] = coordsToPoint(y, x);
      return pointToCoords(clampedRank, clampedFile);
    }

    return {
      set,
      update,
      subscribe,
      clampPoint,
      clampCoords,
      coordsToPoint,
      pointToCoords,
      snapCoords,
    };
  }
</script>
