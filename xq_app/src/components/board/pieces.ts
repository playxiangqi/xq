import {
  RED,
  BLACK,
  ADVISOR,
  CANNON,
  CHARIOT,
  GENERAL,
  ELEPHANT,
  HORSE,
  SOLDIER,
} from '@xq/utils/xq';
import type { Side, Character } from '@xq/utils/xq';
import {
  TRAD_HORSE_RED,
  TRAD_CHARIOT_RED,
  TRAD_ADVISOR_RED,
  TRAD_SOLDIER_RED,
  TRAD_CANNON_RED,
  TRAD_ELEPHANT_RED,
  TRAD_GENERAL_RED,
  TRAD_SOLDIER_BLACK,
  TRAD_ADVISOR_BLACK,
  TRAD_CANNON_BLACK,
  TRAD_ELEPHANT_BLACK,
  TRAD_CHARIOT_BLACK,
  TRAD_HORSE_BLACK,
  TRAD_GENERAL_BLACK,
} from './glyphs';

export const toHanzi: { [letter: string]: string } = {
  A: '仕',
  a: '士',
  R: '俥',
  r: '車',
  C: '炮',
  c: '砲',
  B: '相',
  b: '象',
  K: '帥',
  k: '將',
  N: '傌',
  n: '馬',
  P: '',
  p: '',
};

// Glyph
export const TRADITIONAL = 'traditional';
export type GlyphStyle = typeof TRADITIONAL;
export type Glyph = string;

export function getGlyph(
  side: Side,
  ch: Character,
  style: GlyphStyle = TRADITIONAL,
): Glyph {
  const glyphs: {
    [style: string]: {
      [ch: string]: {
        [side: string]: Glyph;
      };
    };
  } = {
    [TRADITIONAL]: {
      [ADVISOR]: {
        [RED]: TRAD_ADVISOR_RED,
        [BLACK]: TRAD_ADVISOR_BLACK,
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
