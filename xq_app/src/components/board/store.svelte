<script context="module" lang="ts">
  import { writable } from 'svelte/store';
  import type { Writable } from 'svelte/store';
  import Enum from '@xq/utils/enum';
  import type { Dimensions } from '@xq/utils/dimensions';
  import { BLACK, DEFAULT_POINTS, RED, enrichPoint } from '@xq/utils/xq';
  import type { CartesianPoint, Layout, Side } from '@xq/utils/xq';

  export type EnrichedCartesianPoint = CartesianPoint & { grabbing: boolean };

  export type BoardState = {
    flipped: boolean;
    turn: Side;
    workingLayout: Layout<EnrichedCartesianPoint>;
  };

  // TODO: Use immer's produce as middleware
  //       to improve Updater function conciseness
  export interface BoardStore extends Writable<BoardState> {
    flipBoard: () => void;
    dropPiece: (index: number, side: Side) => boolean;
    focusPiece: (index: number) => void;
    grabPiece: (index: number) => void;
    movePiece: (index: number, position: [number, number]) => void;
  }

  export function createBoardStore(dimensions: Dimensions): BoardStore {
    const store = writable<BoardState>({
      flipped: false,
      turn: RED,
      workingLayout: {
        points: DEFAULT_POINTS.map((p) => ({
          ...enrichPoint(p, dimensions),
          grabbing: false,
        })),
      },
    });

    function flipBoard() {
      store.update(({ workingLayout, flipped, ...state }) => {
        const { points, prevPoint, nextPoint } = workingLayout;
        workingLayout = {
          points: points.map((p) => ({
            ...enrichPoint(p, dimensions, true),
            grabbing: false,
          })),
          prevPoint: prevPoint
            ? enrichPoint(prevPoint, dimensions, true)
            : prevPoint,
          nextPoint: nextPoint
            ? enrichPoint(nextPoint, dimensions, true)
            : nextPoint,
        } as Layout<EnrichedCartesianPoint>;

        return { ...state, workingLayout, flipped: !flipped };
      });
    }

    function dropPiece(index: number, side: Side): boolean {
      const isValidMove = (movingSide: Side, turn: Side) => {
        return movingSide === turn;
      };

      let movedFromPrev = false;

      store.update(({ workingLayout: wl, turn, ...state }) => {
        const destPosition = wl.points[index].position;
        const prevPosition = wl.points[index].prevPosition;

        wl.points[index].grabbing = false;

        // Track if piece was moved
        movedFromPrev = !Enum.strictEquals(
          destPosition,
          prevPosition ?? [-1, -1],
        );

        // Confirm drop by updating prevPosition
        if (isValidMove(side, turn) && movedFromPrev) {
          // Update position
          wl.points[index].prevPosition = destPosition;
          turn = turn === RED ? BLACK : RED;
        } else {
          movedFromPrev = false;

          // Return to previous position
          wl.points[index].position = prevPosition ?? destPosition;
        }
        return { ...state, workingLayout: wl, turn };
      });

      return movedFromPrev;
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
        state.workingLayout.points[index].grabbing = true;
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
      ...store,
      dropPiece,
      flipBoard,
      focusPiece,
      grabPiece,
      movePiece,
    };
  }
</script>
