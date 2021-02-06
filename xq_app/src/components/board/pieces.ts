import { Dimensions, FILE_MAX } from './dimensions';
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

// Piece
export const RED = 'red';
export const BLACK = 'black';
export type Side = typeof RED | typeof BLACK;

export const CHARIOT = 'chariot';
export const HORSE = 'horse';
export const ELEPHANT = 'elephant';
export const ADVISOR = 'guard';
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

export const toHanzi: { [ch: string]: { [side: string]: string } } = {
  chariot: { red: '俥', black: '車' },
  cannon: { red: '炮', black: '砲' },
  elephant: { red: '相', black: '象' },
  general: { red: '帥', black: '將' },
  guard: { red: '仕', black: '士' },
  horse: { red: '傌', black: '馬' },
  soldier: { red: '', black: '' },
};

export type Point = {
  side: Side;
  ch: Character;
  rank: number;
  file: number;
  position: [number, number];
  prevPosition: [number, number];
  grabbing: boolean;
};

export type Move = Omit<Point, 'grabbing'>;

// TODO: eventually load as parseFEN
export function createInitialLayout(dimensions: Dimensions): Point[] {
  const layout: [Side, Character, number, number][] = [
    [BLACK, CHARIOT, 0, 0],
    [BLACK, HORSE, 0, 1],
    [BLACK, ELEPHANT, 0, 2],
    [BLACK, ADVISOR, 0, 3],
    [BLACK, GENERAL, 0, 4],
    [BLACK, ADVISOR, 0, 5],
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
    [RED, ADVISOR, 9, 3],
    [RED, GENERAL, 9, 4],
    [RED, ADVISOR, 9, 5],
    [RED, ELEPHANT, 9, 6],
    [RED, HORSE, 9, 7],
    [RED, CHARIOT, 9, 8],
  ];

  return layout.map(([side, ch, rank, file]) => {
    const position = dimensions.pointToCoords(rank, file);
    return {
      side,
      ch,
      position,
      rank,
      file,
      prevPosition: position,
      grabbing: false,
    } as Point;
  });
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

export function notationToMove(notation: string) {
  const sideFacing = RED;

  // 'A4+5'
  const letterToPiece: {
    [ch: string]: {
      ch: Character;
      side: Side;
      range: (diffFile: number) => number;
    };
  } = {
    A: { ch: ADVISOR, side: RED, range: () => 1 },
    p: { ch: SOLDIER, side: BLACK, range: () => 1 },
    // B: { ch: ELEPHANT, side: RED, range: 2 },
    // b: { ch: ELEPHANT, side: BLACK, range: 2 },
    // N: { ch: HORSE, side: RED, range: 2 }, // TODO: can be 1 or 2 depending on file diff
    // n: { ch: HORSE, side: BLACK, range: 2 },
  };

  const calcAbsoluteFile = (relativeFile: number, side: Side) => {
    const resolvedFile = side === sideFacing ? 10 - relativeFile : relativeFile;
    return resolvedFile - 1;
  };

  const matches = /([a-z])([0-9])([+=])([0-9])/gi.exec(notation);
  const ch = matches?.[1] ?? '';
  const piece = letterToPiece[ch];
  const rawFile = Number(matches?.[2]) ?? 0;
  const absoluteFile = calcAbsoluteFile(rawFile, piece.side);
  const rawNewFile = Number(matches?.[4]) ?? 0;
  const absoluteNewFile = calcAbsoluteFile(rawNewFile, piece.side);
  const rawSign = matches?.[3] === '+' ? 1 : -1;
  const absoluteSign = piece.side === sideFacing ? -rawSign : rawSign;
  const diffRank = absoluteSign * piece.range(absoluteNewFile - absoluteFile);
  console.log('file', absoluteFile);
  console.log('newFile', absoluteNewFile);
  console.log('diffRank', diffRank);
  return {
    ...piece,
    file: absoluteFile,
    newFile: absoluteNewFile,
    diffRank,
  };
}
