export type GameResult = 'Red Victory' | 'Draw' | 'Black Victory';

export type GameInfo = {
  id: number;
  redPlayer: string;
  blackPlayer: string;
  result: GameResult;
  event: string;
  date: string;
  openingCode: string;
  openingName: string;
  moves: string[];
};

export type Opening = {
  id: string;
  name: string;
};
