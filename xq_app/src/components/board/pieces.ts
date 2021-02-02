import { Dimensions } from './dimensions';
import {
  TRAD_HORSE_RED,
  TRAD_CHARIOT_RED,
  TRAD_GUARD_RED,
  TRAD_SOLDIER_RED,
  TRAD_CANNON_RED,
  TRAD_ELEPHANT_RED,
  TRAD_GENERAL_RED,
  TRAD_SOLDIER_BLACK,
  TRAD_GUARD_BLACK,
  TRAD_CANNON_BLACK,
  TRAD_ELEPHANT_BLACK,
  TRAD_CHARIOT_BLACK,
  TRAD_HORSE_BLACK,
  TRAD_GENERAL_BLACK,
} from './glyphs';

// Piece
export const RED = 'red';
export const BLACK = 'black';
export type Side = typeof RED | typeof BLACK;

export const CHARIOT = 'chariot';
export const HORSE = 'horse';
export const ELEPHANT = 'elephant';
export const GUARD = 'guard';
export const GENERAL = 'general';
export const CANNON = 'cannon';
export const SOLDIER = 'soldier';
export type Character =
  | typeof CHARIOT
  | typeof HORSE
  | typeof ELEPHANT
  | typeof GUARD
  | typeof GENERAL
  | typeof CANNON
  | typeof SOLDIER;

export type Point = {
  side: Side;
  ch: Character;
  rank: number;
  file: number;
  position: [number, number];
  grabbing: boolean;
};

export function createInitialLayout(dimensions: Dimensions): Point[] {
  const layout: [Side, Character, number, number][] = [
    [BLACK, CHARIOT, 0, 0],
    [BLACK, HORSE, 0, 1],
    [BLACK, ELEPHANT, 0, 2],
    [BLACK, GUARD, 0, 3],
    [BLACK, GENERAL, 0, 4],
    [BLACK, GUARD, 0, 5],
    [BLACK, ELEPHANT, 0, 6],
    [BLACK, HORSE, 0, 7],
    [BLACK, CHARIOT, 0, 8],
    [BLACK, CANNON, 2, 1],
    [BLACK, CANNON, 2, 7],
    [BLACK, SOLDIER, 3, 0],
    [BLACK, SOLDIER, 3, 2],
    [BLACK, SOLDIER, 3, 4],
    [BLACK, SOLDIER, 3, 6],
    [BLACK, SOLDIER, 3, 8],
    [RED, SOLDIER, 6, 0],
    [RED, SOLDIER, 6, 2],
    [RED, SOLDIER, 6, 4],
    [RED, SOLDIER, 6, 6],
    [RED, SOLDIER, 6, 8],
    [RED, CANNON, 7, 1],
    [RED, CANNON, 7, 7],
    [RED, CHARIOT, 9, 0],
    [RED, HORSE, 9, 1],
    [RED, ELEPHANT, 9, 2],
    [RED, GUARD, 9, 3],
    [RED, GENERAL, 9, 4],
    [RED, GUARD, 9, 5],
    [RED, ELEPHANT, 9, 6],
    [RED, HORSE, 9, 7],
    [RED, CHARIOT, 9, 8],
  ];

  return layout.map(
    ([side, ch, rank, file]) =>
      ({
        side,
        ch,
        rank,
        file,
        position: dimensions.pointToCoords(rank, file),
        grabbing: false,
      } as Point)
  );
}

// Glyph
export const TRADITIONAL = 'traditional';
export type GlyphStyle = typeof TRADITIONAL;
export type Glyph = string;

export function getGlyph(
  side: Side,
  ch: Character,
  style: GlyphStyle = TRADITIONAL
): Glyph {
  const glyphs: {
    [style: string]: {
      [ch: string]: {
        [side: string]: Glyph;
      };
    };
  } = {
    [TRADITIONAL]: {
      [GUARD]: {
        [RED]: TRAD_GUARD_RED,
        [BLACK]: TRAD_GUARD_BLACK,
      },
      [CHARIOT]: {
        [RED]: TRAD_CHARIOT_RED,
        [BLACK]: TRAD_CHARIOT_BLACK,
      },
      [HORSE]: {
        [RED]: TRAD_HORSE_RED,
        [BLACK]: TRAD_HORSE_BLACK,
      },
      [SOLDIER]: {
        [RED]: TRAD_SOLDIER_RED,
        [BLACK]: TRAD_SOLDIER_BLACK,
      },
      [CANNON]: {
        [RED]: TRAD_CANNON_RED,
        [BLACK]: TRAD_CANNON_BLACK,
      },
      [ELEPHANT]: {
        [RED]: TRAD_ELEPHANT_RED,
        [BLACK]: TRAD_ELEPHANT_BLACK,
      },
      [GENERAL]: {
        [RED]: TRAD_GENERAL_RED,
        [BLACK]: TRAD_GENERAL_BLACK,
      },
    },
  };

  return glyphs[style][ch][side] ?? '';
}
