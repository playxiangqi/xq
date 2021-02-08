import { writable } from 'svelte/store';
import { apiClient } from 'services';
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

type Layout = Point[];

// TODO: AnalysisState which contains/extends a BoardState
export type BoardState = {
  activeLayout: Layout;
  layouts: Layout[];
  moves: Move[];
  turn: Side;
};

async function fetchGameAnalysis(): Promise<{
  boardStates: Layout[];
  gameInfo: any;
}> {
  const { data } = await apiClient.get('/api/analysis/game');
  console.log(data);
  return data;
}

export function createBoardState(dimensions: Dimensions) {
  const activeLayout = createInitialLayout(dimensions);

  const store = writable<BoardState>({
    activeLayout,
    layouts: [activeLayout],
    moves: [],
    turn: RED,
  });
  const { update } = store;

  const isValidMove = (movingSide: Side, turn: Side) => {
    return movingSide === turn;
  };

  return {
    store,
    loadGameAnalysis: async () => {
      const { boardStates, gameInfo } = await fetchGameAnalysis();
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
          })
        );
        return state;
      });
      return gameInfo;
    },
    transitionBoardState: (turnIndex: number) =>
      update((state) => {
        state.activeLayout = state.layouts[turnIndex];
        console.log('activeLayout:', state.activeLayout);
        console.log('turnIndex:', turnIndex);
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
            position[1]
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
    slidePiece: (move: {
      ch: Character;
      side: Side;
      file?: number;
      newFile: number;
      diffRank: number;
      isFront: boolean;
    }) => {
      update((state) => {
        // movePiece/dropPiece combined, but set by specific rank/file
        // TODO: use flatmap of indices to index front/rear (default 0/front when only a single piece)
        const pieces = state.activeLayout
          .filter((v) => v.ch === move.ch && v.side === move.side)
          .filter((v) => (move.file != null ? v.file === move.file : true))
          .sort((a, b) =>
            move.side === RED ? a.rank - b.rank : b.rank - a.rank
          );

        let piece = move.isFront ? pieces[0] : pieces[1];

        const index = state.activeLayout.indexOf(piece);
        const computedRank = piece.rank + move.diffRank;
        const computedFile = move.newFile;

        console.log('computedRank', computedRank);
        console.log('computedFile', move.newFile);

        const newPoint = [computedRank, computedFile];
        console.log('newPoint:', newPoint);
        state.activeLayout[index].rank = newPoint[0];
        state.activeLayout[index].file = newPoint[1];
        state.activeLayout[index].prevPosition =
          state.activeLayout[index].position;
        const [newY, newX] = dimensions.pointToCoords(newPoint[0], newPoint[1]);
        console.log('newPosition:', [newY, newX]);
        state.activeLayout[index].position = [newY, newX];

        // Potential capture
        state.activeLayout = state.activeLayout.filter(
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
