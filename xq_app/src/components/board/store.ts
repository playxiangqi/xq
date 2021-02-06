import { writable } from 'svelte/store';
import { Dimensions } from './dimensions';
import {
  createInitialLayout,
  Move,
  Point,
  Side,
  RED,
  BLACK,
  Character,
} from './pieces';

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

        // BUG: movedFromPrev returning false when dropping pieces
        // that don't actually move after call to slidePiece

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
          const [rank, file] = dimensions.coordsToPoint(
            position[0],
            position[1]
          );
          state.moves = [
            ...state.moves,
            { side, ch, rank, file, position, prevPosition },
          ];
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
    slidePiece: (move: {
      ch: Character;
      side: Side;
      file?: number;
      newFile: number;
      diffRank: number;
      isFront: boolean;
    }) => {
      store.update((state) => {
        // movePiece/dropPiece combined, but set by specific rank/file
        // TODO: use flatmap of indices to index front/rear (default 0/front when only a single piece)
        const pieces = state.layout
          .filter((v) => v.ch === move.ch && v.side === move.side)
          .filter((v) => (move.file != null ? v.file === move.file : true))
          .sort((a, b) =>
            move.side === RED ? a.rank - b.rank : b.rank - a.rank
          );

        let piece = move.isFront ? pieces[0] : pieces[1];

        const index = state.layout.indexOf(piece);
        const computedRank = piece.rank + move.diffRank;
        const computedFile = move.newFile;

        console.log('computedRank', computedRank);
        console.log('computedFile', move.newFile);

        const newPoint = [computedRank, computedFile];
        console.log('newPoint:', newPoint);
        state.layout[index].rank = newPoint[0];
        state.layout[index].file = newPoint[1];
        state.layout[index].prevPosition = state.layout[index].position;
        const [newY, newX] = dimensions.pointToCoords(newPoint[0], newPoint[1]);
        console.log('newPosition:', [newY, newX]);
        state.layout[index].position = [newY, newX];

        // Potential capture
        state.layout = state.layout.filter(
          (v) =>
            !(
              v.side !== move.side &&
              v.file === computedFile &&
              v.rank === computedRank
            )
        );
        return state;
      });
    },
  };
}
