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
  turnCount: number;
};

export type Opening = {
  id: string;
  name: string;
};

export type EngineMetadata = {
  depth: number;
  hashfull: number;
  multipv: number;
  nodes: number;
  nps: number;
  scorecp: number;
  seldepth: number;
  tbhits: number;
  time: number;
};

export type EngineMove = readonly [string, string | undefined];

export type EngineResults = {
  best_move: string[];
  results: {
    lines: EngineMove[];
    metadata: EngineMetadata;
  }[];
};
