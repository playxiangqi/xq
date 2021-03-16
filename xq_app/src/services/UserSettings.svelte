<script context="module" lang="ts">
  import { writable } from 'svelte/store';
  import type { GameSettings } from '@xq/core/analysis/GameInfoPanel.svelte';

  // TODO: Define these types and import from elsewhere
  export type UserSettings = {
    uiSettings: {
      theme: 'white' | 'g100';
    };
    gameSettings: GameSettings;
  };

  const DEFAULT_SETTINGS: UserSettings = {
    uiSettings: {
      theme: 'white',
    },
    gameSettings: {
      moveNotation: 'axf',
      pieceNotation: 'alphabetic',
    },
  };

  export const userSettingsStore = writable(DEFAULT_SETTINGS);
</script>

<script lang="ts">
  import { LocalStorage } from 'carbon-components-svelte';

  let storage: LocalStorage;
</script>

<LocalStorage
  key="xq:user-settings"
  bind:this={storage}
  bind:value={$userSettingsStore}
/>
