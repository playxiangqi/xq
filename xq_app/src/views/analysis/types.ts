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
  best_move: string;
  results: {
    lines: EngineMove[];
    metadata: EngineMetadata;
  }[];
};
