import { writable } from 'svelte/store';
import Enum from 'utils/enum';
import { Dimensions } from './dimensions';
import {
  newPoint,
  createInitialLayout,
  Move,
  Point,
  Side,
  RED,
  BLACK,
} from './pieces';

export type Layout = Point[];

export type Transition = {
  prevPoint?: Point;
  nextPoint?: Point;
};

export type LayoutWithTransitions = {
  state: Layout;
} & Transition;

// TODO: AnalysisState which contains/extends a BoardState
export type BoardState = {
  activeLayout: Layout;
  layouts: Layout[];
  activeTransition: Transition;
  transitions: Transition[];
  moves: Move[];
  turn: Side;
  facing: Side;
};

const isValidMove = (movingSide: Side, turn: Side) => {
  return movingSide === turn;
};

export function createBoardState(dimensions: Dimensions) {
  const activeLayout = createInitialLayout(dimensions);

  const store = writable<BoardState>({
    activeLayout,
    layouts: [activeLayout],
    activeTransition: {},
    transitions: [{}],
    moves: [],
    turn: RED,
    facing: RED,
  });
  const { update } = store;

  const flipBoard = () =>
    update(
      ({
        facing,
        layouts,
        activeLayout,
        activeTransition,
        transitions,
        ...state
      }) => {
        // TODO: Horrendous code that needs to be cleaned up
        const invertPoint = newPoint(dimensions, true);

        activeTransition = {
          prevPoint: activeTransition.prevPoint
            ? invertPoint(activeTransition.prevPoint)
            : activeTransition.prevPoint,
          nextPoint: activeTransition.nextPoint
            ? invertPoint(activeTransition.nextPoint)
            : activeTransition.nextPoint,
        };
        transitions = transitions.map(({ prevPoint, nextPoint }) => ({
          prevPoint: prevPoint ? invertPoint(prevPoint) : prevPoint,
          nextPoint: nextPoint ? invertPoint(nextPoint) : nextPoint,
        }));
        return {
          ...state,
          facing: facing === RED ? BLACK : RED,
          layouts: layouts.map((l) => l.map(invertPoint)),
          activeLayout: activeLayout.map(invertPoint),
          activeTransition,
          transitions,
        };
      },
    );

  return {
    store,
    loadBoardState: (layoutWithTrans: LayoutWithTransitions[]) =>
      update((state) => {
        const np = newPoint(dimensions, state.facing !== RED);

        state.layouts = layoutWithTrans.map(({ state: s }) => s.map(np));
        state.transitions = layoutWithTrans.map(({ prevPoint, nextPoint }) => ({
          prevPoint: prevPoint ? np(prevPoint) : prevPoint,
          nextPoint: nextPoint ? np(nextPoint) : nextPoint,
        }));
        return state;
      }),
    transitionBoardState: (turnIndex: number) =>
      update((state) => {
        state.activeLayout = state.layouts[turnIndex];
        state.activeTransition = state.transitions[turnIndex];
        return state;
      }),
    dropPiece: (index: number, side: Side): boolean => {
      let movedFromPrev = false;

      update((state) => {
        state.activeLayout[index].grabbing = false;

        // BUG: movedFromPrev returning false when dropping pieces
        // that don't actually move after call to slidePiece

        // Track if piece was moved
        movedFromPrev = !Enum.strictEquals(
          state.activeLayout[index].position,
          state.activeLayout[index].prevPosition,
        );

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
    flipBoard,
  };
}
