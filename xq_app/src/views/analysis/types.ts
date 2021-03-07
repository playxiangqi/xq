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

export type EngineResults = {
  best_move: string;
  results: {
    lines: [string, string | undefined][];
    metadata: EngineMetadata;
  }[];
};
