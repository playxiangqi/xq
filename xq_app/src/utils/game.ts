import { Point } from 'components/board';

export type GameResult = 'Red Victory' | 'Draw' | 'Black Victory';

export type GameInfo = {
  redPlayer: string;
  blackPlayer: string;
  result: GameResult;
  event: string;
  date: string;
  openingCode: string;
  openingName: string;
  moves: string[];
};
