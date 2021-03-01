import { writable } from 'svelte/store';
import { Dimensions } from './dimensions';
import { createInitialLayout, Move, Point, Side, RED, BLACK } from './pieces';

export type Layout = Point[];

// TODO: AnalysisState which contains/extends a BoardState
export type BoardState = {
  activeLayout: Layout;
  layouts: Layout[];
  moves: Move[];
  turn: Side;
  facing: Side;
};

export function createBoardState(dimensions: Dimensions) {
  const activeLayout = createInitialLayout(dimensions);

  const store = writable<BoardState>({
    activeLayout,
    layouts: [activeLayout],
    moves: [],
    turn: RED,
    facing: RED,
  });
  const { update } = store;

  const isValidMove = (movingSide: Side, turn: Side) => {
    return movingSide === turn;
  };

  return {
    store,
    updateBoardState: (boardStates: Layout[]) =>
      update((state) => {
        state.layouts = boardStates.map((layout) =>
          layout.map(({ ch, side, rank, file }) => {
            const position = dimensions.pointToCoords(rank, file);
            return {
              side,
              ch,
              position,
              rank,
              file,
              prevPosition: position,
              grabbing: false,
            } as Point;
          }),
        );
        return state;
      }),
    transitionBoardState: (turnIndex: number) =>
      update((state) => {
        state.activeLayout = state.layouts[turnIndex];
        return state;
      }),
    dropPiece: (index: number, side: Side): boolean => {
      let movedFromPrev = false;

      update((state) => {
        state.activeLayout[index].grabbing = false;

        // BUG: movedFromPrev returning false when dropping pieces
        // that don't actually move after call to slidePiece

        // TODO: helper type + function for tuples
        // Track if piece was moved
        movedFromPrev =
          state.activeLayout[index].position[0] !==
            state.activeLayout[index].prevPosition[0] ||
          state.activeLayout[index].position[1] !==
            state.activeLayout[index].prevPosition[1];

        // Confirm drop by updating prevPosition
        if (isValidMove(side, state.turn) && movedFromPrev) {
          state.activeLayout[index].prevPosition =
            state.activeLayout[index].position;

          const { side, ch, position, prevPosition } = state.activeLayout[
            index
          ];
          const [rank, file] = dimensions.coordsToPoint(
            position[0],
            position[1],
          );
          state.moves = [
            ...state.moves,
            { side, ch, rank, file, position, prevPosition },
          ];
          state.turn = state.turn === RED ? BLACK : RED;
        } else {
          movedFromPrev = false;
          state.activeLayout[index].position =
            state.activeLayout[index].prevPosition;
        }
        console.log(state.moves);
        return state;
      });

      return movedFromPrev;
    },
    focusPiece: (index: number) => {
      update((state) => {
        const lastIndex = state.activeLayout.length - 1;
        [state.activeLayout[index], state.activeLayout[lastIndex]] = [
          state.activeLayout[lastIndex],
          state.activeLayout[index],
        ];
        return state;
      });
    },
    grabPiece: (index: number) => {
      update((state) => {
        state.activeLayout[index].grabbing = true;
        return state;
      });
    },
    movePiece: (index: number, position: [number, number]) => {
      update((state) => {
        state.activeLayout[index].position = position;
        return state;
      });
    },
    flipBoard: () => {
      update((state) => {
        state.facing = state.facing === RED ? BLACK : RED;
        return state;
      });
    },
  };
}
