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
    dropPiece: (index: number) => {
      store.update((state) => {
        state.layout[index].grabbing = false;
        return state;
      });
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
