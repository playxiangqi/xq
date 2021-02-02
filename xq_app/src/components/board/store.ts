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
  };
}

// export function movePiece(
//   index: number,
//   point: readonly [number, number],
//   coords?: [number, number]
// ) {
//   console.log('we here boyz');
//   console.log(point);
//   console.log(coords);
//   store.update((state) => {
//     const [rank, file] = point;
//     state.layout[index].rank = rank;
//     state.layout[index].file = file;
//     state.layout[index].position = coords;
//     return state;
//   });
// }

// export function dropPiece(index: number) {
//   store.update((state) => {
//     state.layout[index].grabbing = false;
//     return state;
//   });
// }
