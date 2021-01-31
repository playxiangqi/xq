import {
  TRAD_HORSE_RED,
  TRAD_CHARIOT_RED,
  TRAD_GUARD_RED,
  TRAD_SOLDIER_RED,
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
      },
      [CHARIOT]: {
        [RED]: TRAD_CHARIOT_RED,
      },
      [HORSE]: {
        [RED]: TRAD_HORSE_RED,
      },
      [SOLDIER]: {
        [RED]: TRAD_SOLDIER_RED,
      },
    },
  };

  return glyphs[style][ch][side] ?? '';
}
