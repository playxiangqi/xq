<script context="module" lang="ts">
  import { writable } from 'svelte/store';
  import type { Readable } from 'svelte/store';
  import { DEFAULT_POINTS } from '@xq/utils/xq';
  import { FILE_MAX, RANK_MAX } from '@xq/utils/dimensions';
  import type { Dimensions } from '@xq/utils/dimensions';
  import type { CartesianPoint, Layout, Point, Side } from '@xq/utils/xq';

  export type EnrichedCartesianPoint = CartesianPoint & { grabbed: boolean };

  export type BoardState = {
    flipped: boolean;
    workingLayout: Layout<EnrichedCartesianPoint>;
  };

  // TODO: Use immer's produce as middleware
  //       to improve Updater function conciseness
  export interface BoardStore extends Readable<BoardState> {
    flipBoard: () => void;
    dropPiece: (index: number, side: Side) => boolean;
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

    function dropPiece(index: number, side: Side): boolean {
      return false;
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
      dropPiece,
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

  // const isValidMove = (movingSide: Side, turn: Side) => {
  //   return movingSide === turn;
  // };

  //   const dropPiece = (index: number, side: Side): boolean => {
  //     let movedFromPrev = false;

  //     update(({ activeLayout, moves, turn, ...state }) => {
  //       activeLayout[index].grabbing = false;

  //       // Track if piece was moved
  //       movedFromPrev = !Enum.strictEquals(
  //         activeLayout[index].position,
  //         activeLayout[index].prevPosition,
  //       );

  //       // Confirm drop by updating prevPosition
  //       if (isValidMove(side, turn) && movedFromPrev) {
  //         // Update position
  //         activeLayout[index].prevPosition = activeLayout[index].position;

  //         const { side, ch, position, prevPosition } = activeLayout[index];
  //         const [rank, file] = dimensions.coordsToPoint(position[0], position[1]);

  //         moves = [...moves, { side, ch, rank, file, position, prevPosition }];
  //         turn = turn === RED ? BLACK : RED;
  //       } else {
  //         movedFromPrev = false;

  //         // Return to previous position
  //         activeLayout[index].position = activeLayout[index].prevPosition;
  //       }
  //       return { ...state, activeLayout, moves, turn };
  //     });

  //     return movedFromPrev;
  //   };
</script>
