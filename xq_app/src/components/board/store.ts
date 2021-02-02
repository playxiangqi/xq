import { writable } from 'svelte/store';
import { Dimensions } from './dimensions';
import { createInitialLayout, Point } from './pieces';

export type BoardState = {
  layout: Point[];
};

export function createBoardState(dimensions: Dimensions) {
  const layout = createInitialLayout(dimensions);
  const store = writable<BoardState>({ layout });

  return {
    store,
    dropPiece: (index: number): boolean => {
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
        // TODO: do the reverse of this assignment if not a valid move
        state.layout[index].prevPosition = state.layout[index].position;
        return state;
      });

      // TODO: to be AND'd with isValidMove and if invalid, for the position
      //       to be updated BACK to previous
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
