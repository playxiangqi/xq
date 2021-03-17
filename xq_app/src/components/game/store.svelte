<script context="module" lang="ts">
  import { writable } from 'svelte/store';
  import { DEFAULT_POINTS } from '@xq/utils/xq';
  import type { Layout, Point } from '@xq/utils/xq';

  export type GameState = {
    currentTurnIndex: number;
    layouts: Layout<Point>[];
  };

  const DEFAULT_GAME_STATE: GameState = {
    currentTurnIndex: 0,
    layouts: [{ points: DEFAULT_POINTS }],
  };

  export function createGameStore() {
    const gameStore = writable<GameState>(DEFAULT_GAME_STATE);

    function loadGameLayouts(layouts: Layout<Point>[]) {
      gameStore.update((state) => ({ ...state, layouts }));
    }

    function transition(turnIndex: number) {
      gameStore.update((state) => ({ ...state, currentTurnIndex: turnIndex }));
    }

    return {
      gameStore,
      loadGameLayouts,
      transition,
    };
  }
</script>
