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
} from './pieces';

export class Point {
  constructor(
    public readonly side: Side,
    public readonly rank: number,
    public readonly file: number,
    public readonly glyph: Glyph,
    public grabbing: boolean = false
  ) {}
}

export type BoardState = {
  layout: Point[];
};

const INITIAL_STATE: BoardState = {
  layout: [
    new Point(BLACK, 0, 0, getGlyph(BLACK, CHARIOT)),
    new Point(BLACK, 0, 1, getGlyph(BLACK, HORSE)),
    new Point(BLACK, 0, 2, getGlyph(BLACK, ELEPHANT)),
    new Point(BLACK, 0, 3, getGlyph(BLACK, GUARD)),
    new Point(BLACK, 0, 4, getGlyph(BLACK, GENERAL)),
    new Point(BLACK, 0, 5, getGlyph(BLACK, GUARD)),
    new Point(BLACK, 0, 6, getGlyph(BLACK, ELEPHANT)),
    new Point(BLACK, 0, 7, getGlyph(BLACK, HORSE)),
    new Point(BLACK, 0, 8, getGlyph(BLACK, CHARIOT)),
    new Point(BLACK, 2, 1, getGlyph(BLACK, CANNON)),
    new Point(BLACK, 2, 7, getGlyph(BLACK, CANNON)),
    new Point(BLACK, 3, 0, getGlyph(BLACK, SOLDIER)),
    new Point(BLACK, 3, 2, getGlyph(BLACK, SOLDIER)),
    new Point(BLACK, 3, 4, getGlyph(BLACK, SOLDIER)),
    new Point(BLACK, 3, 6, getGlyph(BLACK, SOLDIER)),
    new Point(BLACK, 3, 8, getGlyph(BLACK, SOLDIER)),
    new Point(RED, 6, 0, getGlyph(RED, SOLDIER)),
    new Point(RED, 6, 2, getGlyph(RED, SOLDIER)),
    new Point(RED, 6, 4, getGlyph(RED, SOLDIER)),
    new Point(RED, 6, 6, getGlyph(RED, SOLDIER)),
    new Point(RED, 6, 8, getGlyph(RED, SOLDIER)),
    new Point(RED, 7, 1, getGlyph(RED, CANNON)),
    new Point(RED, 7, 7, getGlyph(RED, CANNON)),
    new Point(RED, 9, 0, getGlyph(RED, CHARIOT)),
    new Point(RED, 9, 1, getGlyph(RED, HORSE)),
    new Point(RED, 9, 2, getGlyph(RED, ELEPHANT)),
    new Point(RED, 9, 3, getGlyph(RED, GUARD)),
    new Point(RED, 9, 4, getGlyph(RED, GENERAL)),
    new Point(RED, 9, 5, getGlyph(RED, GUARD)),
    new Point(RED, 9, 6, getGlyph(RED, ELEPHANT)),
    new Point(RED, 9, 7, getGlyph(RED, HORSE)),
    new Point(RED, 9, 8, getGlyph(RED, CHARIOT)),
  ],
};

export const store = writable(INITIAL_STATE);
