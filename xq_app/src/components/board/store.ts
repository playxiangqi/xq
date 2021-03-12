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

// TODO: Need consistent naming on both Frontend/Backend with respect to
//       the following terminologies:
// * board / state / board state
// * point / piece
// * board state / layout
// * move / turn / transition
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

  const loadBoardState = (layoutWithTrans: LayoutWithTransitions[]) =>
    update((state) => {
      const np = newPoint(dimensions, state.facing !== RED);
      return {
        ...state,
        layouts: layoutWithTrans.map(({ state: s }) => s.map(np)),
        transitions: layoutWithTrans.map(({ prevPoint, nextPoint }) => ({
          prevPoint: prevPoint && np(prevPoint),
          nextPoint: nextPoint && np(nextPoint),
        })),
      };
    });

  const transitionBoardState = (turnIndex: number) =>
    update(({ activeLayout, activeTransition, ...state }) => ({
      ...state,
      activeLayout: state.layouts[turnIndex],
      activeTransition: state.transitions[turnIndex],
    }));

  const dropPiece = (index: number, side: Side): boolean => {
    let movedFromPrev = false;

    update(({ activeLayout, ...state }) => {
      activeLayout[index].grabbing = false;

      // Track if piece was moved
      movedFromPrev = !Enum.strictEquals(
        activeLayout[index].position,
        activeLayout[index].prevPosition,
      );

      // Confirm drop by updating prevPosition
      if (isValidMove(side, state.turn) && movedFromPrev) {
        // Update position
        activeLayout[index].prevPosition = activeLayout[index].position;

        const { side, ch, position, prevPosition } = activeLayout[index];
        const [rank, file] = dimensions.coordsToPoint(position[0], position[1]);
        state.moves = [
          ...state.moves,
          { side, ch, rank, file, position, prevPosition },
        ];
        state.turn = state.turn === RED ? BLACK : RED;
      } else {
        movedFromPrev = false;

        // Return to previous position
        activeLayout[index].position = activeLayout[index].prevPosition;
      }
      return { ...state, activeLayout };
    });

    return movedFromPrev;
  };

  const focusPiece = (index: number) =>
    update((state) => {
      const lastIndex = state.activeLayout.length - 1;
      [state.activeLayout[index], state.activeLayout[lastIndex]] = [
        state.activeLayout[lastIndex],
        state.activeLayout[index],
      ];
      return state;
    });

  const grabPiece = (index: number) =>
    update((state) => {
      state.activeLayout[index].grabbing = true;
      return state;
    });

  const movePiece = (index: number, position: [number, number]) =>
    update((state) => {
      state.activeLayout[index].position = position;
      return state;
    });

  const flipBoard = () =>
    update(({ activeTransition, transitions, ...state }) => {
      const invertPoint = newPoint(dimensions, true);

      return {
        ...state,
        facing: state.facing === RED ? BLACK : RED,
        layouts: state.layouts.map((l) => l.map(invertPoint)),
        activeLayout: state.activeLayout.map(invertPoint),
        activeTransition: {
          prevPoint:
            activeTransition.prevPoint &&
            invertPoint(activeTransition.prevPoint),
          nextPoint:
            activeTransition.nextPoint &&
            invertPoint(activeTransition.nextPoint),
        },
        transitions: transitions.map(({ prevPoint, nextPoint }) => ({
          prevPoint: prevPoint && invertPoint(prevPoint),
          nextPoint: nextPoint && invertPoint(nextPoint),
        })),
      };
    });

  return {
    store,
    loadBoardState,
    transitionBoardState,
    dropPiece,
    focusPiece,
    grabPiece,
    movePiece,
    flipBoard,
  };
}
