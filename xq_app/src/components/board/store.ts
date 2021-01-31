import { writable } from 'svelte/store';
import { RED, BLACK, Side, getGlyph, Glyph, GUARD } from './pieces';

export class Point {
  constructor(
    public readonly side: Side,
    public readonly file: number,
    public readonly rank: number,
    public readonly glyph: Glyph,
    public grabbed: boolean = false
  ) {}
}

export type BoardState = {
  layout: Point[];
};

const INITIAL_STATE: BoardState = {
  layout: [
    // new Point(BLACK, 0, 0, Chariot),
    // new Point(BLACK, 0, 1, Horse),
    // new Point(BLACK, 0, 2, Elephant),
    // new Point(BLACK, 0, 3, getGlyph(BLACK, GUARD)),
    // new Point(BLACK, 0, 4, General),
    // new Point(BLACK, 0, 5, Guard),
    // new Point(BLACK, 0, 6, Elephant),
    // new Point(BLACK, 0, 7, Horse),
    // new Point(BLACK, 0, 8, Chariot),
    // new Point(BLACK, 2, 1, Cannon),
    // new Point(BLACK, 2, 7, Cannon),
    // new Point(BLACK, 3, 0, Soldier),
    // new Point(BLACK, 3, 2, Soldier),
    // new Point(BLACK, 3, 4, Soldier),
    // new Point(BLACK, 3, 6, Soldier),
    // new Point(BLACK, 3, 8, Soldier),
    // new Point(RED, 6, 0, Soldier),
    // new Point(RED, 6, 2, Soldier),
    // new Point(RED, 6, 4, Soldier),
    // new Point(RED, 6, 6, Soldier),
    // new Point(RED, 6, 8, Soldier),
    // new Point(RED, 7, 1, Cannon),
    // new Point(RED, 7, 7, Cannon),
    // new Point(RED, 9, 0, Chariot),
    // new Point(RED, 9, 1, Horse),
    // new Point(RED, 9, 2, Elephant),
    new Point(RED, 9, 3, getGlyph(RED, GUARD)),
    // new Point(RED, 9, 4, General),
    // new Point(RED, 9, 5, Guard),
    // new Point(RED, 9, 6, Elephant),
    // new Point(RED, 9, 7, Horse),
    // new Point(RED, 9, 8, Chariot),
  ],
};

export const store = writable(INITIAL_STATE);
