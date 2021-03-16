<script context="module" lang="ts">
  import { userSettingsStore } from '@xq/services/UserSettings.svelte';

  export type Move = {
    num: number;
    red: string;
    black: string;
  };
</script>

<script lang="ts">
  import type { GameSettings } from '../analysis/GameInfoPanel.svelte';
  import { toHanzi } from '../board';

  export let move: Move;
  export let moveRef: HTMLElement | null = null;
  export let isRedCurrent: boolean;
  export let isBlackCurrent: boolean;
  export let onRedClick: () => void;
  export let onBlackClick: () => void;

  const { num, red, black } = move;

  $: ({ gameSettings } = $userSettingsStore);
  $: redMove = formatMove(red, gameSettings);
  $: blackMove = formatMove(black, gameSettings);

  function formatMove(move: string, gameSettings: GameSettings) {
    switch (gameSettings?.pieceNotation) {
      default:
        return move;
      case 'traditional':
        return move.replace(/[AaRrCcBbKkNnPp]/g, (substr) => toHanzi[substr]);
    }
  }
</script>

<div class="move">
  <span class="move-num">{num}.</span>
  <span
    bind:this={moveRef}
    class="move-red"
    class:current={isRedCurrent}
    on:click={onRedClick}>{redMove}</span
  >
  <span
    class="move-black"
    class:current={isBlackCurrent}
    on:click={onBlackClick}>{blackMove}</span
  >
</div>

<style lang="scss">
  .move {
    display: flex;

    span.move-num {
      display: inline-block;

      width: 40px;

      margin-right: 10px;
      text-align: right;
    }

    span.move-red,
    span.move-black {
      width: 60px;

      margin-left: auto;
      margin-right: 16px;

      text-align: center;
      font-family: 'IBM Plex Mono', 'Menlo', 'DejaVu Sans Mono',
        'Bitstream Vera Sans Mono', 'Courier Prime', Courier, monospace;

      &:hover {
        cursor: pointer;
      }
    }

    span.current {
      background-color: #ededed;
    }
  }
</style>
