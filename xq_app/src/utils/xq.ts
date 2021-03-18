import { FILE_MAX, RANK_MAX } from '@xq/utils/dimensions';
import type { Dimensions } from '@xq/utils/dimensions';

export const RED = 'red';
export const BLACK = 'black';
export type Side = typeof RED | typeof BLACK;

export const CHARIOT = 'chariot';
export const HORSE = 'horse';
export const ELEPHANT = 'elephant';
export const ADVISOR = 'advisor';
export const GENERAL = 'general';
export const CANNON = 'cannon';
export const SOLDIER = 'soldier';
export type Character =
  | typeof CHARIOT
  | typeof HORSE
  | typeof ELEPHANT
  | typeof ADVISOR
  | typeof GENERAL
  | typeof CANNON
  | typeof SOLDIER;

export type Point = {
  side: Side;
  ch: Character;
  rank: number;
  file: number;
};

export interface CartesianPoint extends Point {
  position: [number, number];
  prevPosition?: [number, number];
}

export type Transition<T extends Point> = {
  prevPoint?: T;
  nextPoint?: T;
};

export type Layout<T extends Point> = { points: T[] } & Transition<T>;

export const DEFAULT_POINTS: Point[] = [
  { side: BLACK, ch: CHARIOT, rank: 0, file: 0 },
  { side: BLACK, ch: HORSE, rank: 0, file: 1 },
  { side: BLACK, ch: ELEPHANT, rank: 0, file: 2 },
  { side: BLACK, ch: ADVISOR, rank: 0, file: 3 },
  { side: BLACK, ch: GENERAL, rank: 0, file: 4 },
  { side: BLACK, ch: ADVISOR, rank: 0, file: 5 },
  { side: BLACK, ch: ELEPHANT, rank: 0, file: 6 },
  { side: BLACK, ch: HORSE, rank: 0, file: 7 },
  { side: BLACK, ch: CHARIOT, rank: 0, file: 8 },
  { side: BLACK, ch: CANNON, rank: 2, file: 1 },
  { side: BLACK, ch: CANNON, rank: 2, file: 7 },
  { side: BLACK, ch: SOLDIER, rank: 3, file: 0 },
  { side: BLACK, ch: SOLDIER, rank: 3, file: 2 },
  { side: BLACK, ch: SOLDIER, rank: 3, file: 4 },
  { side: BLACK, ch: SOLDIER, rank: 3, file: 6 },
  { side: BLACK, ch: SOLDIER, rank: 3, file: 8 },
  { side: RED, ch: SOLDIER, rank: 6, file: 0 },
  { side: RED, ch: SOLDIER, rank: 6, file: 2 },
  { side: RED, ch: SOLDIER, rank: 6, file: 4 },
  { side: RED, ch: SOLDIER, rank: 6, file: 6 },
  { side: RED, ch: SOLDIER, rank: 6, file: 8 },
  { side: RED, ch: CANNON, rank: 7, file: 1 },
  { side: RED, ch: CANNON, rank: 7, file: 7 },
  { side: RED, ch: CHARIOT, rank: 9, file: 0 },
  { side: RED, ch: HORSE, rank: 9, file: 1 },
  { side: RED, ch: ELEPHANT, rank: 9, file: 2 },
  { side: RED, ch: ADVISOR, rank: 9, file: 3 },
  { side: RED, ch: GENERAL, rank: 9, file: 4 },
  { side: RED, ch: ADVISOR, rank: 9, file: 5 },
  { side: RED, ch: ELEPHANT, rank: 9, file: 6 },
  { side: RED, ch: HORSE, rank: 9, file: 7 },
  { side: RED, ch: CHARIOT, rank: 9, file: 8 },
];

export function enrichPoint(
  point: Point,
  dimensions: Dimensions,
  shouldInvert = false,
): CartesianPoint {
  const newPoint = invert(point, shouldInvert);
  return {
    ...newPoint,
    position: dimensions.pointToCoords(newPoint.rank, newPoint.file),
  } as CartesianPoint;
}

export function invert(point: Point, shouldInvert: boolean): Point {
  const [rank, file] = shouldInvert
    ? [RANK_MAX - point.rank, FILE_MAX - point.file]
    : [point.rank, point.file];
  return { ...point, rank, file };
}
