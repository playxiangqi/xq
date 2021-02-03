import { writable } from 'svelte/store';
import { Dimensions } from './dimensions';
import { createInitialLayout, Move, Point, Side, RED, BLACK } from './pieces';

export type BoardState = {
  layout: Point[];
  moves: Move[];
  turn: Side;
};

export function createBoardState(dimensions: Dimensions) {
  const layout = createInitialLayout(dimensions);
  const store = writable<BoardState>({ layout, moves: [], turn: RED });

  const isValidMove = (movingSide: Side, turn: Side) => {
    return movingSide === turn;
  };

  return {
    store,
    dropPiece: (index: number, side: Side): boolean => {
      let movedFromPrev = false;

      store.update((state) => {
        state.layout[index].grabbing = false;

        // TODO: helper type + function for tuples
        // Track if piece was moved
        movedFromPrev =
          state.layout[index].position[0] !==
            state.layout[index].prevPosition[0] ||
          state.layout[index].position[1] !==
            state.layout[index].prevPosition[1];

        // Confirm drop by updating prevPosition
        if (isValidMove(side, state.turn) && movedFromPrev) {
          state.layout[index].prevPosition = state.layout[index].position;

          const { side, ch, position, prevPosition } = state.layout[index];
          state.moves = [...state.moves, { side, ch, position, prevPosition }];
          state.turn = state.turn === RED ? BLACK : RED;
        } else {
          movedFromPrev = false;
          state.layout[index].position = state.layout[index].prevPosition;
        }
        console.log(state.moves);
        return state;
      });

      return movedFromPrev;
    },
    focusPiece: (index: number) => {
      store.update((state) => {
        const lastIndex = state.layout.length - 1;
        [state.layout[index], state.layout[lastIndex]] = [
          state.layout[lastIndex],
          state.layout[index],
        ];
        return state;
      });
    },
    grabPiece: (index: number) => {
      store.update((state) => {
        state.layout[index].grabbing = true;
        return state;
      });
    },
    movePiece: (index: number, position: [number, number]) => {
      store.update((state) => {
        state.layout[index].position = position;
        return state;
      });
    },
  };
}
