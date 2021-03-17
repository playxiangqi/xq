<script context="module" lang="ts">
  import { derived, writable } from 'svelte/store';
  import type { Writable } from 'svelte/store';
  import type { GameState } from '@xq/core/game';
  import { DEFAULT_POINTS } from '@xq/utils/xq';
  import { FILE_MAX, RANK_MAX } from '@xq/utils/dimensions';
  // import type { Dimensions } from '@xq/utils/dimensions';
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

  export function createBoardStore(
    gameStore: Writable<GameState>,
    dimensions: Dimensions,
  ) {
    const pieceStore = writable<PieceState>({
      grabbing: {},
      flipped: true,
    });

    const boardStore = derived<
      [Writable<GameState>, typeof pieceStore],
      BoardState
    >([gameStore, pieceStore], ([gameState, { grabbing, flipped }]) => {
      const { points, nextPoint, prevPoint } = gameState.layouts[
        gameState.currentTurnIndex
      ];

      return {
        activeLayout: {
          points: points.map((p) => pointToCartesian(p, dimensions, flipped)),
          nextPoint: nextPoint ? invert(nextPoint, flipped) : nextPoint,
          prevPoint: prevPoint ? invert(prevPoint, flipped) : nextPoint,
        },
        grabbing,
        flipped,
      };
    });

    function flipBoard() {
      pieceStore.update((state) => ({ ...state, flipped: !state.flipped }));
    }

    return {
      boardStore,
      flipBoard,
    };
  }

  // TODO: Move to utils
  function pointToCartesian(
    point: Point,
    dimensions: Dimensions,
    shouldInvert = false,
  ): CartesianPoint {
    const newPoint = invert(point, shouldInvert);
    return {
      ...newPoint,
      position: dimensions.coordsToPoint(newPoint.rank, newPoint.file),
    } as CartesianPoint;
  }

  function invert(point: Point, shouldInvert: boolean): Point {
    const [rank, file] = shouldInvert
      ? [RANK_MAX - point.rank, FILE_MAX - point.file]
      : [point.rank, point.file];
    return { ...point, rank, file };
  }
</script>
