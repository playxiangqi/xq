<script context="module" lang="ts">
  import { writable } from 'svelte/store';
  import type { Readable } from 'svelte/store';
  import { DEFAULT_POINTS } from '@xq/utils/xq';
  import type { Layout, Point } from '@xq/utils/xq';

  export type Line = Layout<Point>[];

  export type AnalysisState = {
    currentTurnIndex: number;
    primaryLine: Line;
  };

  const DEFAULT_ANALYSIS_STORE: AnalysisState = {
    currentTurnIndex: 0,
    primaryLine: [{ points: DEFAULT_POINTS }],
  };

  export interface AnalysisStore extends Readable<AnalysisState> {
    loadLine: (line: Line) => void;
    transitionMoveWithinLine: (turnIndex: number) => void;
  }

  export function createAnalysisStore(): AnalysisStore {
    const store = writable<AnalysisState>(DEFAULT_ANALYSIS_STORE);
    const { subscribe } = store;

    function loadLine(line: Line) {
      store.update((state) => ({ ...state, primaryLine: line }));
    }

    function transitionMoveWithinLine(turnIndex: number) {
      store.update((state) => ({ ...state, currentTurnIndex: turnIndex }));
    }

    return { subscribe, loadLine, transitionMoveWithinLine };
  }
</script>
