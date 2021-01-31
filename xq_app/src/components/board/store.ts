import { writable } from 'svelte/store';
import {
  RED,
  BLACK,
  Side,
  getGlyph,
  Glyph,
  GUARD,
  CHARIOT,
  HORSE,
  SOLDIER,
  CANNON,
  ELEPHANT,
  GENERAL,
  Character,
} from './pieces';

export class Point {
  constructor(
    public readonly side: Side,
    public readonly rank: number,
    public readonly file: number,
    public readonly ch: Character,
    public readonly glyph: Glyph = getGlyph(side, ch),
    public grabbing: boolean = false
  ) {}
}

export type BoardState = {
  layout: Point[];
};

const INITIAL_STATE: BoardState = {
  layout: [
    new Point(BLACK, 0, 0, CHARIOT),
    new Point(BLACK, 0, 1, HORSE),
    new Point(BLACK, 0, 2, ELEPHANT),
    new Point(BLACK, 0, 3, GUARD),
    new Point(BLACK, 0, 4, GENERAL),
    new Point(BLACK, 0, 5, GUARD),
    new Point(BLACK, 0, 6, ELEPHANT),
    new Point(BLACK, 0, 7, HORSE),
    new Point(BLACK, 0, 8, CHARIOT),
    new Point(BLACK, 2, 1, CANNON),
    new Point(BLACK, 2, 7, CANNON),
    new Point(BLACK, 3, 0, SOLDIER),
    new Point(BLACK, 3, 2, SOLDIER),
    new Point(BLACK, 3, 4, SOLDIER),
    new Point(BLACK, 3, 6, SOLDIER),
    new Point(BLACK, 3, 8, SOLDIER),
    new Point(RED, 6, 0, SOLDIER),
    new Point(RED, 6, 2, SOLDIER),
    new Point(RED, 6, 4, SOLDIER),
    new Point(RED, 6, 6, SOLDIER),
    new Point(RED, 6, 8, SOLDIER),
    new Point(RED, 7, 1, CANNON),
    new Point(RED, 7, 7, CANNON),
    new Point(RED, 9, 0, CHARIOT),
    new Point(RED, 9, 1, HORSE),
    new Point(RED, 9, 2, ELEPHANT),
    new Point(RED, 9, 3, GUARD),
    new Point(RED, 9, 4, GENERAL),
    new Point(RED, 9, 5, GUARD),
    new Point(RED, 9, 6, ELEPHANT),
    new Point(RED, 9, 7, HORSE),
    new Point(RED, 9, 8, CHARIOT),
  ],
};

export const store = writable(INITIAL_STATE);
