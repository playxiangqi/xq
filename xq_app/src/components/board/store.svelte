<script context="module" lang="ts">
  import { derived, writable } from 'svelte/store';
  import { gameStore } from '@xq/core/game';
  import { DEFAULT_POINTS } from '@xq/utils/xq';
  import type { CartesianPoint, Layout, Point } from '@xq/utils/xq';
  import type { Dimensions } from './dimensions';

  export type PieceState = {
    grabbing: { [key: string]: boolean };
    flipped: boolean;
  };

  export type BoardState = {
    activeLayout: Layout<CartesianPoint>;
  } & PieceState;

  // const DEFAULT_BOARD_STATE = (dimensions: Dimensions) =>

  const pieceStore = writable<PieceState>({
    grabbing: {},
    flipped: true,
  });

  export function createBoardStore(dimensions: Dimensions) {
    const boardStore = derived<
      [typeof gameStore, typeof pieceStore],
      BoardState
    >([gameStore, pieceStore], ([gameState, { grabbing, flipped }]) => {
      const { points, nextPoint, prevPoint } = gameState.layouts[
        gameState.currentTurnIndex
      ];

      return {
        activeLayout: {
          points: points.map((p) => pointToCartesian(p, dimensions)),
          nextPoint,
          prevPoint,
        },
        grabbing,
        flipped,
      };
    });

    return {
      boardStore,
    };
  }

  function pointToCartesian(
    { rank, file, ...point }: Point,
    dimensions: Dimensions,
  ): CartesianPoint {
    return {
      ...point,
      position: dimensions.coordsToPoint(rank, file),
    } as CartesianPoint;
  }
</script>
