<script context="module" lang="ts">
  import type { Writable } from 'svelte/store';
  import { writable } from '@xq/utils/store.svelte';
  import type { Dimensions } from '@xq/utils/dimensions';
  import { BLACK, DEFAULT_POINTS, RED, enrichPoint } from '@xq/utils/xq';
  import type { CartesianPoint, Layout, Side } from '@xq/utils/xq';

  export type EnrichedCartesianPoint = CartesianPoint & { grabbing: boolean };

  export type BoardState = {
    flipped: boolean;
    turn: Side;
    workingLayout: Layout<EnrichedCartesianPoint>;
  };

  export interface BoardStore extends Readable<BoardState> {
    flipBoard: () => void;
    setLayout: (layout: Layout<EnrichedCartesianPoint>) => void;
    dropPiece: (index: number, movedFromPrev: boolean) => boolean;
    focusPiece: (index: number) => void;
    grabPiece: (index: number) => void;
    movePiece: (index: number, position: [number, number]) => void;
  }

  export function createBoardStore(dimensions: Dimensions) {
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
    const { update } = store;

    function flipBoard() {
      update(({ workingLayout, flipped, ...state }) => {
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

    function setLayout(layout: Layout<EnrichedCartesianPoint>) {
      update(($state) => {
        $state.workingLayout = layout;
      });
    }

    function dropPiece(index: number, movedFromPrev: boolean): boolean {
      update(($state) => {
        const destPosition = $state.workingLayout.points[index].position;
        const prevPosition = $state.workingLayout.points[index].prevPosition;

        $state.workingLayout.points[index].grabbing = false;

        // Confirm drop by updating prevPosition
        if (movedFromPrev) {
          // Update position
          $state.workingLayout.points[index].prevPosition = destPosition;
          $state.turn = $state.turn === RED ? BLACK : RED;
        } else {
          // Return to previous position
          $state.workingLayout.points[index].position = prevPosition;
        }
      });
      return movedFromPrev;
    }

    function focusPiece(index: number) {
      update(({ workingLayout: { points } }) => {
        const lastIndex = points.length - 1;
        [points[index], points[lastIndex]] = [points[lastIndex], points[index]];
      });
    }

    function grabPiece(index: number) {
      update(($state) => {
        $state.workingLayout.points[index].grabbing = true;
      });
    }

    function movePiece(index: number, position: [number, number]) {
      update(($state) => {
        $state.workingLayout.points[index].position = position;
      });
    }

    return {
      ...store,
      flipBoard,
      setLayout,
      dropPiece,
      focusPiece,
      grabPiece,
      movePiece,
    };
  }
</script>
