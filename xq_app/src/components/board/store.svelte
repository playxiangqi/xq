<script context="module" lang="ts">
  import { writable } from 'svelte/store';
  import type { Readable } from 'svelte/store';
  import { DEFAULT_POINTS } from '@xq/utils/xq';
  import { FILE_MAX, RANK_MAX } from '@xq/utils/dimensions';
  // import type { Dimensions } from '@xq/utils/dimensions';
  import type { CartesianPoint, Layout, Point } from '@xq/utils/xq';
  import type { Dimensions } from './dimensions';

  export type EnrichedCartesianPoint = CartesianPoint & { grabbed: boolean };

  export type BoardState = {
    flipped: boolean;
    workingLayout: Layout<EnrichedCartesianPoint>;
  };

  // TODO: Use immer's produce as middleware
  //       to improve Updater function conciseness
  export interface BoardStore extends Readable<BoardState> {
    flipBoard: () => void;
    focusPiece: (index: number) => void;
    grabPiece: (index: number) => void;
    movePiece: (index: number, position: [number, number]) => void;
  }

  export function createBoardStore(dimensions: Dimensions): BoardStore {
    const store = writable<BoardState>({
      flipped: false,
      workingLayout: {
        points: DEFAULT_POINTS.map((p) => enrichPoints(p, dimensions)),
      },
    });
    const { subscribe } = store;

    function flipBoard() {
      store.update((state) => ({ ...state, flipped: !state.flipped }));
    }

    function focusPiece(index: number) {
      store.update(({ workingLayout: { points, ...rest }, ...state }) => {
        const lastIndex = points.length - 1;
        [points[index], points[lastIndex]] = [points[lastIndex], points[index]];
        return {
          ...state,
          workingLayout: {
            ...rest,
            points,
          },
        };
      });
    }

    function grabPiece(index: number) {
      store.update((state) => {
        state.workingLayout.points[index].grabbed = true;
        return state;
      });
    }

    function movePiece(index: number, position: [number, number]) {
      store.update((state) => {
        state.workingLayout.points[index].position = position;
        return state;
      });
    }

    return {
      subscribe,
      flipBoard,
      focusPiece,
      grabPiece,
      movePiece,
    };
  }

  function enrichPoints(
    point: Point,
    dimensions: Dimensions,
    shouldInvert = false,
  ): EnrichedCartesianPoint {
    const newPoint = invert(point, shouldInvert);
    return {
      ...newPoint,
      position: dimensions.coordsToPoint(newPoint.rank, newPoint.file),
      grabbed: false,
    } as EnrichedCartesianPoint;
  }

  function invert(point: Point, shouldInvert: boolean): Point {
    const [rank, file] = shouldInvert
      ? [RANK_MAX - point.rank, FILE_MAX - point.file]
      : [point.rank, point.file];
    return { ...point, rank, file };
  }
</script>
