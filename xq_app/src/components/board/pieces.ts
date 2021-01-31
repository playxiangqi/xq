import { GUARD_RED } from './glyphs/traditional';

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
  switch (style) {
    case TRADITIONAL:
      switch (ch) {
        case GUARD:
          return side === RED ? GUARD_RED : GUARD_RED;
      }
  }
  return '';
}
